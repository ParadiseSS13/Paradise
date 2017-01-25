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

/obj/machinery/atmospherics/binary/pump
	icon = 'icons/atmos/pump.dmi'
	icon_state = "map_off"

	name = "gas pump"
	desc = "A pump"

	can_unwrench = 1

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/pump/highcap
	name = "High capacity gas pump"
	desc = "A high capacity pump"

	target_pressure = 15000000

/obj/machinery/atmospherics/binary/pump/on
	icon_state = "map_on"
	on = 1

/obj/machinery/atmospherics/binary/pump/update_icon()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/pump/process()
	if(!..() || (stat & (NOPOWER|BROKEN)) || !on)
		return 0

	var/output_starting_pressure = air2.return_pressure()

	if( (target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return 1

	//Calculate necessary moles to transfer using PV=nRT
	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = 1

		parent2.update = 1
	return 1

//Radio remote control
/obj/machinery/atmospherics/binary/pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
	return 1

/obj/machinery/atmospherics/binary/pump/interact(mob/user as mob)
	var/dat = {"<b>Power: </b><a href='?src=[UID()];power=1'>[on?"On":"Off"]</a><br>
				<b>Desirable output pressure: </b>
				[round(target_pressure,0.1)]kPa | <a href='?src=[UID()];set_press=1'>Change</a>
				"}

	var/datum/browser/popup = new(user, "atmo_pump", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "atmo_pump")

/obj/machinery/atmospherics/binary/pump/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if(signal.data["power"])
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"])
		on = !on

	if(signal.data["set_output_pressure"])
		target_pressure = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE*50
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
	return

/obj/machinery/atmospherics/binary/pump/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return
	usr.set_machine(src)
	interact(user)
	return

/obj/machinery/atmospherics/binary/pump/Topic(href,href_list)
	if(..())
		return 1
	if(href_list["power"])
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", "atmos")
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
		investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", "atmos")
	usr.set_machine(src)
	src.update_icon()
	src.updateUsrDialog()
	return

/obj/machinery/atmospherics/binary/pump/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/binary/pump/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()