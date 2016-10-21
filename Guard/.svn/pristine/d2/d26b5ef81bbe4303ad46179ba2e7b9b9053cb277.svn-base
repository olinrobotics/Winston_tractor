#include "+Msg/Proto.h"
#include "+Msg/Transport.h"
#include "JSONRead.h"
#include "+hidi/pause.h"

// protocol
#include "nav/nav.pb.cc"

// configuration
static JSONRead cfg("guard.json");

void printUsage(void)
{
  printf("  Executes a series of GUARD commands.\n");
  printf("\n");
  printf("    usage: guard [arg1] [arg2] ... [argN]\n");
  printf("\n");
  printf("      arg: command to execute\n");
  return;
}

void send(const std::string& message)
{
  static Msg::Transport transport(cfg.get<std::string>("subURI"), cfg.get<std::string>("pubURI"), 0);
  transport.send(message);
  return;
}

// Sends the specified command or behavior on behalf of ARDCommander.
int main(int argc, char* argv[])
{
  int narg;
  std::string arg;
  if(argc<2)
  {
    printUsage();
    return EXIT_FAILURE;
  }
  for(narg = 1; narg<argc; ++narg)
  {
    arg = argv[narg];
    if(!arg.compare("OFF"))
    {
      msg::Cmd pb;
      pb.set_mode(msg::OFF);
      send(Msg::Proto::pack("msg.Cmd", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("IDLE"))
    {
      msg::Cmd pb;
      pb.set_mode(msg::IDLE);
      send(Msg::Proto::pack("msg.Cmd", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("RUN"))
    {
      msg::Cmd pb;
      pb.set_mode(msg::RUN);
      send(Msg::Proto::pack("msg.Cmd", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("LOITER"))
    {
      nav::Mission pb;
      pb.set_behavior(nav::LOITER);
      send(Msg::Proto::pack("nav.Mission", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("APPROACH"))
    {
      nav::Mission pb;
      pb.set_behavior(nav::APPROACH);
      send(Msg::Proto::pack("nav.Mission", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("CAPTURE"))
    {
      nav::Mission pb;
      pb.set_behavior(nav::CAPTURE);
      send(Msg::Proto::pack("nav.Mission", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("RELEASE"))
    {
      nav::Mission pb;
      pb.set_behavior(nav::RELEASE);
      send(Msg::Proto::pack("nav.Mission", "ARDCommander", pb.SerializeAsString()));
    }
    else if(!arg.compare("DEPART"))
    {
      nav::Mission pb;
      pb.set_behavior(nav::DEPART);
      send(Msg::Proto::pack("nav.Mission", "ARDCommander", pb.SerializeAsString()));
    }
    else
    {
      printf("guard: Unrecognized command '%s'.\n", arg.c_str());
    }
  }
  return EXIT_SUCCESS;
}
