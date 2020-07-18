include git.mk

ifndef $(VERBOSE)
PRECMD?=@
endif

DC?=dmd
AR?=ar
include $(REPOROOT)/command.mk

include setup.mk
WORKDIR?=$(REPOROOT)
-include $(WORKDIR)/dfiles.mk

BIN:=$(REPOROOT)/bin/
LDCFLAGS+=$(LINKERFLAG)-L$(BIN)
ARFLAGS:=rcs
BUILD?=$(REPOROOT)/build
#SRC?=$(REPOROOT)

.SECONDARY: $(TOUCHHOOK)
.PHONY: ddoc makeway


INCFLAGS=${addprefix -I,${INC}}

LIBRARY:=$(BIN)/$(LIBNAME)
LIBOBJ:=${LIBRARY:.a=.o};

REVISION:=$(REPOROOT)/$(SOURCE)/revision.d
.PHONY: $(REVISION)
.SECONDARY: .touch

ifdef COV
RUNFLAGS+=--DRT-covopt="merge:1 dstpath:reports"
DCFLAGS+=-cov
endif


ifndef DFILES
include $(REPOROOT)/source.mk
endif

HELP+=help-main
# DDOC help
include $(DDOCBUILDER)

help: $(HELP)
	@echo "make lib       : Builds $(LIBNAME) library"
	@echo
	@echo "make test      : Run the unittests"
	@echo

help-main:
	@echo "Usage "
	@echo
	@echo "make info      : Prints the Link and Compile setting"
	@echo
	@echo "make proper    : Clean all"
	@echo
	@echo "make PRECMD=   : Verbose mode"
	@echo "                 make PRECMD= <tag> # Prints the command while executing"
	@echo

info:
	@echo "WAYS    =$(WAYS)"
	@echo "DFILES  =$(DFILES)"
#	@echo "OBJS    =$(OBJS)"
	@echo "LDCFLAGS=$(LDCFLAGS)"
	@echo "DCFLAGS =$(DCFLAGS)"
	@echo "INCFLAGS=$(INCFLAGS)"

include $(REPOROOT)/revsion.mk

ifndef DFILES
lib: $(REVISION) dfiles.mk
	$(MAKE) lib
else
lib: $(REVISION) $(LIBRARY)

test: $(UNITTEST)
	export LD_LIBRARY_PATH=$(LIBBRARY_PATH); $(UNITTEST)

$(UNITTEST):
	$(PRECMD)$(DC) $(DCFLAGS) $(INCFLAGS) $(DFILES) $(TESTDCFLAGS) $(OUTPUT)$@
#$(LDCFLAGS)

endif

define LINK
$(1): $(1).d $(LIBRARY)
	@echo "########################################################################################"
	@echo "## Linking $(1)"
#	@echo "########################################################################################"
	$(PRECMD)$(DC) $(DCFLAGS) $(INCFLAGS) $(1).d $(OUTPUT)$(BIN)/$(1) $(LDCFLAGS)
endef

$(eval $(foreach main,$(MAIN),$(call LINK,$(main))))

makeway: ${WAYS}

include $(REPOROOT)/makeway.mk
$(eval $(foreach dir,$(WAYS),$(call MAKEWAY,$(dir))))

%.touch:
	@echo "########################################################################################"
	@echo "## Create dir $(@D)"
	$(PRECMD)mkdir -p $(@D)
	$(PRECMD)touch $@

$(DDOCMODULES): $(DFILES)
	$(PRECMD)echo $(DFILES) | scripts/ddocmodule.pl > $@

include $(DDOCBUILDER)

$(LIBRARY): ${DFILES}
	@echo "########################################################################################"
	@echo "## Library $@"
	@echo "########################################################################################"
	${PRECMD}$(DC) ${INCFLAGS} $(DCFLAGS) $(DFILES) -c $(OUTPUT)$(LIBRARY)

CLEANER+=clean

clean:
	rm -f $(LIBRARY)
	rm -f ${OBJS}
	rm -f $(UNITTEST) $(UNITTEST).o

proper: $(CLEANER)
	rm -fR $(WAYS)

$(PROGRAMS):
	$(DC) $(DCFLAGS) $(LDCFLAGS) $(OUTPUT) $@
