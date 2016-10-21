/******************************************************************************
 **  dubins_lib.c    - Library of functions to provide the dubins path functionality
 **
 ** History:
 **    05/19/15      rwise - initial conversion from c++
 **
 ******************************************************************************/

#include <math.h>
#include <stdio.h>
#include "angle_lib.h"
#include "dubins_lib.h"

typedef struct
{
    double begin_circle[2]; /* {E,N} */
    double end_circle[2]; /* {E,N} */
    double start_tangent[3]; /* {E,N,h} */
    double end_tangent[3]; /* {E,N,h} */
    double dist_to;
    double brng_to; /* cw [0:2pi) from N */
    double path_len;
    double len1;
    double len2;
    double len3;
} _dubins_vals_t;

//extern void log_output( const char* format, ... );

int dubins_adjoin_to_start( double start_N, double start_E, double start_h, dubins_path* a_path, int is_debug_print )
{
    _dubins_vals_t dls[4];
    double sp[2] = { start_E, start_N };
    double ep[2] = { a_path->end[1], a_path->end[0] };
    int ii;
    int best_i = 0;
    double short_l;

    /* check if a straight line will do */
    double d_to_end = hypot((sp[1] - ep[1]), (sp[0] - ep[0]));
    double d_ang = angular_distance(start_h, atan2((sp[0] - ep[0]), (sp[1] - ep[1])), 1);
    if (d_ang < PI / 180.0)
    {
        if (d_to_end * d_ang < a_path->tr)
        {
            /*
if (is_debug_print > 0)
                log_output("Straight line will do");
*/
            a_path->start[0] = start_E;
            a_path->start[1] = start_N;
            a_path->start[2] = start_h;
            a_path->d[0] = 0.0;
            a_path->d[1] = d_to_end;
            a_path->d[2] = 0.0;
            a_path->tan1[0] = start_E;
            a_path->tan1[1] = start_N;
            a_path->tan1[2] = start_h;
            a_path->tan2[0] = a_path->end[0];
            a_path->tan2[1] = a_path->end[1];
            a_path->tan2[2] = a_path->end[2];
            a_path->td[0] = DB_STRAIGHT;
            a_path->td[1] = DB_STRAIGHT;
            a_path->td[2] = DB_STRAIGHT;
            return 0;
        }
    }

    if (d_to_end < a_path->tr)
        return DB_CASE_NONE;

    _circle_center(_CIRCLE_CASE_RIGHT, sp, start_h, a_path->tr, dls[DB_CASE_RSR].begin_circle);
    _circle_center(_CIRCLE_CASE_RIGHT, ep, a_path->end[2], a_path->tr, dls[DB_CASE_RSR].end_circle);

    _circle_center(_CIRCLE_CASE_LEFT, sp, start_h, a_path->tr, dls[DB_CASE_LSL].begin_circle);
    _circle_center(_CIRCLE_CASE_LEFT, ep, a_path->end[2], a_path->tr, dls[DB_CASE_LSL].end_circle);

    dls[DB_CASE_RSL].begin_circle[0] = dls[DB_CASE_RSR].begin_circle[0];
    dls[DB_CASE_RSL].begin_circle[1] = dls[DB_CASE_RSR].begin_circle[1];
    dls[DB_CASE_RSL].end_circle[0] = dls[DB_CASE_LSL].end_circle[0];
    dls[DB_CASE_RSL].end_circle[1] = dls[DB_CASE_LSL].end_circle[1];

    dls[DB_CASE_LSR].begin_circle[0] = dls[DB_CASE_LSL].begin_circle[0];
    dls[DB_CASE_LSR].begin_circle[1] = dls[DB_CASE_LSL].begin_circle[1];
    dls[DB_CASE_LSR].end_circle[0] = dls[DB_CASE_RSR].end_circle[0];
    dls[DB_CASE_LSR].end_circle[1] = dls[DB_CASE_RSR].end_circle[1];

    for ( ii = 0; ii < 4; ++ii )
    {
        dls[ii].dist_to = hypot((dls[ii].end_circle[0] - dls[ii].begin_circle[0]), (dls[ii].end_circle[1] - dls[ii].begin_circle[1]));
        dls[ii].brng_to = atan2((dls[ii].end_circle[0] - dls[ii].begin_circle[0]), (dls[ii].end_circle[1] - dls[ii].begin_circle[1]));
        dls[ii].path_len = _path_length(ii, a_path->tr, dls[ii].dist_to, dls[ii].brng_to, start_h, a_path->end[2], &dls[ii].len1,
                &dls[ii].len2, &dls[ii].len3);
/*        
if (is_debug_print > 0)
        {
            _find_circle_tangents(ii, a_path->tr, dls[ii].begin_circle, dls[ii].end_circle, &dls[ii].start_tangent[0],
                    &dls[ii].end_tangent[0]);
            //case,wpb_e,wpb_n,wpb_h,wpe_e,wpe_n,wpe_h,cs_e,cs_n,ce_e,ce_n,c_dist,c_relb,ts_e,ts_n,te_e,te_n,path_len,len1,len2,len3
            log_output("%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f", ii + 1, start_E, start_N, start_h, a_path->end[1],
                    a_path->end[0], a_path->end[2], dls[ii].begin_circle[0], dls[ii].begin_circle[1], dls[ii].end_circle[0],
                    dls[ii].end_circle[1], dls[ii].dist_to, dls[ii].brng_to, dls[ii].start_tangent[0], dls[ii].start_tangent[1],
                    dls[ii].end_tangent[0], dls[ii].end_tangent[1], dls[ii].path_len, dls[ii].len1, dls[ii].len2, dls[ii].len3);
        }
*/
    }
/*
    if (is_debug_print > 0)
    {
        for ( ii = 0; ii < 4; ++ii )
        {
            log_output("Case %d", ii);
            log_output("\tStart{E,N,h}:{%f,%f,%f}", start_E, start_N, start_h);
            log_output("\tEnd{E,N,h}:{%f,%f,%f}", a_path->end[1], a_path->end[0], a_path->end[2]);
            log_output("\tCircle_s{E,N}:{%f,%f}", dls[ii].begin_circle[0], dls[ii].begin_circle[1]);
            log_output("\tCircle_e{E,N}:{%f,%f}", dls[ii].end_circle[0], dls[ii].end_circle[1]);
            log_output("\tTangent_s{E,N,h}:{%f,%f,%f}", dls[ii].start_tangent[0], dls[ii].start_tangent[1], dls[ii].start_tangent[2]);
            log_output("\tTangent_e{E,N,h}:{%f,%f,%f}", dls[ii].end_tangent[0], dls[ii].end_tangent[1], dls[ii].end_tangent[2]);
            log_output("\tD1:%f + D2:%f + D3:%f = %f", dls[ii].len1, dls[ii].len2, dls[ii].len3, dls[ii].path_len);
        }
    }
*/
    best_i = 0;
    short_l = dls[0].path_len;
    for ( ii = 1; ii < 4; ++ii )
    {
        if (dls[ii].path_len < short_l)
        {
            short_l = dls[ii].path_len;
            best_i = ii;
        }
    }

    _find_circle_tangents(best_i, a_path->tr, dls[best_i].begin_circle, dls[best_i].end_circle, dls[best_i].start_tangent,
            dls[best_i].end_tangent);

/*
    if (is_debug_print > 0)
        log_output("DUBINS: best case:%d", best_i);
*/
    a_path->tan1[0] = dls[best_i].start_tangent[1];
    a_path->tan1[1] = dls[best_i].start_tangent[0];
    a_path->tan1[2] = dls[best_i].start_tangent[2];
    a_path->tan2[0] = dls[best_i].end_tangent[1];
    a_path->tan2[1] = dls[best_i].end_tangent[0];
    a_path->tan2[2] = dls[best_i].end_tangent[2];

    /* fill in rest of data */
    a_path->start[0] = start_E;
    a_path->start[1] = start_N;
    a_path->start[2] = start_h;
    a_path->d[0] = dls[best_i].len1;
    a_path->d[1] = dls[best_i].len2;
    a_path->d[2] = dls[best_i].len3;
    a_path->td[1] = DB_STRAIGHT;
    if (best_i == DB_CASE_RSR)
    {
        a_path->td[0] = DB_CW;
        a_path->td[2] = DB_CW;
    }
    else if (best_i == DB_CASE_RSL)
    {
        a_path->td[0] = DB_CW;
        a_path->td[2] = DB_CCW;
    }
    else if (best_i == DB_CASE_LSR)
    {
        a_path->td[0] = DB_CCW;
        a_path->td[2] = DB_CW;
    }
    else /*if (best_i == DB_CASE_LSL)*/
    {
        a_path->td[0] = DB_CCW;
        a_path->td[2] = DB_CCW;
    }

/*
    if (is_debug_print > 0)
        log_output("DUBINS: best case:%d", best_i);
*/
    return best_i;
}

int dubins_join( double start_N, double start_E, double start_h, double end_N, double end_E, double end_h, double turn_radius,
        dubins_path* a_path, int is_debug_print )
{
    a_path->end[0] = end_N;
    a_path->end[1] = end_E;
    a_path->end[2] = end_h;
    a_path->tr = turn_radius;
    return dubins_adjoin_to_start(start_N, start_E, start_h, a_path, is_debug_print);
}

/****************
 * LOCAL
 ****************/
double _path_length( DUBINS_CASE d_case, double turn_radius, double dist_to_next_circle, double rel_brng_next, double start_heading,
        double end_heading, double *o_len_turn1, double *o_len_straight, double *o_len_turn2 )
{
    double c1 = 0;
    double c2 = 0;
    double sd = 0;
    switch (d_case)
    {
        case DB_CASE_RSR:
        {
            c1 = angular_distance(mod_ang(start_heading - PI_OVER_TWO), mod_ang(rel_brng_next - PI_OVER_TWO), 1);
            c2 = angular_distance(mod_ang(rel_brng_next - PI_OVER_TWO), mod_ang(end_heading - PI_OVER_TWO), 1);
            sd = dist_to_next_circle;
            break;
        }
        case DB_CASE_RSL:
        {
            double t2 = rel_brng_next + asin(2.0 * turn_radius / dist_to_next_circle) - PI_OVER_TWO;
            c1 = angular_distance(mod_ang(start_heading - PI_OVER_TWO), mod_ang(t2), 1);
            c2 = angular_distance(mod_ang(t2 + PI), mod_ang(end_heading + PI_OVER_TWO), -1);
            sd = sqrt(dist_to_next_circle * dist_to_next_circle - 4.0 * turn_radius * turn_radius);
            //            log_output("RSL. rb:%f, start_h:%f, t2:%f, c1:%f, c2:%f", rel_brng_next, start_heading, t2, c1, c2);
            break;
        }
        case DB_CASE_LSR:
        {
            double t2 = acos(2.0 * turn_radius / dist_to_next_circle);
            c1 = angular_distance(mod_ang(start_heading + PI_OVER_TWO), mod_ang(rel_brng_next + t2), -1);
            c2 = angular_distance(mod_ang(rel_brng_next + t2 - PI), mod_ang(end_heading - PI_OVER_TWO), 1);
            sd = sqrt(dist_to_next_circle * dist_to_next_circle - 4.0 * turn_radius * turn_radius);
            break;
        }
        case DB_CASE_LSL:
        {
            c1 = angular_distance(mod_ang(start_heading + PI_OVER_TWO), mod_ang(rel_brng_next + PI_OVER_TWO), -1);
            c2 = angular_distance(mod_ang(rel_brng_next + PI_OVER_TWO), mod_ang(end_heading + PI_OVER_TWO), -1);
            sd = dist_to_next_circle;
            break;
        }
    }
    *o_len_turn1 = turn_radius * c1;
    *o_len_turn2 = turn_radius * c2;
    *o_len_straight = sd;

    return sd + turn_radius * (c1 + c2);
}

void _circle_center( _CIRCLE_CASE c_case, double ref_position_en[2], double heading, double turn_radius, double o_center_en[2] )
{
    double rot_by = PI_OVER_TWO;
    if (c_case == _CIRCLE_CASE_LEFT)
        rot_by = -PI_OVER_TWO;

    o_center_en[0] = ref_position_en[0] + turn_radius * sin(heading + rot_by);
    o_center_en[1] = ref_position_en[1] + turn_radius * cos(heading + rot_by);
}

void _find_circle_tangents( DUBINS_CASE d_case, double turn_radius, double start_circle_center_en[2], double end_circle_center_en[2],
        double o_start_circle_tangent_enh[3], double o_end_circle_tangent_enh[3] )
{
    double to_end_circle[2] = { end_circle_center_en[0] - start_circle_center_en[0], end_circle_center_en[1] - start_circle_center_en[1] };
    double len_cc = hypot(to_end_circle[0], to_end_circle[1]);
    double brng = atan2(to_end_circle[0], to_end_circle[1]); /* cw positive */
    double tng_en[2];
    double t2;

    switch (d_case)
    {
        case DB_CASE_RSR:
        {
            tng_en[0] = turn_radius * sin(brng - PI_OVER_TWO);
            tng_en[1] = turn_radius * cos(brng - PI_OVER_TWO);
            o_start_circle_tangent_enh[0] = start_circle_center_en[0] + tng_en[0];
            o_start_circle_tangent_enh[1] = start_circle_center_en[1] + tng_en[1];
            o_start_circle_tangent_enh[2] = brng;

            o_end_circle_tangent_enh[0] = end_circle_center_en[0] + tng_en[0];
            o_end_circle_tangent_enh[1] = end_circle_center_en[1] + tng_en[1];
            o_end_circle_tangent_enh[2] = brng;

            break;
        }
        case DB_CASE_RSL:
        {
            t2 = brng + asin(2.0 * turn_radius / len_cc) - PI_OVER_TWO;
            tng_en[0] = turn_radius * sin(t2);
            tng_en[1] = turn_radius * cos(t2);

            o_start_circle_tangent_enh[0] = start_circle_center_en[0] + tng_en[0];
            o_start_circle_tangent_enh[1] = start_circle_center_en[1] + tng_en[1];
            o_start_circle_tangent_enh[2] = t2 + PI_OVER_TWO;

            tng_en[0] = turn_radius * sin(t2 + PI);
            tng_en[1] = turn_radius * cos(t2 + PI);

            o_end_circle_tangent_enh[0] = end_circle_center_en[0] + tng_en[0];
            o_end_circle_tangent_enh[1] = end_circle_center_en[1] + tng_en[1];
            o_end_circle_tangent_enh[2] = t2 + PI_OVER_TWO;

            break;
        }
        case DB_CASE_LSR:
        {
            t2 = brng + acos(2.0 * turn_radius / len_cc);
            tng_en[0] = turn_radius * sin(t2);
            tng_en[1] = turn_radius * cos(t2);

            o_start_circle_tangent_enh[0] = start_circle_center_en[0] + tng_en[0];
            o_start_circle_tangent_enh[1] = start_circle_center_en[1] + tng_en[1];
            o_start_circle_tangent_enh[2] = t2 - PI_OVER_TWO;

            tng_en[0] = turn_radius * sin(t2 - PI);
            tng_en[1] = turn_radius * cos(t2 - PI);
            o_end_circle_tangent_enh[0] = end_circle_center_en[0] + tng_en[0];
            o_end_circle_tangent_enh[1] = end_circle_center_en[1] + tng_en[1];
            o_end_circle_tangent_enh[2] = t2 - PI_OVER_TWO;
            break;
        }
        default: /*case DB_CASE_LSL:*/
        {
            tng_en[0] = turn_radius * sin(brng + PI_OVER_TWO);
            tng_en[1] = turn_radius * cos(brng + PI_OVER_TWO);

            o_start_circle_tangent_enh[0] = start_circle_center_en[0] + tng_en[0];
            o_start_circle_tangent_enh[1] = start_circle_center_en[1] + tng_en[1];
            o_start_circle_tangent_enh[2] = brng;

            o_end_circle_tangent_enh[0] = end_circle_center_en[0] + tng_en[0];
            o_end_circle_tangent_enh[1] = end_circle_center_en[1] + tng_en[1];
            o_end_circle_tangent_enh[2] = brng;

            break;
        }
    }
}

/***************************** end of dubins_lib.c *******************************/
int main()
{
  dubins_path path;
  dubins_join(0, 0, 0, 1, 1, 0.7071, 0.1, &path, 0);
  return 0;
}
