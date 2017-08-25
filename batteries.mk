DIR_GOMAKE:=$(dir $(lastword $(MAKEFILE_LIST)))

# output directory for test reports etc
DIR_OUT?=./out

include $(DIR_GOMAKE)/tools.mk

.PHONY: install
install:
	$(call PROMPT,$@)
	$(GO) install $(NO_VENDOR)

.PHONY: lint
lint: $(GOMETALINTER)
	$(call PROMPT,$@)
	$(GOMETALINTER) $(GOMETALINTER_OPT) $(NO_VENDOR)

.PHONY: lint-full
lint-full: $(GOMETALINTER)
	$(call PROMPT,$@)
	$(GOMETALINTER) --enable-all $(GOMETALINTER_OPT) $(NO_VENDOR)

.PHONY: lint-fast
lint-fast: $(GOMETALINTER)
	$(call PROMPT,$@)
	$(GOMETALINTER) --fast $(GOMETALINTER_OPT) $(NO_VENDOR)

# wish this wasn't necessary
lint lint-fast lint-full: install

.PHONY: test test-full
test: test-full
test-full:
	$(call PROMPT,$@)
	GOOS=$(GOHOSTOS) GOARCH=$(GOHOSTARCH) $(GO) test -v -race $(NO_VENDOR)

.PHONY: test-short
test-short:
	$(call PROMPT,$@)
	GOOS=$(GOHOSTOS) GOARCH=$(GOHOSTARCH) $(GO) test -v -short $(NO_VENDOR)

.PHONY: coverage coverage-full
coverage: coverage-full
coverage-full: $(GOCOV) $(GOCOV_HTML) | $(DIR_OUT)
	$(call PROMPT,$@)
	GOOS=$(GOHOSTOS) GOARCH=$(GOHOSTARCH) $(GOCOV) test -v -race $(NO_VENDOR) > $(DIR_OUT)/coverage.json
	$(GOCOV_HTML) $(DIR_OUT)/coverage.json > $(DIR_OUT)/coverage.html

.PHONY: coverage-short
coverage-short: $(GOCOV) $(GOCOV_HTML) | $(DIR_OUT)
	$(call PROMPT,$@)
	GOOS=$(GOHOSTOS) GOARCH=$(GOHOSTARCH) $(GOCOV) test -v -short $(NO_VENDOR) > $(DIR_OUT)/coverage.json
	$(GOCOV_HTML) $(DIR_OUT)/coverage.json > $(DIR_OUT)/coverage.html

$(DIR_OUT):
	$(call PROMPT,Creating output directory)
	mkdir -p $@

.PHONY: clean
clean::
	rm -f $(DIR_OUT)/coverage.html $(DIR_OUT)/coverage.json
	$(GO) clean

.PHONY: clobber
clobber:: clean
