//Shared Bag

//Internal
/obj/item/weapon/storage/backpack/shared
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	max_combined_w_class = 60
	max_w_class = 3

//External
/obj/item/device/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	slot_flags = SLOT_BACK
	var/obj/item/weapon/storage/backpack/shared/bag

/obj/item/device/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/device/shared_storage/red/New()
	..()
	if(!bag)
		var/obj/item/weapon/storage/backpack/shared/S = new(src)
		var/obj/item/device/shared_storage/blue = new(loc)

		bag = S
		blue.bag = S

/obj/item/device/shared_storage/attackby(obj/item/W, mob/user, params)
	if(bag)
		bag.forceMove(user)
		bag.attackby(W, user, params)

/obj/item/device/shared_storage/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(loc == user && user.back && user.back == src)
		if(bag)
			bag.forceMove(user)
			bag.attack_hand(user)
	else
		..()

/obj/item/device/shared_storage/MouseDrop(atom/over_object)
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if (istype(usr.loc, /obj/mecha))
			return

		if(!M.restrained() && !M.stat)
			playsound(loc, "rustle", 50, 1, -5)

			if(istype(over_object, /obj/screen/inventory/hand))
				if(!M.unEquip(src))
					return
				M.put_in_active_hand(src)

			add_fingerprint(usr)
			

//Potion of Flight: as we do not have the "Angel" species this currently does not work.

/obj/item/weapon/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/weapon/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list("flightpotion" = 5)

/obj/item/weapon/reagent_containers/glass/bottle/potion/update_icon()
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
	return // This item currently does not work as we do not have the angel species.
	if(ishuman(M) && M.stat != DEAD)
		var/mob/living/carbon/human/H = M
		if(H.species.name != "Human" || reac_volume < 5) // implying xenohumans are holy
			if(method == INGEST && show_message)
				to_chat(H, "<span class='notice'><i>You feel nothing but a terrible aftertaste.</i></span>")
			return ..()

		to_chat(H, "<span class='userdanger'>A terrible pain travels down your back as wings burst out!</span>")
		H.set_species("Angel")
		playsound(H.loc, 'sound/items/poster_ripped.ogg', 50, 1, -1)
		H.adjustBruteLoss(20)
		H.emote("scream")
	..()
	
//Boat

/obj/vehicle/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	keytype = /obj/item/weapon/oar
	burn_state = LAVA_PROOF | FIRE_PROOF

/obj/vehicle/lavaboat/relaymove(mob/user, direction)
	var/turf/next = get_step(src, direction)
	var/turf/current = get_turf(src)

	if(istype(next, /turf/unsimulated/floor/lava) || istype(current, /turf/unsimulated/floor/lava)) //We can move from land to lava, or lava to land, but not from land to land
		..()
	else
		to_chat(user, "Boats don't go on land!")
		return 0

/obj/item/weapon/oar
	name = "oar"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	item_state = "rods"
	desc = "Not to be confused with the kind Research hassles you for."
	force = 12
	w_class = 3
	burn_state = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "goliath bone oar"
	result = /obj/item/weapon/oar
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
	user << "You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out."
	playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
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