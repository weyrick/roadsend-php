TOPLEVEL      = ../
MY_TESTDIR    = bugs/tests/
MY_TESTOUTDIR = bugs/testoutput/
DOTEST        = ./dotest

check : 
	-rm -rf $(TOPLEVEL)$(MY_TESTOUTDIR)
	-mkdir $(TOPLEVEL)$(MY_TESTOUTDIR)
	@(cd $(TOPLEVEL) && $(DOTEST) $(MY_TESTDIR) $(MY_TESTOUTDIR))


clean :
	-rm -rf testoutput