/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Box
 */

/obj/item/storage/fancy/
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	burn_state = FLAMMABLE
	var/icon_type = "donut"

/obj/item/storage/fancy/update_icon(var/itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "[src.icon_type]box[total_contents]"
	return

/obj/item/storage/fancy/examine(mob/user)
	if(!..(user, 1))
		return

	if(contents.len <= 0)
		to_chat(user, "There are no [src.icon_type]s left in the box.")
	else if(contents.len == 1)
		to_chat(user, "There is one [src.icon_type] left in the box.")
	else
		to_chat(user, "There are [src.contents.len] [src.icon_type]s in the box.")



/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	icon_state = "donutbox6"
	icon_type = "donut"
	name = "donut box"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/food/snacks/donut)


/obj/item/storage/fancy/donut_box/New()
	..()
	for(var/i = 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/donut(src)

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon_state = "eggbox"
	icon_type = "egg"
	name = "egg box"
	storage_slots = 12
	can_hold = list(/obj/item/reagent_containers/food/snacks/egg)

/obj/item/storage/fancy/egg_box/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/reagent_containers/food/snacks/egg(src)
	return

/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "Candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	storage_slots = 5
	throwforce = 2
	slot_flags = SLOT_BELT


/obj/item/storage/fancy/candle_box/full/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/candle(src)
	return

/obj/item/storage/fancy/candle_box/eternal
	name = "Eternal Candle pack"
	desc = "A pack of red candles made with a special wax."

/obj/item/storage/fancy/candle_box/eternal/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/candle/eternal(src)
	return

/*
 * Crayon Box
 */

/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL
	storage_slots = 6
	icon_type = "crayon"
	can_hold = list(
		/obj/item/toy/crayon
	)

/obj/item/storage/fancy/crayons/New()
	..()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	update_icon()

/obj/item/storage/fancy/crayons/update_icon()
	overlays = list() //resets list
	overlays += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/storage/fancy/crayons/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/toy/crayon))
		switch(W:colourName)
			if("mime")
				to_chat(usr, "This crayon is too sad to be contained in this box.")
				return
			if("rainbow")
				to_chat(usr, "This crayon is too powerful to be contained in this box.")
				return
	..()

////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 2
	slot_flags = SLOT_BELT
	storage_slots = 6
	max_combined_w_class = 6
	can_hold = list(/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match)
	cant_hold = list(/obj/item/clothing/mask/cigarette/cigar,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/lighter/zippo)
	icon_type = "cigarette"
	var/list/unlaced_cigarettes = list() // Cigarettes that haven't received reagents yet
	var/default_reagents = list("nicotine" = 15) // List of reagents to pre-generate for each cigarette
	var/cigarette_type = /obj/item/clothing/mask/cigarette

/obj/item/storage/fancy/cigarettes/New()
	..()
	create_reagents(30 * storage_slots)//so people can inject cigarettes without opening a packet, now with being able to inject the whole one
	reagents.set_reacting(FALSE)
	for(var/i = 1 to storage_slots)
		var/obj/item/clothing/mask/cigarette/C = new cigarette_type(src)
		unlaced_cigarettes += C
		for(var/R in default_reagents)
			reagents.add_reagent(R, default_reagents[R])


/obj/item/storage/fancy/cigarettes/Destroy()
	QDEL_NULL(reagents)
	return ..()


/obj/item/storage/fancy/cigarettes/update_icon()
	icon_state = "[initial(icon_state)][contents.len]"
	return

/obj/item/storage/fancy/cigarettes/proc/lace_cigarette(var/obj/item/clothing/mask/cigarette/C as obj)
	if(istype(C) && (C in unlaced_cigarettes)) // Only transfer reagents to each cigarette once
		reagents.trans_to(C, (reagents.total_volume/unlaced_cigarettes.len))
		unlaced_cigarettes -= C
		reagents.maximum_volume = 30 * unlaced_cigarettes.len

/obj/item/storage/fancy/cigarettes/remove_from_storage(obj/item/W as obj, atom/new_location)
	lace_cigarette(W)
	..()

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(istype(M) && M == user && user.zone_sel.selecting == "mouth" && contents.len > 0 && !user.wear_mask)
		var/got_cig = 0
		for(var/num=1, num <= contents.len, num++)
			var/obj/item/I = contents[num]
			if(istype(I, /obj/item/clothing/mask/cigarette))
				var/obj/item/clothing/mask/cigarette/C = I
				lace_cigarette(C)
				user.equip_to_slot_if_possible(C, slot_wear_mask)
				to_chat(user, "<span class='notice'>You take \a [C.name] out of the pack.</span>")
				update_icon()
				got_cig = 1
				break
		if(!got_cig)
			to_chat(user, "<span class='warning'>There are no smokables in the pack!</span>")
	else
		..()

/obj/item/storage/fancy/cigarettes/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(istype(W, /obj/item/match))
		var/obj/item/match/M = W
		if(M.lit == 1)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>Putting a lit [W] in [src] probably isn't a good idea.</span>")
			return 0
	if(istype(W, /obj/item/lighter))
		var/obj/item/lighter/L = W
		if(L.lit == 1)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>Putting [W] in [src] while lit probably isn't a good idea.</span>")
			return 0
	//if we get this far, handle the insertion checks as normal
	.=..()

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	item_state = "cigpacket"


/obj/item/storage/fancy/cigarettes/syndicate
	name = "\improper Syndicate Cigarettes"
	desc = "A packet of six evil-looking cigarettes, A label on the packaging reads, \"Donk Co\""
	icon_state = "robustpacket"
	item_state = "cigpacket"

/obj/item/storage/fancy/cigarettes/syndicate/New()
	..()
	var/new_name = pick("evil", "suspicious", "ominous", "donk-flavored", "robust", "sneaky")
	name = "[new_name] cigarette packet"

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndiepacket"
	item_state = "cigpacket"
	default_reagents = list("nicotine" = 15, "omnizine" = 15)

/obj/item/storage/fancy/cigarettes/cigpack_med
	name = "Medical Marijuana Packet"
	desc = "A prescription packet containing six marijuana cigarettes."
	icon_state = "medpacket"
	item_state = "cigpacket"
	default_reagents = list("thc" = 15)

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "upliftpacket"
	item_state = "cigpacket"

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robustpacket"
	item_state = "cigpacket"

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustgpacket"
	item_state = "cigpacket"
	default_reagents = list("nicotine" = 15, "gold" = 1)

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carppacket"
	item_state = "cigpacket"

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midoripacket"
	item_state = "cigpacket"

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name ="\improper Shady Jim's Super Slims"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjimpacket"
	item_state = "cigpacket"
	default_reagents = list("nicotine" = 15,
		"lipolicide" = 7.5,
		"ammonia" = 2,
		"atrazine" = 1,
		"toxin" = 1.5)

/obj/item/storage/fancy/cigarettes/cigpack_random
	name ="\improper Embellished Enigma packet"
	desc = "For the true connoisseur of exotic flavors."
	icon_state = "shadyjimpacket"
	item_state = "cigpacket"
	cigarette_type  = /obj/item/clothing/mask/cigarette/random

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	storage_slots = 10
	icon_type = "rolling paper"
	can_hold = list(/obj/item/rollingpaper)

/obj/item/storage/fancy/rollingpapers/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/rollingpaper(src)

/obj/item/storage/fancy/rollingpapers/update_icon()
	overlays.Cut()
	if(!contents.len)
		overlays += "[icon_state]_empty"

/*
 * Vial Box
 */

/obj/item/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox6"
	icon_type = "vial"
	name = "vial storage box"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)


/obj/item/storage/fancy/vials/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/reagent_containers/glass/beaker/vial(src)
	return

/obj/item/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial)
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 6
	req_access = list(access_virology)

/obj/item/storage/lockbox/vials/New()
	..()
	update_icon()

/obj/item/storage/lockbox/vials/update_icon(var/itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "vialbox[total_contents]"
	src.overlays.Cut()
	if(!broken)
		overlays += image(icon, src, "led[locked]")
		if(locked)
			overlays += image(icon, src, "cover")
	else
		overlays += image(icon, src, "ledb")
	return

/obj/item/storage/lockbox/vials/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	update_icon()



///Aquatic Starter Kit

/obj/item/storage/firstaid/aquatic_kit
	name = "aquatic starter kit"
	desc = "It's a starter kit box for an aquarium."
	icon_state = "AquaticKit"
	throw_speed = 2
	throw_range = 8
	med_bot_skin = "fish"

/obj/item/storage/firstaid/aquatic_kit/full
	desc = "It's a starter kit for an acquarium; includes 1 tank brush, 1 egg scoop, 1 fish net, and 1 container of fish food."

/obj/item/storage/firstaid/aquatic_kit/full/New()
	..()
	new /obj/item/egg_scoop(src)
	new /obj/item/fish_net(src)
	new /obj/item/tank_brush(src)
	new /obj/item/fishfood(src)
