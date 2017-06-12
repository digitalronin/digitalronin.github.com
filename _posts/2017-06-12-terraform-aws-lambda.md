---
layout: post
title: "AWS Lambda + HTTP + Terraform"
description: "Use Terraform to setup an AWS Lambda function and expose it via an HTTP endpoint"
category:
tags: [terraform,aws,lambda,javascript]
image: "/images/lambda-logo.png"
---

I've been meaning to play around with [AWS Lambda][aws-lambda] for a while.
When I saw [this post][freecodecamp-post] I finally got around to trying
it.

It's a great post, but I prefer automation to pointing and
clicking a web GUI. So, I decided to try to create a similar setup using
[Terraform][terraform]

I'm using this [tutorial][aws-tutorial], but recreating it using terraform.

The goal is to be able to run `terraform apply` and create a Lambda function
which we can call via HTTP.

You can find all the code for this article on [Github][git-repo].

# Pre-requisites

You'll need some AWS credentials. I would strongly advise you **not** to use
your root credentials for your AWS account. Instead, create an [IAM][iam] user via the
AWS web console, and attach the following policies;

* AWSLambdaFullAccess
* IAMFullAccess
* AmazonAPIGatewayAdministrator

There is probably a way to work through this using less expansive permissions,
but this is just a simple tutorial. For a production system, I'd create a new
IAM user with the smallest set of permissions possible.

# AWS Credentials

When you have the access key and secret key for your new IAM user, put them into
environment variables like this;

~~~bash
export TF_VAR_access_key=YOUR_ACCESS_KEY
export TF_VAR_secret_key=YOUR_SECRET_KEY
~~~

Make sure you use those variable names, so that terraform will be able to pick
up the values.

Now, let's set up terraform. Create a `variables.tf` file with the following
content;

~~~
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}
~~~

Now, whenever we run terraform, it will use your credentials, and it will do
everything in the `us-east-1` AWS region.

Now create a `.gitignore` file (you are using `git`, right?) like this;

~~~
terraform.tfstate
terraform.tfstate.backup
*.zip
~~~

The `tfstate` files will be created when we run terraform. They will contain
your AWS credentials in cleartext, so we don't want them ending up on github, by
mistake.

We need to provide the code of our lambda function in a zip file, which is why
we're ignoring `*.zip` Let's add the code now.

Create a `helloWorld.js` file, with this content;

~~~javascript
'use strict';

exports.handler = function(event, context, callback) {
  var name = (event.name === undefined ? 'No-Name' : event.name);
  callback(null, {"Hello":name}); // SUCCESS with message
};
~~~

We need to zip the source code whenever we deploy it to AWS. Let's set up a
`Makefile` to take care of that for us;

~~~make
helloworld.zip: helloWorld.js
  zip -r9 helloworld.zip helloWorld.js
~~~

For those not familiar with `make` that says; "The file `helloworld.zip` depends
on the file `helloWorld.js`. Whenever `helloWorld.js` is newer than
`helloworld.zip`, run this command."

NB: The indentation before `zip` needs to be a tab character, not spaces.

We've got our lambda function. Now, let's add terraform code to deploy it to
AWS. Open up `main.tf` and add this at the bottom;

~~~
# IAM Role for Lambda function
resource "aws_iam_role" "helloworld_role" {
    name = "helloworld_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# AWS Lambda function
resource "aws_lambda_function" "helloworld" {
    filename         = "helloworld.zip"
    function_name    = "helloWorld"
    role             = "${aws_iam_role.helloworld_role.arn}"
    handler          = "helloWorld.handler"
    runtime          = "nodejs6.10"
    timeout          = 3
    source_code_hash = "${base64sha256(file("helloworld.zip"))}"
}
~~~

The second stanza creates the lambda function, but the first is required so that
the function has sufficient permissions to execute.

# Deploying to AWS

We can run `make` to zip up our source code, and then `terraform apply` to push
it to AWS. Better still, add this at the top of your `Makefile`;

~~~make
deploy: helloworld.zip
	terraform apply
~~~

Now, we can run `make deploy` to do both steps.

After a little while, you should be able to see your new lambda function in the
AWS console, and test it via the web GUI. After clicking on the function in the
Lambda console, choose "Actions > Configure Test Event" and add this code;

~~~
{
  "name": "David"
}
~~~

When you click `Save and test`, you should see the response;

~~~
{
  "Hello": "David"
}
~~~


# Amazon API Gateway

That was the easy part, and the part that makes the most sense to me.

Now, we need to add an API using the [Amazon API Gateway][api-gateway]. I have
to confess, I don't understand this part very well. I've cobbled together
something that more or less works by digging around tutorials, stackoverflow
posts and other bits and pieces, but there's probably a much simpler way to get
the same result. Anyway, here we go.

When you follow through on the [freecodecamp tutorial][freecodecamp-post], the
AWS console sets up most of the following plumbing for you, automatically. But, using terraform, we have to set it all up explicitly.

## API & Gateway Resource

The first part is easy - we need an API. Add this to `main.tf`

~~~
resource "aws_api_gateway_rest_api" "HelloWorldAPI" {
  name        = "HelloWorldAPI"
  description = "Endpoint for the Hello World function"
}
~~~

Most examples also use a gateway resource, so add this;

~~~
resource "aws_api_gateway_resource" "HelloWorldResource" {
  rest_api_id = "${aws_api_gateway_rest_api.HelloWorldAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.HelloWorldAPI.root_resource_id}"
  path_part   = "helloworldresource"
}
~~~

## API Method

We need a method that our API will expose;

~~~
resource "aws_api_gateway_method" "HelloWorldPostMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.HelloWorldAPI.id}"
  resource_id   = "${aws_api_gateway_resource.HelloWorldResource.id}"
  http_method   = "POST"
  authorization = "NONE"
}
~~~

## Gateway Integration

Most of the messy stuff is how we connect our API endpoint to our Lambda
function. First, we need the integration;

~~~
resource "aws_api_gateway_integration" "HelloWorldPostIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.HelloWorldAPI.id}"
  resource_id = "${aws_api_gateway_resource.HelloWorldResource.id}"
  http_method = "${aws_api_gateway_method.HelloWorldPostMethod.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.helloworld.arn}/invocations"
  request_templates = {
    "application/json" = <<REQUEST_TEMPLATE
{
  "name": "$input.params('name')"
}
REQUEST_TEMPLATE
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}
~~~

The inline request template tells the integration how to map parameters from
the HTTP request to our lambda function.

## API Response

We also need to do something similar with the response from our lambda
function, to map it onto our API endpoint's response (in case it wasn't already obvious, I don't really understand this bit).

~~~
resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.HelloWorldAPI.id}"
  resource_id = "${aws_api_gateway_resource.HelloWorldResource.id}"
  http_method = "${aws_api_gateway_method.HelloWorldPostMethod.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "HelloWorldPostIntegrationResponse" {
  depends_on  = ["aws_api_gateway_integration.HelloWorldPostIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.HelloWorldAPI.id}"
  resource_id = "${aws_api_gateway_resource.HelloWorldResource.id}"
  http_method = "${aws_api_gateway_method.HelloWorldPostMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  response_templates {
    "application/json" = ""
  }
}
~~~

## Lambda Permissions

The API Gateway needs to be granted permission to call our lambda function.

To do this, we need the ID of the AWS account we're using. We could store that
in an environment variable, like we did with the IAM user credentials, but we
can figure it out via terraform.

~~~
data "aws_caller_identity" "current" {}
~~~

Once we have this in our `main.tf` file, we can get the account ID like this;

~~~
${data.aws_caller_identity.current.account_id}
~~~

So, we can create the lambda permission we need, like this;

~~~
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.helloworld.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.HelloWorldAPI.id}/*/${aws_api_gateway_method.HelloWorldPostMethod.http_method}/helloworldresource"
}
~~~

At this point, after running `terraform apply`, we can use the AWS command-line utility to test our API endpoint.

To do that, you need to execute the following (piping the output through
[jq][jq] is optional, but it makes it much easier to see what's going on);

~~~
aws apigateway test-invoke-method \
  --region us-east-1 \
  --rest-api-id YOUR_API_ID \
  --resource-id YOU_RESOURCE_ID \
  --http-method POST \
  --path-with-query-string "" \
  --headers name=David \
  | jq -r .log,.body
~~~


You can get YOUR_API_ID and YOU_RESOURCE_ID from the API Gateway section of the AWS console;

![API Gateway](/images/api-gateway.png)

When you run the command above, you should see something like the following
output (which I've shortened, for clarity);

~~~
Execution log for request test-request
...
Mon Jun 12 14:49:16 UTC 2017 : Endpoint request body after transformations: {
  "name": "David"
}
...
Mon Jun 12 14:49:16 UTC 2017 : Method response body after transformations: {"Hello":"David"}
...
Mon Jun 12 14:49:16 UTC 2017 : Method completed with status: 200

{"Hello":"David"}
~~~

# Deploy the API

The final step is to deploy our API so that it's available on the internet via
HTTP. Add this to `main.tf`;

~~~
resource "aws_api_gateway_deployment" "HelloWorldAPIDeployment" {
  depends_on  = ["aws_api_gateway_method.HelloWorldPostMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.HelloWorldAPI.id}"
  stage_name  = "prod"
}
~~~

After running `terraform apply`, you should be able to get the public URL of
your API from the AWS console, like this;


![Invoke URL](/images/lambda-invoke-url.png)

Now, you can use curl to invoke your lambda function, like this;

~~~
curl -v -H "Content-Type: application/json" -X POST -H "name: User"
YOUR_INVOKE_URL
~~~

And, you should see output like this;

~~~
...
> POST /prod/helloworldresource HTTP/1.1
...
> Content-Type: application/json
> name: User
>
< HTTP/1.1 200 OK
...
{"Hello":"User"}
~~~

This is a bit weird, because we're supplying the `name` value in an HTTP header.
Normally, we would want to supply everything as a JSON document, or perhaps via
an HTTP form post. But, by the time I'd gotten this far, I couldn't be bothered
to figure out how to do that. I may update this post in future.

# Conclusion

I was surprised how much plumbing was required to hook everything up on AWS, but
I can understand the need for most of it, even if I haven't fully grasped the
details yet.

This was just a learning exercise for me. If I were planning to build a
production system on AWS Lambda, I'd probably look at things like the
[Serverless Framework][serverless-framework].

If you have any suggestions or corrections (or any other feedback), please let
me know in the comments.

[aws-lambda]: https://aws.amazon.com/lambda/
[freecodecamp-post]: https://medium.freecodecamp.com/going-serverless-how-to-run-your-first-aws-lambda-function-in-the-cloud-d866a9b51536
[terraform]: https://terraform.io
[aws-tutorial]: https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html#getting-started-new-api
[git-repo]: https://github.com/digitalronin/terraform-lambda-helloworld
[iam]: https://aws.amazon.com/iam/
[api-gateway]: https://aws.amazon.com/api-gateway/
[jq]: https://stedolan.github.io/jq/
[serverless-framework]: https://serverless.com/framework/
