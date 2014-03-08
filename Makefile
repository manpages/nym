components = nym nym:daemon nym:core nym:node nym:persist 
.PHONY: all build


all: build
	$(foreach var,$(components),dub build $(var);)
	@mv -vt bin/ nym* *.a