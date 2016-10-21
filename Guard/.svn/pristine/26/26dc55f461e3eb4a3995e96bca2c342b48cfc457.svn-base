
#include "LVGuard_DLL.h"
#include "+Msg/Proto.h"
#include "+Msg/Transport.h"
#include "+hidi/pause.h"
#include "JSONRead.h"

// protocol
#include "nav/nav.pb.cc"

// configuration
static JSONRead cfg("guard.json");

void LVRecieveCtrl(bool& valid, double& uReal, int& uInt)
{
  // variables that will created during the first function call
  static Msg::Transport transport(cfg.get<std::string>("subURI"), cfg.get<std::string>("pubURI"));
  static std::string ownID = cfg.get<std::string>("ownID");
  static std::string navTopic = Msg::Proto::topic("nav.Ctrl", ownID);
  static bool init = false;

  // local temporary variables
  std::string inbox;
  std::string topic;
  std::string id;
  std::string data;
  nav::Ctrl ctrl;
  
  // mark output as invalid by default
  valid = false;
  
  // set subscriptions during the first function call
  if(!init)
  {
    transport.subscribe(navTopic);
    init = true;
  }
  
  // receive message
  transport.receive(inbox);
  
  // check if a message was received
  if(!inbox.empty())
  {
    // check if topic is as expected (will always be true if transport is subscribed to only one topic)
    if(Msg::Proto::isTopic(inbox, navTopic))
    {
      // deserialize
      Msg::Proto::unpack(inbox, topic, id, data);
      ctrl.ParseFromString(data);
      
      // get the data
      uReal = ctrl.ureal();
      uInt = ctrl.uint();
      
      // mark as valid
      valid = true;
    }
  }
  return;
}