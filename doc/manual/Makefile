
MANUAL=the_roadsend_php_compiler

.PHONY: all
all: html

.PHONY: html
html: html.stamp ${MANUAL}.texi
#	texi2html --split=chapter -o html ${MANUAL}.texi
	makeinfo --html -o html ${MANUAL}.texi

html.stamp: resources.stamp
	touch html.stamp
	mkdir html/
	ln -s ../resources ./html/resources

.PHONY: docbook
docbook: docbook.stamp ${MANUAL}.texi
	(cd docbook/ && makeinfo --docbook ../${MANUAL}.texi);

docbook.stamp: resources.stamp
	touch docbook.stamp
	mkdir docbook/
	ln -s ../resources ./docbook/resources

.PHONY: pdf
pdf: pdf.stamp ${MANUAL}.texi
	texi2pdf ${MANUAL}.texi -o pdf

pdf.stamp: resources.stamp
	touch pdf.stamp
	mkdir pdf/

resources.stamp:
	touch resources.stamp
	ln -s ../resources ./

.PHONY: clean
clean: 
	-rm resources
	-rm *.stamp *.log
	-rm -r html/
	-rm -r pdf/
	-rm -r docbook/
