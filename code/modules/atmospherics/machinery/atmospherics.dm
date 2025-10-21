/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network
*/
/obj/machinery/atmospherics
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	power_state = NO_POWER_USE
	power_channel = PW_CHANNEL_ENVIRONMENT
	on_blueprints = TRUE
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 100, ACID = 70)

	layer = GAS_PIPE_HIDDEN_LAYER  //under wires
	var/layer_offset = 0.0 // generic over VISIBLE and HIDDEN, should be less than 0.01, or you'll reorder non-pipe things

	/// Can this be unwrenched?
	var/can_unwrench = FALSE
	/// Can this be put under a tile?
	var/can_be_undertile = FALSE
	/// If the machine is currently operating or not.
	var/on = FALSE
	/// The amount of pressure the machine wants to operate at.
	var/target_pressure = 0


	// Vars below this point are all pipe related
	// I know not all subtypes are pipes, but this helps

	/// Type of pipes this machine can connect to
	var/list/connect_types = list(CONNECT_TYPE_NORMAL)
	/// What this machine is connected to
	var/connected_to = CONNECT_TYPE_NORMAL
	/// Icon suffix for connection, can be "-supply" or "-scrubbers"
	var/icon_connect_type = ""
	/// Directions to initialize in to grab pipes
	var/initialize_directions = 0
	/// Pipe colour, not used for all subtypes
	var/pipe_color
	/// Pipe image, not used for all subtypes
	var/image/pipe_image

	/// ID for automatic linkage of stuff. This is used to assist in connections at mapload. Dont try use it for other stuff
	var/autolink_id = null

	/// Whether or not this can be unwrenched while on.
	var/can_unwrench_while_on = TRUE


/obj/machinery/atmospherics/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src


	if(!pipe_color)
		pipe_color = color

	color = null

	if(!pipe_color_check(pipe_color))
		pipe_color = null

/obj/machinery/atmospherics/proc/process_atmos() //If you dont use process why are you here
	// Any proc that wants MILLA to be synchronous should not sleep.
	SHOULD_NOT_SLEEP(TRUE)
	return PROCESS_KILL

/obj/machinery/atmospherics/proc/atmos_init()
	// Updates all pipe overlays and underlays
	update_underlays()

/obj/machinery/atmospherics/onShuttleMove(turf/oldT, turf/T1, rotation, mob/calling_mob)
	. = ..()
	update_underlays()

/obj/machinery/atmospherics/Destroy()
	SSair.atmos_machinery -= src
	SSair.pipenets_to_build -= src
	for(var/mob/living/L in src) //ventcrawling is serious business
		L.remove_ventcrawl()
		L.forceMove(get_turf(src))
	QDEL_NULL(pipe_image) //we have to qdel it, or it might keep a ref somewhere else
	return ..()

// Icons/overlays/underlays
/obj/machinery/atmospherics/update_icon(updates=ALL)
	if(check_icon_cache())
		..(ALL)
	else
		..(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/update_icon_state()
	switch(level)
		if(1)
			plane = FLOOR_PLANE
			layer = GAS_PIPE_HIDDEN_LAYER + layer_offset
		if(2)
			plane = GAME_PLANE
			layer = GAS_PIPE_VISIBLE_LAYER + layer_offset

/obj/machinery/atmospherics/proc/update_pipe_image(overlay = src)
	pipe_image = image(overlay, loc, layer = ABOVE_HUD_LAYER, dir = dir) //the 20 puts it above Byond's darkness (not its opacity view)
	pipe_image.plane = HUD_PLANE

/obj/machinery/atmospherics/proc/check_icon_cache()
	if(!istype(GLOB.pipe_icon_manager))
		return FALSE

	return TRUE

/obj/machinery/atmospherics/proc/color_cache_name(obj/machinery/atmospherics/node)
	//Don't use this for standard pipes
	if(!istype(node))
		return null

	return node.pipe_color

/obj/machinery/atmospherics/proc/add_underlay(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type)
	if(node)
		if(T.intact && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe) && !T.transparent_floor)
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		if(T.transparent_floor) //we want to keep pipes under transparent floors connected normally
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
		else
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "exposed" + icon_connect_type)

/obj/machinery/atmospherics/proc/update_underlays()
	return check_icon_cache()

// Connect types
/obj/machinery/atmospherics/proc/check_connect_types(obj/machinery/atmospherics/atmos1, obj/machinery/atmospherics/atmos2)
	var/list/list1 = atmos1.connect_types
	var/list/list2 = atmos2.connect_types
	for(var/i in 1 to length(list1))
		for(var/j in 1 to length(list2))
			if(list1[i] == list2[j])
				var/n = list1[i]
				return n
	return 0

/obj/machinery/atmospherics/proc/check_connect_types_construction(obj/machinery/atmospherics/atmos1, obj/item/pipe/pipe2)
	var/list/list1 = atmos1.connect_types
	var/list/list2 = pipe2.connect_types
	for(var/i in 1 to length(list1))
		for(var/j in 1 to length(list2))
			if(list1[i] == list2[j])
				var/n = list1[i]
				return n
	return 0

// Pipenet related functions
/obj/machinery/atmospherics/proc/returnPipenet()
	return

/**
 * Whether or not this atmos machine has multiple pipenets attached to it
 * Used to determine if a ventcrawler should update their vision or not
 */
/obj/machinery/atmospherics/proc/is_pipenet_split()
	return FALSE

/obj/machinery/atmospherics/proc/returnPipenetAir()
	return

/obj/machinery/atmospherics/proc/setPipenet()
	return

/obj/machinery/atmospherics/proc/replacePipenet()
	return

/obj/machinery/atmospherics/proc/build_network(remove_deferral = FALSE)
	// Called to build a network from this node
	if(remove_deferral)
		SSair.pipenets_to_build -= src

/obj/machinery/atmospherics/proc/defer_build_network()
	SSair.pipenets_to_build += src

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	return

/obj/machinery/atmospherics/proc/nullifyPipenet(datum/pipeline/P)
	if(P)
		P.other_atmosmch -= src

/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/wrench/W)
	var/turf/T = get_turf(src)
	if(!can_unwrench_while_on && !(stat & NOPOWER) && on)
		to_chat(user, "<span class='alert'>You cannot unwrench this [name], turn it off first.</span>")
		return TRUE
	if(!can_unwrench)
		return FALSE
	. = TRUE
	if(wrench_floor_check())
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	if(level == 1 && isturf(T) && T.intact)
		to_chat(user, "<span class='danger'>You must remove the plating first.</span>")
		return
	var/datum/gas_mixture/int_air = return_obj_air()
	var/datum/gas_mixture/env_air = T.get_readonly_air()
	add_fingerprint(user)


	var/unsafe_wrenching = FALSE
	var/safefromgusts = FALSE
	var/I = int_air ? int_air.return_pressure() : 0
	var/E = env_air ? env_air.return_pressure() : 0
	var/internal_pressure = I - E

	to_chat(user, "<span class='notice'>You begin to unfasten [src]...</span>")

	if(HAS_TRAIT(user, TRAIT_MAGPULSE))
		safefromgusts = TRUE

	if(internal_pressure > 2 * ONE_ATMOSPHERE)
		unsafe_wrenching = TRUE //Oh dear oh dear
		if(internal_pressure > 1750 && !safefromgusts) // 1750 is the pressure limit to do 60 damage when thrown
			to_chat(user, "<span class='userdanger'>As you struggle to unwrench [src] a huge gust of gas blows in your face! This seems like a terrible idea!</span>")
		else
			to_chat(user, "<span class='warning'>As you begin unwrenching [src] a gust of air blows in your face... maybe you should reconsider?</span>")

	if(!W.use_tool(src, user, 4 SECONDS, volume = 50) || QDELETED(src))
		return

	safefromgusts = FALSE

	if(HAS_TRAIT(user, TRAIT_MAGPULSE))
		safefromgusts = TRUE

	user.visible_message(
		"<span class='notice'>[user] unfastens [src].</span>",
		"<span class='notice'>You have unfastened [src].</span>",
		"<span class='italics'>You hear ratcheting.</span>"
	)
	investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

	//You unwrenched a pipe full of pressure? let's splat you into the wall silly.
	if(unsafe_wrenching)
		if(safefromgusts)
			to_chat(user, "<span class='notice'>Your magboots cling to the floor as a great burst of wind bellows against you.</span>")
		else
			unsafe_pressure_release(user,internal_pressure)
	deconstruct(TRUE)

/**
 * This proc is to tell if an atmospheric device is in a state that should be unwrenchable because its under the floor.
 **/
/obj/machinery/atmospherics/proc/wrench_floor_check()
	return FALSE

//(De)construction
/obj/machinery/atmospherics/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/turf/T = get_turf(src)
	if(T.transparent_floor)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

//Called when an atmospherics object is unwrenched while having a large pressure difference
//with it's locs air contents.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/user, pressures)
	if(!user)
		return

	if(!pressures)
		var/datum/gas_mixture/int_air = return_obj_air()
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env_air = T.get_readonly_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	var/fuck_you_dir = get_dir(src, user)
	if(!fuck_you_dir)
		fuck_you_dir = pick(GLOB.alldirs)

	var/turf/general_direction = get_edge_target_turf(user, fuck_you_dir)
	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")
	//Values based on 2*ONE_ATMOS (the unsafe pressure), resulting in 20 range and 4 speed
	user.throw_at(general_direction, pressures/10, pressures/50)

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(can_unwrench)
			var/obj/item/pipe/stored = new(loc, null, null, src)
			if(!disassembled)
				stored.obj_integrity = stored.max_integrity * 0.5
			transfer_fingerprints_to(stored)
	..()

/obj/machinery/atmospherics/on_construction(D, P, C)
	if(C)
		color = C
	dir = D
	initialize_directions = P
	var/turf/T = loc
	if(!T.transparent_floor)
		level = (T.intact || !can_be_undertile) ? 2 : 1
	else
		level = 2
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(usr)
	if(!SSair.initialized) //If there's no atmos subsystem, we can't really initialize pipenets
		SSair.machinery_to_construct.Add(src)
		return
	initialize_atmos_network()

/obj/machinery/atmospherics/proc/initialize_atmos_network()
	atmos_init()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmos_init()
		A.addMember(src)
	build_network()

// Find a connecting /obj/machinery/atmospherics in specified direction.
/obj/machinery/atmospherics/proc/findConnecting(direction)
	for(var/obj/machinery/atmospherics/target in get_step(src,direction))
		var/can_connect = check_connect_types(target, src)
		if(can_connect && (target.initialize_directions & get_dir(target,src)))
			return target

// Ventcrawling
#define VENT_SOUND_DELAY 30
/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	var/datum/pipeline/current_pipenet = returnPipenet(src)
	direction &= initialize_directions
	if(!direction || !(direction in GLOB.cardinal)) //cant go this way.
		return

	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return

	var/obj/machinery/atmospherics/target_move = findConnecting(direction)
	if(target_move)
		if(is_type_in_list(target_move, GLOB.ventcrawl_machinery) && target_move.can_crawl_through())
			current_pipenet.crawlers -= user
			user.remove_ventcrawl()
			user.forceMove(target_move.loc) //handles entering and so on
			user.visible_message("You hear something squeezing through the ducts.", "You climb out of the ventilation system.")
		else if(target_move.can_crawl_through())
			if(is_pipenet_split()) // Going away from a split means we want to update the view of the pipenet
				user.update_pipe_vision(target_move)
			user.forceMove(target_move)
			if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
				user.last_played_vent = world.time
				playsound(src, 'sound/machines/ventcrawl.ogg', 50, TRUE, -3)
	else
		if((direction & initialize_directions) || is_type_in_list(src, GLOB.ventcrawl_machinery)) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			current_pipenet.crawlers -= user
			user.remove_ventcrawl()
			user.forceMove(loc)
			user.visible_message("You hear something squeezing through the pipes.", "You climb out of the ventilation system.")
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, "ventcrawling")
	spawn(1) // this is awful
		REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, "ventcrawling")

/obj/machinery/atmospherics/AltClick(mob/living/L)
	if(is_type_in_list(src, GLOB.ventcrawl_machinery))
		L.handle_ventcrawl(src)
		return
	..()

/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/extinguish_light(force)
	set_light(0)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/proc/change_color(new_color)
	//only pass valid pipe colors please ~otherwise your pipe will turn invisible
	if(!pipe_color_check(new_color))
		return

	pipe_color = new_color
	update_icon()

// Additional icon procs
/obj/machinery/atmospherics/proc/universal_underlays(obj/machinery/atmospherics/node, direction)
	var/turf/T = get_turf(src)
	if(!istype(T)) return
	if(node)
		var/node_dir = get_dir(src,node)
		if(node.icon_connect_type == "-supply")
			add_underlay_adapter(T, null, node_dir, "")
			add_underlay_adapter(T, node, node_dir, "-supply")
			add_underlay_adapter(T, null, node_dir, "-scrubbers")
		else if(node.icon_connect_type == "-scrubbers")
			add_underlay_adapter(T, null, node_dir, "")
			add_underlay_adapter(T, null, node_dir, "-supply")
			add_underlay_adapter(T, node, node_dir, "-scrubbers")
		else
			add_underlay_adapter(T, node, node_dir, "")
			add_underlay_adapter(T, null, node_dir, "-supply")
			add_underlay_adapter(T, null, node_dir, "-scrubbers")
	else
		add_underlay_adapter(T, null, direction, "-supply")
		add_underlay_adapter(T, null, direction, "-scrubbers")
		add_underlay_adapter(T, null, direction, "")

/obj/machinery/atmospherics/proc/add_underlay_adapter(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type) //modified from add_underlay, does not make exposed underlays
	if(node)
		if(T.intact && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe) && !T.transparent_floor)
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		if(T.transparent_floor) //we want to keep pipes under transparent floors connected normally
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
		else
			underlays += GLOB.pipe_icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "retracted" + icon_connect_type)

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)
	return ..()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)
	. = ..()

//Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE

/**
 * Turns the machine either on, or off. If this is done by a user, display a message to them.
 *
 * NOTE: Only applies to atmospherics machines which can be toggled on or off, such as pumps, or other devices.
 *
 * Arguments:
 * * user - the mob who is toggling the machine.
 */
/obj/machinery/atmospherics/proc/toggle(mob/living/user)
	if(!has_power())
		return
	on = !on
	update_icon()
	if(user)
		to_chat(user, "<span class='notice'>You toggle [src] [on ? "on" : "off"].</span>")

/**
 * Maxes the output pressure of the machine. If this is done by a user, display a message to them.
 *
 * NOTE: Only applies to atmospherics machines which allow a `target_pressure` to be set, such as pumps, or other devices.
 *
 * Arguments:
 * * user - the mob who is setting the output pressure to maximum.
 */
/obj/machinery/atmospherics/proc/set_max(mob/living/user)
	if(!has_power())
		return
	target_pressure = MAX_OUTPUT_PRESSURE
	update_icon()
	if(user)
		to_chat(user, "<span class='notice'>You set the target pressure of [src] to maximum.</span>")

/obj/machinery/atmospherics/proc/get_machinery_pipelines()
	return list()

#undef VENT_SOUND_DELAY
