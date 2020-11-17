LOCAL_TAG=r
PUBLIC_TAG=ghcr.io/opensafely/r

.PHONY: build
build: packages.txt
	docker build . --tag $(LOCAL_TAG)

packages.txt: packages.in conda-compile.py
	docker inspect --type=image $(LOCAL_TAG) > /dev/null || $(MAKE) fetch
	@echo Warning: this may take a while...
	cat $< | docker run -i --rm -v $$PWD/conda-compile.py:/conda-compile.py --entrypoint /conda-compile.py $(LOCAL_TAG) > $@


.PHONY: fetch
fetch:
	docker pull $(PUBLIC_TAG)
	docker tag $(PUBLIC_TAG) $(LOCAL_TAG)
