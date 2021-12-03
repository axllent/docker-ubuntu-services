BUILD_IMAGE=axllent/ubuntu-services

docker:
	docker build -t "${BUILD_IMAGE}:latest" .
	docker push "${BUILD_IMAGE}:latest"
