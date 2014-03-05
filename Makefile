components = nym nym:core

.PHONY: all build

all: build

build:
	$(foreach var,$(components),dub build $(var);)
