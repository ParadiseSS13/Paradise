
GLOBAL_VAR_INIT(starlight_colour, "#d2e5f7")

/proc/set_starlight_colour(new_colour, transition_time)
	GLOB.starlight_colour = new_colour
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, new_colour, transition_time)
