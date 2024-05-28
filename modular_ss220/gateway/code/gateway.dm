/* Now you can click through gateways while observing. */
/obj/machinery/gateway/centerstation/attack_ghost(mob/user as mob)
	if(awaygate)
		user.forceMove(awaygate.loc)
	else
		to_chat(user, "[src] не имеет пункта назначения.")

/obj/machinery/gateway/centeraway/attack_ghost(mob/user as mob)
	if(stationgate)
		user.forceMove(stationgate.loc)
	else

		to_chat(user, "[src] не имеет пункта назначения.")

GLOBAL_DATUM_INIT(the_gateway, /obj/machinery/gateway/centerstation, null)
/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_2 = NO_MALF_EFFECT_2
	var/active = FALSE

/obj/machinery/gateway/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	update_density_from_dir()

/obj/machinery/gateway/proc/update_density_from_dir()
	if(dir in list(SOUTH, SOUTHEAST, SOUTHWEST))
		density = FALSE

/obj/machinery/gateway/update_icon_state()
	icon_state = active ? "on" : "off"


// This is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = TRUE
	icon_state = "offcenter"
	power_state = IDLE_POWER_USE


	// Warping vars
	var/list/linked = list()
	var/ready = FALSE				// Have we got all the parts for a gateway?
	var/obj/machinery/gateway/centeraway/awaygate = null

/obj/machinery/gateway/centerstation/Initialize(mapload)
	. = ..()
	if(!GLOB.the_gateway)
		GLOB.the_gateway = src

	update_icon(UPDATE_ICON_STATE)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/gateway/centerstation/LateInitialize()
	awaygate = locate(/obj/machinery/gateway/centeraway) in GLOB.machines

/obj/machinery/gateway/centerstation/update_density_from_dir()
	return

/obj/machinery/gateway/centerstation/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	return ..()

/obj/machinery/gateway/centerstation/update_icon_state()
	icon_state = active ? "oncenter" : "offcenter"


/obj/machinery/gateway/centerstation/process()
	if(stat & (NOPOWER))
		if(active) toggleoff()
		return

	if(active)
		use_power(5000)


/obj/machinery/gateway/centerstation/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		// This is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if(linked.len == 8)
		ready = TRUE


/obj/machinery/gateway/centerstation/proc/toggleon(mob/user as mob)
	if(!ready)
		return
	if(linked.len != 8)
		return
	if(!has_power())
		return
	if(!awaygate)
		awaygate = locate(/obj/machinery/gateway/centeraway) in GLOB.machines
		if(!awaygate)
			to_chat(user, span_notice("Error: No destination found."))
			return
	var/wait = GLOB.configuration.gateway.away_mission_delay + SSticker.round_start_time
	if(wait > world.time)
		to_chat(user, span_notice("Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes."))
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon(UPDATE_ICON_STATE)
	active = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon(UPDATE_ICON_STATE)
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centerstation/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


// Okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/M as mob|obj)
	if(!ready)
		return
	if(!active)
		return
	if(!awaygate)
		return

	if(awaygate.calibrated)
		M.forceMove(get_step(awaygate.loc, SOUTH))
		M.dir = SOUTH
		return
	else
		var/obj/effect/landmark/dest = pick(GLOB.awaydestinations)
		if(dest)
			M.forceMove(dest.loc)
			M.dir = SOUTH
			use_power(5000)
		return


/obj/machinery/gateway/centerstation/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/multitool))
		to_chat(user, "The gate is already calibrated, there is no work for you to do here.")
		return
	return ..()

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = TRUE
	icon_state = "offcenter"
	power_state = NO_POWER_USE

	var/calibrated = TRUE
	var/list/linked = list()	// A list of the connected gateway chunks
	var/ready = FALSE
	var/obj/machinery/gateway/centeraway/stationgate = null


/obj/machinery/gateway/centeraway/Initialize()
	..()
	update_icon(UPDATE_ICON_STATE)
	stationgate = locate(/obj/machinery/gateway/centerstation) in GLOB.machines


/obj/machinery/gateway/centeraway/update_density_from_dir()
	return

/obj/machinery/gateway/centeraway/update_icon_state()
	icon_state = active ? "oncenter" : "offcenter"


/obj/machinery/gateway/centeraway/proc/detect()
	linked.Cut()
	var/turf/T = loc

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		// This is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if(length(linked) == 8)
		ready = TRUE


/obj/machinery/gateway/centeraway/proc/toggleon(mob/user as mob)
	if(!ready)
		return
	if(length(linked) != 8)
		return
	if(!stationgate)
		stationgate = locate(/obj/machinery/gateway/centerstation) in GLOB.machines
		if(!stationgate)
			to_chat(user, span_notice("Error: No destination found."))
			return

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon(UPDATE_ICON_STATE)
	active = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon(UPDATE_ICON_STATE)
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centeraway/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


/obj/machinery/gateway/centeraway/Bumped(atom/movable/AM)
	if(!ready)
		return
	if(!active)
		return
	if(!stationgate || QDELETED(stationgate))
		return
	if(isliving(AM))
		if(exilecheck(AM))
			return
	else
		for(var/mob/living/L in AM.contents)
			if(exilecheck(L))
				atom_say("Rejecting [AM]: Exile bio-chip detected in contained lifeform.")
				return
	if(AM.has_buckled_mobs())
		for(var/mob/living/L in AM.buckled_mobs)
			if(exilecheck(L))
				atom_say("Rejecting [AM]: Exile bio-chip detected in close proximity lifeform.")
				return
	AM.forceMove(get_step(stationgate.loc, SOUTH))
	AM.setDir(SOUTH)
	if(ismob(AM))
		var/mob/M = AM
		if(M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)

/obj/machinery/gateway/centeraway/proc/exilecheck(mob/living/carbon/M)
	for(var/obj/item/bio_chip/exile/E in M) // Checking that there is an exile bio-chip in the contents
		if(E.imp_in == M) // Checking that it's actually implanted vs just in their pocket
			to_chat(M, span_notice("The station gate has detected your exile bio-chip and is blocking your entry."))
			return TRUE
	return FALSE

/obj/machinery/gateway/centeraway/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/multitool))
		if(calibrated)
			to_chat(user, span_notice("The gate is already calibrated, there is no work for you to do here."))
			return
		else
			to_chat(user, span_boldannounce("Recalibration successful!") + span_notice(": This gate's systems have been fine tuned.  Travel to this gate will now be on target."))
			calibrated = TRUE
		return
	return ..()
