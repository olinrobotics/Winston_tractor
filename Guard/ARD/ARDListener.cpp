#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "JSONRead.h"

// configuration
static JSONRead cfg("guard.json");

// An application that displays all messages published to a connected switch.
class ARDListener : virtual public Msg::App
{
public:
  ARDListener(void) :
    Msg::App("ARDListener", cfg.get<double>("fastTick"))
  {
    this->maxDisplay = static_cast<uint32_t>(cfg.get<double>("maxDisplay"));
  }
  
  void topics(std::vector< std::string >& sub)
  {
    sub.assign(1, ""); // subscribe to all topics
    return;
  }
  
  void process(const std::string& inbox)
  {
    std::string type;
    std::string id;
    std::string pbData;
    if(!inbox.empty())
    {
      Msg::Proto::unpack(inbox, type, id, pbData);
      if(!type.empty())
      {
        printf("%s:", type.c_str());
        printf("%s;", id.c_str());
        if(!type.compare("msg.Time"))
        {
          msg::Time msgTime;
          msgTime.ParseFromString(pbData);
          double time = msgTime.times();
          printf("time=%.3f", time);
        }
        else if(!type.compare("msg.Log"))
        {
          msg::Log msgLog;
          msgLog.ParseFromString(pbData);
          std::string text = msgLog.text();
          printf("text=%s", text.c_str());
        }
        else if(!type.compare("msg.Cmd"))
        {
          msg::Cmd msgCmd;
          msgCmd.ParseFromString(pbData);
          msg::Mode msgMode = msgCmd.mode();
          printf("mode=%s", msg::Mode_Name(msgMode).c_str());
        }
        else if(!type.compare("msg.Ack"))
        {
          msg::Ack msgAck;
          msgAck.ParseFromString(pbData);
          msg::Mode msgMode = msgAck.mode();
          printf("mode=%s", msg::Mode_Name(msgMode).c_str());
        }
        else
        {
          size_t n;
          printf("data=");
          if(pbData.size()>this->maxDisplay)
          {
            for(n = 0; n<this->maxDisplay; ++n)
            {
              printf("%X", static_cast<uint8_t>(pbData[n]));
            }
            printf("...");
          }
          else
          {
            for(n = 0; n<pbData.size(); ++n)
            {
              printf("%X", static_cast<uint8_t>(pbData[n]));
            }
          }
        }
        printf("\n");
      }
    }
  }
  
private:
  uint32_t maxDisplay;
};

int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDListener subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDListener app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
