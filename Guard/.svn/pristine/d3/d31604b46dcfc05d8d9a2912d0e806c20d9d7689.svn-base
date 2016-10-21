#ifndef MSGTIME_H
#define MSGTIME_H

#include <cmath>
#include <string>
#include "+hidi/getCurrentTime.h"
#include "+Msg/Proto.h"

namespace Msg
{
  class App;
  
  // Optionally inherited time synchronization system.
  class Time
  {
  public:    
    // Get system time as an integer.
    //
    // @param[out] usec system time as an integer
    uint64_t tick(void);
    
    // Compute elapsed time.
    //
    // @param[in]  usec system time as an integer
    // @param[out] dt   elapsed time in seconds
    double tock(const uint64_t& usec);
    
    // Determine whether the time has been set.
    //
    // @param[out] flag indicates whether time has been set
    bool isTimeSet(void);
    
    // Set the current time.
    //
    // @param[in] time value to accept as the current time
    void setTime(const double& time);
    
    // Get the current time.
    //
    // @param[out] time current time including warp factor
    double getTime(void);
    
    // Publish the current time.
    void sendTime(void);
    
    // Inserts a time topic.
    void msgTopicsTime(std::vector< std::string >& sub);
    
    // Inserts a time handling process.
    void msgProcessTime(const std::string& inbox);

  protected:
    // Constructor.
    //
    // @param[in] msgTimeSourceID application identifier of time source
    // @param[in] msgTimeWarp     time scaling parameter
    Time(App* msgApp, const std::string& msgTimeSourceID, const double& msgTimeWarp);
    
  private:
    App* msgApp;
    std::string msgTimeSourceID;
    double msgTimeWarp;
    bool msgTimeSet;
    uint64_t msgTimeSys;
    double msgTimeRef;
    std::string msgTimeTopic;
  };
}

#endif
