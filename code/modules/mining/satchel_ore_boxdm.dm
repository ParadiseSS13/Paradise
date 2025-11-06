
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
			to_chat(user, "<span class='notice'>You empty the satchel into the box.</span>")
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/ore_box/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return
	user.visible_message("<span class='notice'>[user] pries [src] apart.</span>", "<span class='notice'>You pry apart [src].</span>", "<span class='italics'>You hear splitting wood.</span>")
	deconstruct(TRUE, user)

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/proc/show_contents(mob/user)
	var/dat = "<b>The contents of the ore box reveal...</b><br>"
	var/list/assembled = list()
	for(var/obj/item/stack/ore/O in src)
		assembled[O.type] += O.amount
	for(var/type in assembled)
		var/obj/item/stack/ore/O = type
		dat += "[initial(O.name)] - [assembled[type]]<br>"

	dat += "<br><br><A href='byond://?src=[UID()];removeall=1'>Empty box</A>"
	var/datum/browser/popup = new(user, "orebox", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["removeall"])
		dump_box_contents()
		to_chat(usr, "<span class='notice'>You empty the box.</span>")
	updateUsrDialog()

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
		. += "<span class='notice'>You can <b>Alt-Shift-Click</b> to empty the ore box.</span>"

/obj/structure/ore_box/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents = FALSE)
	return ..()

/obj/structure/ore_box/AltShiftClick(mob/user)
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "You cannot interact with the ore box.")
		return

	add_fingerprint(user)

	if(length(contents) < 1)
		to_chat(user, "<span class='warning'>The ore box is empty.</span>")
		return

	dump_box_contents()
	to_chat(user, "<span class='notice'>You empty the ore box.</span>")
