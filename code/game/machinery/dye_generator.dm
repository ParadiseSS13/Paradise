/obj/machinery/dye_generator
	name = "Dye Generator"
	desc = "A machine that synthesizes dye. Simply pick the color of your dreams and insert a dye bottle to dispense."
	icon = 'icons/obj/vending.dmi'
	icon_state = "barbervend"
	density = TRUE
	anchored = TRUE
	integrity_failure = 100
	idle_power_consumption = 40
	var/dye_color = "#FFFFFF"

/obj/machinery/dye_generator/Initialize(mapload)
	. = ..()
	power_change()

/obj/machinery/dye_generator/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(loc, 3)
	qdel(src)

/obj/machinery/dye_generator/power_change()
	if(has_power() && anchored)
		stat &= ~NOPOWER
		set_light(2, l_color = dye_color)
	else
		stat |= NOPOWER
		set_light(0)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/dye_generator/extinguish_light(force = FALSE)
	set_light(0)
	underlays.Cut()

/obj/machinery/dye_generator/update_overlays()
	. = ..()
	underlays.Cut()
	if(stat & (BROKEN|NOPOWER))
		. += "barbervend_off"
		if(stat & BROKEN)
			. += "barbervend_broken"
	if(light)
		underlays += emissive_appearance(icon, "barbervend_lightmask")

/obj/machinery/dye_generator/attack_hand(mob/user)
	..()
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	var/temp = tgui_input_color(user, "Please select a dye color", "Dye Color")
	if(isnull(temp))
		return
	dye_color = temp
	set_light(2, l_color = temp)
	user.visible_message(
		SPAN_NOTICE("The light on [src] changes to show a new dye color."),
		SPAN_NOTICE("You set [src] to dispense the new dye color."),
		SPAN_HEAR("[src] whirrs quietly as it prepares to dispense a new dye color.")
	)

/obj/machinery/dye_generator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_unfasten_wrench(user, used, time = 60))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/hair_dye_bottle))
		var/obj/item/hair_dye_bottle/HD = used
		user.visible_message(
			SPAN_NOTICE("[user] fills [HD] up with some dye."),
			SPAN_NOTICE("You fill [HD] up with some hair dye."),
			SPAN_HEAR("You hear a [src] dispensing hair foam.")
		)
		HD.dye_color = dye_color
		HD.update_icon()
		HD.add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/dye_generator/obj_break(damage_flag)
	if(!(stat & BROKEN))
		stat |= BROKEN
		update_icon(UPDATE_OVERLAYS)

//Hair Dye Bottle

/obj/item/hair_dye_bottle
	name = "hair dye bottle"
	desc = "A refillable bottle used for holding hair dyes of all sorts of colors."
	icon_state = "hairdyebottle"
	throw_speed = 4
	w_class = WEIGHT_CLASS_TINY
	var/dye_color = "#FFFFFF"
	new_attack_chain = TRUE

/obj/item/hair_dye_bottle/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/hair_dye_bottle/update_overlays()
	. = ..()
	var/image/I = new('icons/obj/items.dmi', "hairdyebottle-overlay")
	I.color = dye_color
	. += I

/obj/item/hair_dye_bottle/interact_with_atom(mob/living/carbon/human/target, mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HELP)
		return ..()

	if(!ishuman(target))
		return ..()

	var/dye_list = list()
	var/obj/item/organ/external/head/head_organ = target.get_organ("head")

	if(head_organ && !(head_organ.dna.species.bodyflags & BALD))
		dye_list += "hair"
		dye_list += "alt. hair theme"

	if(head_organ && !(head_organ.dna.species.bodyflags & SHAVED))
		dye_list += "facial hair"
		dye_list += "alt. facial hair theme"

	if(target.dna.species.bodyflags & HAS_SKIN_COLOR)
		dye_list += "body"

	if(!length(dye_list))
		to_chat(user, SPAN_WARNING("[target] doesn't have any dyeable features!"))
		return ITEM_INTERACT_COMPLETE

	var/what_to_dye = tgui_input_list(user, "Choose an area to apply the dye", "Dye Application", dye_list)
	if(!user.Adjacent(target))
		return ITEM_INTERACT_COMPLETE
	if(!(what_to_dye in dye_list))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_NOTICE("[user] starts dyeing [target]'s [what_to_dye]!"),
		SPAN_NOTICE("You start dyeing [target]'s [what_to_dye]!")
	)
	add_fingerprint(user)
	if(!do_after(user, 50, target = target))
		to_chat(user, SPAN_NOTICE("You stop dyeing [target]'s [what_to_dye]."))
		return ITEM_INTERACT_COMPLETE
	switch(what_to_dye)
		if("hair")
			target.change_hair_color(dye_color)
		if("alt. hair theme")
			target.change_hair_color(dye_color, TRUE)
		if("facial hair")
			target.change_facial_hair_color(dye_color)
		if("alt. facial hair theme")
			target.change_facial_hair_color(dye_color, TRUE)
		if("body")
			target.change_skin_color(dye_color)
	target.update_dna()
	user.visible_message(
		SPAN_NOTICE("[user] finishes dyeing [target]'s [what_to_dye]!"),
		SPAN_NOTICE("You finish dyeing [target]'s [what_to_dye]!")
	)
	return ITEM_INTERACT_COMPLETE
