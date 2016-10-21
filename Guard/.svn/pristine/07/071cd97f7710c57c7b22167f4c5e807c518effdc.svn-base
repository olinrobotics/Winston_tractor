#include <cstdlib>
#include <exception>
#include <string>
#include "+Msg/Proxy.h"

int main(int argc, char** argv)
{
  std::string message;
  if(argc<3)
  {
    printf(" Virtual network bridge that connects two ports.");
    printf("\n");
    printf("   usage: MsgBridge subProtocol://*:subPort pubProtocol://*:pubPort\n");
    printf("\n");
    printf("     subProtocol: subscribe protocol {tcp, ipc, inproc, pgm, epgm}\n");
    printf("         subPort: subscribe port\n");
    printf("     pubProtocol: publish protocol {tcp, ipc, inproc, pgm, epgm}\n");
    printf("         pubPort: publish port\n");
    return EXIT_FAILURE;
  }
  try
  {
    Msg::Proxy(argv[1], argv[2], false);
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
