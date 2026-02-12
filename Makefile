all: build/charte.pdf build/charte.html \
	build/positions.pdf build/positions.html \
	build/codedevie.pdf build/codedevie.html
	# build/coussin.pdf build/coussin.html
	# build/faecum.pdf build/faecum.html

build/%.pdf: %.typ
	typst compile --features=html $< $@

build/%.html: %.typ
	typst compile --features=html $< $@
