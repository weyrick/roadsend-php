all: debs rpms selfs

clean:
	(cd deb && $(MAKE) clean)
	(cd rpm && $(MAKE) clean)
	(cd self && $(MAKE) clean)

debs:
	(cd deb && $(MAKE) all)

rpms:
	(cd rpm && $(MAKE) all)

selfs:
	(cd self && $(MAKE) all)

compiler:
	(cd deb && $(MAKE) compiler)
	(cd rpm && $(MAKE) compiler)
	(cd self && $(MAKE) compiler)

runtime:
	(cd deb && $(MAKE) compiler)
	(cd rpm && $(MAKE) compiler)
	(cd self && $(MAKE) compiler)

prereqs:
	(cd deb && $(MAKE) prereqs)
	(cd rpm && $(MAKE) prereqs)
	(cd self && $(MAKE) prereqs)

compiler-deb:
	(cd deb && $(MAKE) compiler)

compiler-rpm:
	(cd rpm && $(MAKE) compiler)

compiler-self:
	(cd self && $(MAKE) compiler)

runtime-deb:
	(cd deb && $(MAKE) runtime)

runtime-rpm:
	(cd rpm && $(MAKE) runtime)

runtime-self:
	(cd self && $(MAKE) runtime)

prereqs-deb:
	(cd deb && $(MAKE) prereqs)

prereqs-rpm:
	(cd rpm && $(MAKE) prereqs)

prereqs-self:
	(cd self && $(MAKE) prereqs)
