/obj/machinery/atmospherics/binary/passive_gate
	//Tries to achieve target pressure at output (like a normal pump) except
	//	Uses no power but can not transfer gases from a low pressure area to a high pressure area
	icon = 'icons/atmos/passive_gate.dmi'
	icon_state = "map"

	name = "passive gate"
	desc = "A one-way air valve that does not require power"

	can_unwrench = 1

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/passive_gate/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/passive_gate/update_icon()
	icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/passive_gate/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, 180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/passive_gate/process()
	if(!..() || !on)
		return 0

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 KPa difference to overcome friction in the mechanism
		return 1

	//Calculate necessary moles to transfer using PV = nRT
	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = 1

		parent2.update = 1
	return 1

//Radio remote control
/obj/machinery/atmospherics/binary/passive_gate/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/passive_gate/proc/broadcast_status()
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

/obj/machinery/atmospherics/binary/passive_gate/interact(mob/user as mob)
	var/dat = {"<b>Power: </b><a href='?src=[UID()];power=1'>[on?"On":"Off"]</a><br>
				<b>Desirable output pressure: </b>
				[round(target_pressure,0.1)]kPa | <a href='?src=[UID()];set_press=1'>Change</a>
				"}

	var/datum/browser/popup = new(user, "atmo_pump", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "atmo_pump")

/obj/machinery/atmospherics/binary/passive_gate/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		target_pressure = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", "atmos")

	if("status" in signal.data)
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/binary/passive_gate/attack_hand(user as mob)
	if(..())
		return
	src.add_fingerprint(usr)
	if(!src.allowed(user))
		to_chat(user, "<span class='alert'>Access denied.</span>")
		return
	usr.set_machine(src)
	interact(user)
	return

/obj/machinery/atmospherics/binary/passive_gate/Topic(href,href_list)
	if(..()) return
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

/obj/machinery/atmospherics/binary/passive_gate/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [src], turn it off first.</span>")
		return 1
	return ..()
