/obj/machinery/papershredder
	name = "paper shredder"
	desc = "For those documents you don't want seen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papershredder0"
	density = 1
	anchored = 1
	max_integrity = 100
	var/max_paper = 10
	var/paperamount = 0
	var/list/shred_amounts = list(
		/obj/item/photo = -1,
		/obj/item/shreddedp = 1,
		/obj/item/paper = 1,
		/obj/item/newspaper = 3,
		/obj/item/paper_bundle = 3
		)// use -1 if it doesn't generate paper

/obj/machinery/papershredder/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/electrolyzer(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)

	RefreshParts()

/obj/machinery/papershredder/wrench_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, I.tool_volume))
		return
	if(!anchored)
		to_chat(user, SPAN_NOTICE("You secure the [src] to the floor."))
	else
		to_chat(user, SPAN_NOTICE("You unsecure the [src] from the floor."))
	anchored = !anchored

/obj/machinery/papershreader/screwdriver_act(mob/living/user, obj/item/I)
	. = default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(!.)
		return
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/papershredder/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
		var/cut_hand = pick("l_hand", "r_hand")
		user.visible_message(
			SPAN_WARNING("[user] accidentally slides their fingers into [src]!"),
			SPAN_USERDANGER("Your fingers slip and jam them into [src]!")
		)
		user.apply_damage(5, BRUTE, cut_hand)
		user.drop_item(used)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/storage))
		empty_bin(user, used)
		return ITEM_INTERACT_COMPLETE

	var/paper_result
	for(var/shred_type in shred_amounts)
		if(istype(used, shred_type))
			paper_result = shred_amounts[shred_type]
			break

	if(isnull(paper_result))
		return ..()

	if(!anchored)
		to_chat(user, SPAN_WARNING("\The [src] must be anchored to the ground to operate!"))
		return ITEM_INTERACT_COMPLETE
	if(paperamount == max_paper)
		to_chat(user, SPAN_WARNING("\The [src] is full, please empty it before you continue."))
		return ITEM_INTERACT_COMPLETE

	if(paper_result > 0)
		paperamount += paper_result

	if(used.icon_state == "scrap")
		flick("papershredder_s_on", src)
	else if(used.icon_state == "paper_words")
		flick("papershredder_w_on", src)
	else if(used.icon_state == "paper_plane")
		flick("papershredder_p_on", src)
	else
		flick("papershredder_on", src)

	qdel(used)
	playsound(src.loc, 'sound/effects/papershred.ogg', 75, 1)
	to_chat(user, SPAN_NOTICE("You shred the paper."))

	if(paperamount > max_paper)
		to_chat(user, SPAN_DANGER("\The [src] was too full, and shredded paper goes everywhere!"))
		for(var/i=(paperamount-max_paper);i>0;i--)
			var/obj/item/shreddedp/SP = get_shredded_paper()
			SP.forceMove(get_turf(src))
			SP.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),1,5)
		paperamount = max_paper

	update_icon()
	return ITEM_INTERACT_COMPLETE

/obj/machinery/papershredder/AltClick(mob/user)
	if(!Adjacent(user) || user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(!paperamount)
		to_chat(user, SPAN_NOTICE("\The [src] is empty."))
		return

	if(!paperamount)
		to_chat(usr, SPAN_NOTICE("\The [src] is empty."))
		return

	empty_bin(usr)

/obj/machinery/papershredder/proc/empty_bin(var/mob/living/user, var/obj/item/storage/empty_into)

	// Sanity.
	if(empty_into && !istype(empty_into))
		empty_into = null

	if(empty_into && empty_into.contents.len >= empty_into.storage_slots)
		to_chat(user,  SPAN_NOTICE("\The [empty_into] is full."))
		return

	while(paperamount)
		var/obj/item/shreddedp/SP = get_shredded_paper()
		if(!SP) break
		if(empty_into)
			empty_into.handle_item_insertion(SP)
			if(empty_into.contents.len >= empty_into.storage_slots)
				break
	if(empty_into)
		if(paperamount)
			to_chat(user,  SPAN_NOTICE("You fill \the [empty_into] with as much shredded paper as it will carry."))
		else
			to_chat(user,  SPAN_NOTICE("You empty \the [src] into \the [empty_into]."))

	else
		to_chat(user,  SPAN_NOTICE("You empty \the [src]."))
	update_icon()

/obj/machinery/papershredder/proc/get_shredded_paper()
	if(!paperamount)
		return
	paperamount--
	return new /obj/item/shreddedp(get_turf(src))

/obj/machinery/papershredder/update_overlays()
	. = ..()
	switch(paperamount)
		if(2 to 3)
			. += "papershredder1"
		if(4 to 5)
			. += "papershredder2"
		if(6 to 7)
			. += "papershredder3"
		if(8 to 9)
			. += "papershredder4"
		if(10)
			. += "papershredder5"

/obj/item/shreddedp
	name = "shredded paper"
	desc = "The remains of a private, confidential, or otherwise sensitive document."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	throw_speed = 1

/obj/item/shreddedp/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(resistance_flags & ON_FIRE)
		to_chat(user, SPAN_WARNING("[src] is on fire!"))
		return ITEM_INTERACT_COMPLETE

	add_fingerprint(user)
	if(used.get_heat())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message(
				SPAN_WARNING("[user] accidentally ignites [user.p_themselves()]!"),
				SPAN_USERDANGER("You miss the [src] and accidentally light yourself on fire!")
			)
			user.drop_item_to_ground(used)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return ITEM_INTERACT_COMPLETE

		if(!Adjacent(user))
			return ITEM_INTERACT_COMPLETE

		user.drop_item_to_ground(src)
		user.visible_message(
			SPAN_DANGER("[user] lights [src] ablaze with [used]!"),
			SPAN_DANGER("You light [src] on fire!")
		)
		fire_act()
		return ITEM_INTERACT_COMPLETE
