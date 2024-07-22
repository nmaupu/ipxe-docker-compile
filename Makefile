IMAGE_NAME="$(USER)/ipxe-builder"
VERSION=latest

all: build

.PHONY: docker-build
docker-build:
	docker build --build-arg UID=$(shell id -g) --build-arg GID=$(shell id -u) \
		-t $(IMAGE_NAME):$(VERSION) .

.PHONY: docker-push
docker-push: docker-build
	docker push $(IMAGE_NAME):$(VERSION)

.PHONY: build
build: compile/ipxe/src/bin-x86_64-efi/ipxe.efi

compile/ipxe/src/bin-x86_64-efi/ipxe.efi: docker-build compile output
	mkdir -p compile output
	docker run --rm \
		-v ./compile:/compile \
		-v ./ipxe-local:/opt/ipxe.local \
		-e BUILD="make -j4 bin-x86_64-efi/ipxe.efi" \
		-e EMBED="/opt/ipxe.local/break-loop.ipxe" \
		$(IMAGE_NAME):$(VERSION)
	cp compile/ipxe/src/bin-x86_64-efi/ipxe.efi output/ipxe-x86_64.efi

compile:
	mkdir -p compile

output:
	mkdir -p output
