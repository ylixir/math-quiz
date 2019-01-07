SOURCES = src/*.elm
OBJECTS = obj/Main.js
TEMPLATES = templates/Main.html
APP = app/index.html

debug: ELMFLAGS = --debug
debug: app

release: ELMFLAGS = --optimize
release: app

ELM = nix run -c elm make $(ELMFLAGS)

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
