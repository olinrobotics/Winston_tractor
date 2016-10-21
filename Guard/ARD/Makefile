CC = g++
INCLUDES = -I.. -I/usr/local/include
CFLAGS = -Wall -ansi -pedantic -std=c++11
LIBS  = -lzmq -lprotobuf -lncurses
LFLAGS = -L/usr/local/lib
SOURCES = $(wildcard ARD*.cpp)
PROGRAMS = $(patsubst %.cpp,%,$(SOURCES))

all: $(PROGRAMS)

.PHONY: $(SOURCES)

%: %.cpp
	rm -f $@
	$(CC) -o $@ $< $(INCLUDES) $(CFLAGS) $(LFLAGS) $(LIBS) 

clean:
	rm -f $(PROGRAMS)
