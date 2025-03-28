/obj/machinery/atmospherics/binary/valve
	icon = 'icons/atmos/valve.dmi'
	icon_state = "map_valve0"

	name = "manual valve"
	desc = "A pipe valve."

	can_unwrench = TRUE

	var/open = FALSE
	var/animating = FALSE

	req_one_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)

/obj/machinery/atmospherics/binary/valve/examine(mob/user)
	. = ..()
	. += "It is currently [open ? "open" : "closed"]."
	. += "<span class='notice'>Click this to turn the valve. If red, the pipes on each end are separated. Otherwise, they are connected.</span>"

/obj/machinery/atmospherics/binary/valve/open
	open = TRUE
	icon_state = "map_valve1"

/obj/machinery/atmospherics/binary/valve/update_icon_state()
	if(animating)
		flick("valve[open][!open]",src)
	else
		icon_state = "valve[open]"

/obj/machinery/atmospherics/binary/valve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, get_dir(src, node1))
		add_underlay(T, node2, get_dir(src, node2))

/obj/machinery/atmospherics/binary/valve/proc/open()
	open = TRUE
	update_icon(UPDATE_ICON_STATE)
	parent1.update = 0
	parent2.update = 0
	parent1.reconcile_air()
	investigate_log("was opened by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return

/obj/machinery/atmospherics/binary/valve/proc/close()
	open = FALSE
	update_icon(UPDATE_ICON_STATE)
	investigate_log("was closed by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return

/obj/machinery/atmospherics/binary/valve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/binary/valve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/attack_hand(mob/user)
	add_fingerprint(usr)
	animating = TRUE
	update_icon(UPDATE_ICON_STATE)
	sleep(10)
	animating = FALSE
	if(open)
		close()
	else
		open()
	to_chat(user, "<span class='notice'>You [open ? "open" : "close"] [src].</span>")

/// can be controlled by AI
/obj/machinery/atmospherics/binary/valve/digital
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_valve.dmi'

/obj/machinery/atmospherics/binary/valve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/digital/attack_hand(mob/user)
	if(!has_power())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return
	..()

/obj/machinery/atmospherics/binary/valve/digital/open
	open = TRUE
	icon_state = "map_valve1"

/obj/machinery/atmospherics/binary/valve/digital/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/binary/valve/digital/update_icon_state()
	if(!has_power())
		icon_state = "valve[open]nopower"
		return
	..()
