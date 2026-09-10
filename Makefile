.PHONY: clean test

SPELLCHECK_FILES := $(shell find . -name '*.md' -not -path './.git/*' | sort)

.spell: $(SPELLCHECK_FILES)
	@misspellings=$$(cat $(SPELLCHECK_FILES) | aspell --mode=markdown --lang=en_US --personal=./.aspell.en.pws list | sort -u); \
	if [ -n "$$misspellings" ]; then \
		printf 'Spelling issues found:\n%s\n' "$$misspellings"; \
		exit 1; \
	fi
	@touch $@

clean:
	rm -f .spell

test: .spell
