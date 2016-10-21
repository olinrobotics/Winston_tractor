#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "JSONRead.h"

// protocol
#include "nav/nav.pb.cc"

// configuration
static JSONRead cfg("guard.json");

class ARDClock : virtual public Msg::App, virtual public Msg::Time, virtual public Msg::Log
{
public:
  ARDClock(void) :
    Msg::App("ARDClock", INF, 1.0, 0), // zero input message length
    Msg::Time(this, "ARDClock", cfg.get<double>("timeWarp")),
    Msg::Log(this)
  {
    this->setTime(0.0);
  }
  
  void process(const std::string& inbox)
  {
    this->sendTime();
    this->log("%.6f", this->getTime());
  }
};

int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDClock subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDClock app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
