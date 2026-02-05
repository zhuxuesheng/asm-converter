# PowerPC Examples Master Makefile

SUBDIRS = calling-conv/ppc32 calling-conv/ppc64

.PHONY: all clean $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir clean; done
