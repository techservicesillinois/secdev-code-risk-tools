.PHONY: all clean test

MD_FILES := $(wildcard *.md)
SPELL_CHECKED := $(patsubst %.md,.%.spell,$(MD_FILES))

all: test

echo:
	echo $(MD_FILES)
	echo $(SPELL_CHECKED)

test: $(SPELL_CHECKED)

.%.spell: %.md
	cat $^ | aspell list | sort -u | tee /dev/tty | grep -v '^'
	@touch $@

clean:
	rm -f .*.spell
