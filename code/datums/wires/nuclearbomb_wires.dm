/datum/wires/nuclearbomb
	holder_type = /obj/machinery/nuclearbomb
	labelled = TRUE
	randomize = TRUE
	wire_count = 5
	proper_name = "Nuclear bomb"

/datum/wires/nuclearbomb/New(atom/_holder)
	wires = list(WIRE_NUKE_SAFETY, WIRE_NUKE_DETONATOR, WIRE_NUKE_DISARM, WIRE_NUKE_LIGHT, WIRE_NUKE_CONTROL)
	return ..()

/datum/wires/nuclearbomb/interactable(mob/user)
	var/obj/machinery/nuclearbomb/N = holder
	if(N.panel_open)
		return TRUE
	return FALSE

/datum/wires/nuclearbomb/get_status()
	. = ..()
	var/obj/machinery/nuclearbomb/N = holder
	. += "The device is [N.timing ? "shaking!" : "still."]"
	. += "The control panel is [is_cut(WIRE_NUKE_CONTROL) ? "turned off" : "functional"]."
	. += "The disarm controls are [is_cut(WIRE_NUKE_DISARM) || is_cut(WIRE_NUKE_CONTROL) ? "disabled" : "functional"]."
	. += "The safety controls are [is_cut(WIRE_NUKE_SAFETY) || is_cut(WIRE_NUKE_CONTROL) ? "disabled" : "functional"]."
	. += "The lights are [is_cut(WIRE_NUKE_LIGHT) ? "static" : "functional"]."

/datum/wires/nuclearbomb/on_pulse(wire)
	var/obj/machinery/nuclearbomb/N = holder
	switch(wire)
		if(WIRE_NUKE_SAFETY)
			if(!is_cut(WIRE_NUKE_CONTROL))
				N.audible_message("<span class='notice'>The safety controls flicker.</span>", hearing_distance = 1)

		if(WIRE_NUKE_DETONATOR)
			if(N.timing)
				if(!N.training)
					message_admins("[key_name_admin(usr)] pulsed a nuclear bomb's detonator wire, causing it to explode (<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[holder.x];Y=[holder.y];Z=[holder.z]'>JMP</a>)")
				N.explode()
			else
				N.audible_message("<span class='warning'>[N] whirrs ominously.</span>", hearing_distance = 1)

		if(WIRE_NUKE_DISARM)
			if(N.timing && is_cut(WIRE_NUKE_CONTROL))
				if(!is_cut(WIRE_NUKE_LIGHT))
					N.icon_state = N.sprite_prefix + "nuclearbomb1"
				N.timing = FALSE
				N.audible_message("<span class='boldnotice'>The timer on [N] stops!</span>", hearing_distance = 1)
				N.update_icon(UPDATE_OVERLAYS)
				if(!N.training)
					GLOB.bomb_set = FALSE
				if(!N.is_syndicate && !N.training)
					SSsecurity_level.set_level(N.previous_level)
			else if(N.timing && !is_cut(WIRE_NUKE_CONTROL))
				N.audible_message("<span class='boldnotice'>The disarm controls flash with an error. You need to disable the control panel first!</span>", hearing_distance = 1)
			else if(!is_cut(WIRE_NUKE_CONTROL))
				N.audible_message("<span class='notice'>The disarm controls flicker.</span>", hearing_distance = 1)

		if(WIRE_NUKE_LIGHT)
			N.audible_message("<span class='notice'>The lights on [N] flicker.</span>", hearing_distance = 1)
			flick(N.sprite_prefix + "nuclearbombc", N)

		if(WIRE_NUKE_CONTROL)
			N.audible_message("<span class='notice'>[N]'s control panel flickers.</span>", hearing_distance = 1)

/datum/wires/nuclearbomb/on_cut(wire, mend)
	var/obj/machinery/nuclearbomb/N = holder
	switch(wire)
		if(WIRE_NUKE_DETONATOR)
			if(N.timing && !mend)
				if(!N.training)
					message_admins("[key_name_admin(usr)] cut a nuclear bomb's detonator wire, causing it to explode (<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[holder.x];Y=[holder.y];Z=[holder.z]'>JMP</a>)")
				N.explode()

		if(WIRE_NUKE_LIGHT)
			if(!mend)
				N.icon_state = N.sprite_prefix + "nuclearbomb0"
			if(mend)
				if(N.timing)
					N.icon_state = N.sprite_prefix + "nuclearbomb2"
				else
					N.icon_state = N.sprite_prefix + "nuclearbomb1"
			N.update_icon(UPDATE_OVERLAYS)
