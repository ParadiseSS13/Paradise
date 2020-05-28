/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/binary/volume_pump
	icon = 'icons/atmos/volume_pump.dmi'
	icon_state = "map_off"

	name = "volumetric gas pump"
	desc = "A volumetric pump"

	can_unwrench = 1

	var/on = 0
	var/transfer_rate = 200

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/volume_pump/CtrlClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user) && !issilicon(usr))
		return
	if(!ishuman(usr) && !issilicon(usr))
		return
	toggle()
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user) && !issilicon(usr))
		return
	if(!ishuman(usr) && !issilicon(usr))
		return
	set_max()
	return

/obj/machinery/atmospherics/binary/volume_pump/AIAltClick()
	set_max()
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/proc/toggle()
	if(powered())
		on = !on
		update_icon()

/obj/machinery/atmospherics/binary/volume_pump/proc/set_max()
	if(powered())
		transfer_rate = MAX_TRANSFER_RATE
		update_icon()

/obj/machinery/atmospherics/binary/volume_pump/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/on
	on = 1
	icon_state = "map_on"

/obj/machinery/atmospherics/binary/volume_pump/atmos_init()
	..()
	set_frequency(frequency)

/obj/machinery/atmospherics/binary/volume_pump/update_icon()
	..()

	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/volume_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/volume_pump/process_atmos()
	..()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return 0

	// Pump mechanism just won't do anything if the pressure is too high/too low
	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || (output_starting_pressure > 9000))
		return 1

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)


	parent1.update = 1
	parent2.update = 1

	return 1

/obj/machinery/atmospherics/binary/volume_pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency)

/obj/machinery/atmospherics/binary/volume_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "APV",
		"power" = on,
		"transfer_rate" = transfer_rate,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/binary/volume_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if(signal.data["power"])
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"])
		on = !on

	if(signal.data["set_transfer_rate"])
		transfer_rate = between(
			0,
			text2num(signal.data["set_transfer_rate"]),
			air1.volume
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", "atmos")

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()

/obj/machinery/atmospherics/binary/volume_pump/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, var/master_ui = null, var/datum/topic_state/state = GLOB.default_state)
	user.set_machine(src)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_pump.tmpl", name, 310, 115, state = state)
		ui.open()

/obj/machinery/atmospherics/binary/volume_pump/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["rate"] = round(transfer_rate)
	data["max_rate"] = round(MAX_TRANSFER_RATE)
	return data

/obj/machinery/atmospherics/binary/volume_pump/Topic(href,href_list)
	if(..())
		return 1

	if(href_list["power"])
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
		. = TRUE
	if(href_list["rate"])
		var/rate = href_list["rate"]
		if(rate == "max")
			rate = MAX_TRANSFER_RATE
			. = TRUE
		else if(rate == "input")
			rate = input("New transfer rate (0-[MAX_TRANSFER_RATE] L/s):", name, transfer_rate) as num|null
			if(!isnull(rate))
				. = TRUE
		else if(text2num(rate) != null)
			rate = text2num(rate)
			. = TRUE
		if(.)
			transfer_rate = Clamp(rate, 0, MAX_TRANSFER_RATE)
			investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", "atmos")

	update_icon()
	SSnanoui.update_uis(src)

/obj/machinery/atmospherics/binary/volume_pump/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/binary/volume_pump/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		var/t = copytext(stripped_input(user, "Enter the name for the volume pump.", "Rename", name), 1, MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		name = t
		return
	else if(!istype(W, /obj/item/wrench))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()
