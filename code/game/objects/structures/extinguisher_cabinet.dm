#define NO_EXTINGUISHER 0
#define NORMAL_EXTINGUISHER 1
#define MINI_EXTINGUISHER 2


/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher. \"Don't break the glass\" is written next to the handle."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher"
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 50
	/// The extinguisher stored inside us.
	var/obj/item/extinguisher/stored_extinguisher = null
	var/extinguishertype
	var/opened = FALSE
	var/material_drop = /obj/item/stack/sheet/metal

/obj/structure/extinguisher_cabinet/Initialize(mapload, direction = null)
	. = ..()
	name = "extinguisher cabinet"
	if(direction)
		setDir(direction)
		set_pixel_offsets_from_dir(28, -28, 30, -30)
	switch(extinguishertype)
		if(NO_EXTINGUISHER)
			return
		if(MINI_EXTINGUISHER)
			stored_extinguisher = new /obj/item/extinguisher/mini(src)
		else
			stored_extinguisher = new /obj/item/extinguisher(src)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/extinguisher_cabinet/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<b>Alt-click</b> to [opened ? "close":"open"] it.")
	. += SPAN_NOTICE("It looks like it can be <b>welded</b> off the wall.")

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	if(!iscarbon(user) && !isrobot(user))
		return
	toggle_open(user)

/obj/structure/extinguisher_cabinet/Destroy()
	QDEL_NULL(stored_extinguisher)
	return ..()

/obj/structure/extinguisher_cabinet/ex_act(severity)
	if(stored_extinguisher)
		stored_extinguisher.ex_act(severity)
	..()

/obj/structure/extinguisher_cabinet/handle_atom_del(atom/A)
	if(A == stored_extinguisher)
		stored_extinguisher = null
		update_icon(UPDATE_ICON_STATE)

/obj/structure/extinguisher_cabinet/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/extinguisher))
		return NONE

	if(isalien(user) || user.a_intent == INTENT_HARM)
		return NONE

	if(!opened)
		toggle_open(user)
		return ITEM_INTERACT_COMPLETE

	if(stored_extinguisher)
		to_chat(user, SPAN_WARNING("[src] already contains \a [stored_extinguisher.name]!"))
		return ITEM_INTERACT_COMPLETE

	if(isrobot(user))
		to_chat(user, SPAN_WARNING("You cannot store [used] in [src], it's attached to you!"))
		return ITEM_INTERACT_COMPLETE

	if(!user.transfer_item_to(used, src))
		to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
		return ITEM_INTERACT_COMPLETE

	stored_extinguisher = used
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, SPAN_NOTICE("You place [used] in [src]."))
	return ITEM_INTERACT_COMPLETE

/obj/structure/extinguisher_cabinet/welder_act(mob/user, obj/item/I)
	if(stored_extinguisher)
		to_chat(user, SPAN_WARNING("You need to remove [stored_extinguisher] before deconstructing [src]!"))
		return
	if(!opened)
		to_chat(user, SPAN_WARNING("Open [src] before cutting it apart!"))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isalien(user))
		return

	if(!opened || !stored_extinguisher)
		toggle_open(user)
		return

	if(isrobot(user))
		to_chat(user, SPAN_WARNING("You cannot interface with [stored_extinguisher]!"))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_DANGER("You try to move your [temp.name], but cannot!"))
			return

	if(stored_extinguisher)
		user.put_in_hands(stored_extinguisher)
		user.visible_message(
			SPAN_NOTICE("[user] takes [stored_extinguisher] from [src]."),
			SPAN_NOTICE("You take [stored_extinguisher] from [src].")
		)
		stored_extinguisher = null
		update_icon(UPDATE_ICON_STATE)

/obj/structure/extinguisher_cabinet/attack_robot(mob/living/user)
	if(Adjacent(user))
		attack_hand()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(!opened || !stored_extinguisher)
		toggle_open(no_user = TRUE) // It's spoooooky!

	if(stored_extinguisher)
		stored_extinguisher.loc = loc
		to_chat(user, SPAN_NOTICE("You telekinetically remove [stored_extinguisher] from [src]."))
		stored_extinguisher = null

/obj/structure/extinguisher_cabinet/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		broken = TRUE
		opened = TRUE
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null
		update_icon(UPDATE_ICON_STATE)

/obj/structure/extinguisher_cabinet/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null
	qdel(src)

/obj/structure/extinguisher_cabinet/update_icon_state()
	icon_state = "extinguisher" // Needs to reset the state with every update

	if(stored_extinguisher)
		if(istype(stored_extinguisher, /obj/item/extinguisher/mini))
			icon_state += "_mini"
		else
			icon_state += "_full"

	if(!opened)
		icon_state += "_closed"

/obj/structure/extinguisher_cabinet/proc/toggle_open(mob/user, no_user = FALSE)
	if(no_user)
		src.visible_message(
			SPAN_WARNING("[src] swings open!"),
			SPAN_HEAR("You hear a latch clicking.")
		)
	else
		user.visible_message(
			SPAN_NOTICE("[user] opens [src]."),
			SPAN_NOTICE("You open [src]."),
			SPAN_HEAR("You hear a latch clicking.")
		)
	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	opened = !opened
	update_icon(UPDATE_ICON_STATE)

/obj/structure/extinguisher_cabinet/empty
	extinguishertype = NO_EXTINGUISHER

#undef NO_EXTINGUISHER
#undef NORMAL_EXTINGUISHER
#undef MINI_EXTINGUISHER
