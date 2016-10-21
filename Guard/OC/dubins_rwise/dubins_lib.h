/******************************************************************************
 **  dubins_lib.h    - Library of functions for dubins path connectivity
 **
 ** History:
 **    05/19/15      rwise
 **
 ******************************************************************************/

#ifndef DUBINS_LIB_H__
#define DUBINS_LIB_H__

typedef enum {DB_STRAIGHT,DB_CW,DB_CCW}TURN_DIRECTION;
typedef enum {DB_CASE_NONE = -1,
    DB_CASE_RSR = 0,
    DB_CASE_RSL = 1,
    DB_CASE_LSR = 2,
    DB_CASE_LSL = 3
}DUBINS_CASE;

typedef struct{
   double start[3]; /* {N,E,h} , h is cw from N*/
   double end[3]; /* {N,E,h}, h is cw from N*/
   double tan1[3]; /* {N,E,h}, h is cw from N*/
   double tan2[3]; /* {N,E,h}, h is cw from N*/
   double d[3]; /* distances of the three legs */
   TURN_DIRECTION td[3]; /* turn direction of the three legs {0:straight,1:CW,2:CCW}, td[1]==STRAIGHT, by definition */
   double tr; /* tr used in path */
}dubins_path;

/* Returns the dubins_path (and associated case) if any, else DB_CASE_NONE */
int dubins_adjoin_to_start( double start_N, double start_E, double start_h, dubins_path* a_path, int is_debug_print );

/* alternate version of dubins_adjoin_to_start(...) */
int dubins_join( double start_N, double start_E, double start_h, double end_N, double end_E, double end_h, double turn_radius, dubins_path* a_path, int is_debug_print );

/* LOCAL */

typedef enum {_CIRCLE_CASE_LEFT,_CIRCLE_CASE_RIGHT}_CIRCLE_CASE;

double _path_length( DUBINS_CASE d_case, double turn_radius, double dist_to_next_circle, double rel_brng_next, double start_heading,
        double end_heading, double *o_len_turn1, double *o_len_straight, double *o_len_turn2 );

void _circle_center( _CIRCLE_CASE c_case, double ref_position_en[2], double heading, double turn_radius, double o_center_en[2] );

void _find_circle_tangents( DUBINS_CASE d_case, double turn_radius, double start_circle_center_en[2], double end_circle_center_en[2],
        double o_start_circle_tangent_enh[3], double o_end_circle_tangent_enh[3] );

#endif /* DUBINS_LIB_H__ */

/***************************** and of angle_lib.h *******************************/

