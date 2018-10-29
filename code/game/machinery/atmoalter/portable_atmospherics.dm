/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = NO_POWER_USE
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100)
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/unary/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/New()
	..()
	SSair.atmos_machinery += src

	air_contents.volume = volume
	air_contents.temperature = T20C

	return 1

/obj/machinery/portable_atmospherics/Initialize()
	. = ..()
	spawn()
		var/obj/machinery/atmospherics/unary/portables_connector/port = locate() in loc
		if(port)
			connect(port)
			update_icon()

/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) //only react when pipe_network will ont it do it for you
		//Allow for reactions
		air_contents.react()
	else
		update_icon()

/obj/machinery/portable_atmospherics/Destroy()
	SSair.atmos_machinery -= src
	disconnect()
	QDEL_NULL(air_contents)
	QDEL_NULL(holding)
	return ..()

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	// To avoid a chicken-egg thing where pipes need to
	// be initialized before the atmos cans are
	if(!connected_port.parent)
		connected_port.build_network()
	connected_port.parent.reconcile_air()

	anchored = 1 //Prevent movement

	return 1

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return 0

	anchored = 0

	connected_port.connected_device = null
	connected_port = null

	return 1

/obj/machinery/portable_atmospherics/portableConnectorReturnAir()
	return air_contents

/obj/machinery/portable_atmospherics/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	if((istype(W, /obj/item/tank) && !( src.destroyed )))
		if(src.holding)
			return
		var/obj/item/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
		update_icon()
		return

	else if(istype(W, /obj/item/wrench))
		if(connected_port)
			disconnect()
			to_chat(user, "<span class='notice'>You disconnect [name] from the port.</span>")
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					to_chat(user, "<span class='notice'>You connect [name] to the port.</span>")
					update_icon()
					return
				else
					to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
					return
			else
				to_chat(user, "<span class='notice'>Nothing happens.</span>")
				return

	else if((istype(W, /obj/item/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)

	return
