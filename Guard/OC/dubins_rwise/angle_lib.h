/******************************************************************************
 **  angle_lib.h    - Library of functions to provide the common angle functions
 **
 ** History:
 **    05/18/15      rwise
 **
 ******************************************************************************/

#ifndef ANGLE_LIB_H__
#define ANGLE_LIB_H__

#ifndef PI
#define PI 3.141592654
#endif

#ifndef TWO_PI
#define TWO_PI 6.28318530718
#endif

#ifndef PI_OVER_TWO
#define PI_OVER_TWO 1.57079632679
#endif

#ifndef R2D
#define R2D 57.2957795131
#endif

#ifndef D2R
#define D2R 0.0174532925199
#endif

// bound angle [0:2pi) if is_center > 0, [-PI:PI) o/w
void bound_angle( double *angle_rad, int is_center );

// Angular distance, in the direction specified, from ang_from.  input in radians, output [0:2pi)
double angular_distance( double ang_from, double ang_to, int is_cw );

// Return signed shortest angular distance between two input angles, Output -180 : 180 degrees, CW is positive
double short_delta_angle( double ang_from, double ang_to );

// return fractional part of input angle w.r.t. 2*PI, output is [-2pi:2pi]
double mod_ang( double ang );

#endif /* ANGLE_LIB_H__ */

/***************************** and of angle_lib.h *******************************/

