#include <curses.h>
#include <algorithm>
#include <cstdlib>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "JSONRead.h"

// configuration
static JSONRead cfg("guard.json");
static const uint8_t unknown = static_cast<uint8_t>(msg::RUN)+1;
static const double ackPeriod = cfg.get<double>("ackPeriod");
static const double tDanger = cfg.get<double>("tDanger");

// An application that displays all messages published to a connected switch.
class ARDWatcher : virtual public Msg::App, virtual public Msg::Time
{
public:
  ARDWatcher(void) :
    Msg::App("ARDWatcher", cfg.get<double>("fastTick"), ackPeriod),
    Msg::Time(this, cfg.get<std::string>("timeSourceID"), cfg.get<double>("timeWarp"))
  {
    // initialize application states
    this->appName.push_back("ARDWatcher");
    this->appCmd.push_back(unknown);
    this->appAck.push_back(unknown);
    this->appLog.push_back("");
    this->appAckTick.push_back(this->tick());

    // initialize ncurses
    mainwin = initscr();
    if(mainwin==NULL)
    {
      fprintf(stderr, "Terminal does not support ncurses.\n");
      exit(EXIT_FAILURE);
    }
    start_color();
    this->enableColor = has_colors()&&(COLOR_PAIRS>=6);
    if(this->enableColor)
    {
      init_pair(1, COLOR_WHITE, COLOR_BLACK);
      init_pair(2, COLOR_RED, COLOR_RED);
      init_pair(3, COLOR_YELLOW, COLOR_YELLOW);
      init_pair(4, COLOR_GREEN, COLOR_GREEN);
      init_pair(5, COLOR_WHITE, COLOR_WHITE);
      this->colorMap[msg::OFF] = 2;
      this->colorMap[msg::IDLE] = 3;
      this->colorMap[msg::RUN] = 4;
      this->colorMap[unknown] = 5;
    }
    else
    {
      this->charMap[msg::OFF] = 'O';
      this->charMap[msg::IDLE] = 'I';
      this->charMap[msg::RUN] = 'R';
      this->charMap[unknown] = ' ';
    }
    curs_set(0);
    this->updateDisplay();
  }

  ~ARDWatcher(void)
  {
    delwin(mainwin);
    endwin();
    refresh();
  }

  void topics(std::vector< std::string >& sub)
  {
    sub.clear();
    sub.push_back(Msg::Proto::topic("msg.Cmd", ""));
    sub.push_back(Msg::Proto::topic("msg.Ack", ""));
    sub.push_back(Msg::Proto::topic("msg.Log", ""));
    return;
  }

  void process(const std::string& inbox)
  {
    if(inbox.empty())
    {
      this->checkTimeout();
    }
    else
    {
      this->updateState(inbox);
    }
    this->updateDisplay();
    return;
  }
    
private:
  WINDOW* mainwin; // ncurses window
  std::map< uint8_t, short > colorMap;
  std::map< uint8_t, char > charMap;
  std::vector< std::string > appName;
  std::vector< uint8_t > appCmd;
  std::vector< uint8_t > appAck;
  std::vector< std::string > appLog;
  std::vector< uint64_t > appCmdTick;
  std::vector< uint64_t > appAckTick;
  bool enableColor;
  
  void checkTimeout(void)
  {
    size_t n;
    for(n = 0; n<this->appName.size(); ++n)
    {
      if(this->tock(this->appAckTick[n])>tDanger)
      {
        this->appAck[n] = unknown;
      }
    }
    return;
  }
  
  void updateState(const std::string& inbox)
  {
    std::vector< std::string >::iterator it;
    size_t n;
    std::string type;
    std::string id;
    std::string pbData;
    
    Msg::Proto::unpack(inbox, type, id, pbData);
    if(!type.compare("msg.Cmd"))
    {
      uint64_t tick;
      msg::Cmd msgCmd;
      msgCmd.ParseFromString(pbData);
      msg::Mode msgMode = msgCmd.mode();
      tick = this->tick();
      it = std::find(this->appName.begin(), this->appName.end(), id);
      if(it==this->appName.end())
      {
        this->appName.push_back(id);
        this->appCmd.push_back(msgMode);
        this->appAck.push_back(unknown);
        this->appLog.push_back("");
        this->appCmdTick.push_back(tick);
        this->appAckTick.push_back(tick);
      }
      else
      {
        n = static_cast<size_t>(it-this->appName.begin());
        this->appCmd[n] = msgMode;
        this->appCmdTick[n] = this->tick();
      }
    }
    else if(!type.compare("msg.Ack"))
    {
      uint64_t tick;
      msg::Ack msgAck;
      msgAck.ParseFromString(pbData);
      msg::Mode msgMode = msgAck.mode();
      tick = this->tick();
      it = std::find(this->appName.begin(), this->appName.end(), id);
      if(it==this->appName.end())
      {
        this->appName.push_back(id);
        this->appCmd.push_back(unknown);
        this->appAck.push_back(msgMode);
        this->appLog.push_back("");
        this->appCmdTick.push_back(tick);
        this->appAckTick.push_back(tick);
      }
      else
      {
        n = static_cast<size_t>(it-this->appName.begin());
        this->appAck[n] = msgMode;
        this->appAckTick[n] = this->tick();
      }
    }
    else if(!type.compare("msg.Log"))
    {
      uint64_t tick;
      msg::Log msgLog;
      msgLog.ParseFromString(pbData);
      tick = this->tick();
      it = std::find(this->appName.begin(), this->appName.end(), id);
      if(it==this->appName.end())
      {
        this->appName.push_back(id);
        this->appCmd.push_back(unknown);
        this->appAck.push_back(unknown);
        this->appLog.push_back(msgLog.text());
        this->appCmdTick.push_back(tick);
        this->appAckTick.push_back(tick);
      }
      else
      {
        n = static_cast<size_t>(it-this->appName.begin());
        this->appLog[n] = msgLog.text();
      }
    }
    return;
  }
  
  void updateDisplay(void)
  {
    std::string str;
    size_t n;
    int colMax;
    int colRemain;
    colMax = getmaxx(stdscr);
    clear();
    for(n = 0; n<this->appName.size(); ++n)
    {
      // display the application status
      if(this->enableColor)
      {
        color_set(this->colorMap[this->appCmd[n]], NULL);
        mvaddstr(n, 1, " ");
        color_set(this->colorMap[this->appAck[n]], NULL);
        mvaddstr(n, 2, " ");
        color_set(1, NULL);
      }
      else
      {
        mvaddch(n, 1, this->charMap[this->appCmd[n]]);
        mvaddch(n, 2, this->charMap[this->appAck[n]]);
      }
      // display the application name and log information
      str = this->appName[n]+" ";
      colRemain = (std::max)(0, colMax-4-static_cast<int>(str.size()));
      str += this->appLog[n].substr(0, colRemain); // do not print past the screen edge
      mvaddstr(n, 4, str.c_str());
    }
    refresh();
  }
};

int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDWatcher subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDWatcher app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
