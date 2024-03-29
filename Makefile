NAME       := mariadb-toolbox
TAG        := `git describe --long --tags --dirty --always`
IMAGE_NAME := panubo/$(NAME)

.PHONY: *

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

test: ## Run tests (dind)
	./tests/dind-runner.sh

test-local: ## Run tests (local)
	./tests/runner.sh

_ci_test:
	true

shell: ## Run shell
	docker run --rm -t -i --entrypoint /bin/bash $(IMAGE_NAME):$(TAG)

clean: ## Remove built image
	docker rmi $(IMAGE_NAME):$(TAG)

push: ## Pushes the docker image to hub.docker.com
	# Don't --pull here, we don't want any last minute upsteam changes
	docker build -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):latest
