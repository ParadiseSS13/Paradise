// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	see_in_dark = 8
	invisibility = 101  // No one can see us
	sight = SEE_SELF
	move_on_shuttle = FALSE
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2

/mob/camera/experience_pressure_difference(flow_x, flow_y)
	return // Immune to gas flow.

/mob/camera/forceMove(atom/destination)
	var/oldloc = loc
	loc = destination
	Moved(oldloc, NONE)
