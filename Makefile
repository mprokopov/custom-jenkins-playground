IMAGE := ghcr.io/mprokopov/custom-jenkins-playground:1.3.3

build:
	docker build --platform linux/amd64 . -t $(IMAGE)

push:
	docker push $(IMAGE)

# Convenience: run a local Jenkins from the image for smoke testing before push.
test: build
	@echo "Starting local Jenkins on http://localhost:8080 ..."
	@echo "Stop with Ctrl+C; container is removed automatically."
	docker run --rm -it --platform linux/amd64 -p 8080:8080 \
	  --entrypoint bash \
	  $(IMAGE) -c "systemctl disable jenkins 2>/dev/null; /usr/share/java/jenkins.war --httpPort=8080"

.PHONY: build push test
