CC = g++
INCLUDES = -I. -I/usr/local/include
CFLAGS = -Wall -ansi -pedantic -std=c++11
LIBS  = -lzmq -lprotobuf -lncurses
LFLAGS = -L/usr/local/lib
PROTOC = $(shell which protoc)
PWD = $(shell pwd)
SOURCES = $(wildcard *.proto)
PACKAGES = $(patsubst %.proto,%,$(SOURCES))
MAKEFILES = $(shell find . -mindepth 2 -name Makefile)
SUBDIRS = $(patsubst %/Makefile,%,$(MAKEFILES))

all: $(PACKAGES) $(SUBDIRS) guard

.PHONY: all $(SOURCES) $(SUBDIRS) guard

%: %.proto
	rm -Rf "$(PWD)/$@"
	mkdir "$(PWD)/$@"
	$(PROTOC) -I"$(PWD)" --cpp_out="$(PWD)/$@" "$(PWD)/$<"

$(SUBDIRS):
	$(MAKE) -C $@

guard: $(SOURCES)
	rm -f guard
	$(CC) -o guard guard.cpp $(INCLUDES) $(CFLAGS) $(LFLAGS) $(LIBS) 

clean:
	@for dir in $(SUBDIRS); do $(MAKE) -C $$dir clean; done
	rm -Rf $(PACKAGES)
	rm -f guard
	rm -Rf slprj
	rm -f Thumbs.db

