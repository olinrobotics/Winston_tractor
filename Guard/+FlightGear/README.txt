
Flightgear needs to be running on a host that you can connect to with the http port open, these matlab scripts connect to flight gear, they do not set up models in flight gear so everything has to be loaded already.  The scripts assume that you have set up the flying saucer as the host aircraft since it allows an unobstructed view of the environment.  Many of the scripts are focussed on following an aircraft carrier, which requires that Flightgear be opened with one of the carrier configurations.

Most of the scripts come from an external source, some of then theoretically allow you to set up way points to fly the aircraft, here's the list of the files and what they do:

activate_ap.m   - activates autopilot with a parameter speed, holds current altitude and heading (will follow way points)
add_wp.m		- adds a waypoint to the autopilot list
clear_rt.m		- clears the autopilot waypoints
delete_wp.m		- deletes a waypoint at position param
get_simtime.m	- gets the simulation time
get_wp.m		- gets the waypoint at position param
get_wpdist.m	- gets the distance to the current way point
get_wpstack.m	- gets the total number of waypoints in the stack
insert_wp.m		- inserts a waypoint at position param
pop_wp.m		- pops the waypoints???
speedup_fg.m	- increases flightgear simulation speed by a factor of param
license.txt		- license for the wp based matlab code (everything above, nothing below)


All of the scripts below were written by Dr. Andrew Browning in his own time as an extension of work started at Boston University on using commercial/open source simulation tools for sensor simulation and robotics algorithm development.

follow_carrier.m 			- finds the carrier model (driving with it's own ai) and maintains a fixed position relative to it
get_carrier_position.m		- gets the position, heading, and orientation of the carrier
get_pos.m					- gets the position and orientation of the host vehicle (camera)
set_alt.m 					- sets the altitude of the camera
change_view.m 				- changes the camera view of the aircraft (cockpit, tail camera, etc)

lat_lon_to_m_at_equator.m	- generates a trajectory
fly_trajectory.m	- generates a trajectory, sets a carrier model moving, and then flys trajectory
