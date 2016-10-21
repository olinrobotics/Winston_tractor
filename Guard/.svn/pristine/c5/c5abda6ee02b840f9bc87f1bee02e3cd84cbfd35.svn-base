#include <cstdio>
#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "JSONRead.h"

// configuration
static JSONRead cfg("guard.json");

class ARDCmdTest : virtual public Msg::App, virtual public Msg::Cmd
{
public:
  ARDCmdTest() :
    Msg::App("ARDCmdTest", cfg.get<double>("fastTick"), cfg.get<double>("slowTick"), cfg.get<double>("msgLength")), 
    Msg::Cmd(this, cfg.get<double>("ackPeriod"), cfg.get<double>("timeWarp"))
  {}

  bool init(void)
  {
    printf("INIT\n");
    return true;
  }
  
  void idle(const std::string& inbox)
  {
    printf("IDLE\n");
    return;
  }
  
  bool run(const std::string& inbox)
  {
    printf("RUN\n");
    return false;
  }
  
  void term(void)
  {
    printf("TERM\n");
    return;
  }
};

int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDCmdTest subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDCmdTest app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
