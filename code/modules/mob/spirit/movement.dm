// spirits are not moved by airflow
mob/spirit/Move()
	return 0

// this is the main move proc for spirits, it uses their 'setLoc' function to handle all the visibility shenanigans
// this, like most movement code for these guys, is cribbed from the AIEye movement code
mob/spirit/proc/Spirit_Move(direct)

	var/initial = initial(sprint)
	var/max_sprint = 50

	// if we haven't moved in a while, we stop sprinting
	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(src, direct))
		if(step)
			setLoc(step)

	dir = direct // update our sprite

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

	// if we're trying to move, we want to stop following our target
	follow_target = null

mob/spirit/setLoc(var/T)
	T = get_turf(T)
	loc = T

mob/spirit/verb/toggle_acceleration()
	set category = "Spirit"
	set name = "Toggle Acceleration"

	acceleration = !acceleration
	to_chat(usr, "Acceleration has been toggled [acceleration ? "on" : "off"].")
