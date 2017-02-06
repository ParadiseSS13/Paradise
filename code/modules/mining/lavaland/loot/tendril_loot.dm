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
			

//Potion of Flight

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