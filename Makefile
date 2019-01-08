SOURCES = src/*.elm
OBJECTS = obj/Main.js
TEMPLATES = templates/Main.html
APP = app/index.html
debug: ELMFLAGS = --debug
release: ELMFLAGS = --optimize
ELM = nix run -c elm make $(ELMFLAGS)

debug: app

release: app

format: $(SOURCES)
	nix run -c elm-format --yes $<


clean:
	# -f suppresses missing file errors
	rm -rf obj
	rm -rf app

app: $(APP)

$(APP): $(OBJECTS) $(TEMPLATES)
	mkdir -p app
	sed -e '/{{elmcode}}/r obj/Main.js' < templates/Main.html \
	| sed -e 's/{{elmcode}}//' > $@

$(OBJECTS): $(SOURCES)
	mkdir -p obj
	$(ELM) $< --output $@
