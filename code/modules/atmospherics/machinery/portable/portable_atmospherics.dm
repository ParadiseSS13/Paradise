/obj/machinery/atmospherics/portable
	name = "atmoalter"
	anchored = FALSE
	layer = BELOW_OBJ_LAYER
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 60, ACID = 30)
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/unary/portables_connector/connected_port
	var/obj/item/tank/holding_tank

	var/volume = 0

	var/maximum_pressure = 90 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/portable/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src

	air_contents.volume = volume
	air_contents.set_temperature(T20C)

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	check_for_port()

// Late init this otherwise it shares with the port and it tries to div temperature by 0
/obj/machinery/atmospherics/portable/LateInitialize()
	check_for_port()

/obj/machinery/atmospherics/portable/proc/check_for_port()
	var/obj/machinery/atmospherics/unary/portables_connector/port = locate() in loc
	if(port)
		connect(port)

/obj/machinery/atmospherics/portable/process_atmos()
	if(!connected_port) //only react when pipe_network will ont it do it for you
		//Allow for reactions
		air_contents.react()
		return

/obj/machinery/atmospherics/portable/Destroy()
	SSair.atmos_machinery -= src
	disconnect()
	QDEL_NULL(air_contents)
	QDEL_NULL(holding_tank)
	return ..()

/obj/machinery/atmospherics/portable/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	// To avoid a chicken-egg thing where pipes need to
	// be initialized before the atmos cans are
	if(!connected_port.parent)
		connected_port.build_network()
	connected_port.parent.reconcile_air()

	anchored = TRUE //Prevent movement

	update_icon()

	return TRUE

/obj/machinery/atmospherics/portable/disconnect()
	if(!connected_port)
		return

	anchored = FALSE

	connected_port.connected_device = null
	connected_port = null

	update_icon()

	return TRUE

/obj/machinery/atmospherics/portable/portableConnectorReturnAir()
	return air_contents

/obj/machinery/atmospherics/portable/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(!ishuman(usr) && !issilicon(usr))
		return
	if(holding_tank)
		to_chat(user, "<span class='notice'>You remove [holding_tank] from [src].</span>")
		replace_tank(user, TRUE)

/obj/machinery/atmospherics/portable/examine(mob/user)
	. = ..()
	if(holding_tank)
		. += "<span class='notice'>\The [src] contains [holding_tank]. Alt-click [src] to remove it.</span>"

/obj/machinery/atmospherics/portable/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/portable/proc/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	if(holding_tank)
		holding_tank.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(holding_tank)
	if(new_tank)
		holding_tank = new_tank
	else
		holding_tank = null
	update_icon()
	return TRUE

/obj/machinery/atmospherics/portable/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/tank))
		if(!(stat & BROKEN))
			if(!user.drop_item())
				return ITEM_INTERACT_COMPLETE
			var/obj/item/tank/T = used
			user.drop_item()
			if(holding_tank)
				to_chat(user, "<span class='notice'>[holding_tank ? "In one smooth motion you pop [holding_tank] out of [src]'s connector and replace it with [T]" : "You insert [T] into [src]"].</span>")
				replace_tank(user, FALSE)
			T.loc = src
			holding_tank = T
			update_icon()
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/atmospherics/portable/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(connected_port)
		disconnect()
		to_chat(user, "<span class='notice'>You disconnect [name] from the port.</span>")
		update_icon()
	else
		var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
		if(possible_port)
			if(connect(possible_port))
				on = FALSE
				to_chat(user, "<span class='notice'>You connect [src] to the port.</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>[src] failed to connect to the port.</span>")
				return
		else
			to_chat(user, "<span class='notice'>Nothing happens.</span>")

/obj/machinery/atmospherics/portable/attacked_by(obj/item/attacker, mob/living/user)
	if(attacker.force < 10 && !(stat & BROKEN))
		take_damage(0)
	else
		add_fingerprint(user)
		return ..()
