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
	slot_flags = SLOT_BELT

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
	var/obj/effect/portal/jaunt_tunnel/J = new(get_turf(src), get_turf(chosen_beacon), src, 100)
	J.emagged = emagged
	if(adjacent)
		try_move_adjacent(J)
	else
		J.teleport(user)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(slot_belt) == src)
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
			L.Weaken(6)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, /mob/living/carbon.proc/vomit), 20)

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
	addtimer(CALLBACK(src, .proc/create_portal, destination), 5 SECONDS)

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
