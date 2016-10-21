/******************************************************************************
 **  qt_lib.c    - Library of functions to provide the Quad-tree functionality
 **
 ** History:
 **    05/06/05      Jayesh     - First cut
 **    03/05/13      rwise - allow user to set parameters
 **
 ******************************************************************************/

#include <math.h>
#include "angle_lib.h"

// input in radians
void bound_angle( double *angle_rad, int is_center )
{
    if (is_center > 0)
    {
        while (*angle_rad <= -PI)
            *angle_rad = *angle_rad + TWO_PI;
        while (*angle_rad > PI)
            *angle_rad = *angle_rad - TWO_PI;
    }
    else
    {
        while (*angle_rad < 0.0)
            *angle_rad = *angle_rad + TWO_PI;
        while (*angle_rad >= TWO_PI)
            *angle_rad = *angle_rad - TWO_PI;
    }
}

// Angular distance, in the direction specified, from ang_from.  input in radians, output [0:2pi)
double angular_distance( double ang_from, double ang_to, int is_cw )
{
    double int_part = 0.0;
    double delta = 0.0;
    bound_angle(&ang_from, 0);
    bound_angle(&ang_to, 0);
    if (is_cw > 0)
        delta = modf(( TWO_PI + ang_to - ang_from) / TWO_PI, &int_part);
    else
        delta = modf(( TWO_PI - ang_to + ang_from) / TWO_PI, &int_part);
    return delta * TWO_PI;
}

// Return signed shortest angular distance between two input angles, Output -pi:pi degrees, CW is positive
double short_delta_angle( double ang_from, double ang_to )
{
    bound_angle(&ang_from, 0);
    bound_angle(&ang_to, 0);
    double delta = ang_to - ang_from;
    if (ang_from < ang_to)
        delta = TWO_PI - ang_from + ang_to;

    bound_angle(&delta, 1);

    return delta;
}

double mod_ang( double ang )
{
    double int_part;
    double delta = modf(ang / TWO_PI, &int_part);
    return delta * TWO_PI;
}

/***************************** end of qt_lib.c *******************************/
