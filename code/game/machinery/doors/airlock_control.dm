#define AIRLOCK_CONTROL_RANGE 22

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	var/id_tag
	var/shockedby = list()
	var/cur_command = null	//the command the door is currently attempting to complete

// this is an override, in addition to the one in airlock_control.dm
/obj/machinery/door/airlock/Initialize()
	. = ..()
	update_icon()

/obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	layer = ABOVE_WINDOW_LAYER
	name = "airlock sensor"
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	power_channel = ENVIRON

	var/autolink_id
	var/command = "cycle"

	var/on = TRUE
	var/alert = 0
	var/previousPressure

/obj/machinery/airlock_sensor/update_icon_state()
	if(on)
		if(alert)
			icon_state = "airlock_sensor_alert"
		else
			icon_state = "airlock_sensor_standby"
	else
		icon_state = "airlock_sensor_off"

/obj/machinery/airlock_sensor/attack_hand(mob/user)
	#warn todo - make cycle with whatever controller owns it
	/*
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.data["tag"] = master_tag
	signal.data["command"] = command

	radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	*/
	flick("airlock_sensor_cycle", src)

/obj/machinery/airlock_sensor/process()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()
		var/pressure = round(air_sample.return_pressure(),0.1)

		if(abs(pressure - previousPressure) > 0.001 || previousPressure == null)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			//signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time
			signal.data["pressure"] = num2text(pressure)

			#warn todo - just have the controller read this ffs
			//radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			previousPressure = pressure

			alert = (pressure < ONE_ATMOSPHERE*0.8)

			update_icon(UPDATE_ICON_STATE)

/obj/machinery/airlock_sensor/airlock_interior
	command = "cycle_interior"

/obj/machinery/airlock_sensor/airlock_exterior
	command = "cycle_exterior"

/obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "access button"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	power_channel = ENVIRON
	/// UID of the airlock controller that owns us
	var/controller_uid
	/// Id to be used by the controller to grab us on spawn
	var/autolink_id
	var/command = "cycle"
	var/on = TRUE

/obj/machinery/access_button/update_icon_state()
	if(on)
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"

/obj/machinery/access_button/attackby(obj/item/I, mob/user, params)
	//Swiping ID on the access button
	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		attack_hand(user)
		return
	return ..()

/obj/machinery/access_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/access_button/attack_hand(mob/user)
	add_fingerprint(usr)

	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='warning'>Access denied.</span>")

	#warn todo - make these call their owning controller
	/*
	else if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	*/
	flick("access_button_cycle", src)

/obj/machinery/access_button/airlock_interior
	name = "interior access button";
	command = "cycle_interior"

/obj/machinery/access_button/airlock_exterior
	name = "exterior access button";
	command = "cycle_exterior"
