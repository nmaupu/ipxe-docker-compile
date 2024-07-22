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
build: compile/ipxe/src/bin-x86_64-efi/ipxe.efi compile/ipxe/src/bin/ipxe.lkrn compile/ipxe/src/bin/undionly.kpxe

compile/ipxe/src/bin-x86_64-efi/ipxe.efi: docker-build compile output prepare-efi
	mkdir -p compile output
	docker run --rm \
		-v ./compile:/compile \
		-v ./.build:/opt/ipxe.local \
		-e BUILD="make -j4 bin-x86_64-efi/ipxe.efi" \
		-e EMBED="/opt/ipxe.local/break-loop.ipxe" \
		$(IMAGE_NAME):$(VERSION)
	cp compile/ipxe/src/bin-x86_64-efi/ipxe.efi output/ipxe.efi

compile/ipxe/src/bin/ipxe.lkrn: docker-build compile output prepare-legacy
	mkdir -p compile output
	docker run --rm \
		-v ./compile:/compile \
		-v ./.build:/opt/ipxe.local \
		-e BUILD="make -j4 bin/ipxe.lkrn" \
		-e EMBED="/opt/ipxe.local/break-loop.ipxe" \
		$(IMAGE_NAME):$(VERSION)
	cp compile/ipxe/src/bin/ipxe.lkrn output/ipxe.lkrn

compile/ipxe/src/bin/undionly.kpxe: docker-build compile output prepare-legacy
	mkdir -p compile output
	docker run --rm \
		-v ./compile:/compile \
		-v ./.build:/opt/ipxe.local \
		-e BUILD="make -j4 bin/undionly.kpxe" \
		-e EMBED="/opt/ipxe.local/break-loop.ipxe" \
		$(IMAGE_NAME):$(VERSION)
	cp compile/ipxe/src/bin/undionly.kpxe output/undionly.kpxe

.PHONY: prepare-efi
prepare-efi:
	rm -rf .build && mkdir .build
	cp -a \
		./ipxe-local/general.efi.h \
		./ipxe-local/colour.h \
		./ipxe-local/crypto.h \
		./ipxe-local/console.h \
		./ipxe-local/break-loop.ipxe \
		.build/

.PHONY: prepare-legacy
prepare-legacy:
	rm -rf .build && mkdir .build
	cp -a \
		./ipxe-local/general.legacy.h \
		./ipxe-local/colour.h \
		./ipxe-local/crypto.h \
		./ipxe-local/console.h \
		./ipxe-local/break-loop.ipxe \
		.build/

compile:
	mkdir -p compile

output:
	mkdir -p output

clean:
	rm -rf compile output .build
