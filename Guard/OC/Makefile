CC = g++
INCLUDES = -I.. -I/usr/local/include
CFLAGS = -Wall -ansi -pedantic -std=c++11
LIBS  = -lzmq -lprotobuf
LFLAGS = -L/usr/local/lib
FCFLAGS = -I../../flycapture/src/FlyCapture2Test -I/usr/include/flycapture -L../../flycapture/lib -lflycapture
SOURCES = $(patsubst OCCamera.cpp,,$(wildcard OC*.cpp))
PROGRAMS = $(patsubst %.cpp,%,$(SOURCES))

all: $(PROGRAMS)

.PHONY: $(SOURCES)

%: %.cpp
	rm -f $@
	$(CC) -o $@ $< $(INCLUDES) $(CFLAGS) $(LFLAGS) $(LIBS) 

dubins: dubins.cpp
	mex dubins.cpp

OCCamera: OCCamera.cpp
	rm -f $@
	$(CC) -o $@ $< $(INCLUDES) $(CFLAGS) $(LFLAGS) $(FCFLAGS) $(LIBS) 

LVGuard: LVGuard_DLL.cpp
	rm -f $@
	$(CC) -o $@ $< $(INCLUDES) $(CFLAGS) $(LFLAGS) $(FCFLAGS) $(LIBS) 

clean:
	rm -f dubins.mex*
	rm -f OCCamera
	rm -f $(PROGRAMS)
