components = nym nym:core nym:node nym:persist nym:daemon

.PHONY: all build

all: build

build:
	$(foreach var,$(components),dub build $(var);)
	@mv -vt bin/ ./nym*
	@mv -vt lib/ ./*.a
