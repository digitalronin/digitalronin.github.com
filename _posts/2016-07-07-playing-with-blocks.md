---
layout: post
title: "Toyblocks: Playing with Block(chain)s - Part 1"
description: ""
category:
tags: [blockchain]
image: "/images/blocks.jpg"
---

I read the [original bitcoin whitepaper][bitcoin_paper] today, and I wanted to play around with some of the ideas in it. So, here is a toy project in Ruby to do just that.

I'm not going to go into the mathematical stuff about hash functions - I'll just handwave all that and assume it's being taken care of. Instead, what I want to look at in this experiment is to see how the nodes in the network achieve consensus and extend a single chain of blocks, even when two valid blocks are announced simultaneously.

NB: I'm not saying this is how proper blockchains work - I'm just playing with the ideas for my own amusement.

Here's what my toy blockchain nodes need to do;

* Join the network and download the current agreed state (i.e. the blockchain so far), then listen for new blocks to be announced
* Extend the chain as new blocks are announce
* Resolve conflicts where two new blocks could both be added to the end of the current chain. i.e. the nodes should achieve consensus on the one, true chain

For the first part of this exercise, we'll make some assumptions;

* All blocks consist of data which is internally valid and consistent (i.e. any given block, taken in isolation, is fine, even if it cannot be used to extend a chain)
* Blocks are issued by some magic block-issuing thing, just to keep the experiment simple

# Blocks & Chains

The structure of a [bitcoin](bitcoin) block is defined [here](block_structure). We'll use that as a template for our toy blocks.

For this exercise, only the contents of the block header are relevant, so we can ignore the other fields.

In the block header, the only thing we really care about is the value of `hash_prev_block`. That's a pointer back to the previous entry in the chain. In a real blockchain, this hash would be derived from running a hashing function against the header of the previous block. For this exercise, I want things to be a lot simpler, so I'm going to add a `hash` field to our block header, and that's just going to be a string value that (within the context of this experiment) uniquely identifies the block (well, the header of the block, and hence the block). I'll use `x_` as a prefix to any fields that aren't a part of a real bitcoin blockchain.

So, our initial Block class is something like this;

~~~ruby
class Block
  attr_reader :magic_number,
              :size,
              :header,
              :transactions

  def initialize(params)
    @header = BlockHeader.new(
      x_hash:           params.fetch(:x_hash),
      hash_prev_block:  params.fetch(:hash_prev_block),
      timestamp:        params.fetch(:timestamp, Time.now.to_i),
    )
  end
end
~~~

BlockHeader can be something like this;

~~~ruby
class BlockHeader
  attr_reader :x_hash,
              :version,
              :hash_prev_block,
              :hash_merkle_root,
              :timestamp,
              :target,
              :nonce

  def initialize(params)
    @x_hash          = params.fetch(:x_hash)
    @hash_prev_block = params.fetch(:hash_prev_block)
    @timestamp       = params.fetch(:timestamp)
  end

  def hash
    x_hash
  end
end
~~~

We'll create a Chain class as well. This will need to maintain and return a list of block headers, add blocks to the list, and also tell us the length of the chain. Let's write some tests;

~~~ruby
describe Chain do
  subject(:chain) { described_class.new }
  let(:block0) { Block.new(x_hash: "GENESIS", hash_prev_block: nil) }
  let(:block1) { Block.new(x_hash: "B1", hash_prev_block: "GENESIS") }
  let(:block2) { Block.new(x_hash: "B2", hash_prev_block: "B1") }

  it "returns empty list of block headers" do
    expect(chain.block_headers).to eq([])
  end

  it "has length zero when empty" do
    expect(chain.length).to eq(0)
  end

  it "adds a block, when empty" do
    chain.add_block block0
    expect(chain.block_headers).to eq([block0.header])
  end

  it "adds a block that points back to the end of the chain" do
    chain.add_block block0
    chain.add_block block1

    expect(chain.block_headers).to eq([block0.header, block1.header])
  end

  it "doesn't add a block that doesn't point to the end of the chain" do
    chain.add_block block0
    chain.add_block block2

    expect(chain.block_headers).to eq([block0.header])
  end
end
~~~

Here is our first iteration of the Chain class;

~~~ruby
class Chain
  attr_reader :block_headers

  def initialize
    @block_headers = []
  end

  def add_block(block)
    block_headers.push(block.header) if valid_add?(block)
  end

  def length
    block_headers.length
  end

  private

  def valid_add?(block)
    length == 0 || block.header.hash_prev_block == end_of_chain.hash
  end

  def end_of_chain
    block_headers[-1]
  end
end
~~~

The code so far is [here](https://github.com/digitalronin/toyblocks/tree/v0.0.2)

# Nodes

Now let's look at our blockchain nodes. To start with, we need a class which will;

* Accept new blocks and (possibly) extend the chain
* Resolve a conflict if it gets two different, valid blocks to add

Here are our initial specs;

~~~ruby
require_relative 'spec_helper'

describe Node do
  subject(:node) { described_class.new }

  let(:block0)  { Block.new(x_hash: "GENESIS",  hash_prev_block: nil)       }
  let(:block1a) { Block.new(x_hash: "B1A",      hash_prev_block: "GENESIS") }
  let(:block1b) { Block.new(x_hash: "B1B",      hash_prev_block: "GENESIS") }
  let(:block2a) { Block.new(x_hash: "B2A",      hash_prev_block: "B1A")     }
  let(:block2b) { Block.new(x_hash: "B2B",      hash_prev_block: "B1B")     }

  it "adds blocks" do
    node.add_block block0
    node.add_block block1a
    node.add_block block2a

    expect(node.chain).to eq([
      { hash: "GENESIS",  hash_prev_block: nil       },
      { hash: "B1A",      hash_prev_block: "GENESIS" },
      { hash: "B2A",      hash_prev_block: "B1A"     },
    ])
  end

end
~~~

...and here is the code;

~~~ruby
class Node
  def initialize
    @chain = Chain.new
  end

  def add_block(block)
    @chain.add_block block
  end

  def chain
    @chain.block_headers.map(&:to_h)
  end
end
~~~

Things get more interesting when we try to handle the situation where conflicting valid blocks arrive.

Let's say we have a chain like this;

    [..., { hash: "foo" ... } ]

...and the next two blocks to arrive are these;

    { hash: "bar", hash_prev_block: "foo" }
    { hash: "baz", hash_prev_block: "foo" }

Both of these could be added to the chain, but then we have two different chains. We'll only know
which is valid when we get more blocks, such that one of the chains becomes longer than the other.

Let's handle the simplest case, first;

~~~ruby
it "resolves conflicts" do
  node.add_block block0
  node.add_block block1a
  node.add_block block1b # now we have a forked chain
  node.add_block block2b # the 'b' branch of the chain wins

  expect(node.chain).to eq([
    { hash: "GENESIS",  hash_prev_block: nil       },
    { hash: "B1B",      hash_prev_block: "GENESIS" },
    { hash: "B2B",      hash_prev_block: "B1B"     },
  ])
end
~~~

We could do something like this;

~~~ruby
class Node
  def initialize
    @blockchain = Chain.new
    @forks      = []
  end

  def add_block(block)
    @blockchain.add_block(block) || handle_fork(block)
  end

  def chain
    @blockchain.block_headers.map(&:to_h)
  end

  private

  def handle_fork(block)
    conflicting_valid_block?(block) ? create_fork(block) : resolve_fork(block)
  end

  def conflicting_valid_block?(block)
    penultimate = @blockchain.block_headers[-2]
    block.header.hash_prev_block == penultimate.hash
  end

  def create_fork(block)
    @forks.push(@blockchain)
    @forks.push(create_branch block)
  end

  def create_branch(block)
    branch = @blockchain.dup
    branch.block_headers.pop
    branch.add_block(block)
    branch
  end

  def resolve_fork(block)
    if winner = @forks.find {|branch| branch.add_block(block) }
      @blockchain = winner
      @forks      = []
    end
  end
end
~~~

To make this work, I had to add a custom 'dup' method to the chain class. You can check out the code [here](https://github.com/digitalronin/toyblocks/tree/v0.0.3).

That's it for this post. I'll develop these ideas in subsequent parts.

[bitcoin_paper]: https://bitcoin.org/bitcoin.pdf
[block_structure]: https://en.bitcoin.it/wiki/Block
[bitcoin]: https://bitcoin.org

