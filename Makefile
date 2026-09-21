.PHONY: all clean test

MD_FILES := $(wildcard *.md) # Only checks top level .md files.
SPELL_CHECKED := $(patsubst %.md,.%.spell,$(MD_FILES))
ASPELL_OPTS ?= --mode=markdown --lang=en_US --personal=./.aspell.en.pws

all: test

echo:
	echo $(MD_FILES)
	echo $(SPELL_CHECKED)

test: $(SPELL_CHECKED)

.%.spell: %.md
	! cat $^ | aspell $(ASPELL_OPTS) list | sort -u | grep .
	@touch $@

clean:
	rm -f .*.spell
