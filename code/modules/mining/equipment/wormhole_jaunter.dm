// the stuff used for wormhole weaver
GLOBAL_LIST_EMPTY(wormhole_effect)

/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to bluespace for more accurate teleportation. \
		The wormholes it creates are unpleasant to travel through, to say the least. If attached to your belt, it'll automatically activate should you fall into a chasm."
	icon_state = "Jaunter"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = ITEM_SLOT_BELT

/obj/item/wormhole_jaunter/attack_self__legacy__attackchain(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [name]!</span>")
	activate(user, TRUE)

/obj/item/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	var/area/our_area = get_area(device_turf)
	if(!device_turf || !is_teleport_allowed(device_turf.z) || our_area.tele_proof)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	for(var/obj/item/beacon/B in GLOB.beacons)
		var/turf/T = get_turf(B)
		if(is_station_level(T.z))
			destinations += B

	return destinations

/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!length(L))
		to_chat(user, "<span class='notice'>[src] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/jaunt_tunnel/J = new(get_turf(src), chosen_beacon, src, 100, user)
	J.emagged = emagged
	if(adjacent)
		try_move_adjacent(J)
	else
		J.teleport(user)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		to_chat(user, "Your [name] activates, saving you from the chasm!</span>")
		activate(user, FALSE)
	else
		to_chat(user, "[src] is not attached to your belt, preventing it from saving you from the chasm. RIP.</span>")

/obj/item/wormhole_jaunter/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You emag [src].</span>")
		var/turf/T = get_turf(src)
		do_sparks(5, FALSE, T)
		playsound(T, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/jaunt_tunnel/can_teleport(atom/movable/M)
	if(!emagged && ismegafauna(M))
		return FALSE
	return ..()

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M)
	. = ..()
	if(.)
		// KERPLUNK
		playsound(M,'sound/weapons/resonator_blast.ogg', 50, 1)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			L.KnockDown(12 SECONDS)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living/carbon, vomit)), 20)

/obj/item/wormhole_jaunter/contractor
	name = "emergency extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use extraction flare that will let you create a portal to any beacon on the station. You must choose the destination beforehand, else it will target a random beacon. The portal is generated 5 seconds after activation, and has 1 use."
	icon_state = "flare-contractor"
	inhand_icon_state = "flare"
	var/destination

/obj/item/wormhole_jaunter/contractor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to change its destination!</span>"

/obj/item/wormhole_jaunter/contractor/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/beacon/R in GLOB.beacons)
		var/turf/T = get_turf(R)
		if(!T)
			continue
		if(!is_teleport_allowed(T.z))
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	var/desc = tgui_input_list(user, "Please select a location to target.", "Flare Target Interface", L)
	if(!desc)
		return
	destination = L[desc]

/obj/item/wormhole_jaunter/contractor/attack_self__legacy__attackchain(mob/user) // message is later down
	activate(user, TRUE)

/obj/item/wormhole_jaunter/contractor/activate(mob/user)
	if(!turf_check(user))
		return
	if(istype(get_area(src), /area/ruin/space/telecomms)) //It should work in the depot, because it's syndicate, but I don't want someone lighting the flare in the middle of telecomms and calling it a day.
		to_chat(user, "<span class='warning'>Error! Unknown jamming system blocking teleportation in this area!</span>")
		return
	if(!destination)
		var/list/L = get_destinations(user)
		if(!length(L))
			to_chat(user, "<span class='warning'>[src] found no beacons in the sector to target.</span>")
			return
		destination = pick(L)
	var/obj/effect/temp_visual/getaway_flare/F = new(get_turf(src))
	user.visible_message("<span class='notice'>[user] pulls out a black and gold flare and lights it.</span>",\
						"<span class='notice'>You light an emergency extraction flare, initiating the extraction process.</span>")
	user.drop_item()
	forceMove(F)
	addtimer(CALLBACK(src, PROC_REF(create_portal), destination), 5 SECONDS)

/obj/item/wormhole_jaunter/contractor/proc/create_portal(turf/destination)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	new /obj/effect/portal/advanced/getaway(get_turf(src), get_turf(destination), src, 100)
	qdel(src)

/obj/item/wormhole_jaunter/contractor/emag_act(mob/user)
	to_chat(user, "<span class='warning'>Emagging [src] has no effect.</span>")

/obj/item/wormhole_jaunter/contractor/chasm_react(mob/user)
	return //This is not an instant getaway portal like the jaunter

/obj/item/storage/box/syndie_kit/escape_flare
	name = "emergency extraction kit"

/obj/item/storage/box/syndie_kit/escape_flare/populate_contents()
	new /obj/item/wormhole_jaunter/contractor(src)
	new /obj/item/beacon/emagged(src)

/obj/effect/portal/advanced/getaway
	one_use = TRUE

/// Because the original contractor flare is not a temp visual, for some reason.
/obj/effect/temp_visual/getaway_flare
	name = "contractor extraction flare"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"
	duration = 5.1 SECONDS // Needs to be slightly longer then the callback to make the portal

/obj/effect/temp_visual/getaway_flare/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, TRUE)
	set_light(8, l_color = "#FFD165")

/obj/item/grenade/jaunter_grenade
	name = "chasm jaunter recovery grenade"
	desc = "NT-Drunk Dialer Grenade. Originally built by NT for locating all beacons in an area and creating wormholes to them, it now finds use to miners for recovering allies from chasms."
	icon_state = "mirage"
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/jaunter_grenade/Destroy()
	thrower = null
	return ..()

/obj/item/grenade/jaunter_grenade/attack_self__legacy__attackchain(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/jaunter_grenade/prime()
	var/area/our_area = get_area(src)
	var/turf/T = get_turf(src)
	if(!is_teleport_allowed(T.z) || our_area.tele_proof)
		do_sparks(5, 0, T)
		qdel(src)
		return
	update_mob()
	var/list/destinations = list()
	for(var/obj/item/beacon/B in GLOB.beacons)
		var/turf/BT = get_turf(B)
		if(is_station_level(BT.z))
			destinations += BT
	if(istype(T, /turf/simulated/floor/chasm/straight_down/lava_land_surface))
		for(var/obj/effect/abstract/chasm_storage/C in T)
			var/found_mob = FALSE
			for(var/mob/M in C)
				found_mob = TRUE
				do_teleport(M, pick(destinations))
			if(found_mob)
				new /obj/effect/temp_visual/thunderbolt(T) //Visual feedback it worked.
				playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
		qdel(src)
		return

	var/list/portal_turfs = list()
	for(var/turf/PT in circleviewturfs(T, 3))
		if(!PT.density)
			portal_turfs += PT
	playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	for(var/turf/drunk_dial in shuffle(destinations))
		var/drunken_opening = pick_n_take(portal_turfs)
		new /obj/effect/portal/jaunt_tunnel(drunken_opening, drunk_dial, src, 100, thrower)
		new /obj/effect/temp_visual/thunderbolt(drunken_opening)
	qdel(src)

/obj/item/wormhole_jaunter/wormhole_weaver
	name = "wormhole weaver"
	icon = 'icons/obj/device.dmi'
	icon_state = "wormhole_weaver"
	desc = "This peculiar device is a prototype from a discontinued project. It was designed as an alternative to jaunters, offering more precise teleportation. However, as a prototype, it drains its entire battery with a single wormhole and can only target the beacons included in the kit."
	/// Where are we teleporting to?
	var/destination
	/// Power cell (10000W).
	var/obj/item/stock_parts/cell/high/wcell = null
	/// The amount it costs to use this.
	var/chargecost = 10000
	var/icon_state_inactive = "wormhole_weaver_inactive"
	/// Used for icon update check.
	var/inactive = FALSE
	/// Is user re-activating the device?
	var/currently_reactivating = FALSE
	/// Does the user already have the teleportation menu open?
	var/menu_open = FALSE
	/// Did we get hit by EMP?
	var/emp_inflicted = FALSE
	/// The turf where we activated the wormwhole.
	var/wormhole_loc

/obj/item/wormhole_jaunter/wormhole_weaver/attack_self__legacy__attackchain(mob/user)
	activate(user, TRUE)

/obj/item/wormhole_jaunter/wormhole_weaver/emp_act(severity)

	if(!emp_inflicted)
		playsound(loc, 'sound/machines/shut_down.ogg', 50, TRUE)
		visible_message("<span class='warning'>A malfunction detected in the weaver's subsystems. Initiating safety protocols.</span>")
	emp_inflicted = TRUE
	inactive = TRUE
	icon_state = icon_state_inactive
	for(var/obj/O in contents)
		O.emp_act(severity)
	for(var/obj/effect/temp_visual/thunderbolt_targeting/wormhole_weaver/E in GLOB.wormhole_effect)
		if(E)
			qdel(E)
			visible_message("<span class='warning'>Wormhole marker disappears!</span>")
			do_sparks(5, FALSE, wormhole_loc)

/obj/item/wormhole_jaunter/wormhole_weaver/proc/prepare_foractivation(mob/user)
	if(do_after(user, 3 SECONDS, target = src))
		playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
		to_chat(user, "<span class='notice'>The weaver is now ready for use.</span>")
		inactive = FALSE
		emp_inflicted = FALSE
		currently_reactivating = FALSE
		icon_state = initial(icon_state)
	else
		currently_reactivating = FALSE

/obj/item/wormhole_jaunter/wormhole_weaver/get_destinations(mob/user)
	var/list/destinations = list()

	for(var/obj/item/beacon/B in GLOB.beacons)
		if(B.wormhole_weaver)
			destinations += B

	return destinations

/obj/item/wormhole_jaunter/wormhole_weaver/activate(mob/user)
	if(wcell.charge < chargecost)
		to_chat(user, "<span class='warning'>Device isn't charged enough to be used at this time.</span>")
		return

	if(inactive || emp_inflicted)
		if(currently_reactivating)
			to_chat(user, "<span class='warning'>You are already reactivating the device!</span>")
			return
		currently_reactivating = TRUE
		prepare_foractivation(user)
		return

	var/list/C = get_destinations(user)
	if(!length(C))
		to_chat(user, "<span class='notice'>[src] found no beacons in the world to anchor a wormhole to.</span>")
		return

	if(menu_open)
		return

	var/list/L = list()
	var/list/areaindex = list()
	menu_open = TRUE

	for(var/obj/item/beacon/R in GLOB.beacons)
		var/turf/T = get_turf(R)
		if(!T)
			continue
		if(!R.wormhole_weaver)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	var/desc = tgui_input_list(user, "Please select a location to target.", "Device Target Interface", L)
	if(!desc)
		menu_open = FALSE
		return

	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !turf_check(user) || !Adjacent(user))
		menu_open = FALSE
		return

	wormhole_loc = get_turf(src)
	new /obj/effect/temp_visual/thunderbolt_targeting/wormhole_weaver(wormhole_loc)
	destination = L[desc]
	user.visible_message(
			"<span class='notice'>[user] pulls out a black colored device and points it to the floor.</span>",
			"<span class='notice'>You activate the wormhole weaver, it will take some time until device assembles a wormhole link.</span>"
	)
	wcell.use(chargecost)
	icon_state = icon_state_inactive
	inactive = TRUE
	menu_open = FALSE

	addtimer(CALLBACK(src, PROC_REF(post_activate)), 5 SECONDS)

/obj/item/wormhole_jaunter/wormhole_weaver/proc/post_activate()
	if(emp_inflicted)
		return

	create_wormhole(wormhole_loc, destination)

/obj/item/wormhole_jaunter/wormhole_weaver/proc/create_wormhole(used_turf, turf/destination)
	new /obj/effect/portal/jaunt_tunnel(used_turf, get_turf(destination), src, 100)
	do_sparks(5, FALSE, used_turf)

// overridden because we don't need this
/obj/item/wormhole_jaunter/wormhole_weaver/chasm_react(mob/user)
	return

/obj/item/wormhole_jaunter/wormhole_weaver/emag_act(mob/user)
	to_chat(user, "<span class='warning'>Emagging [src] has no effect.</span>")

/obj/effect/temp_visual/thunderbolt_targeting/wormhole_weaver
	duration = 5 SECONDS

/obj/effect/temp_visual/thunderbolt_targeting/wormhole_weaver/Initialize(mapload)
	. = ..()
	GLOB.wormhole_effect += src
	playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
	set_light(2, l_color = "#FFD165")

/obj/effect/temp_visual/thunderbolt_targeting/wormhole_weaver/Destroy()
	GLOB.wormhole_effect -= src
	return ..()

// below here is recharge code for wormhole weaver, taken from rcs code
/obj/item/wormhole_jaunter/wormhole_weaver/get_cell()
	return wcell

/obj/item/wormhole_jaunter/wormhole_weaver/New()
	..()
	wcell = new(src)

/obj/item/wormhole_jaunter/wormhole_weaver/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Device currently has [chargecost > wcell.charge ? "insufficient" : "sufficient"] power. You can recharge it with a recharger.</span>"

/obj/item/wormhole_jaunter/wormhole_weaver/Destroy()
	QDEL_NULL(wcell)
	return ..()

/obj/item/paper/fluff/weaver_instruction
	name = "prototype guideline"
	info = {"<hr><center><h2>Introduction and Caution</h2></center><hr>
	<br><br>
	Firstly, thank you for your interest in our cutting-edge technology. The package you hold contains three (3) targeting beacons, each tuned to emit a specific frequency
	that can only be detected by wormhole weaver devices. For this reason, do not damage or destroy the beacons under any circumstances.
	<br><br>
	Using this device is fairly simple. First, choose a target destination and confirm your choice. Then, point the device at the location where you want the wormhole to
	position itself. It will take approximately five seconds for the weaver to establish a connection.
	<br><br>
	Please note that this prototype must be fully charged before use. Each activation drains the entire battery, and after each recharge, the device must be manually
	reactivated. Due to its fragile design, even the slightest malfunction will trigger safety protocols, immediately canceling the weaving process. Therefore, keep the
	device away from EMP interference.
	<br><br>
	It is also highly advised to avoid taking a wormhole on a full stomach."}

/obj/item/storage/box/weaver_kit
	name = "dusty package"

/obj/item/storage/box/weaver_kit/populate_contents()
	new /obj/item/wormhole_jaunter/wormhole_weaver(src)
	new /obj/item/paper/fluff/weaver_instruction(src)
	new /obj/item/beacon/wormhole_weaver(src)
	new /obj/item/beacon/wormhole_weaver(src)
	new /obj/item/beacon/wormhole_weaver(src)
