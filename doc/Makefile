
.PHONY: all
all: html
	(cd api && $(MAKE) clean all)

.PHONY: html
html:
	(cd manual && $(MAKE) html)

.PHONY: clean
clean: 
	(cd manual && $(MAKE) clean)

.PHONY: distclean
distclean: clean

