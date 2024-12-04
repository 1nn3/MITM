prefix ?= ~/.local

bindir ?= $(prefix)/bin
sbindir ?= $(prefix)/sbin
libdir ?= $(prefix)/lib
mandir ?= $(prefix)/share/man
sharedir ?= $(prefix)/share/mitm

all:

install:
	install -D dsniffd $(DESTDIR)$(bindir)/dsniffd
	install -D dsniffd.1 $(DESTDIR)$(mandir)/man1/dsniffd.1
	install -D dsniffd-cleanup $(DESTDIR)$(bindir)/dsniffd-cleanup
	install -D dsniffd-cleanup.1 $(DESTDIR)$(mandir)/man1/dsniffd-cleanup.1
	install -D mitm $(DESTDIR)$(bindir)/mitm
	install -D mitm.1 $(DESTDIR)$(mandir)/man1/mitm.1
	install -D mitm6 $(DESTDIR)$(bindir)/mitm6
	install -D mitm6.1 $(DESTDIR)$(mandir)/man1/mitm6.1

uninstall:
	-rm -f $(DESTDIR)$(bindir)/dsniffd
	-rm -f $(DESTDIR)$(mandir)/man1/dsniffd.1
	-rm -f $(DESTDIR)$(bindir)/dsniffd-cleanup
	-rm -f $(DESTDIR)$(mandir)/man1/dsniffd-cleanup.1
	-rm -f $(DESTDIR)$(bindir)/mitm
	-rm -f $(DESTDIR)$(mandir)/man1/mitm.1
	-rm -f $(DESTDIR)$(bindir)/mitm6
	-rm -f $(DESTDIR)$(mandir)/man1/mitm6.1

clean:

distclean: clean

.PHONY: all install clean distclean uninstall

