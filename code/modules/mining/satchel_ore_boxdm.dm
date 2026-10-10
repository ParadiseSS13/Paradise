
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = TRUE
	pressure_resistance = 5 * ONE_ATMOSPHERE

/obj/structure/ore_box/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/stack/ore))
		if(user.drop_item())
			W.forceMove(src)
		return ITEM_INTERACT_COMPLETE
	else if(isstorage(W))
		var/obj/item/storage/S = W
		S.hide_from(user)
		if(length(S.contents))
			for(var/obj/item/stack/ore/O in S.contents)
				S.remove_from_storage(O, src) //This will move the item to this item's contents
			to_chat(user, SPAN_NOTICE("You empty the satchel into the box."))
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/ore_box/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return
	user.visible_message(SPAN_NOTICE("[user] pries [src] apart."), SPAN_NOTICE("You pry apart [src]."), SPAN_ITALICS("You hear splitting wood."))
	deconstruct(TRUE, user)

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		ui_interact(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		ui_interact(user)


/obj/structure/ore_box/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/ore_box/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreBox", name)
		ui.open()

/obj/structure/ore_box/ui_data(mob/user)
	var/list/data = list()
	var/list/assembled = list()
	for(var/obj/item/stack/ore/O in src)
		assembled[O.type] += O.amount
	var/list/ores = list()
	for(var/type in assembled)
		var/obj/item/stack/ore/O = type
		ores += list(list(
			"id" = "[type]",
			"name" = initial(O.name),
			"amount" = assembled[type],
			"icon" = initial(O.icon),
			"icon_state" = initial(O.icon_state)
		))
	data["ores"] = ores
	return data


/obj/structure/ore_box/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return
	if(!Adjacent(ui.user))
		return
	switch(action)
		if("empty")
			add_fingerprint(ui.user)
			dump_box_contents()
			to_chat(ui.user, SPAN_NOTICE("You empty the box."))
			return TRUE

/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/wood/W = new (loc, 4)
	if(user)
		W.add_fingerprint(user)
	dump_box_contents()
	qdel(src)

/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/stack/ore/O in src)
		if(QDELETED(O))
			continue
		if(QDELETED(src))
			break
		O.forceMove(loc)
		CHECK_TICK

/obj/structure/ore_box/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += SPAN_NOTICE("You can <b>Alt-Shift-Click</b> to empty the ore box.")

/obj/structure/ore_box/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents = FALSE)
	return ..()

/obj/structure/ore_box/AltShiftClick(mob/user)
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "You cannot interact with the ore box.")
		return

	add_fingerprint(user)

	if(length(contents) < 1)
		to_chat(user, SPAN_WARNING("The ore box is empty."))
		return

	dump_box_contents()
	to_chat(user, SPAN_NOTICE("You empty the ore box."))

