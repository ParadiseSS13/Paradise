#define TVALVE_STATE_STRAIGHT 0
#define TVALVE_STATE_SIDE 1

/obj/machinery/atmospherics/trinary/tvalve
	icon = 'icons/atmos/tvalve.dmi'
	icon_state = "map_tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve"
	
	can_unwrench = 1

	level = 1

	var/state = TVALVE_STATE_STRAIGHT

/obj/machinery/atmospherics/trinary/tvalve/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE
	
/obj/machinery/atmospherics/trinary/tvalve/update_icon(animation)
	if(animation)
		flick("tvalve[src.state][!src.state]",src)
	else
		icon_state = "tvalve[state]"

/obj/machinery/atmospherics/trinary/tvalve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))

		add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)
			
/obj/machinery/atmospherics/trinary/tvalve/proc/switch_side()
	if(state == TVALVE_STATE_STRAIGHT)
		src.go_to_side()
	else
		src.go_straight()

/obj/machinery/atmospherics/trinary/tvalve/proc/go_to_side()
	if(state == TVALVE_STATE_SIDE) 
		return 0

	state = TVALVE_STATE_SIDE
	update_icon()

	parent1.update = 0
	parent2.update = 0
	parent3.update = 0
	parent3.reconcile_air()

	investigate_log("was set to side by [usr ? key_name(usr) : "a remote signal"]", "atmos")
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
	
	investigate_log("was set to straight by [usr ? key_name(usr) : "a remote signal"]", "atmos")
	return 1

/obj/machinery/atmospherics/trinary/tvalve/attack_ai(mob/user as mob)
	return

/obj/machinery/atmospherics/trinary/tvalve/attack_hand(mob/user as mob)
	add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	switch_side()

/obj/machinery/atmospherics/trinary/tvalve/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_tvalve.dmi'

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/trinary/tvalve/digital/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/digital/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/tvalve/digital/update_icon()
	..()
	if(!powered())
		icon_state = "tvalvenopower"

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_hand(mob/user as mob)
	if(!powered())
		return
	if(!src.allowed(user))
		user << "<span class='alert'>Access denied.</span>"
		return
	..()

//Radio remote control
/obj/machinery/atmospherics/trinary/tvalve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/tvalve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/trinary/tvalve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return 0

	switch(signal.data["command"])
		if("valve_open")
			go_to_side()

		if("valve_close")
			go_straight()

		if("valve_toggle")
			switch_side()

#undef TVALVE_STATE_STRAIGHT
#undef TVALVE_STATE_SIDE