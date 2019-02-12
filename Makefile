TAG ?= nrcp:latest

.PHONY: build
build:
	docker build -t docker.camplexer.com/$(TAG) .

.PHONY: push
push:
	docker push docker.camplexer.com/$(TAG)

.PHONY: run
run:
	docker run -it --env-file=ops/.env docker.camplexer.com/$(TAG) $(CMD)

.PHONY: shell
shell: build
	docker run -it  docker.camplexer.com/$(TAG) env \
	-d AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-d AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-d NEWRELIC_KEY=${NEWRELIC_KEY}
