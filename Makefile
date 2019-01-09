SOURCES = src/*.elm

debug: ELMFLAGS = --debug
debug: MINIFY = cat
debug: MANGLE = cat
debug: index.html

release: ELMFLAGS = --optimize
release: MINIFY = nix run -c yarn --silent uglifyjs --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe'
release: MANGLE = nix run -c yarn --silent uglifyjs --mangle
release: clean node_modules/.bin/uglifyjs index.html

format: $(SOURCES)
	nix run -c elm-format --yes $<

clean:
	# -f suppresses missing file errors
	rm -rf obj
	rm -rf index.html

node_modules/.bin/uglifyjs: package.json
	nix run -c yarn install

index.html: obj/release.js templates/Main.html
	mkdir -p app
	sed -e "/{{elmcode}}/r obj/release.js" < templates/Main.html \
	| sed -e 's/{{elmcode}}//' > $@

obj/release.js: obj/Main.js
	$(MINIFY) < $< | $(MANGLE) > $@

obj/Main.js: $(SOURCES)
	mkdir -p obj
	nix run -c elm make $(ELMFLAGS) $< --output $@
