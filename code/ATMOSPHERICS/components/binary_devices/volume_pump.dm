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

/obj/machinery/atmospherics/binary/volume_pump/on
	on = 1
	icon_state = "map_on"

/obj/machinery/atmospherics/binary/volume_pump/initialize()
	..()
	set_frequency(frequency)

/obj/machinery/atmospherics/binary/volume_pump/update_icon()
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

/obj/machinery/atmospherics/binary/volume_pump/process()
	if(!..() || (stat & (NOPOWER|BROKEN)) || !on)
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
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

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

/obj/machinery/atmospherics/binary/volume_pump/interact(mob/user as mob)
	var/dat = {"<b>Power: </b><a href='?src=[UID()];power=1'>[on?"On":"Off"]</a><br>
				<b>Desirable output flow: </b>
				[round(transfer_rate,1)]l/s | <a href='?src=[UID()];set_transfer_rate=1'>Change</a>
				"}

	var/datum/browser/popup = new(user, "atmo_pump", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "atmo_pump")


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

/obj/machinery/atmospherics/binary/volume_pump/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return
	usr.set_machine(src)
	interact(user)
	return

/obj/machinery/atmospherics/binary/volume_pump/Topic(href,href_list)
	if(..())
		return 1
	if(href_list["power"])
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
	if(href_list["set_transfer_rate"])
		var/new_transfer_rate = input(usr,"Enter new output volume (0-200l/s)","Flow control",src.transfer_rate) as num
		src.transfer_rate = max(0, min(200, new_transfer_rate))
		investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", "atmos")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/binary/volume_pump/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/binary/volume_pump/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()