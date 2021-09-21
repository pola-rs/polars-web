build:
	docker build --tag polars-web .

serve: build
	docker run --name polars-web --publish 8000:80 --rm polars-web

fmt:
	npx prettier -w .
