#ifndef HIDIPAUSE_H
#define HIDIPAUSE_H

#include "+hidi/hidi.h"

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif
#include <cmath>

namespace hidi
{
  void pause(const double& tSeconds)
  {
#ifdef _WIN32
    Sleep(static_cast<unsigned long>(floor(tSeconds*1000.0)));
#else
    unsigned int decimal = static_cast<unsigned int>(floor(tSeconds));
    double fraction = tSeconds-static_cast<double>(decimal);
    sleep(decimal);
    usleep(static_cast<unsigned long>(floor(fraction*1000000.0)));
#endif
    return;
  }
}

#endif
