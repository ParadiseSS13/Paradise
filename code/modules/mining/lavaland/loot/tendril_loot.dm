//Shared Bag

//Internal
/obj/item/storage/backpack/shared
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	max_combined_w_class = 60
	max_w_class = WEIGHT_CLASS_NORMAL

//External
/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	slot_flags = SLOT_BACK
	var/obj/item/storage/backpack/shared/bag

/obj/item/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/shared_storage/red/New()
	..()
	if(!bag)
		var/obj/item/storage/backpack/shared/S = new(src)
		var/obj/item/shared_storage/blue = new(loc)

		bag = S
		blue.bag = S

/obj/item/shared_storage/attackby(obj/item/W, mob/user, params)
	if(bag)
		bag.loc = user
		bag.attackby(W, user, params)

/obj/item/shared_storage/attack_self(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(src == user.l_hand || src == user.r_hand)
		if(bag)
			bag.loc = user
			bag.attack_hand(user)
	else
		..()

/obj/item/shared_storage/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(loc == user && user.back && user.back == src)
		if(bag)
			bag.loc = user
			bag.attack_hand(user)
	else
		..()

/obj/item/shared_storage/MouseDrop(atom/over_object)
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(istype(M.loc, /obj/mecha))
			return

		if(!M.restrained() && !M.stat)
			playsound(loc, "rustle", 50, 1, -5)

			if(istype(over_object, /obj/screen/inventory/hand))
				if(!M.unEquip(src))
					return
				M.put_in_active_hand(src)
			else if(bag)
				bag.loc = usr
				bag.attack_hand(usr)

			add_fingerprint(M)

//Potion of Flight: as we do not have the "Angel" species this currently does not work.

/obj/item/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list("flightpotion" = 5)

/obj/item/reagent_containers/glass/bottle/potion/update_icon()
	if(reagents.total_volume)
		icon_state = "potionflask"
	else
		icon_state = "potionflask_empty"

/datum/reagent/flightpotion
	name = "Flight Potion"
	id = "flightpotion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1)
	to_chat(M, "<span class='warning'>This item is currently non-functional.</span>")
	/*if(ishuman(M) && M.stat != DEAD)
		var/mob/living/carbon/human/H = M
		if(!ishumanbasic(H) || reac_volume < 5) // implying xenohumans are holy
			if(method == INGEST && show_message)
				to_chat(H, "<span class='notice'><i>You feel nothing but a terrible aftertaste.</i></span>")
			return ..()

		to_chat(H, "<span class='userdanger'>A terrible pain travels down your back as wings burst out!</span>")
		H.set_species(/datum/species/angel)
		playsound(H.loc, 'sound/items/poster_ripped.ogg', 50, 1, -1)
		H.adjustBruteLoss(20)
		H.emote("scream")
	..()*/

//Boat

/obj/vehicle/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	keytype = /obj/item/oar
	burn_state = LAVA_PROOF | FIRE_PROOF

/obj/vehicle/lavaboat/relaymove(mob/user, direction)
	var/turf/next = get_step(src, direction)
	var/turf/current = get_turf(src)

	if(istype(next, /turf/unsimulated/floor/lava) || istype(current, /turf/unsimulated/floor/lava)) //We can move from land to lava, or lava to land, but not from land to land
		..()
	else
		to_chat(user, "<span class='warning'>Boats don't go on land!</span>")
		return 0

/obj/item/oar
	name = "oar"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	item_state = "rods"
	desc = "Not to be confused with the kind Research hassles you for."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	burn_state = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "goliath bone oar"
	result = /obj/item/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_PRIMAL

/datum/crafting_recipe/boat
	name = "goliath hide boat"
	result = /obj/vehicle/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_PRIMAL

//Dragon Boat

/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, "You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out.")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	new /obj/vehicle/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	keytype = null
	icon_state = "dragon_boat"
	generic_pixel_y = 2
	generic_pixel_x = 1
	vehicle_move_delay = 1

// Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	var/obj/effect/wisp/wisp

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, "<span class='warning'>The wisp has gone missing!</span>")
		return
	if(wisp.loc == src)
		to_chat(user, "<span class='notice'>You release the wisp. It begins to bob around your head.</span>")
		user.sight |= SEE_MOBS
		icon_state = "lantern"
		wisp.orbit(user, 20, forceMove = TRUE)
		feedback_add_details("wisp_lantern","F") // freed

	else
		to_chat(user, "<span class='notice'>You return the wisp to the lantern.</span>")

		if(wisp.orbiting)
			var/atom/A = wisp.orbiting
			if(isliving(A))
				var/mob/living/M = A
				M.sight &= ~SEE_MOBS
				to_chat(M, "<span class='notice'>Your vision returns to normal.</span>")

		wisp.stop_orbit()
		wisp.loc = src
		icon_state = "lantern-blue"
		feedback_add_details("wisp_lantern","R") // returned

/obj/item/wisp_lantern/New()
	..()
	wisp = new(src)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message("<span class='notice'>[wisp] has a sad feeling for a moment, then it passes.</span>")
	return ..()

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	layer = ABOVE_ALL_MOB_LAYER
	light_power = 1
	light_range = 7

//Red/Blue Cubes

/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/obj/item/warp_cube/linked

/obj/item/warp_cube/Destroy()
	if(linked)
		linked.linked = null
		linked = null
	return ..()

/obj/item/warp_cube/attack_self(mob/user)
	if(!linked)
		to_chat(user, "[src] fizzles uselessly.")
		return

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, 0, user.loc)
	smoke.start()

	user.forceMove(get_turf(linked))
	feedback_add_details("warp_cube","[src.type]")

	var/datum/effect_system/smoke_spread/smoke2 = new
	smoke2.set_up(1, 0, user.loc)
	smoke2.start()

/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"

/obj/item/warp_cube/red/New()
	..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

//Meat Hook

/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	item_state = "chain"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	flags = NOBLUDGEON
	force = 18

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "a hook."
	projectile_type = /obj/item/projectile/hook
	caliber = "hook"
	icon_state = "hook"

/obj/item/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 25
	armour_penetration = 100
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	weaken = 3
	var/chain

/obj/item/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()
	//TODO: root the firer until the chain returns

/obj/item/projectile/hook/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored)
			L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")
			L.forceMove(get_turf(firer))

/obj/item/projectile/hook/Destroy()
	QDEL_NULL(chain)
	return ..()

//Immortality Talisman

/obj/item/immortality_talisman
	name = "Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		feedback_add_details("immortality_talisman","U") // usage
		cooldown = world.time + 600
		user.visible_message("<span class='danger'>[user] vanishes from reality, leaving a a hole in [user.p_their()] place!</span>")
		var/obj/effect/immortality_talisman/Z = new(get_turf(src.loc))
		Z.name = "hole in reality"
		Z.desc = "It's shaped an awful lot like [user.name]."
		Z.setDir(user.dir)
		user.forceMove(Z)
		user.notransform = 1
		user.status_flags |= GODMODE
		spawn(100)
			user.status_flags &= ~GODMODE
			user.notransform = 0
			user.forceMove(get_turf(Z))
			user.visible_message("<span class='danger'>[user] pops back into reality!</span>")
			Z.can_destroy = TRUE
			qdel(Z)
	else
		to_chat(user, "<span class'warning'>[src] is still recharging.</span>")

/obj/effect/immortality_talisman
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/can_destroy = FALSE

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/ex_act()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return 0

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()
