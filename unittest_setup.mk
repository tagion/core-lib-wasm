UNITTEST:=$(BINDIR)/uinttest_$(PACKAGE)

TESTDCFLAGS+=$(LIBS)
TESTDCFLAGS+=-main
TESTDCFLAGS+=-g
TESTDCFLAGS+=-unittest
