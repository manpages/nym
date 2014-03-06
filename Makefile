components = nym nym:core nym:node nym:persist

.PHONY: all build

all: build

build:
	$(foreach var,$(components),dub build $(var);)
	mv -vt bin/ ./nym*
