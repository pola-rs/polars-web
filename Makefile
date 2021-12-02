.PHONY: build

build:
	docker build --file build/Dockerfile --tag polars-web .

serve: build
	docker run --interactive --name polars-web --publish 8000:80 --rm --tty polars-web
