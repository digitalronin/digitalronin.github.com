server:
	jekyll serve --incremental

deploy:
	git push

clean:
	rm -rf _site/*
