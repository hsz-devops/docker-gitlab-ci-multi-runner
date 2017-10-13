all: build

build:
	@docker build --tag=ez123/gitlab-runner .

# release: build
# 	@docker build --tag=ez123/gitlab-runner:$(shell cat VERSION) .
