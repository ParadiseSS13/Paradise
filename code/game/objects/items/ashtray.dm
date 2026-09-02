/obj/item/ashtray
	icon = 'icons/ashtray.dmi'
	var/max_butts = 0
	var/icon_half = ""
	var/icon_full = ""
	var/material = /obj/item/stack/sheet/metal
	new_attack_chain = TRUE

/obj/item/ashtray/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!(istype(used, /obj/item/cigbutt) || istype(used, /obj/item/clothing/mask/cigarette) || istype(used, /obj/item/match)))
		return ..()

	if(length(contents) >= max_butts)
		to_chat(user, SPAN_WARNING("[src] is full!"))
		return ITEM_INTERACT_COMPLETE

	if(!user.unequip(used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/cigbutt) || istype(used, /obj/item/match))
		user.visible_message(
			SPAN_NOTICE("[user] places [used] in [src]."),
			SPAN_NOTICE("You put [used] in [src]."),
			SPAN_HEAR("You hear a soft tap.")
		)
		used.forceMove(src)
		add_fingerprint(user)
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE

	var/obj/item/clothing/mask/cigarette/cig = used
	if(cig.lit)
		user.visible_message(
			SPAN_NOTICE("[user] crushes [cig] in [src], putting it out."),
			SPAN_NOTICE("You crush [cig] in [src], putting it out."),
			SPAN_HEAR("You hear the crumpling of a snuffed cigarette.")
		)
		var/obj/item/butt = new cig.butt_type(src)
		cig.transfer_fingerprints_to(butt)
		qdel(cig)
		add_fingerprint(user)
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE

	used.forceMove(src)
	user.visible_message(
		SPAN_NOTICE("[user] places an entire unlit [cig] in [src]."),
		SPAN_NOTICE("You place [cig] in [src] without even smoking it. Why would you do that?"),
		SPAN_HEAR("You hear a soft tap.")
	)
	add_fingerprint(user)
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE

/obj/item/ashtray/update_icon_state()
	if(length(contents) == max_butts)
		icon_state = icon_full
	else if(length(contents) > max_butts * 0.5)
		icon_state = icon_half
	else
		icon_state = initial(icon_state)

/obj/item/ashtray/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(contents) == max_butts)
		desc += " It's stuffed full."
	else if(length(contents) > max_butts * 0.5)
		desc += " It's half-filled."
	if(length(contents))
		desc += " You can use <b>Alt-Click</b> to fish through the contents."

/obj/item/ashtray/proc/empty_tray()
	for(var/obj/item/I in contents)
		I.forceMove(loc)
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if(length(contents))
		visible_message(SPAN_WARNING("[src] slams into [hit_atom] spilling its contents!"))
	empty_tray()
	return ..()

/obj/item/ashtray/wrench_act(mob/user, obj/item/used)
	. = TRUE
	if(!used.use_tool(src, user, volume = used.tool_volume))
		return
	empty_tray()
	new material(drop_location(), 1)
	deconstruct()

// Do you want to get your entire unlit cigarette back out without dumping the whole tray? Well now you can.
/obj/item/ashtray/AltClick()
	if(!length(contents))
		return ..()
	if(!Adjacent(usr))
		return ..()
	if(!isliving(usr))
		return ..()
	var/atom/movable/choice = tgui_input_list(usr, "Choose a butt to remove.", "Ashtray fishing", contents)
	if(!choice)
		return
	if(!Adjacent(usr))
		to_chat(usr, SPAN_WARNING("You can't reach that far!"))
		return

	usr.visible_message(
		SPAN_NOTICE("[usr] fishes [choice] out of [src]."),
		SPAN_NOTICE("You [length(contents) > max_butts * 0.5 ? "get ash on yourself, but you fish" : "pick"] [choice] out of [src]."),
		SPAN_HEAR("You hear soot rustling.")
	)
	choice.forceMove(get_turf(src))
	choice.add_fingerprint(usr)
	add_fingerprint(usr)
	if(ishuman(usr))
		var/mob/living/carbon/human/user = usr
		user.equip_to_slot_if_possible(choice, (user.hand ? ITEM_SLOT_LEFT_HAND : ITEM_SLOT_RIGHT_HAND), disable_warning = TRUE)

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	max_butts = 8
	max_integrity = 8
	throwforce = 3
	material = /obj/item/stack/sheet/plastic
	materials = list(MAT_PLASTIC = 2000)

/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	max_butts = 16
	max_integrity = 16
	throwforce = 10
	materials = list(MAT_METAL = 2000)

/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	max_butts = 12
	max_integrity = 12
	throwforce = 6
	material = /obj/item/stack/sheet/glass
	materials = list(MAT_GLASS = 2000)
