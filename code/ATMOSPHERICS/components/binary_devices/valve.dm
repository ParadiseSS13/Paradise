/obj/machinery/atmospherics/binary/valve
	icon = 'icons/atmos/valve.dmi'
	icon_state = "map_valve0"

	name = "manual valve"
	desc = "A pipe valve"

	can_unwrench = 1

	var/open = 0

	req_one_access_txt = "24;10"

/obj/machinery/atmospherics/binary/valve/open
	open = 1
	icon_state = "map_valve1"

/obj/machinery/atmospherics/binary/valve/update_icon(animation)
	if(animation)
		flick("valve[src.open][!src.open]",src)
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
	open = 1
	update_icon()
	parent1.update = 0
	parent2.update = 0
	parent1.reconcile_air()
	investigate_log("was opened by [usr ? key_name(usr) : "a remote signal"]", "atmos")
	return

/obj/machinery/atmospherics/binary/valve/proc/close()
	open = 0
	update_icon()
	investigate_log("was closed by [usr ? key_name(usr) : "a remote signal"]", "atmos")
	return

/obj/machinery/atmospherics/binary/valve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/binary/valve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/attack_hand(mob/user)
	add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	if(open)
		close()
	else
		open()

/obj/machinery/atmospherics/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_valve.dmi'

	var/frequency = ATMOS_VENTSCRUB
	var/id_tag = null
	var/datum/radio_frequency/radio_connection
	settagwhitelist = list("id_tag")

/obj/machinery/atmospherics/binary/valve/digital/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/valve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/digital/attack_hand(mob/user)
	if(!powered())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return
	..()

/obj/machinery/atmospherics/binary/valve/digital/open
	open = 1
	icon_state = "map_valve1"

/obj/machinery/atmospherics/binary/valve/digital/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/binary/valve/digital/update_icon()
	..()
	if(!powered())
		icon_state = "valve[open]nopower"

/obj/machinery/atmospherics/binary/valve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/valve/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()
		if("valve_set")
			if(signal.data["valve_set"] == 1)
				if(!open)
					open()
			else
				if(open)
					close()

/obj/machinery/atmospherics/binary/valve/digital/attackby(var/obj/item/W as obj, var/mob/user)
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1
	..()

/obj/machinery/atmospherics/binary/valve/digital/multitool_menu(var/mob/user,var/obj/item/multitool/P)
	return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[ATMOS_VENTSCRUB]">Reset</a>)</li>
			<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
		</ul>
		"}
