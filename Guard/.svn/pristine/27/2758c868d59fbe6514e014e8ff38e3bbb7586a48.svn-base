Minimum requirements to run on embedded systems:
* Linux (Tested on Fedora Core 21 and Fedora Core 23)
* Protobuf development version 2.5.0 to 2.6.1
* ZeroMQ development version 3.2.5 to 4.1.5
  * See instructions here: http://zeromq.org/intro:get-the-software
  * May need to be compiled locally
  * May need to install additional development tools
  * May require ./configure --without-libsodium

Additional requirements to create new applications:
* Java SE 7 Development Kit 1.7.0_80 (Installed in: /usr/java)
  * May require downloading a package from Oracle
* MATLAB 2013b or newer
  * Apply the following GLIBC fix:
    cd {MATLAB_ROOT}/sys/os/{arch}
    mv libstdc++.so.6 libstdc++.so.6.original
    mv libgcc_s.so.1 libgcc_s.so.1.original

Additional requirements to replicate SSCI's development environment and run all demos:
* svn 1.8 or newer
* ncurses
* curl
* xterm
* find
* which
* pkill
* MATLAB Toolboxes: Image Processing, Simulink
* FlightGear 3.4.0 (Installed in: /usr/share/flightgear)
  * The FlightGear install directory must be user writable
      sudo chmod -R u+w /usr/share/flightgear
  * FlightGear may crash the first few times that it loads while it attempts to download terrain.
  * When FlightGear crashes, your network interface might need to be restarted before it will work again.
  * If FlightGear displays "catalog download failure" it can be ignored.
  * Screen saver must be disabled to reliably capture images.

GETTING STARTED
1) Checkout or download and unzip the GUARD SDK that contains this README.txt file.

2) On a linux machine, install the minimum required packages and additional packages.

3) Change to the directory containing README.txt and start MATLAB.

4) Run the following to make and test the Google Protobuf messaging interface:
>> Msg.Proto.make()
>> Msg.Proto.addpath()
>> pb = msg.NullBuilder()
>> methods(pb) % should display several methods for java class msg$Null$Builder

5) Run the following to make the ZeroMQ message transport interface:
>> Msg.Transport.make() % ignore gcc version warnings
>> system('make -C +Msg');

6) Run the following to make several C++ example applications:
>> system('make -C ARD');

7) Start a pair of GUARD test applications in MATLAB:
>> guard start Test % should print log messages to the command window

8) Stop all GUARD applications:
>> guard stop

9) Optionally test the FlightGear interface:
>> FlightGear.Test % should open two instances of FlightGear
