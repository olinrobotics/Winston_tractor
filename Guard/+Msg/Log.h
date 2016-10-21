#ifndef MSGLOG_H
#define MSGLOG_H

#include <cstdarg>
#include <cstdio>
#include <string>
#include "+Msg/Proto.h"

namespace Msg
{
  class App;
  
  // Optionally inherited text logging system.
  class Log
  {  
  protected:
    // Constructor.
    //
    // @param[in] msgApp initialize with 'this' pointer of the derived class
    Log(App* msgApp);

    // Send a log message at the next opportunity.
    //
    // @param[in] format   @see sprintf()
    // @param[in] varargin @see sprintf()
    void log(const char* format, ...);

  private:
    App* msgApp;
  };
}

#endif
