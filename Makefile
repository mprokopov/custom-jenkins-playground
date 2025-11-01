IMAGE := ghcr.io/mprokopov/custom-jenkins-playground:1.2
build:
	docker build --platform linux/amd64 . -t $(IMAGE)
push:
	docker push $(IMAGE)
