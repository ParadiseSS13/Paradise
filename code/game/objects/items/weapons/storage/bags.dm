/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Trash Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Book Bag
 *		Tray
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = 1 // should work fine now
	use_to_pickup = 1
	slot_flags = SLOT_FLAG_BELT

// -----------------------------
//          Trash bag
// -----------------------------
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
	cant_hold = list(/obj/item/disk/nuclear)

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

/obj/item/storage/bag/trash/handle_item_insertion(obj/item/I, prevent_warning)
	. = ..()
	update_weight()

/obj/item/storage/bag/trash/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!</span>")
	playsound(loc, 'sound/items/eatfood.ogg', 50, 1, -1)
	return TOXLOSS

/obj/item/storage/bag/trash/update_icon_state()
	switch(contents.len)
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

// -----------------------------
//        Plastic Bag
// -----------------------------

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

/obj/item/storage/bag/plasticbag/mob_can_equip(M as mob, slot)

	if(slot==SLOT_HUD_HEAD && contents.len)
		to_chat(M, "<span class='warning'>You need to empty the bag first!</span>")
		return 0
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

// -----------------------------
//        Mining Satchel
// -----------------------------

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

/obj/item/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for infinite ore storage. It's been outfitted with anti-malfunction safety measures."
	storage_slots = INFINITY
	max_combined_w_class = INFINITY
	origin_tech = "bluespace=4;materials=3;engineering=3"
	icon_state = "satchel_bspace"

/obj/item/storage/bag/ore/holding/cyborg
	name = "cyborg mining satchel of holding"
	flags = NODROP

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	storage_slots = 100 //the number of plant pieces it can carry.
	max_combined_w_class = 100 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/food/snacks/grown,/obj/item/seeds,/obj/item/grown,/obj/item/reagent_containers/food/snacks/grown/ash_flora,/obj/item/reagent_containers/food/snacks/honeycomb)
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

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/storage/bag/sheetsnatcher // what is this even used for
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	name = "Sheet Snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."

	var/capacity = 300; //the number of sheets it can carry.
	w_class = WEIGHT_CLASS_NORMAL

	allow_quick_empty = TRUE // this function is superceded

/obj/item/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W,/obj/item/stack/sheet) || istype(W,/obj/item/stack/sheet/mineral/sandstone) || istype(W,/obj/item/stack/sheet/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/S in contents)
		current += S.amount
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>The snatcher is full.</span>")
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/sheet/S2 in contents)
		current += S2.amount
	if(capacity < current + S.amount)//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.amount

	for(var/obj/item/stack/sheet/sheet in contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = 1
			break

	if(!inserted || !S.amount)
		usr.unEquip(S)
		usr.update_icons()	//update our overlays
		if(usr.client && usr.s_active != src)
			usr.client.screen -= S
		S.dropped(usr)
		if(!S.amount)
			qdel(S)
		else
			S.loc = src

	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()
	return 1


// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/obj/item/storage/bag/sheetsnatcher/orient2hud(mob/user as mob)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/I in contents)
			adjusted_contents++
			var/datum/numbered_display/D = new/datum/numbered_display(I)
			D.number = I.amount
			numbered_contents.Add( D )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	standard_orient_objs(row_num, col_count, numbered_contents)
	return


/obj/item/storage/bag/sheetsnatcher/drop_inventory(mob/user)
	var/location = get_turf(src)
	for(var/obj/item/stack/sheet/S in contents)
		while(S.amount)
			var/obj/item/stack/sheet/N = new S.type(location)
			var/stacksize = min(S.amount,N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.amount)
			qdel(S) // todo: there's probably something missing here
	if(user.s_active)
		user.s_active.show_to(user)
	update_icon()

// Instead of removing
/obj/item/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W as obj, atom/new_location)
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.get_amount() > S.max_amount)
		var/obj/item/stack/sheet/temp = new S.type(src)
		temp.amount = S.amount - S.max_amount
		S.amount = S.max_amount

	return ..(S,new_location)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization


// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/storage/bag/cash
	icon = 'icons/obj/storage.dmi'
	icon_state = "cashbag"
	name = "Cash bag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	storage_slots = 50; //the number of cash pieces it can carry.
	max_combined_w_class = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * cash.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/coin,/obj/item/stack/spacecash)

// -----------------------------
//           Book bag
// -----------------------------

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

/*
 * Trays - Agouri
 */
/obj/item/storage/bag/tray
	name = "tray"
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
		spawn()
			for(var/i = 1, i <= rand(1,2), i++)
				if(I)
					step(I, pick(NORTH,SOUTH,EAST,WEST))
					sleep(rand(2,4))

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, 1)

	if(ishuman(M))
		if(prob(10))
			M.Weaken(4 SECONDS)

/obj/item/storage/bag/tray/update_icon_state()
	return

/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		. += image(icon = I.icon, icon_state = I.icon_state, layer = -1)

/obj/item/storage/bag/tray/cyborg

/obj/item/storage/bag/tray/cyborg/afterattack(atom/target, mob/user as mob)
	if(isturf(target) || istype(target,/obj/structure/table))
		var/found_table = istype(target,/obj/structure/table/)
		if(!found_table) //it must be a turf!
			for(var/obj/structure/table/T in target)
				found_table = TRUE
				break

		var/turf/dropspot
		if(!found_table) // don't unload things onto walls or other silly places.
			dropspot = user.loc
		else if(isturf(target)) // they clicked on a turf with a table in it
			dropspot = target
		else					// they clicked on a table
			dropspot = target.loc

		var/dropped_something = FALSE

		for(var/obj/item/I in contents)
			I.loc = dropspot
			contents.Remove(I)
			dropped_something = TRUE
			if(!found_table && isturf(dropspot))
				// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
				spawn()
					for(var/i = 1, i <= rand(1,2), i++)
						if(I)
							step(I, pick(NORTH,SOUTH,EAST,WEST))
							sleep(rand(2,4))
		if(dropped_something)
			if(found_table)
				user.visible_message("<span class='notice'>[user] unloads [user.p_their()] service tray.</span>")
			else
				user.visible_message("<span class='notice'>[user] drops all the items on [user.p_their()] tray.</span>")
		update_icon(UPDATE_OVERLAYS)
	return ..()


/obj/item/storage/bag/tray/cookies_tray
	var/cookie = /obj/item/reagent_containers/food/snacks/cookie

/obj/item/storage/bag/tray/cookies_tray/populate_contents() // By Azule Utama, thank you a lot!
	for(var/i in 1 to 6)
		var/obj/item/C = new cookie(src)
		C.in_inventory = TRUE
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/bag/tray/cookies_tray/sugarcookie
	cookie = /obj/item/reagent_containers/food/snacks/sugarcookie

/*
 *	Chemistry bag
 */

/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bag"
	desc = "A bag for storing pills, patches, and bottles."
	storage_slots = 50
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/food/pill,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle)
	resistance_flags = FLAMMABLE
/*
 *  Biowaste bag (mostly for xenobiologists)
 */

/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other biological materials."
	storage_slots = 25
	max_combined_w_class = 200
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/slime_extract, /obj/item/reagent_containers/food/snacks/monkeycube,
					/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/glass/beaker,
					/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/iv_bag,
					/obj/item/reagent_containers/hypospray/autoinjector/epinephrine)
	resistance_flags = FLAMMABLE

/*
 *	Mail bag
 */

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
