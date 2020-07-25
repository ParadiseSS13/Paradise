///Keeps track of the sources of dynamic luminosity and updates our visibility with the highest.
/atom/movable/proc/update_dynamic_luminosity()
	var/highest = 0
	for(var/i in affected_dynamic_lights)
		if(affected_dynamic_lights[i] <= highest)
			continue
		highest = affected_dynamic_lights[i]
	if(highest == affecting_dynamic_lumi)
		return
	luminosity -= affecting_dynamic_lumi
	affecting_dynamic_lumi = highest
	luminosity += affecting_dynamic_lumi


///Helper to change several lighting overlay settings.
/atom/movable/proc/lighting_overlay_set_range_power_color(range, power, color)
	lighting_overlay_set_range(range)
	lighting_overlay_set_power(power)
	lighting_overlay_set_color(color)

///Changes the overlay range setting of the lighting overlay.
/atom/movable/proc/lighting_overlay_set_range(range)
	return SEND_SIGNAL(src, COMSIG_MOVABLE_LIGHT_OVERLAY_SET_RANGE, range)

///Changes the overlay power setting of the lighting overlay.
/atom/movable/proc/lighting_overlay_set_power(power)
	return SEND_SIGNAL(src, COMSIG_MOVABLE_LIGHT_OVERLAY_SET_POWER, power)

///Changes the overlay color setting of the lighting overlay.
/atom/movable/proc/lighting_overlay_set_color(color)
	return SEND_SIGNAL(src, COMSIG_MOVABLE_LIGHT_OVERLAY_SET_COLOR, color)

///Changes the overlay power setting of the lighting overlay.
/atom/movable/proc/lighting_overlay_toggle_on(new_state)
	return SEND_SIGNAL(src, COMSIG_MOVABLE_LIGHT_OVERLAY_TOGGLE_ON, new_state)
