#ifndef HIDINEWLINE_H
#define HIDINEWLINE_H

#include "+hidi/hidi.h"

namespace hidi
{
  // Prints a platform-independent newline.
  //
  // @param[in] stream output file stream (default = stdout)
  void newline(FILE* stream = stdout)
  {
#ifdef MATLAB_MEX_FILE
    if(stream==stdout)
    {
      printf("\n");
    }
    else
    {
      fprintf(stream, "\x0d\x0a");
    }
#else
    fprintf(stream, "\x0d\x0a");
#endif
    return;
  }
}

#endif
