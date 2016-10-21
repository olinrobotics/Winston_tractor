#include <cstdlib>
#include <exception>
#include <string>
#include "+Msg/Proxy.h"

int main(int argc, char** argv)
{
  std::string message;
  if(argc<3)
  {
    printf(" Virtual network switch that binds two ports.");
    printf("\n");
    printf("   usage: MsgSwitch pubProtocol://*:pubPort subProtocol://*:subPort\n");
    printf("\n");
    printf("     pubProtocol: publish protocol {tcp, ipc, inproc, pgm, epgm}\n");
    printf("         pubPort: publish port\n");
    printf("     subProtocol: subscribe protocol {tcp, ipc, inproc, pgm, epgm}\n");
    printf("         subPort: subscribe port\n");
    return EXIT_FAILURE;
  }
  try
  {
    Msg::Proxy(argv[2], argv[1], true);
  }
  catch(std::exception& e)
  {
    message = "ERROR: ";
    message = message+e.what();
    printf("%s\n", message.c_str());
  }
  catch(const char* str)
  {
    message = "ERROR: ";
    message = message+str;
    printf("%s\n", message.c_str());
  }
  catch(...)
  {
    message = "ERROR: ";
    message = message+"Unhandled exception.";
    printf("%s\n", message.c_str());
  }
  return EXIT_FAILURE;
}
