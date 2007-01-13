
MANUAL=api-main

.PHONY: all
all: apidocs html

.PHONY: html
html: html.stamp ${MANUAL}.texi
#	texi2html --split=chapter -o html ${MANUAL}.texi
	makeinfo --html -o html ${MANUAL}.texi

apidocs:
	(cd ../../runtime/ext/ && $(MAKE) apidocs);

html.stamp:
	touch html.stamp
	mkdir html/
	ln -s ../resources ./
	ln -s ../resources ./html/resources

.PHONY: clean
clean: 
	-rm ext-*.texi
	-rm resources
	-rm html.stamp
	-rm -r html/
