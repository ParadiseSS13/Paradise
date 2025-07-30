#define TVALVE_STATE_STRAIGHT 0
#define TVALVE_STATE_SIDE 1

/obj/machinery/atmospherics/trinary/tvalve
	icon = 'icons/atmos/tvalve.dmi'
	icon_state = "map_tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve."

	can_unwrench = TRUE

	var/state = TVALVE_STATE_STRAIGHT

/obj/machinery/atmospherics/trinary/tvalve/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Click this to toggle the mode. The direction with the green light is where the gas will flow.</span>"

/obj/machinery/atmospherics/trinary/tvalve/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/flipped
	icon_state = "map_tvalvem0"
	flipped = TRUE

/obj/machinery/atmospherics/trinary/tvalve/flipped/bypass
	icon_state = "map_tvalvem1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/update_icon(animation)
	var/flipstate = ""
	if(flipped)
		flipstate = "m"
	if(animation)
		flick("tvalve[flipstate][state][!state]",src)
	else
		icon_state = "tvalve[flipstate][state]"
	..()

/obj/machinery/atmospherics/trinary/tvalve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(flipped)
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/tvalve/proc/switch_side()
	if(state == TVALVE_STATE_STRAIGHT)
		go_to_side()
	else
		go_straight()

/obj/machinery/atmospherics/trinary/tvalve/proc/go_to_side()
	if(state == TVALVE_STATE_SIDE)
		return 0

	state = TVALVE_STATE_SIDE
	update_icon()

	parent1.update = 0
	parent2.update = 0
	parent3.update = 0
	parent1.reconcile_air()

	investigate_log("was set to side by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return 1

/obj/machinery/atmospherics/trinary/tvalve/proc/go_straight()
	if(state == TVALVE_STATE_STRAIGHT)
		return 0

	state = TVALVE_STATE_STRAIGHT
	update_icon()

	parent1.update = 0
	parent2.update = 0
	parent3.update = 0
	parent1.reconcile_air()

	investigate_log("was set to straight by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return 1

/obj/machinery/atmospherics/trinary/tvalve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/trinary/tvalve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/attack_hand(mob/usermob)
	add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	switch_side()

/// can be controlled by AI
/obj/machinery/atmospherics/trinary/tvalve/digital
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_tvalve.dmi'

	var/id = null

/obj/machinery/atmospherics/trinary/tvalve/digital/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/digital/flipped
	icon_state = "map_tvalvem0"
	flipped = TRUE

/obj/machinery/atmospherics/trinary/tvalve/digital/flipped/bypass
	icon_state = "map_tvalvem1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/digital/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/trinary/tvalve/digital/update_icon_state()
	if(!has_power())
		icon_state = "tvalvenopower"

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_hand(mob/user)
	if(!has_power())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return
	..()

#undef TVALVE_STATE_STRAIGHT
#undef TVALVE_STATE_SIDE
