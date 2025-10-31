IMAGE := ghcr.io/mprokopov/custom-jenkins-playground:1.1
build:
	docker build . -t $(IMAGE)
push:
	docker push $(IMAGE)
