#ifndef MSGEXEC_H
#define MSGEXEC_H

#include <algorithm>
#include <cstdlib>
#include <exception>
#include <limits>
#include <vector>
#include "+Msg/Transport.h"
#include "+hidi/hidi.h"
#include "+hidi/getCurrentTime.h"
#include "+hidi/pause.h"

namespace Msg
{
  // Launches a single application and manages timed execution.
  class Exec
  {
  public:
    double msgTimeWarp;
    App* msgApp;
    Transport* msgComms;
    
    // Get singleton instance.
    //
    // @param[in] msgTimeWarp time scaling parameter
    // @param[in] msgApp  message application instance
    // @param[in] subURI  subscrbe endpoint
    // @param[in] pubURI  publish endpoint
    // @param[in] pubBind (optional) bind to the publish endpoint
    static Exec* getInstance(const double& msgTimeWarp)
    {
      static Exec* msgExec = new Exec(msgTimeWarp);
      return msgExec;
    }
    
    // Destructor.
    //
    // @note Does not delete apps.
    ~Exec(void)
    {
      if(this->msgComms!=NULL)
      {
        delete this->msgComms;
      }
    }
    
    // Start application.
    void start(App* msgApp, const std::string& subURI, const std::string& pubURI, const bool& pubBind = false)
    {
      static const double msgTimerMin = 0.001; // timing limitation
      static const double msgTimerMax = double(std::numeric_limits<int32_t>::max()-1)/1000.0; // timing limitation
      std::string str;
      std::vector< std::string > msgTopics;
      size_t iTopic;
      double appTick;
      double commsTick;
      double msgAppTimer;
      double msgCommsTimer;
      double time;
      
      try
      {
        // initialize transport layer
        commsTick = (std::min)((std::max)(msgApp->msgCommsTick/this->msgTimeWarp, msgTimerMin), msgTimerMax);
        appTick = (std::min)((std::max)(msgApp->msgAppTick/this->msgTimeWarp, msgTimerMin), msgTimerMax);
        this->msgApp = msgApp;
        this->msgComms = new Transport(subURI, pubURI, msgApp->msgMaxLength, pubBind);
        
        // set subscriptions
        this->msgApp->msgTopics(msgTopics);
        for(iTopic = 0; iTopic<msgTopics.size(); ++iTopic)
        {
          this->msgComms->subscribe(msgTopics[iTopic]);
        }
        
        // initialize the main loop
        time = hidi::getCurrentTime();
        msgAppTimer = time+appTick;
        msgCommsTimer = time+commsTick;
      }
      catch(std::exception& e)
      {
        str = "Exec:ERROR: ";
        str = str+e.what();
        printf("%s\n", str.c_str());
      }
      catch(const char* e)
      {
        printf("Exec:ERROR: %s\n", e);
      }
      catch(...)
      {
        printf("Exec:ERROR: Unhandled exception.\n");
      }
      
      while(true)
      {
        try
        {
          while(true)
          {
            // check app timer
            if(time>=msgAppTimer)
            {
              this->msgAppTimerCallback(); // takes time
              time = hidi::getCurrentTime();
              msgAppTimer = time+appTick;
            }
            
            // check com timer
            if(time>=msgCommsTimer)
            {
              this->msgCommsTimerCallback(); // takes time
              time = hidi::getCurrentTime();
              msgCommsTimer = time+commsTick;
            }
            
            // pause for the remainder
            hidi::pause((std::max)(time-(std::min)(msgAppTimer, msgCommsTimer), 0.0)); // takes time
            time = hidi::getCurrentTime();
          }
        }
        catch(std::exception& e)
        {
          str = "Exec:ERROR: ";
          str = str+e.what();
          printf("%s\n", str.c_str());
        }
        catch(const char* e)
        {
          printf("Exec:ERROR: %s\n", e);
        }
        catch(...)
        {
          printf("Exec:ERROR: Unhandled exception.\n");
        }
      }
      return;
    }
    
  private:
    Exec(const double& msgTimeWarp)
    {
      this->msgTimeWarp = msgTimeWarp;
    }
    
    void msgAppTimerCallback(void)
    {
      size_t iOutbox;
      
      // call the application with an empty inbox
      this->msgApp->msgProcess("");
      
      // send outgoing messages
      for(iOutbox = 0; iOutbox<this->msgApp->msgOutbox.size(); ++iOutbox)
      {
        this->msgComms->send(this->msgApp->msgOutbox[iOutbox]);
      }
      
      // clear the outbox
      this->msgApp->msgClear();
      return;
    }
    
    void msgCommsTimerCallback(void)
    {
      size_t iOutbox;
      
      // create inbox
      std::string inbox;
      
      // loop until inbox is empty
      while(true)
      {
        // receive incoming message
        this->msgComms->receive(inbox);
        
        // if inbox is empty
        if(inbox.empty())
        {
          // stop receiving
          break;
        }
        else // inbox is not empty
        {
          // call the application
          this->msgApp->msgProcess(inbox);
          
          // send outgoing messages
          for(iOutbox = 0; iOutbox<this->msgApp->msgOutbox.size(); ++iOutbox)
          {
            this->msgComms->send(this->msgApp->msgOutbox[iOutbox]);
          }
          
          // clear the outbox
          this->msgApp->msgClear();
        }
      }
      return;
    }
  };
}

#endif
