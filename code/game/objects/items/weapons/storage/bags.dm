/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	CONTENTS:
 *		Trash bag
 *		Mining satchel
 *		Plant bag
 *		Cash bag
 *		Book bag
 *		Serving tray
 *		Chemistry bag
 *		Bio bag
 *		Mail bag
 *		Construction bag
 *		Treasure bag
 */

//  Generic non-item
/obj/item/storage/bag
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = 1 // should work fine now
	use_to_pickup = 1
	slot_flags = SLOT_FLAG_BELT

////////////////////////////////////////
// MARK:	Trash bag
////////////////////////////////////////
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	belt_icon = "trashbag"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	max_w_class = WEIGHT_CLASS_SMALL
	slot_flags = null
	storage_slots = 30
	max_combined_w_class = 30
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear, /obj/item/grown/bananapeel/traitorpeel)

/obj/item/storage/bag/trash/proc/update_weight()
	if(!length(contents))
		w_class = WEIGHT_CLASS_SMALL
		return

	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/bag/trash/remove_from_storage(obj/item/I, atom/new_location)
	. = ..()
	update_weight()

/obj/item/storage/bag/trash/can_be_inserted(obj/item/I, stop_messages = FALSE)
	if(isstorage(loc) && !istype(loc, /obj/item/storage/backpack/holding))
		to_chat(usr, "<span class='warning'>You can't seem to fit [I] into [src].</span>")
		return FALSE
	if(ishuman(loc)) // If the trashbag is on a humanoid, they can't store things in it while it's in their pockets
		var/mob/living/carbon/human/H = loc
		if(H.l_store == src || H.r_store == src)
			to_chat(usr, "<span class='warning'>You can't seem to fit [I] into [src].</span>")
			return FALSE
	. = ..()

/obj/item/storage/bag/trash/Initialize(mapload)
	. = ..()
	update_weight()

/obj/item/storage/bag/trash/handle_item_insertion(obj/item/I, mob/user, prevent_warning)
	. = ..()
	update_weight()

/obj/item/storage/bag/trash/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!</span>")
	playsound(loc, 'sound/items/eatfood.ogg', 50, 1, -1)
	return TOXLOSS

/obj/item/storage/bag/trash/update_icon_state()
	switch(length(contents))
		if(21 to INFINITY)
			icon_state = "[initial(icon_state)]3"
		if(11 to 20)
			icon_state = "[initial(icon_state)]2"
		if(1 to 10)
			icon_state = "[initial(icon_state)]1"
		else
			icon_state = "[initial(icon_state)]"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_l_hand()
		H.update_inv_r_hand()

/obj/item/storage/bag/trash/cyborg

/obj/item/storage/bag/trash/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	J.mybag = src
	J.put_in_cart(src, user)

/obj/item/storage/bag/trash/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return

/obj/item/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	belt_icon = "trashbag_blue"
	origin_tech = "materials=4;bluespace=4;engineering=4;plasmatech=3"
	max_combined_w_class = 60
	storage_slots = 60
	flags_2 = NO_MAT_REDEMPTION_2

/obj/item/storage/bag/trash/bluespace/cyborg

/obj/item/storage/bag/trash/bluespace/cyborg/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	return

////////////////////////////////////////
// MARK:	Plastic bag
////////////////////////////////////////
/obj/item/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"
	slot_flags = SLOT_FLAG_HEAD|SLOT_FLAG_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 7
	display_contents_with_number = 0 //or else this will lead to stupid behavior.
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

/obj/item/storage/bag/plasticbag/mob_can_equip(mob/M, slot, disable_warning = FALSE)
	if(slot == SLOT_HUD_HEAD && length(contents))
		to_chat(M, "<span class='warning'>You need to empty the bag first!</span>")
		return FALSE
	return ..()


/obj/item/storage/bag/plasticbag/equipped(mob/user, slot)
	if(slot==SLOT_HUD_HEAD)
		storage_slots = 0
		START_PROCESSING(SSobj, src)
	return

/obj/item/storage/bag/plasticbag/process()
	if(is_equipped())
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.get_item_by_slot(SLOT_HUD_HEAD) == src)
				if(H.internal)
					return
				H.AdjustLoseBreath(2 SECONDS)
	else
		storage_slots = 7
		STOP_PROCESSING(SSobj, src)
	return

////////////////////////////////////////
// MARK:	Mining satchel
////////////////////////////////////////
/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	origin_tech = "engineering=2"
	slot_flags = SLOT_FLAG_BELT | SLOT_FLAG_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 10
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/stack/ore)

/obj/item/storage/bag/ore/cyborg
	name = "cyborg mining satchel"
	flags = NODROP

/// miners, your messiah has arrived
/obj/item/storage/bag/ore/holding
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for infinite ore storage. It's been outfitted with anti-malfunction safety measures."
	storage_slots = INFINITY
	max_combined_w_class = INFINITY
	origin_tech = "bluespace=4;materials=3;engineering=3"
	icon_state = "satchel_bspace"

/obj/item/storage/bag/ore/holding/cyborg
	name = "cyborg mining satchel of holding"
	flags = NODROP

////////////////////////////////////////
// MARK:	Plant bag
////////////////////////////////////////
/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	storage_slots = 40 //the number of plant pieces it can carry.
	max_combined_w_class = 40 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/seeds,
		/obj/item/unsorted_seeds,
		/obj/item/food/snacks/grown,
		/obj/item/grown,
		/obj/item/food/snacks/grown/ash_flora,
		/obj/item/food/snacks/honeycomb)
	cant_hold = list(/obj/item/grown/bananapeel/traitorpeel)
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"
	origin_tech = "biotech=3;engineering=2"

/obj/item/storage/bag/plants/portaseeder/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "<span class='notice'>You can <b>Alt-Shift-Click</b> to convert the plants inside to seeds.</span>"

/obj/item/storage/bag/plants/portaseeder/proc/process_plants(mob/user)
	if(!length(contents))
		to_chat(user, "<span class='warning'>[src] has no seeds inside!</span>")
		return
	var/had_anything = FALSE
	for(var/obj/item/O in contents)
		had_anything |= seedify(O, 1)
	hide_from_all()
	if(had_anything)
		to_chat(user, "<span class='notice'>[src] whirrs a bit as it converts the plants inside to seeds.</span>")
	else
		to_chat(user, "<span class='warning'>[src] whirrs a bit but stops. Doesn't seem like it could convert anything inside.</span>")
	playsound(user, "sound/machines/ding.ogg", 25)

/obj/item/storage/bag/plants/portaseeder/AltShiftClick(mob/user)
	if(Adjacent(user) && ishuman(user) && !user.incapacitated(FALSE, TRUE))
		process_plants(user)

/obj/item/storage/bag/plants/seed_sorting_tray
	name = "seed sorting tray"
	desc = "A simple wooden tray with compartments for manually sorting seeds. It's better than nothing, but a plant analyzer would be more effective."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "seed_sorting_tray"
	can_hold = list(
		/obj/item/seeds,
		/obj/item/unsorted_seeds)

/obj/item/storage/bag/plants/seed_sorting_tray/attack_self(mob/user)
	var/depth = 0
	for(var/obj/item/unsorted_seeds/unsorted in src)
		if(!do_after(user, 1 SECONDS, TRUE, src, must_be_held = TRUE))
			break
		depth = min(8, depth + 1)
		unsorted.sort(depth)

////////////////////////////////////////
// MARK:	Cash bag
////////////////////////////////////////

/obj/item/storage/bag/cash
	icon = 'icons/obj/storage.dmi'
	icon_state = "cashbag"
	name = "Cash bag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	storage_slots = 50; //the number of cash pieces it can carry.
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * cash.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/coin, /obj/item/stack/spacecash)

////////////////////////////////////////
// MARK:	Book Bag
////////////////////////////////////////

/obj/item/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	display_contents_with_number = 0 //This would look really stupid otherwise
	storage_slots = 7
	max_combined_w_class = 21
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_BULKY //Bigger than a book because physics
	can_hold = list(/obj/item/book, /obj/item/storage/bible, /obj/item/tome, /obj/item/spellbook)
	resistance_flags = FLAMMABLE

////////////////////////////////////////
// MARK:	Serving tray
////////////////////////////////////////
/obj/item/storage/bag/tray
	name = "serving tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	storage_slots = 8
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	slot_flags = null
	materials = list(MAT_METAL=3000)
	cant_hold = list(/obj/item/disk/nuclear) // Prevents some cheesing

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	drop_inventory(user)

	// Make each item scatter a bit
	for(var/obj/item/I in oldContents)
		I.forceMove(M)
		INVOKE_ASYNC(src, PROC_REF(scatter_tray_items), I)

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, 1)

	if(ishuman(M) && prob(10))
		M.KnockDown(4 SECONDS)

/obj/item/storage/bag/tray/proc/scatter_tray_items(obj/item/I)
	if(!I)
		return

	for(var/i in 1 to rand(1, 2))
		step(I, pick(NORTH,SOUTH,EAST,WEST))
		sleep(rand(2, 4))

/obj/item/storage/bag/tray/update_icon_state()
	return

/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		. += image(icon = I.icon, icon_state = I.icon_state, layer = -1)

/obj/item/storage/bag/tray/cyborg

/obj/item/storage/bag/tray/cyborg/afterattack(atom/target, mob/user, proximity_flag)
	// We cannot reach the target.
	if(!proximity_flag)
		return

	// Tray is empty.
	if(!length(contents))
		return ..()

	// Not a table or turf.
	if(!isturf(target) && !istype(target, /obj/structure/table))
		return ..()

	var/found_table = istype(target, /obj/structure/table)
	// We clicked a turf, search it for a table.
	if(!found_table)
		for(var/obj/structure/table/T in target)
			found_table = TRUE
			break

	var/turf/dropspot
	// We clicked the floor.
	if(!found_table)
		dropspot = user.loc
	// We clicked the floor but there's a table on it.
	else if(isturf(target))
		dropspot = target
	// We clicked a table directly.
	else
		dropspot = target.loc

	var/list/obj/item/oldContents = contents.Copy()
	drop_inventory(user)
	for(var/obj/item/I in oldContents)
		// Set the properties of the new item here, e.g., stack count, hover highlight, tooltip
		I.forceMove(dropspot)
		// If there is no table, dump the contents of the tray at our feet like we're doing the service equivilent of a micdrop.
		if(!found_table && isturf(dropspot))
			INVOKE_ASYNC(src, PROC_REF(scatter_tray_items), I)

	if(found_table)
		user.visible_message("<span class='notice'>[user] unloads [user.p_their()] serving tray.</span>")
	else
		user.visible_message("<span class='warning'>[user] upends [user.p_their()] serving tray, sending everything on it crashing down to the floor!</span>")
	update_icon(UPDATE_OVERLAYS)
	return ..()

/obj/item/storage/bag/tray/cookies_tray
	var/cookie = /obj/item/food/snacks/cookie

/obj/item/storage/bag/tray/cookies_tray/populate_contents() // By Azule Utama, thank you a lot!
	for(var/i in 1 to 6)
		var/obj/item/C = new cookie(src)
		C.in_inventory = TRUE
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/bag/tray/cookies_tray/sugarcookie
	cookie = /obj/item/food/snacks/sugarcookie

////////////////////////////////////////
// MARK:	Chemistry bag
////////////////////////////////////////
/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bag"
	desc = "A bag for storing pills, patches, and bottles."
	storage_slots = 50
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/pill,
					/obj/item/reagent_containers/patch,
					/obj/item/reagent_containers/glass/beaker,
					/obj/item/reagent_containers/glass/bottle)
	resistance_flags = FLAMMABLE

////////////////////////////////////////
// MARK:	Bio bag
////////////////////////////////////////
/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other biological materials."
	storage_slots = 25
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/slime_extract, /obj/item/food/snacks/monkeycube,
					/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/glass/beaker,
					/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/iv_bag,
					/obj/item/reagent_containers/hypospray/autoinjector/epinephrine)
	resistance_flags = FLAMMABLE

////////////////////////////////////////
// MARK:	Mail bag
////////////////////////////////////////
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A bag for envelopes, stamps, pens, and papers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mailbag"
	item_state = "mailbag"
	storage_slots = 14
	max_combined_w_class = 28
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/envelope, /obj/item/stamp, /obj/item/pen, /obj/item/paper, /obj/item/mail_scanner)
	resistance_flags = FLAMMABLE

////////////////////////////////////////
// MARK:	Construction bag
////////////////////////////////////////
/obj/item/storage/bag/construction
	name = "construction bag"
	desc = "A bag for storing various small scale construction supplies, such as wiring and circuit boards."
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	item_state = "construction_bag"
	storage_slots = 30
	max_combined_w_class = 60
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/airlock_electronics, /obj/item/firelock_electronics, /obj/item/firealarm_electronics, /obj/item/apc_electronics, /obj/item/airalarm_electronics, /obj/item/camera_assembly, /obj/item/stock_parts/cell, /obj/item/circuitboard, /obj/item/stack/cable_coil)
	resistance_flags = FLAMMABLE

////////////////////////////////////////
// MARK:	Treasure bag
////////////////////////////////////////

/obj/item/storage/bag/expedition
	name = "treasure satchel"
	desc = "A satchel for storing scavenged salvage. There be treasure."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel" // placeholder
	origin_tech = "engineering=2"
	slot_flags = SLOT_FLAG_BELT | SLOT_FLAG_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 15
	max_combined_w_class = 60
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/salvage)

/obj/item/storage/bag/expedition/robust
	name = "robust treasure satchel"
	desc = "We heard you liked booty so we put booty in your booty so ye could carry more booty."
	storage_slots = 30
	max_combined_w_class = 120
	origin_tech = "materials=3;engineering=3"
	icon_state = "satchel_bspace" // placeholder
