#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "JSONRead.h"

// configuration
static JSONRead cfg("guard.json");

// An application that logs heartbeats.
class ARDTalker : virtual public Msg::App, virtual public Msg::Log
{
public:
  ARDTalker(void) :
    Msg::App("ARDTalker", INF, cfg.get<double>("slowTick")),
    Msg::Log(this)
  {}

  void topics(std::vector< std::string >& sub)
  {
    sub.clear(); // do not subscribe
    return;
  }
    
  void process(const std::string& inbox)
  {
    this->log("Testing ARDTalker.cpp");
    return;
  }
};

int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDTalker subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDTalker app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
