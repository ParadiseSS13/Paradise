// MARK: Salvage Bench
/obj/structure/salvage_bench
	name = "decryptor assembly table"
	desc = "A table used with a decryptor schematic to assemble a schematic."
	icon = 'icons/obj/salvage/salvage_tools.dmi'
	icon_state = "schematics_workbench"
	anchored = TRUE
	/// The schematic loaded into the assembly table
	var/obj/item/salvage_decryptor_schematic/decryptor_schematic
	/// The ingredients inside the table
	var/list/stored_items = list()

/obj/structure/salvage_bench/examine(mob/user)
	. = ..()
	if(decryptor_schematic)
		. += SPAN_NOTICE("Currently displaying [decryptor_schematic].")
		if(LAZYLEN(decryptor_schematic.required_items))
			var/list/nice_list = list()
			for(var/B in decryptor_schematic.required_items)
				var/atom/A = B
				if(!ispath(A))
					continue
				nice_list += list("- [initial(A.name)] x[decryptor_schematic.required_items[A]]")
			. += SPAN_NOTICE("[decryptor_schematic] requires the following components:")
			for(var/S in nice_list)
				. += SPAN_NOTICE(S)
	if(!length(stored_items))
		return

	. += ""
	. += SPAN_NOTICE("[src] contains the following items:")
	var/list/checked_ingredients = list()
	for(var/obj/item/ingredient in stored_items)
		if(ingredient.type in checked_ingredients)
			continue
		var/count = count_by_type(stored_items, ingredient)
		. += SPAN_NOTICE("- [ingredient] x[count]")
		checked_ingredients += ingredient.type

/obj/structure/salvage_bench/update_overlays()
	. = ..()
	overlays.Cut()
	if(decryptor_schematic)
		. += image(icon = icon, icon_state = decryptor_schematic.icon_state + "_workbench")

/obj/structure/salvage_bench/AltClick(mob/user, modifiers)
	. = ..()
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return
	if(!length(stored_items))
		to_chat(user, SPAN_NOTICE("[src] has no ingredients to remove!"))
		return
	var/obj/item/item_to_remove = tgui_input_list(user, "Select an item", src, stored_items)
	user.put_in_hands(item_to_remove)
	stored_items -= item_to_remove

/obj/structure/salvage_bench/Destroy()
	for(var/obj/item/I in contents)
		I.forceMove(get_turf(src))
	. = ..()

/obj/structure/salvage_bench/attack_hand(mob/living/user)
	. = ..()
	if(!Adjacent(user))
		return
	if(!decryptor_schematic)
		return
	if(length(stored_items))
		if(tgui_alert(user, "Are you sure you want to remove the schematic? Doing so will dump the stored ingredients out of [src]!", "Confirm Schematic Removal", list("Yes", "No")) == "No")
			return
		for(var/obj/item/I in stored_items)
			I.forceMove(get_turf(src))
			stored_items -= I
	user.put_in_hands(decryptor_schematic)
	decryptor_schematic = null
	update_appearance()

/obj/structure/salvage_bench/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent != INTENT_HELP)
		return ..()
	if(istype(used, /obj/item/salvage_decryptor_schematic))
		if(decryptor_schematic)
			to_chat(user, SPAN_NOTICE("[src] already has an open schematic! Remove that first!"))
			return ITEM_INTERACT_COMPLETE
		if(used.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
			return ITEM_INTERACT_COMPLETE
		decryptor_schematic = used
		to_chat(user, SPAN_WARNING("You roll [used] out on [src]."))
		update_appearance()
		return ITEM_INTERACT_COMPLETE
	if(!decryptor_schematic)
		to_chat(user, SPAN_NOTICE("There is no schematic open to provide components to!"))
		return ITEM_INTERACT_COMPLETE
	if(!(used.type in decryptor_schematic.required_items))
		to_chat(user, SPAN_NOTICE("This object doesn't fit in [decryptor_schematic]'s requirements!"))
		return ITEM_INTERACT_COMPLETE
	if(used.flags & NODROP || !user.transfer_item_to(used, src))
		to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
		return ITEM_INTERACT_COMPLETE
	stored_items += used
	to_chat(user, SPAN_NOTICE("You add [used] to [src]'s components."))
	return ITEM_INTERACT_COMPLETE

/obj/structure/salvage_bench/hammer_act(mob/living/user, obj/item/hammer)
	. = ..()
	if(!decryptor_schematic)
		to_chat(user, SPAN_WARNING("There is no schematic open!"))
		return TRUE

	var/component_check = 1
	var/list/required = decryptor_schematic.required_items
	for(var/obj/O in stored_items)
		for(var/I in required)
			if(istype(O, I))
				required[I] -= 1
				break
	for(var/R in required)
		if(required[R] > 0)
			component_check = 0
			break
	if(!component_check)
		to_chat(user, SPAN_WARNING("There's not enough components to make [decryptor_schematic.decryptor_type.name]!"))
		return TRUE

	for(var/obj/item/ingredient in stored_items)
		stored_items -= ingredient
		qdel(ingredient)
	new decryptor_schematic.decryptor_type(get_turf(src))
	decryptor_schematic = null
	qdel(decryptor_schematic)
	playsound(src, 'sound/magic/fellowship_armory.ogg', 50, TRUE)
	update_appearance()
	return TRUE
