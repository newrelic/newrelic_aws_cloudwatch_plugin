TAG ?= :latest

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
	docker run -it --env-file=ops/.env -v ${PWD}:/root/nra docker.camplexer.com/$(TAG) bash
