CC = g++
INCLUDES = -I.. -I/usr/local/include
CFLAGS = -Wall -ansi -pedantic -std=c++11
LFLAGS = -L/usr/local/lib
LIBS  = -lzmq -lprotobuf
SOURCES = Switch.cpp Bridge.cpp
PROGRAMS = $(patsubst %.cpp,Msg%,$(SOURCES))

all: $(PROGRAMS)

.PHONY: $(SOURCES)

Msg%: %.cpp
	rm -f $@
	$(CC) -o $@ $< $(INCLUDES) $(CFLAGS) $(LFLAGS) $(LIBS) 

clean:
	rm -f $(PROGRAMS)

