namespace Msg
{ 
  bool Cmd::init(void)
  {
    return true;
  }
  
  void Cmd::idle(const std::string& inbox)
  {
    return;
  }
  
  bool Cmd::run(const std::string& inbox)
  {
    return false;
  }
  
  void Cmd::term(void)
  {
    return;
  }
  
  void Cmd::msgTopicsCmd(std::vector< std::string >& sub)
  {
    sub.clear();
    sub.push_back(this->cacheMsgCmdTopic());
    return;
  }
  
  void Cmd::msgProcessCmd(const std::string& inbox)
  {
    bool done;
    std::string type;
    std::string id;
    std::string pbCmd;
    msg::Cmd msgCmd;
    msg::Ack msgAck;
    
    // if input is a command for this application
    if(Msg::Proto::isTopic(inbox, this->cacheMsgCmdTopic()))
    {
      // unpack the message
      Msg::Proto::unpack(inbox, type, id, pbCmd);
      
      // unpack the command
      msgCmd.ParseFromString(pbCmd);
      
      // implement status transition
      this->msgStatusTransition(msgCmd.mode());
    }
    
    // robustly run the appropriate function
    try
    {
      switch(this->msgStatus)
      {
        case Msg::Cmd::INIT:
        {
          done = this->init();
          if(done)
          {
            this->msgStatus = Msg::Cmd::IDLE;
          }
          break;
        }
        case Msg::Cmd::IDLE:
        {
          this->idle(inbox);
          break;
        }
        case Msg::Cmd::RUN:
        {
          done = this->run(inbox);
          if(done)
          {
            this->msgStatus = Msg::Cmd::IDLE;
          }
          break;
        }
        case Msg::Cmd::RECOVER:
        {
          break; // nop
        }
        default: // Msg::Cmd::TERM
        {
          this->term();
        }
      }
    }
    catch(...)
    {
      this->msgStatus = Msg::Cmd::RECOVER;
      throw;
    }
    
    // if enough time has passed
    if((hidi::getCurrentTime()-this->msgAckTimer)>=(this->msgAckPeriod/this->msgTimeWarp))
    {
      // reset the timer
      this->msgAckTimer = hidi::getCurrentTime();
      
      // send acknowledgement
      msgAck.set_mode(this->msgGetMode());
      this->msgApp->send(Msg::Proto::pack("msg.Ack", this->msgApp->msgAppID, msgAck.SerializeAsString()));
    }
  }
  
  Cmd::Cmd(App* msgApp, const double& msgAckPeriod, const double& msgTimeWarp)
  {
    this->msgApp = msgApp;
    if(this->msgApp->msgAppID.empty())
    {
      throw("Cmd: App must be initialized before Cmd");
    }
    this->msgAckPeriod = msgAckPeriod;
    this->msgTimeWarp = msgTimeWarp;
    this->msgStatus = Msg::Cmd::OFF;
    this->msgAckTimer = hidi::getCurrentTime();
    this->msgCmdTopic = "";
    this->msgApp->msgCmd = this;
  }
  
  std::string Cmd::cacheMsgCmdTopic(void)
  {
    if(this->msgCmdTopic.empty())
    {
      this->msgCmdTopic = Msg::Proto::topic("msg.Cmd", this->msgApp->msgAppID);
    }
    return (this->msgCmdTopic);
  }
  
  // Convert status to mode.
  msg::Mode Cmd::msgGetMode(void)
  {
    msg::Mode msgMode;
    switch(this->msgStatus)
    {
      case Msg::Cmd::RUN:
      {
        msgMode = static_cast<msg::Mode>(Msg::Cmd::RUN);
        break;
      }
      case Msg::Cmd::IDLE:
      {
        msgMode = static_cast<msg::Mode>(Msg::Cmd::IDLE);
        break;
      }
      default: // {OFF, INIT, RECOVER, TERM}
      {
        msgMode = static_cast<msg::Mode>(Msg::Cmd::OFF);
        break;
      }
    }
    return (msgMode);
  }
  
  void Cmd::msgStatusTransition(msg::Mode msgMode)
  {
    switch(this->msgStatus)
    {
      case Msg::Cmd::RUN: // fall through
      case Msg::Cmd::IDLE: 
      {
        switch(msgMode)
        {
          case msg::RUN:
          {
            this->msgStatus = Msg::Cmd::RUN;
            break;
          }
          case msg::IDLE:
          {
            this->msgStatus = Msg::Cmd::IDLE;
            break;
          }
          default: // msg::Mode::OFF
          {
            this->msgStatus = Msg::Cmd::TERM;
            break;
          }
        }
        break;
      }
      case Msg::Cmd::INIT:
      {
        switch(msgMode)
        {
          case msg::Mode::RUN: // fall through
          case msg::Mode::IDLE:
          {
            break; // nop
          }
          default: // msg::Mode::OFF
          {
            this->msgStatus = Msg::Cmd::TERM;
            break;
          }
        }
        break;
      }
      case Msg::Cmd::RECOVER:
      {
        switch(msgMode)
        {
          case msg::Mode::RUN: // fall through
          case msg::Mode::IDLE:
          {
            this->msgStatus = Msg::Cmd::IDLE;
            break;
          }
          default: // msg::Mode::OFF
          {
            this->msgStatus = Msg::Cmd::OFF;
            break;
          }
        }
        break;
      }
      case Msg::Cmd::TERM:
      {
        this->msgStatus = Msg::Cmd::OFF;
        break;
      }
      default: // Msg::Cmd::OFF
      {
        switch(msgMode)
        {
          case msg::Mode::RUN: // fall through
          case msg::Mode::IDLE:
          {
            this->msgStatus = Msg::Cmd::INIT;
            break;
          }
          default: // msg::Mode::OFF
          {
            break; // nop
          }
        }
        break;
      }
    }
  }
}
