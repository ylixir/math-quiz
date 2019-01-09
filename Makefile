SOURCES = src/*.elm

debug: ELMFLAGS = --debug
debug: MINIFY = cat
debug: index.html

release: ELMFLAGS = --optimize
release: MINIFY = nix run -c yarn --silent uglifyjs
release: clean node_modules/bin/uglifyjs index.html

format: $(SOURCES)
	nix run -c elm-format --yes $<

clean:
	# -f suppresses missing file errors
	rm -rf obj
	rm -rf index.html

node_modules/bin/uglifyjs: package.json
	nix run -c yarn install

index.html: obj/release.js templates/Main.html
	mkdir -p app
	sed -e "/{{elmcode}}/r obj/release.js" < templates/Main.html \
	| sed -e 's/{{elmcode}}//' > $@

obj/release.js: obj/Main.js
	$(MINIFY) < $< > $@

obj/Main.js: $(SOURCES)
	mkdir -p obj
	nix run -c elm make $(ELMFLAGS) $< --output $@
