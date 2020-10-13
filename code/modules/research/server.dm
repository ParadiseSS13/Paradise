/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	/// Current health (heat deteriorates it)
	var/heat_health = 100
	/// Is the server working?
	var/working = TRUE
	/// Base point income
	var/base_income = 2
	/// Heat generation
	var/heat_gen = 100
	/// Heat power
	var/heating_power = 40000
	/// Lowest temperature tolerance (Absolute zero)
	var/temp_tolerance_low = 0
	/// Highest temperature tolerance (Room temperature)
	var/temp_tolerance_high = T20C
	/// Temperature penalty | 1 = -1 points per degree above high tolerance. 0.5 = -0.5 points per degree above high tolerance
	var/temp_penalty_coefficient = 0.5
	/// Do we play ambient noise?
	var/plays_sound = TRUE

/obj/machinery/r_n_d/server/New()
	. = ..()
	SSresearch.servers |= src
	desc += "Its ID screen reads: \ref[src]" // fluff
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)

/obj/machinery/r_n_d/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/r_n_d/server/proc/refresh_working()
	if(stat & EMPED)
		working = FALSE
	else
		working = TRUE

/obj/machinery/r_n_d/server/emp_act()
	stat |= EMPED
	addtimer(CALLBACK(src, .proc/unemp), 600)
	refresh_working()
	return ..()

/obj/machinery/r_n_d/server/proc/unemp()
	stat &= ~EMPED
	refresh_working()

/obj/machinery/r_n_d/server/proc/mine()
	. = base_income
	var/penalty = max((get_env_temp() - temp_tolerance_low), 0) / temp_penalty_coefficient
	. = max(. - penalty, 0)

/obj/machinery/r_n_d/server/proc/get_env_temp()
	var/datum/gas_mixture/environment = loc.return_air()
	return environment.temperature

/obj/machinery/r_n_d/server/proc/produce_heat(heat_amt)
	if(!(stat & (NOPOWER|BROKEN))) //Blatently stolen from space heater.
		var/turf/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt+T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000)

				env.merge(removed)
				air_update_turf()

/obj/machinery/computer/rdservercontrol
	name = "\improper R&D server controller"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdservercontrol
	var/list/servers = list()

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	return

/obj/machinery/computer/rdservercontrol/attack_hand(mob/user as mob)
	// Stick a TGUI here
	return
