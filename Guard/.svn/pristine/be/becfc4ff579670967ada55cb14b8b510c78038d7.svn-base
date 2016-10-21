#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "JSONRead.h"

// configuration
static JSONRead cfg("guard.json");

// An application that changes the identifier of a nav.RelFusedState message.
class ARDRepeater : virtual public Msg::App
{
public:
  ARDRepeater(void) :
    Msg::App("ARDRepeater", cfg.get<double>("ctrlTick"))
  {}

  void topics(std::vector< std::string >& sub)
  {
    sub.clear();
    sub.push_back(Msg::Proto::topic("nav.RelFusedState", cfg.get<std::string>("ownID")));
    return;
  }
    
  void process(const std::string& inbox)
  {
    this->send(inbox);
    return;
  }
};

int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDRepeater subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDRepeater app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
