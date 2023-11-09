/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to bluespace for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = SLOT_FLAG_BELT

/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [name]!</span>")
	activate(user, TRUE)

/obj/item/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf || !is_teleport_allowed(device_turf.z))
		to_chat(user, "<span class='notice'>You're having difficulties getting the [name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	for(var/obj/item/radio/beacon/B in GLOB.global_radios)
		var/turf/T = get_turf(B)
		if(is_station_level(T.z))
			destinations += B

	return destinations

/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		to_chat(user, "<span class='notice'>[src] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/jaunt_tunnel/J = new(get_turf(src), get_turf(chosen_beacon), src, 100, user)
	J.emagged = emagged
	if(adjacent)
		try_move_adjacent(J)
	else
		J.teleport(user)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(SLOT_HUD_BELT) == src)
		to_chat(user, "Your [name] activates, saving you from the chasm!</span>")
		activate(user, FALSE)
	else
		to_chat(user, "[src] is not attached to your belt, preventing it from saving you from the chasm. RIP.</span>")

/obj/item/wormhole_jaunter/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You emag [src].</span>")
		var/turf/T = get_turf(src)
		do_sparks(5, 0, T)
		playsound(T, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."
	failchance = 0

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
			L.Weaken(12 SECONDS)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living/carbon, vomit)), 20)

/obj/item/wormhole_jaunter/contractor
	name = "emergency extraction flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use extraction flare that will let you create a portal to any beacon on the station. You must choose the destination beforehand, else it will target a random beacon. The portal is generated 5 seconds after activation, and has 1 use."
	icon_state = "flare-contractor"
	item_state = "flare"
	var/destination

/obj/item/wormhole_jaunter/contractor/verb/set_destination()
	set category = "Object"
	set name = "Change Portal Destination"
	set src in usr

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/radio/beacon/R in GLOB.beacons)
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

	var/desc = input("Please select a location to target.", "Flare Target Interface") in L
	destination = L[desc]
	return

/obj/item/wormhole_jaunter/contractor/attack_self(mob/user) // message is later down
	activate(user, TRUE)

/obj/item/wormhole_jaunter/contractor/activate(mob/user)
	if(!turf_check(user))
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
	new /obj/effect/portal/redspace/getaway(get_turf(src), get_turf(destination), src, 100)
	qdel(src)

/obj/item/wormhole_jaunter/contractor/emag_act(mob/user)
	to_chat(user, "<span class='warning'>Emagging [src] has no effect.</span>")

/obj/item/wormhole_jaunter/contractor/chasm_react(mob/user)
	return //This is not an instant getaway portal like the jaunter

/obj/item/storage/box/syndie_kit/escape_flare
	name = "emergency extraction kit"

/obj/item/storage/box/syndie_kit/escape_flare/populate_contents()
	new /obj/item/wormhole_jaunter/contractor(src)
	new /obj/item/radio/beacon/emagged(src)

/obj/effect/portal/redspace/getaway
	one_use = TRUE

/obj/effect/temp_visual/getaway_flare // Because the original contractor flare is not a temp visual, for some reason.
	name = "contractor extraction flare"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"
	duration = 5.1 SECONDS // Needs to be slightly longer then the callback to make the portal

/obj/effect/temp_visual/getaway_flare/Initialize()
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

/obj/item/grenade/jaunter_grenade/attack_self(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/jaunter_grenade/prime()
	update_mob()
	var/list/destinations = list()
	for(var/obj/item/radio/beacon/B in GLOB.global_radios)
		var/turf/BT = get_turf(B)
		if(is_station_level(BT.z))
			destinations += BT
	var/turf/T = get_turf(src)
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
