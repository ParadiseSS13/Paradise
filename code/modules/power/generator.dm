/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 0
	density = 1
	use_power = NO_POWER_USE

	var/obj/machinery/atmospherics/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/binary/circulator/hot_circ

	var/cold_dir = WEST
	var/hot_dir = EAST

	var/lastgen = 0
	var/lastgenlev = -1
	var/lastcirc = "00"

/obj/machinery/power/generator/New()
	..()
	update_desc()

/obj/machinery/power/generator/proc/update_desc()
	desc = initial(desc) + " Its cold circulator is located on the [dir2text(cold_dir)] side, and its heat circulator is located on the [dir2text(hot_dir)] side."

/obj/machinery/power/generator/Destroy()
	disconnect()
	return ..()

/obj/machinery/power/generator/proc/disconnect()
	if(cold_circ)
		cold_circ.generator = null
	if(hot_circ)
		hot_circ.generator = null
	if(powernet)
		disconnect_from_network()

/obj/machinery/power/generator/Initialize()
	..()
	connect()

/obj/machinery/power/generator/proc/connect()
	connect_to_network()

	var/obj/machinery/atmospherics/binary/circulator/circpath = /obj/machinery/atmospherics/binary/circulator
	cold_circ = locate(circpath) in get_step(src, cold_dir)
	hot_circ = locate(circpath) in get_step(src, hot_dir)

	if(cold_circ && cold_circ.side == cold_dir)
		cold_circ.generator = src
		cold_circ.update_icon()
	else
		cold_circ = null

	if(hot_circ && hot_circ.side == hot_dir)
		hot_circ.generator = src
		hot_circ.update_icon()
	else
		hot_circ = null

	power_change()
	update_icon()
	updateDialog()

/obj/machinery/power/generator/power_change()
	if(!anchored)
		stat |= NOPOWER
	else
		..()

/obj/machinery/power/generator/update_icon()
	if(stat & (NOPOWER|BROKEN))
		overlays.Cut()
	else
		overlays.Cut()

		if(lastgenlev != 0)
			overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")

		overlays += image('icons/obj/power.dmi', "teg-oc[lastcirc]")

/obj/machinery/power/generator/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(!cold_circ || !hot_circ)
		return

	lastgen = 0

	if(powernet)

		//log_debug("cold_circ and hot_circ pass")

		var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()
		var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()

		//log_debug("hot_air = [hot_air]; cold_air = [cold_air];")

		if(cold_air && hot_air)

			//log_debug("hot_air = [hot_air] temperature = [hot_air.temperature]; cold_air = [cold_air] temperature = [hot_air.temperature];")

			//log_debug("coldair and hotair pass")
			var/cold_air_heat_capacity = cold_air.heat_capacity()
			var/hot_air_heat_capacity = hot_air.heat_capacity()

			var/delta_temperature = hot_air.temperature - cold_air.temperature

			//log_debug("delta_temperature = [delta_temperature]; cold_air_heat_capacity = [cold_air_heat_capacity]; hot_air_heat_capacity = [hot_air_heat_capacity]")

			if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
				var/efficiency = 0.65

				var/energy_transfer = delta_temperature * hot_air_heat_capacity * cold_air_heat_capacity / (hot_air_heat_capacity + cold_air_heat_capacity)

				var/heat = energy_transfer * (1 - efficiency)
				lastgen = energy_transfer * efficiency

				//log_debug("lastgen = [lastgen]; heat = [heat]; delta_temperature = [delta_temperature]; hot_air_heat_capacity = [hot_air_heat_capacity]; cold_air_heat_capacity = [cold_air_heat_capacity];")

				hot_air.temperature = hot_air.temperature - energy_transfer / hot_air_heat_capacity
				cold_air.temperature = cold_air.temperature + heat / cold_air_heat_capacity

				//log_debug("POWER: [lastgen] W generated at [efficiency * 100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]")

				add_avail(lastgen)
		// update icon overlays only if displayed level has changed

		if(hot_air)
			var/datum/gas_mixture/hot_circ_air1 = hot_circ.get_outlet_air()
			hot_circ_air1.merge(hot_air)

		if(cold_air)
			var/datum/gas_mixture/cold_circ_air1 = cold_circ.get_outlet_air()
			cold_circ_air1.merge(cold_air)

	var/genlev = max(0, min( round(11 * lastgen / 100000), 11))
	var/circ = "[cold_circ && cold_circ.last_pressure_delta > 0 ? "1" : "0"][hot_circ && hot_circ.last_pressure_delta > 0 ? "1" : "0"]"
	if((genlev != lastgenlev) || (circ != lastcirc))
		lastgenlev = genlev
		lastcirc = circ
		update_icon()

	updateDialog()

/obj/machinery/power/generator/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/generator/attack_ghost(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	interact(user)

/obj/machinery/power/generator/attack_hand(mob/user)
	if(..())
		user << browse(null, "window=teg")
		return
	interact(user)

/obj/machinery/power/generator/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/wrench))
		anchored = !anchored
		if(!anchored)
			disconnect()
			power_change()
		else
			connect()
		playsound(loc, W.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.</span>")
	else if(ismultitool(W))
		if(cold_dir == WEST)
			cold_dir = EAST
			hot_dir = WEST
		else if(cold_dir == NORTH)
			cold_dir = SOUTH
			hot_dir = NORTH
		else if(cold_dir == EAST)
			cold_dir = WEST
			hot_dir = EAST
		else
			cold_dir = NORTH
			hot_dir = SOUTH
		connect()
		to_chat(user, "<span class='notice'>You reverse the generator's circulator settings. The cold circulator is now on the [dir2text(cold_dir)] side, and the heat circulator is now on the [dir2text(hot_dir)] side.</span>")
		update_desc()
	else
		..()

/obj/machinery/power/generator/proc/get_menu(include_link = 1)
	var/t = ""
	if(!powernet)
		t += "<span class='bad'>Unable to connect to the power network!</span>"
		t += "<BR><A href='?src=[UID()];check=1'>Retry</A>"
	else if(cold_circ && hot_circ)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.get_outlet_air()
		var/datum/gas_mixture/cold_circ_air2 = cold_circ.get_inlet_air()
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.get_outlet_air()
		var/datum/gas_mixture/hot_circ_air2 = hot_circ.get_inlet_air()

		t += "<div class='statusDisplay'>"

		t += "Output: [round(lastgen)] W"

		t += "<BR>"

		t += "<B><font color='blue'>Cold loop</font></B><BR>"
		t += "Temperature Inlet: [round(cold_circ_air2.temperature, 0.1)] K / Outlet: [round(cold_circ_air1.temperature, 0.1)] K<BR>"
		t += "Pressure Inlet: [round(cold_circ_air2.return_pressure(), 0.1)] kPa /  Outlet: [round(cold_circ_air1.return_pressure(), 0.1)] kPa<BR>"

		t += "<B><font color='red'>Hot loop</font></B><BR>"
		t += "Temperature Inlet: [round(hot_circ_air2.temperature, 0.1)] K / Outlet: [round(hot_circ_air1.temperature, 0.1)] K<BR>"
		t += "Pressure Inlet: [round(hot_circ_air2.return_pressure(), 0.1)] kPa / Outlet: [round(hot_circ_air1.return_pressure(), 0.1)] kPa<BR>"

		t += "</div>"
	else
		t += "<span class='bad'>Unable to locate all parts!</span>"
		t += "<BR><A href='?src=[UID()];check=1'>Retry</A>"
	if(include_link)
		t += "<BR><A href='?src=[UID()];close=1'>Close</A>"

	return t

/obj/machinery/power/generator/interact(mob/user)
	user.set_machine(src)

	var/datum/browser/popup = new(user, "teg", "Thermo-Electric Generator", 460, 300)
	popup.set_content(get_menu())
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return 1

/obj/machinery/power/generator/Topic(href, href_list)
	if(..())
		return 0
	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.unset_machine()
		return 0
	if( href_list["check"] )
		if(!powernet || !cold_circ || !hot_circ)
			connect()
	return 1

/obj/machinery/power/generator/power_change()
	..()
	update_icon()
