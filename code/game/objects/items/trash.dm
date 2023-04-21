#define ROTTENESS_FRESH 1
#define ROTTENESS_DECOMPOSING 2
#define ROTTENESS_ROTTEN 3

#define DECOMPOSE_RUST 0.5 //metals
#define DECOMPOSE_MOLD 0.3 //Food
#define DECOMPOSE_DEGRADE 1 //plastics & wrappers
#define DECOMPOSE_DISINTEGRATE 0.8 //paper

#define TRASH_ITEMS list(/obj/item/trash, /obj/item/paper, /obj/item/reagent_containers/food, /obj/item/organ)

//------->	This file includes:
//------->	Trashbags
//------->	Trashbag rolls
//------->	Trash Pokers
//------->	Liquid Garbage
//------->	[The Decay Handling datum]
//------->	Trash Items

//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]
// ---------- TRASH BAGS -----------------------------------------------------
//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]

/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	belt_icon = "trashbag"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	slot_flags = null
	storage_slots = 30
	max_combined_w_class = 30
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)
	allow_quick_empty = FALSE
	var/torn_path = /obj/item/trash/trashbag_trash
	var/can_decompose = DECOMPOSE_DEGRADE
	var/decay_counter = 0
	var/decay_amount = ROTTENESS_FRESH //starts @ 1 etc
	var/last_temp_check_time

/obj/item/storage/bag/trash/examine(mob/user)
	. = ..()
	switch(decay_amount)
		if(ROTTENESS_DECOMPOSING)
			. += "It's been out baking in the station lights for a while, its odor is disgusting."
		if(ROTTENESS_ROTTEN)
			. += "It's been neglected for too long! Its all but mush, its odor is piercingly noxious."

/obj/item/storage/bag/trash/can_be_inserted(obj/item/I, stop_messages)
	. = ..()
	if(I.type == type && length(I.contents) <= 0)
		return TRUE

/obj/item/storage/bag/trash/liquid_garbage_act(volume)
	return //trashbags do not transfer drips

/obj/item/storage/bag/trash/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	//collision_damage()
	if(decay_amount >= ROTTENESS_ROTTEN)
		if(!istype(hit_atom, /obj/machinery/conveyor))
			splat(hit_atom)

/obj/item/storage/bag/trash/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()

	if(decay_amount == ROTTENESS_ROTTEN)
		splat()

	var/knockdown_duration

	switch(length(contents))
		if(21 to INFINITY)
			knockdown_duration = 2 SECONDS
			playsound(get_turf(M),'sound/items/eatfood.ogg', 50, 1, -1)
		if(11 to 20)
			knockdown_duration = 1 SECONDS
		if(1 to 10)
			return
		else
			return

	add_fingerprint(user)
	M.KnockDown(knockdown_duration)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.apply_damage(force * 2, BRUTE, "head")
	else
		M.take_organ_damage(force * 2)
	return

/obj/item/storage/bag/trash/proc/splat(atom/target)
	var/roach_amount = rand(3,8)
	var/garbage_gibs_amount = rand(3, (length(contents) / 2))
	var/turf/splat_turf = get_turf(src)
	var/list/targets_turfs = range(2, splat_turf)
	var/list/contents_throwing = list()
	contents_throwing |= contents

	playsound(splat_turf,'sound/items/garbage_splat.ogg', 80, 1, 10)
	take_damage(max_integrity, BRUTE)

	if(decay_amount < ROTTENESS_ROTTEN && obj_integrity)
		return

	for(var/i in 1 to roach_amount)
		var/atom/movable/to_throw = new /mob/living/simple_animal/cockroach(splat_turf)
		to_throw.throw_at(targets_turfs[rand(1, length(targets_turfs))], 1, 1)

	for(var/i in 1 to garbage_gibs_amount)
		var/atom/movable/to_throw = new /obj/effect/decal/cleanable/garbage/gibs(splat_turf)
		to_throw.throw_at(targets_turfs[rand(1, length(targets_turfs))], 3, 1)

	new /obj/effect/decal/cleanable/garbage(splat_turf)

	for(var/atom/movable/i in contents_throwing)
		i.forceMove(splat_turf)
		i.throw_at(targets_turfs[rand(1, length(targets_turfs))], 2, 1)

/obj/item/storage/bag/trash/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.get_active_hand())
			if(H.l_store == src)	//Prevents opening if it's in a pocket.
				H.put_in_hands(src)
				H.l_store = null
				return
			if(H.r_store == src)
				H.put_in_hands(src)
				H.r_store = null
				return

	orient2hud(user)
	if(loc == user)
		if(user.s_active)
			user.s_active.close(user)
		if(alert("Are you sure you want to check inside? This plastic is rather flimsy, and the contents smell bad.",,"Yes","No") != "Yes")
			return
		take_damage(35, BRUTE)
		if(obj_integrity)
			show_to(user)
	else
		..()
	add_fingerprint(user)

/obj/item/storage/bag/trash/MouseDrop(obj/over_object)
	if(alert("Are you sure you want to check inside? This plastic is rather flimsy, and the contents smell bad.",,"Yes","No") != "Yes")
		return
	take_damage(35, BRUTE)
	..()

/obj/item/storage/bag/trash/handle_item_insertion(obj/item/I, prevent_warning)
	if(!length(contents))
		START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/storage/bag/trash/remove_from_storage(obj/item/I, atom/new_location)
	.=..()
	if(!length(contents))
		STOP_PROCESSING(SSobj, src)
	if(obj_integrity > 0)
		if(usr)
			to_chat(usr, "<span class='warning'>The plastic streches and tears with the effort of removing [I]!</span>")
		take_damage(25, BRUTE)

/obj/item/storage/bag/trash/process()
	if(GLOB.trash_handler.handle_decay(src, 1, FALSE))
		update_icon_state(UPDATE_ICON_STATE)
		for(var/obj/item/trash/T in contents)
			if(T.decay_amount < decay_amount)
				T.decay_amount = decay_amount

/obj/item/storage/bag/trash/play_attack_sound(damage_amount, damage_type, damage_flag)
	if(damage_amount > 30 && length(contents) >= 2)
		playsound(get_turf(src),'sound/items/garbage_check.ogg', 50, 1)
	else
		playsound(get_turf(src),'sound/items/garbage_access.ogg', 50, 1)

/obj/item/storage/bag/trash/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!</span>")
	playsound(loc, 'sound/items/eatfood.ogg', 50, 1, -1)
	return TOXLOSS

/obj/item/storage/bag/trash/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(!isliving(AM))
		return

	var/mob/living/M = AM
	if(M.mob_size <= MOB_SIZE_SMALL)
		return

	if(decay_amount == ROTTENESS_ROTTEN && isturf(loc))
		playsound(loc,'sound/items/garbage_tread.ogg', 50, 1, -1)
		splat()

/obj/item/storage/bag/trash/Moved(atom/OldLoc, Dir, Forced)
	. = ..()

	if(isturf(loc))
		if(!isturf(OldLoc))
			update_icon_state(UPDATE_ICON_STATE)
			pixel_x = rand(-8,8)
			pixel_y = rand(-8,8)
		else if(isturf(OldLoc) && decay_amount >= ROTTENESS_ROTTEN)
			message_admins("spawn trash trail")
	if(ishuman(OldLoc) && !ishuman(loc))
		UnregisterSignal(OldLoc, COMSIG_MOVABLE_MOVED)
	else if(ishuman(loc) && !ishuman(OldLoc))
		update_icon_state(UPDATE_ICON_STATE)
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(leak))

/obj/item/storage/bag/trash/proc/leak()
	SIGNAL_HANDLER

	if(decay_amount < ROTTENESS_ROTTEN)
		return
	take_damage(5 ,BRUTE)
	new /obj/effect/decal/cleanable/garbage/drip(get_turf(src))

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

	if(decay_amount > ROTTENESS_FRESH)
		icon_state = "[icon_state]-[decay_amount == ROTTENESS_DECOMPOSING ? "deco" : "rot"]"

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	else if(isturf(loc))
		icon_state = "[icon_state]_g"

/obj/item/storage/bag/trash/obj_destruction(damage_flag)
	var/loc_cache = loc
	var/human_loc_target
	var/mob/living/carbon/human/H
	var/turf/my_turf = get_turf(src)
	visible_message("<span class='boldwarning'>[src] tears open completely!</span>")
	for(var/obj/O in contents)
		remove_from_storage(O, my_turf)
	if(ishuman(loc_cache))
		H = loc_cache
		if(H.get_inactive_hand() == src)
			human_loc_target = "inactive"
		else
			human_loc_target = "active"
	. = ..()
	var/obj/item/trash/trashed_bag = new torn_path(loc_cache)
	if(human_loc_target && H)
		if(human_loc_target == "inactive")
			H.put_in_inactive_hand(trashed_bag)
		else
			H.put_in_active_hand(trashed_bag)

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
	torn_path = /obj/item/trash/trashbag_trash/bluespace






//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]
// ---------- TRASH BAG ROLLS -----------------------------------------------------
//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]

/obj/item/stack/trashbag_roll
	origin_tech = "engineering=1;materials=1"
	name = "trashbag roll"
	desc = "A roll of trashbags, with this theres no mess to large to handle!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashroll"
	singular_name = "trashbag"
	w_class = WEIGHT_CLASS_TINY
	amount = 6
	max_amount = 6
	materials = list(MAT_PLASTIC=1000) // 3 plastic sheets is the recipe, 1/2 a sheet per bag (1 sheet = 2000)
	var/singular_item_type = /obj/item/storage/bag/trash

/obj/item/stack/trashbag_roll/list_recipes(mob/user, recipes_sublist)
	return

/obj/item/stack/trashbag_roll/Initialize(mapload)
	. = ..()

	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/trashbag_roll/update_icon_state()
	var/amount = get_amount()
	switch(amount)
		if(1 to 2)
			icon_state = "[initial(icon_state)]_0"
		if(3)
			icon_state = "[initial(icon_state)]_1"
		if(4 to 5)
			icon_state = "[initial(icon_state)]_2"
		if(6 to INFINITY)
			icon_state = "[initial(icon_state)]_3"

/obj/item/stack/trashbag_roll/attack_hand(mob/user)
	if(isturf(loc))
		return ..()
	var/obj/item/created_thingy = new singular_item_type
	if(user.put_in_active_hand(created_thingy))
		if(amount >= 2)
			amount--
			update_icon_state(UPDATE_ICON_STATE)
		else
			qdel(src)
	else
		qdel(created_thingy)
		to_chat(user, "<span class='notice'>You need an empty hand to take out a trashbag!</span>")
	return null

/obj/item/stack/trashbag_roll/attackby(obj/item/W, mob/user, params)
	. = ..()

	if(istype(W, singular_item_type))
		to_chat(user, "<spawn class='notice'>This must have been folded by a space wizard or something, there is no way you can add this back into the roll.</span>")

/obj/item/stack/trashbag_roll/MouseDrop(obj/over_object)
	. = ..()
	if(!ismob(usr))
		return
	var/mob/M = usr

	if(!(istype(over_object, /obj/screen)) || M.Adjacent(over_object))
		return

	if(!M.restrained() && !M.stat)
		switch(over_object.name)
			if("r_hand")
				M.put_in_r_hand(src)
			if("l_hand")
				M.put_in_l_hand(src)
		add_fingerprint(usr)
		return

/obj/item/stack/trashbag_roll/change_stack(mob/user, amount)
	if(amount == 1)
		attack_hand(user)
		return
	. = ..()


/obj/item/stack/trashbag_roll/bluespace
	origin_tech = "engineering=1;materials=1"
	name = "bluespace trashbag roll"
	desc = "A roll of bluespace trashbags, made with the minty freshness of bluespace to warp away odors! If they aren't here they aren't your problem!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bluetrashroll"
	singular_name = "bluespace trashbag"
	materials = list(MAT_PLASTIC=1000, MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PLASMA = 1500) // 3 plastic sheets is the recipe, 1/2 a sheet per bag (1 sheet = 2000)
	singular_item_type = /obj/item/storage/bag/trash/bluespace






//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]
// ---------- TRASH POKER -----------------------------------------------------
//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]

/obj/item/twohanded/trash_poker
	icon_state = "trash_poker0"
	name = "trash poker"
	desc = "A key item in the arsenal of any good Janitor, or bluepace-side workordered space felons"
	force = 5
	throwforce = 15
	sharp = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 10
	toolspeed = 0.1
	attack_verb = list("poked", "pierced", "jabbed", "needled")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/crowbar.ogg'
	max_integrity = 200
	var/max_storage = 3

/obj/item/twohanded/trash_poker/Initialize(mapload)
	. = ..()
	wield_message = "<span class='notice'>You clean off the point of the [src], dumping everything onto the ground.</span>"

/obj/item/twohanded/trash_poker/examine(mob/user)
	. = ..()
	var/contents_length = length(contents)
	if(contents_length)
		var/message = "Its got "
		for(var/obj/item/I in contents)
			message +=  contents_length >= 2 && I == contents[contents_length - 1] ? "[I], and " : "[I], "
		message += " poked onto its point."
		. += message

/obj/item/twohanded/trash_poker/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "trash_poker[wielded]"

/obj/item/twohanded/trash_poker/afterattack(atom/target, mob/user, proximity, params)
	. = ..()

	//none of this works without a human user (dexterity or something :P)
	if(!ishuman(loc) || loc != user || !istype(target, /obj/item/trash) || ishuman(target.loc))
		return

	var/is_trash = FALSE
	for(var/i in TRASH_ITEMS)
		if(istype(target, i))
			is_trash = TRUE
			break

	if(!is_trash)
		return

	var/mob/living/carbon/human/human_location = loc
	var/obj/item/thingamagig = human_location.get_inactive_hand()
	var/obj/item/item_target = target

	//if we are attacking a trashbag, put everything on the poker into it
	if(istype(item_target, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/my_trashbag = item_target
		for(var/obj/item/I in contents)
			if(my_trashbag.can_be_inserted(I))
				my_trashbag.handle_item_insertion(I)
		my_trashbag.update_icon_state(UPDATE_ICON_STATE)
		return

	//can we actually pick anything up?
	if(length(contents) >= max_storage)
		to_chat(user, "<span class='notice'>There is no more room on [src]!.</span>")
		return

	//pick it up!
	item_target.forceMove(src)
	to_chat(user, "<span class='notice'>You pick up [item_target] on the end of the poker.</span>")

	//do we have a trashbag in our other hand? place the trash in there if we do
	if(istype(thingamagig, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/my_trashbag = thingamagig

		for(var/obj/item/I in contents)
			if(my_trashbag.can_be_inserted(I))
				my_trashbag.handle_item_insertion(I)

		thingamagig.update_icon_state(UPDATE_ICON_STATE)
		return

/obj/item/twohanded/trash_poker/wield(mob/living/carbon/user)
	. = ..()
	var/turf/my_turf = get_turf(user)
	for(var/obj/item/I in contents)
		I.forceMove(my_turf)






//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]
// ---------- LIQUID GARBAGE -----------------------------------------------------
//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]

/datum/reagent/liquid_garbage
	name = "Liquid Garbage"
	id = "liquid_garbage"
	description = "This is a fetid putrid mass of goop, grossness incarnate."
	reagent_state = LIQUID
	color = "#8b8b24" // rgb: 0, 100, 200
	taste_description = "water"
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "glass_clear"
	drink_name = "Glass of Liquid Garbage"
	drink_desc = "This is vileness incarnate, its putrid and fetid."

/datum/reagent/liquid_garbage/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	M.liquid_garbage_act(volume)

/mob/living/proc/liquid_garbage_act(volume)
	//dirty part holding trash, or the entire body if not specified
	var/turf/T = get_turf(src)
	T.liquid_garbage_act(volume)

/datum/reagent/liquid_garbage/reaction_turf(turf/T, volume)
	T.liquid_garbage_act(volume)

/turf/proc/liquid_garbage_act(volume)
	if(volume && volume <= 5)
		new /obj/effect/decal/cleanable/garbage/drip(src)
	else
		new /obj/effect/decal/cleanable/garbage(src)

/datum/reagent/liquid_garbage/reaction_obj(obj/O, volume)
	O.liquid_garbage_act(volume)

/obj/proc/liquid_garbage_act(volume)
	var/turf/T = get_turf(src)
	T.liquid_garbage_act(volume)

// I am not making this a child of /obj/effect/decal/cleanable/blood because its stinky dog water
/obj/effect/decal/cleanable/garbage
	name = "liquid garbage"
	var/dryname = "crusty garbage"
	desc = "It's putrid and voliatile, grossness incarnate."
	var/drydesc = "It's dry and crusty. Someone is not doing their job."
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	var/base_icon = 'icons/effects/blood.dmi'
	var/basecolor = "#8b8b24" // Color when wet.
	var/dry_timer = 0
	var/amount = 5
	alpha = 220

/obj/effect/decal/cleanable/garbage/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	forceMove(get_turf(hit_atom))
	update_icon(UPDATE_ICON)

/obj/effect/decal/cleanable/garbage/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/garbage/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON)
	if(!.)
		dry_timer = addtimer(CALLBACK(src, PROC_REF(dry)),  1 MINUTES, TIMER_STOPPABLE)

/obj/effect/decal/cleanable/garbage/update_icon()
	var/turf/T = get_turf(src)
	if(T && (T.opacity && T.density || locate(/obj/structure/window) in T))
		plane = GAME_PLANE
		layer = ABOVE_WINDOW_LAYER
		icon_state = "splatter[pick("1","2","3","4","5","6")]"
	color = basecolor
	..()

/obj/effect/decal/cleanable/garbage/proc/dry()
	name = dryname
	desc = drydesc
	basecolor = "#5f5700"
	color = basecolor
	amount = 0
	alpha = 255

/obj/effect/decal/cleanable/garbage/drip
	name = "drips of liquid garbage"
	desc = "A drop of mess in an ocean of clean."
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1", "2", "3", "4", "5")
	amount = 0
	bloodiness = 0
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/garbage/drip/Initialize(mapload)
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(-6, 6)

/obj/effect/decal/cleanable/garbage/gibs
	//colored and using custom sprites for each garbage type
	name = "congealed blob of liquid garbage"
	desc = "rancid, putrid, fetid, grossness, just looking at it makes you sick."
	random_icon_states = list("gib1", "gib2", "gib4", "gib5", "gib6", "gibmid1","gibmid2","gibmid3","gibtorso_flesh")

/obj/effect/decal/cleanable/garbage/gibs/dry()
	return

/obj/effect/decal/cleanable/garbage/gibs/Crossed(atom/movable/O)
	. = ..()
	if(!isliving(O))
		return

	var/mob/living/M = O
	if(M.mob_size <= MOB_SIZE_SMALL)
		return

	//dirty shoes
	playsound(loc,'sound/items/garbage_tread.ogg', 50, 1, -1)
	new /obj/effect/decal/cleanable/garbage(get_turf(src))
	qdel(src)

/obj/effect/decal/cleanable/garbage/gibs/Moved(atom/OldLoc, Dir, Forced)
	. = ..()

	if(!isturf(loc))
		return

	new /obj/effect/decal/cleanable/garbage(loc)






//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]
// ---------- TRASH DECAYING PROC-----------------------------------------------------
//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]

//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//decay timings 1:2min --> 10 minutes, 20 minutes, 40 minutes
#define DECAY_TIMINGS list(5, 10, 20, INFINITY)

/datum/trash_handler
//this is so non-obj/item/trash things can also rot by calling this proc while having correct variables
/datum/trash_handler/proc/handle_decay(var/obj/item/trash/input_item, timing_multiplier=1, do_icon_operations=TRUE)
	/*!!!!!!--->items need to have these variables set<------!!!!!!!!!!
	[last_temp_check_time][can_decompose][decay_counter][decay_amount]
	--I'm not doing checks here since this is called by process()...
	--But yea, have these defined if you are going to call this proc*/

	. = FALSE

	// temp check based off the turf they're in
	var/turf/current_turf = get_turf(input_item)
	var/temperature_check
	if(world.time > input_item.last_temp_check_time + 10 SECONDS) //set to 10 seconds for debugging, should be 2 minutes
		var/datum/gas_mixture/environment = current_turf.return_air()
		switch(environment.temperature)
			if(0 to 273)
				temperature_check = FALSE //frozen
			if(274 to 280)
				temperature_check = 0.333 //refrigerated
			if(281 to 292)
				temperature_check = 0.666 //below room temp
			if(293 to INFINITY)
				temperature_check = 1.0 //room temp and above
		input_item.last_temp_check_time = world.time

		if(temperature_check && input_item.can_decompose == 1 ? TRUE : isturf(input_item.loc)) // temps warm enough for decay, and out in the toxic decaying air
			input_item.decay_counter += temperature_check * input_item.can_decompose

		// logic for spawning roaches here
		if(input_item.decay_amount == ROTTENESS_ROTTEN && prob(10*temperature_check))
			new /mob/living/simple_animal/cockroach(input_item.loc)
		else if(input_item.can_decompose == DECOMPOSE_DEGRADE && prob(input_item.decay_amount * input_item.can_decompose * 20))
			// make reagent amount and force it to interact with its loc
			var/datum/reagents/R = new/datum/reagents(30)
			input_item.reagents = R
			input_item.reagents.add_reagent("liquid_garbage", input_item.decay_amount != ROTTENESS_ROTTEN ? rand(1,5) : rand(6,30))
			input_item.reagents.reaction(input_item.loc)

		// logic for moving between decay states (fresh-->decomposing-->rotting-->mush)
		var/next_decay_level = DECAY_TIMINGS[input_item.decay_amount]
		if(input_item.decay_counter >= next_decay_level)
			input_item.decay_amount++
			if(!do_icon_operations)
				return TRUE
			switch(input_item.decay_amount)
				//if(1) 1 is fresh so no need
				if(2)
					//move from fresh to decomposing
					input_item.name = "[input_item.can_decompose == DECOMPOSE_RUST ? "rusting" : input_item.can_decompose == DECOMPOSE_MOLD ? "stale" : input_item.can_decompose == DECOMPOSE_DEGRADE ? pick("decomposing","smelly") : "disintegrating"] [input_item.name]"
					input_item.desc += " Its beginning to [input_item.can_decompose == DECOMPOSE_RUST ? "rust" : input_item.can_decompose == DECOMPOSE_MOLD ? "stale" : input_item.can_decompose == DECOMPOSE_DEGRADE ? pick("decay","decompose","smell") : "disintegrate"], gross!"
					var/image/I = image('icons/obj/trash.dmi',"deco")
					I.color = input_item.can_decompose == DECOMPOSE_RUST ? "#9b4519" : input_item.can_decompose == DECOMPOSE_MOLD ? "#887a90" : input_item.can_decompose == DECOMPOSE_DEGRADE ? pick("#34461f","#5f5700","#8b8b24") : rgb(101, 99, 101, 123)
					I.alpha = 120
					I.blend_mode = BLEND_INSET_OVERLAY
					input_item.overlays += I
				if(3)
					//move from decomposing to rotting
					input_item.name = "rotting [initial(input_item.name)]"
					input_item.desc  = "[initial(input_item.desc)] Its completly [input_item.can_decompose == DECOMPOSE_RUST ? "rusted" : input_item.can_decompose == DECOMPOSE_MOLD ? "covered in mold" : input_item.can_decompose == DECOMPOSE_DEGRADE ? pick("rotten","decayed") : "disintegrated"], disgusting!"
					var/image/I = image('icons/obj/trash.dmi',"deco")
					I.blend_mode = BLEND_INSET_OVERLAY
					I.color = rgb(255,0,255)
					input_item.color = input_item.can_decompose == DECOMPOSE_RUST ? "#a9572e" : input_item.can_decompose == DECOMPOSE_MOLD ? "#b1b1b1ff" : input_item.can_decompose == DECOMPOSE_DEGRADE ? pick("#4c593c","#5f5b30","#767654") : "#FFFFFF"
					I.color = input_item.can_decompose == DECOMPOSE_RUST ? "#9b4519" : input_item.can_decompose == DECOMPOSE_MOLD ? "#887a90" : input_item.can_decompose == DECOMPOSE_DEGRADE ? pick("#34461f","#5f5700","#8b8b24") : rgb(71, 66, 71)
					input_item.overlays += I
				if(4)
					//move from rotting to MUSH
					input_item.visible_message("<span class='warning'>[input_item] decays into a pile of mush!</span>")
					qdel(input_item)






//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]
// ---------- TRASH ITEMS-----------------------------------------------------
//[x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = WEIGHT_CLASS_TINY
	desc = "This is rubbish."
	resistance_flags = FLAMMABLE
	appearance_flags = KEEP_TOGETHER
	var/can_decompose = DECOMPOSE_DEGRADE
	var/decay_counter = 0
	var/decay_amount = 1 //starts @ 1 etc
	var/last_temp_check_time

/obj/item/trash/Initialize(mapload)
	. = ..()

	START_PROCESSING(SSobj, src)
	last_temp_check_time = world.time

/obj/item/trash/Destroy()
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/trash/process()
	if(!can_decompose)
		return PROCESS_KILL

	GLOB.trash_handler.handle_decay(src)

/obj/item/trash/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["metal"] += 2
	C.stored_comms["wood"] += 1
	C.stored_comms["glass"] += 1
	qdel(src)
	return TRUE

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"
	can_decompose = DECOMPOSE_DISINTEGRATE

/obj/item/trash/candy
	name = "Candy Wrapper"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "Cheesie honkers bag"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "Chips bag"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "Popcorn bag"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky bag"
	icon_state = "sosjerky"

/obj/item/trash/spacetwinkie
	name = "Space Twinkie Wrapper"
	icon_state = "space_twinkie"

/obj/item/trash/syndi_cakes
	name = "Syndi cakes Wrapper"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "Waffles tray"
	icon_state = "waffles"
	can_decompose = DECOMPOSE_RUST

/obj/item/trash/plate
	name = "plate"
	icon_state = "plate"
	resistance_flags = NONE
	can_decompose = FALSE

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"
	can_decompose = FALSE

/obj/item/trash/fried_vox
	name = "Kentucky Fried Vox"
	icon_state = "fried_vox_empty"
	item_state = "fried_vox_empty"
	slot_flags = SLOT_HEAD
	dog_fashion = /datum/dog_fashion/head/fried_vox_empty
	can_decompose = FALSE
	sprite_sheets = list(
	"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
	"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
	"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
	)

/obj/item/trash/pistachios
	name = "Pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "Semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "Tray"
	icon_state = "tray"
	resistance_flags = NONE
	can_decompose = DECOMPOSE_RUST

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"
	can_decompose = FALSE

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration Wrapper"
	icon_state = "liquidfood"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	var/is_glass = 0
	var/is_plastic = 0
	resistance_flags = NONE
	can_decompose = DECOMPOSE_RUST

/obj/item/trash/can/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/decompose_type_check), 1 SECONDS) // if these variables are set right after creating this proc call should work

/obj/item/trash/can/proc/decompose_type_check()
	if(is_glass)
		can_decompose = FALSE
	if(is_plastic)
		can_decompose = DECOMPOSE_DEGRADE

/obj/item/trash/gum
	name = "chewed gum"
	desc = "NOT free candy."
	icon_state = "gum"
	can_decompose = FALSE

/obj/item/trash/tastybread
	name = "bread tube"
	icon_state = "tastybread"

/obj/item/trash/spentcasing
	icon = 'icons/obj/ammo.dmi'
	name = "bullet casing"
	desc = "A spent bullet casing. Smells like cordite."
	icon_state = "gshell"
	can_decompose = DECOMPOSE_RUST

/obj/item/trash/tapetrash
	name = "old duct tape"
	icon_state = "tape"
	desc = "Not sticky anymore."
	throw_range = 1
	can_decompose = DECOMPOSE_DISINTEGRATE

/obj/item/trash/trashbag_trash
	name = "torn trashbag"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag_torn"
	desc = "The trash won."
	throw_range = 2

/obj/item/trash/trashbag_trash/bluespace
	name = "torn bluespace trashbag"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bluetrashbag_torn"

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return


#undef ROTTENESS_FRESH
#undef ROTTENESS_DECOMPOSING
#undef ROTTENESS_ROTTEN
