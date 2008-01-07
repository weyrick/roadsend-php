TOPLEVEL      = ../
MY_TESTDIR    = benchmarks/tests/
MY_REGRESSIONDIR    = benchmarks/regression/
MY_TESTOUTDIR = benchmarks/testoutput/
DOTEST        = ./dotest

check : 
	-rm -rf $(TOPLEVEL)$(MY_TESTOUTDIR)
	-mkdir $(TOPLEVEL)$(MY_TESTOUTDIR)
	@(cd $(TOPLEVEL) && STORE_RESULTS=1 TEST_CYCLES=5 STATIC=1 $(DOTEST) $(MY_TESTDIR) $(MY_TESTOUTDIR))

regression : 
	-rm -rf $(TOPLEVEL)$(MY_TESTOUTDIR)
	-mkdir $(TOPLEVEL)$(MY_TESTOUTDIR)
	@(cd $(TOPLEVEL) && $(DOTEST) $(MY_REGRESSIONDIR) $(MY_TESTOUTDIR))


clean :
	-rm -rf testoutput

.PHONY: regression