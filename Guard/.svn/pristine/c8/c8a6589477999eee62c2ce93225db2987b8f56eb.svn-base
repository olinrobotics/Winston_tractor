#include "+Msg/Proto.h"
#include "+Msg/Transport.h"
#include "+hidi/pause.h"
#include "JSONRead.h"

// protocol
#include "nav/nav.pb.cc"

// configuration
static JSONRead cfg("guard.json");

void OCExampleReceive(bool& valid, double& timeS, double& latR, double& lonR)
{
  // variables that will created during the first function call
  static Msg::Transport transport(cfg.get<std::string>("subURI"), cfg.get<std::string>("pubURI"), 
    cfg.get<double>("maxLength"));
  static std::string ownID = cfg.get<std::string>("ownID");
  static std::string navTopic = Msg::Proto::topic("nav.LatLon", ownID);
  static bool init = false;

  // local temporary variables
  std::string inbox;
  std::string topic;
  std::string id;
  std::string data;
  nav::LatLon latLon;
  
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
      latLon.ParseFromString(data);
      
      // get the data
      timeS = latLon.times();
      latR = latLon.latr();
      lonR = latLon.lonr();
      
      // mark as valid
      valid = true;
    }
  }
  return;
}

// This main loop simulates LabView calling OCExampleReceive() at 20Hz.
int main(void)
{
  static const double dt = 0.05;
  double timeS = 0.0;
  double latR = 0.0;
  double lonR = 0.0;
  bool valid = false;
  while(true)
  {
    OCExampleReceive(valid, timeS, latR, lonR);
    if(valid)
    {
      printf("timeS=%f;latR=%f;lonR=%f\n", timeS, latR, lonR);
    }
    hidi::pause(dt);
  }
  return EXIT_SUCCESS;
}
