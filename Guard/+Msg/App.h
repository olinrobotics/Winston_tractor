#ifndef MSGAPP_H
#define MSGAPP_H

#include <string>
#include <vector>
#include "+Msg/Cmd.h"
#include "+Msg/Log.h"
#include "+Msg/Time.h"
#include "+hidi/hidi.h"

namespace Msg
{
  /**
   * Abstract base class from which all message applications derive.
   */
  class App
  {
  public:
    const std::string msgAppID;
    const double msgCommsTick;
    const double msgAppTick;
    const uint64_t msgMaxLength;
    std::vector< std::string > msgOutbox;
    Time* msgTime;
    Cmd* msgCmd;
    
    /** 
     * Abstract function that returns subscription topics (derived class must implement).
     *
     * @param[in] sub cell array of message headers defining subscription topics
     */
    virtual void topics(std::vector< std::string >& sub)
    {
      sub.clear();
      return;
    }

    /** 
     * Abstract process for handling all message types (derived class must implement).
     *
     * @param[in] inbox input message (may be empty)
     */
    virtual void process(const std::string& inbox)
    {
      return;
    }

    /** Send a message at the next opportunity.
     *
     * @param[in] outbox message to send
     */
    void send(const std::string& message)
    {
      this->msgOutbox.push_back(message);
      return;
    }

    // Get subscription topics.
    void msgTopics(std::vector< std::string >& sub)
    {
      size_t iTopic;
      std::vector< std::string > subTopics;
      sub.clear();
      if(this->msgTime!=NULL)
      {
        this->msgTime->msgTopicsTime(subTopics);
        for(iTopic = 0; iTopic<subTopics.size(); ++iTopic)
        {
          sub.push_back(subTopics[iTopic]);
        }
      }
      if(this->msgCmd!=NULL)
      {
        this->msgCmd->msgTopicsCmd(subTopics);
        for(iTopic = 0; iTopic<subTopics.size(); ++iTopic)
        {
          sub.push_back(subTopics[iTopic]);
        }
      }
      this->topics(subTopics);
      for(iTopic = 0; iTopic<subTopics.size(); ++iTopic)
      {
        sub.push_back(subTopics[iTopic]);
      }
      return;
    }

    // Main process.
    void msgProcess(const std::string& inbox)
    {
      if(this->msgTime!=NULL)
      {
        this->msgTime->msgProcessTime(inbox);
      }
      if(this->msgCmd!=NULL)
      {
        this->msgCmd->msgProcessCmd(inbox);
      }
      this->process(inbox);
      return;
    }

    // Clear message outbox.
    void msgClear(void)
    {
      this->msgOutbox.clear();
      return;
    }
    
  protected:
    /** 
     * Base class constructor that must be called from the derived class with at least one argument.
     *
     * @param[in] msgAppID     unique application identifier
     * @param[in] msgCommsTick desired maximum time interval between checking for incoming messages (default=1.0)
     * @param[in] msgAppTick   desired time interval between iterations with guaranteed empty inbox (default=inf)
     * @param[in] msgMaxLength maximum incoming message length (remainder will be truncated) (default=67108864)
     */
    App(const std::string& msgAppID, const double& msgCommsTick = 1.0, const double& msgAppTick = INF,
      const uint64_t& msgMaxLength = 67108864) : msgAppID(msgAppID), msgCommsTick(msgCommsTick), msgAppTick(msgAppTick),
      msgMaxLength(msgMaxLength)
    {
      this->msgOutbox.clear();
      this->msgTime = NULL;
      this->msgCmd = NULL;
    }
  };
}

#include "+Msg/Cmd.cpp"
#include "+Msg/Log.cpp"
#include "+Msg/Time.cpp"

#endif
