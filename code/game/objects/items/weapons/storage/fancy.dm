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

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	resistance_flags = FLAMMABLE
	var/icon_type

/obj/item/storage/fancy/update_icon_state()
	icon_state = "[icon_type]box[length(contents)]"

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		var/len = LAZYLEN(contents)
		if(len <= 0)
			. += "There are no [icon_type]s left in the box."
		else if(len == 1)
			. += "There is one [icon_type] left in the box."
		else
			. += "There are [length(contents)] [icon_type]s in the box."

/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	name = "donut box"
	icon_type = "donut"
	icon_state = "donutbox"
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/food/snacks/donut)
	icon_type = "donut"
	foldable = /obj/item/stack/sheet/cardboard
	foldable_amt = 1

/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()
	for(var/I = 1 to length(contents))
		var/obj/item/reagent_containers/food/snacks/donut/donut = contents[I]
		var/icon/new_donut_icon = icon('icons/obj/food/containers.dmi', "[(I - 1)]donut[donut.donut_sprite_type]")
		. += new_donut_icon

/obj/item/storage/fancy/update_icon_state()
	return

/obj/item/storage/fancy/donut_box/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/donut(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/fancy/donut_box/empty/populate_contents()
	update_icon(UPDATE_OVERLAYS)
	return

/obj/item/storage/fancy/donut_box/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!length(contents))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon_state = "eggbox"
	icon_type = "egg"
	item_state = "eggbox"
	name = "egg box"
	storage_slots = 12
	can_hold = list(/obj/item/reagent_containers/food/snacks/egg)

/obj/item/storage/fancy/egg_box/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/egg(src)

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
	slot_flags = SLOT_FLAG_BELT


/obj/item/storage/fancy/candle_box/full/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/candle(src)

/obj/item/storage/fancy/candle_box/eternal
	name = "Eternal Candle pack"
	desc = "A pack of red candles made with a special wax."

/obj/item/storage/fancy/candle_box/eternal/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/candle/eternal(src)

/*
 * Crayon Box
 */

/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL
	storage_slots = 8
	icon_type = "crayon"
	can_hold = list(
		/obj/item/toy/crayon
	)

/obj/item/storage/fancy/crayons/populate_contents()
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_icon()

/obj/item/storage/fancy/crayons/update_overlays()
	. = ..()
	. += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		. += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/storage/fancy/crayons/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		switch(C.colourName)
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
	belt_icon = "patch_pack"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 2
	slot_flags = SLOT_FLAG_BELT
	storage_slots = 6
	max_combined_w_class = 6
	can_hold = list(/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match)
	cant_hold = list(/obj/item/clothing/mask/cigarette/cigar,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/lighter/zippo)
	icon_type = "cigarette"
	var/cigarette_type = /obj/item/clothing/mask/cigarette

/obj/item/storage/fancy/cigarettes/populate_contents()
	for(var/I in 1 to storage_slots)
		new cigarette_type(src)

/obj/item/storage/fancy/cigarettes/update_icon_state()
	icon_state = "[initial(icon_state)][contents.len]"

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ismob(M))
		return

	if(istype(M) && M == user && user.zone_selected == "mouth" && contents.len > 0 && !user.wear_mask)
		var/got_cig = 0
		for(var/num=1, num <= contents.len, num++)
			var/obj/item/I = contents[num]
			if(istype(I, /obj/item/clothing/mask/cigarette))
				var/obj/item/clothing/mask/cigarette/C = I
				user.equip_to_slot_if_possible(C, SLOT_HUD_WEAR_MASK)
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
		if(M.lit)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>Putting a lit [W] in [src] probably isn't a good idea.</span>")
			return 0
	if(istype(W, /obj/item/lighter))
		var/obj/item/lighter/L = W
		if(L.lit)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>Putting [W] in [src] while lit probably isn't a good idea.</span>")
			return 0
	//if we get this far, handle the insertion checks as normal
	. = ..()

/obj/item/storage/fancy/cigarettes/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!length(contents))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	item_state = "Dpacket"


/obj/item/storage/fancy/cigarettes/syndicate
	name = "\improper Syndicate Cigarettes"
	desc = "A packet of six evil-looking cigarettes, A label on the packaging reads, \"Donk Co\""
	icon_state = "robustpacket"
	item_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/syndicate/Initialize(mapload)
	. = ..()
	var/new_name = pick("evil", "suspicious", "ominous", "donk-flavored", "robust", "sneaky")
	name = "[new_name] cigarette packet"

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndiepacket"
	item_state = "syndiepacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_med
	name = "\improper Medical Marijuana Packet"
	desc = "A prescription packet containing six marijuana cigarettes."
	icon_state = "medpacket"
	item_state = "medpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/medical_marijuana


/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "upliftpacket"
	item_state = "upliftpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/menthol

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robustpacket"
	item_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustgpacket"
	item_state = "robustgpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carppacket"
	item_state = "carppacket"

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midoripacket"
	item_state = "midoripacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/rollie

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name ="\improper Shady Jim's Super Slims"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjimpacket"
	item_state = "shadyjimpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_random
	name ="\improper Embellished Enigma packet"
	desc = "For the true connoisseur of exotic flavors."
	icon_state = "shadyjimpacket"
	item_state = "shadyjimpacket"
	cigarette_type = /obj/item/clothing/mask/cigarette/random

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	item_state = "cig_paper_pack"
	storage_slots = 10
	icon_type = "rolling paper"
	can_hold = list(/obj/item/rollingpaper)

/obj/item/storage/fancy/rollingpapers/populate_contents()
	for(var/I in 1 to storage_slots)
		new /obj/item/rollingpaper(src)

/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!contents.len)
		. += "[icon_state]_empty"

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


/obj/item/storage/fancy/vials/populate_contents()
	for(var/I in 1 to storage_slots)
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
	req_access = list(ACCESS_VIROLOGY)

/obj/item/storage/lockbox/vials/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/lockbox/vials/update_icon_state()
	icon_state = "vialbox[length(contents)]"
	cut_overlays()

/obj/item/storage/lockbox/vials/update_overlays()
	. = ..()
	if(!broken)
		. += "led[locked]"
		if(locked)
			. += "cover"
	else
		. += "ledb"

/obj/item/storage/lockbox/vials/attackby(obj/item/I, mob/user, params)
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
	desc = "It's a starter kit for an aquarium; includes 1 tank brush, 1 egg scoop, 1 fish net, 1 container of fish food and 1 fish bag."

/obj/item/storage/firstaid/aquatic_kit/full/populate_contents()
	new /obj/item/egg_scoop(src)
	new /obj/item/fish_net(src)
	new /obj/item/tank_brush(src)
	new /obj/item/fishfood(src)
	new /obj/item/storage/bag/fish(src)
