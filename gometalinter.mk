export GOMETALINTER:=$(GOPATH)/bin/gometalinter

# grab the gometalinter binary and install the actual linters
$(GOMETALINTER): | $(GOPATH)
	$(call PROMPT,Installing $@)
	$(GO) get github.com/alecthomas/gometalinter
	$(GOMETALINTER) --install

ifndef GOMETALINTER_LINELENGTH
GOMETALINTER_LINELENGTH:=100
endif

ifndef GOMETALINTER_DEADLINE
GOMETALINTER_DEADLINE:=30s
endif

ifndef GOMETALINTER_CYCLO
GOMETALINTER_CYCLO:=15
endif

ifndef GOMETALINTER_OPT

# protobuf-generated code fails "go lint" with a couple of things...
GOMETALINTER_OPT_PROTOBUF:=\
	--exclude="don't use underscores in Go names; (func|var|const|type|method|struct field) [^ ]+ should be" \
	--exclude="\.pb.go:[0-9]+:[0-9]+:warning: context.Context should be the first parameter of a function" \
	--exclude="\.pb.go:[0-9]+:[0-9]+:warning: exported method [^ ]+ returns unexported type" \
	--exclude="\.pb.go:[0-9]+::warning: Errors unhandled."

GOMETALINTER_OPT:=\
	--exclude='should have comment or be unexported' \
	--exclude='should have comment \(or a comment on this block\) or be unexported' \
	--exclude='error return value not checked \(defer ' \
	$(GOMETALINTER_OPT_PROTOBUF) \
	--deadline=$(GOMETALINTER_DEADLINE) \
	--line-length=$(GOMETALINTER_LINELENGTH) \
	--cyclo-over=$(GOMETALINTER_CYCLO)

endif
