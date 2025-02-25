/obj/effect/cooking_container_lip
	icon = 'icons/obj/cooking/containers.dmi'
	icon_state = "blank"
	vis_flags = VIS_INHERIT_ID

/**
 * Cooking containers are used in ovens, fryers and so on, to hold multiple
 * ingredients for a recipe. They interact with the cooking process, and link
 * up with the cooking code dynamically. Originally sourced from the Aurora,
 * heavily retooled to actually work with PCWJ Holder for a portion of an
 * incomplete meal, allows a cook to temporarily offload recipes to work on
 * things factory-style, eliminating the need for 20 plates to get things done
 * fast.
 **/
/obj/item/reagent_containers/cooking
	icon = 'icons/obj/cooking/containers.dmi'
	w_class = WEIGHT_CLASS_SMALL
	volume = 240
	container_type = OPENCONTAINER
	visible_transfer_rate = null
	possible_transfer_amounts = null
	new_attack_chain = TRUE

	/// The [/datum/cooking/recipe_tracker] of the current food preparation.
	var/datum/cooking/recipe_tracker/tracker = null
	/// Icon state of the lip layer of the object
	var/lip
	var/obj/effect/cooking_container_lip/lip_effect
	/// A flat quality reduction for removing an unfinished recipe from the container.
	var/removal_penalty = 0
	/// Record of what cooking has been done on this food.
	var/list/cooker_data = list()
	/// Preposition for human-readable recipe e.g. "in a pain", "on a grill".
	var/preposition = "In"

/obj/item/reagent_containers/cooking/Initialize(mapload)
	. = ..()
	flags |= REAGENT_NOREACT
	if(lip)
		lip_effect = new
		lip_effect.icon_state = lip

	clear_cooking_data()

/obj/item/reagent_containers/cooking/Destroy()
	. = ..()
	qdel(tracker)
	qdel(lip_effect)

/obj/item/reagent_containers/cooking/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> to remove items from this.</span>"

	if(length(contents))
		. += get_content_info()

/obj/item/reagent_containers/cooking/proc/get_content_info()
	return "It contains [english_list(contents)]."

/obj/item/reagent_containers/cooking/proc/get_usable_status()
	if(tracker)
		return PCWJ_CONTAINER_BUSY
	if(length(contents) || reagents.total_volume > 0)
		return PCWJ_CONTAINER_BUSY

	return PCWJ_CONTAINER_AVAILABLE

/obj/item/reagent_containers/cooking/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!tracker && (contents.len || reagents.total_volume != 0))
		to_chat(user, "The [src] is full. Empty its contents first.")
		return ITEM_INTERACT_COMPLETE

	process_item(user, used)

	return ITEM_INTERACT_COMPLETE

/obj/item/reagent_containers/cooking/proc/process_item(mob/user, obj/used)
	if(!istype(used))
		return PCWJ_NO_STEPS

	if(!tracker)
		if(!(type in GLOB.pcwj_recipe_dictionary))
			return PCWJ_NO_STEPS

		var/list/container_recipes = GLOB.pcwj_recipe_dictionary[type]
		if(!length(container_recipes))
			return PCWJ_NO_STEPS

		tracker = new(src)

		for(var/datum/cooking/recipe/recipe in container_recipes)
			tracker.recipes_last_completed_step[recipe] = 0

	react_to_process(tracker.process_item_wrap(user, used), user, used)

/obj/item/reagent_containers/cooking/proc/react_to_process(reaction_status, mob/user, obj/used)
	if(istype(used, /obj/machinery/cooking) && reaction_status == PCWJ_NO_STEPS)
		// When a finished recipe is still sitting on a cooking machine, and the
		// cooking machine is sending periodic process pings as it is activated,
		// the container will still be processed and a tracker created, because
		// the result from the finished recipe counts as the potential input to
		// a new recipe. Which is valid; it may be the input to a new recipe.
		// But if it's not, we don't want a message to keep showing up as if the
		// player is trying to step through a recipe.
		return

	if(reaction_status == PCWJ_NO_STEPS && !tracker.recipe_started)
		to_chat(user, "<span class='notice'>You don't know what you'd begin to make with this.</span>")
		return

	switch(reaction_status)
		if(PCWJ_NO_RECIPES)
			to_chat(user, "<span class='notice'>You don't know what you'd begin to make with this.</span>")
		if(PCWJ_NO_STEPS)
			to_chat(user, "<span class='notice'>You get a feeling this wouldn't improve the recipe.</span>")
		if(PCWJ_SUCCESS)
			if(tracker.step_reaction_message && ismob(user))
				to_chat(user, "<span class='notice'>[tracker.step_reaction_message]</span>")

			update_appearance(UPDATE_ICON)
		if(PCWJ_COMPLETE)
			if(tracker.step_reaction_message && ismob(user))
				to_chat(user, "<span class='notice'>[tracker.step_reaction_message]</span>")
				to_chat(user, "<span class='notice'>You finish cooking with \the [src].</span>")
			QDEL_NULL(tracker)
			clear_cooking_data()
			update_appearance(UPDATE_ICON)

/obj/item/reagent_containers/cooking/proc/handle_burning()
	// Only create a burnt mess with objects in us, so boiled water doesn't
	// turn into a burnt mess when left on the stove too long.
	if(length(contents))
		clear()
		new/obj/item/food/badrecipe(src)
	else
		clear()

	update_appearance(UPDATE_ICON)

/obj/item/reagent_containers/cooking/proc/handle_ignition()
	clear()
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/reagent_containers/cooking/proc/do_empty(mob/user, atom/target, reagent_clear = TRUE)
	#ifdef PCWJ_DEBUG
	log_debug("cooking_container/do_empty() called!")
	#endif

	if(length(contents))
		for(var/contained in contents)
			var/atom/movable/AM = contained
			remove_from_visible(AM)
			if(!target)
				AM.forceMove(get_turf(src))
			else
				AM.forceMove(get_turf(target))

		if(ismob(user))
			to_chat(user, "<span class='notice'>You remove all the solid items from [src].</span>")

	if(reagent_clear)
		reagents.clear_reagents()

	update_icon()
	QDEL_NULL(tracker)
	clear_cooking_data()

/obj/item/reagent_containers/cooking/AltClick(mob/user)
	do_empty(user)

/// Deletes contents and reagents of container.
/obj/item/reagent_containers/cooking/proc/clear()
	QDEL_LIST_CONTENTS(contents)
	contents = list()
	reagents.clear_reagents()
	if(tracker)
		qdel(tracker)
		tracker = null
	clear_cooking_data()

/obj/item/reagent_containers/cooking/proc/cooker_temp_data(datum/cooking_surface/surface)
	if(!(surface.cooker_id in cooker_data))
		return null
	if(!(surface.temperature in cooker_data[surface.cooker_id]))
		return null

	return cooker_data[surface.cooker_id][surface.temperature]

/obj/item/reagent_containers/cooking/proc/set_cooker_data(datum/cooking_surface/surface, val)
	if(!(surface.cooker_id in cooker_data))
		cooker_data[surface.cooker_id] = list()

	cooker_data[surface.cooker_id][surface.temperature] = val

/obj/item/reagent_containers/cooking/proc/get_cooker_time(surface_name, temp)
	// can't fucking trust LAZYACCESSASSOC
	if(!(surface_name in cooker_data))
		return null
	if(!(temp in cooker_data[surface_name]))
		return null

	return cooker_data[surface_name][temp]

/obj/item/reagent_containers/cooking/proc/clear_cooking_data()
	cooker_data.Cut()

/obj/item/reagent_containers/cooking/update_icon()
	..()

	vis_contents.Remove(lip_effect)

	for(var/obj/content in vis_contents)
		remove_from_visible(content)

	for(var/i = length(contents), i >= 1, i--)
		var/obj/content = contents[i]
		add_to_visible(content)

	if(length(contents) && lip_effect)
		vis_contents += lip_effect

/obj/item/reagent_containers/cooking/proc/add_to_visible(obj/our_item)
	our_item.pixel_x = initial(our_item.pixel_x)
	our_item.pixel_y = initial(our_item.pixel_y)
	our_item.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	our_item.blend_mode = BLEND_INSET_OVERLAY
	our_item.transform *= 0.6
	vis_contents += our_item

/obj/item/reagent_containers/cooking/proc/remove_from_visible(obj/our_item)
	our_item.vis_flags = 0
	our_item.blend_mode = 0
	our_item.transform = null
	vis_contents.Remove(our_item)

/obj/item/reagent_containers/cooking/board
	name = "cutting board"
	desc = "Good for making sandwiches on, too."
	icon_state = "cutting_board"
	item_state = "cutting_board"
	preposition = "On"
	materials = list(MAT_WOOD = 5)

/obj/item/reagent_containers/cooking/sushimat
	name = "Sushi Mat"
	desc = "A wooden mat used for efficient sushi crafting."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sushi_mat"
	preposition = "On"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("rolled", "cracked", "battered", "thrashed")

/obj/item/reagent_containers/cooking/oven
	name = "oven dish"
	desc = "Put ingredients in this; designed for use with an oven. Warranty void if used."
	icon_state = "oven_dish"
	lip = "oven_dish_lip"
	materials = list(MAT_METAL = 10)

/obj/item/reagent_containers/cooking/pan
	name = "pan"
	desc = "An normal pan."
	icon_state = "pan"
	lip = "pan_lip"
	materials = list(MAT_METAL = 5)
	force = 8
	throwforce = 10
	attack_verb = list("smashed", "fried")
	hitsound = 'sound/weapons/smash.ogg'

/obj/item/reagent_containers/cooking/pot
	name = "cooking pot"
	desc = "Boil things with this. Maybe even stick 'em in a stew."
	icon_state = "pot"
	lip = "pot_lip"
	materials = list(MAT_METAL = 5)
	hitsound = 'sound/weapons/smash.ogg'
	removal_penalty = 5
	force = 8
	throwforce = 10
	attack_verb = list("clanged", "boiled")
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reagent_containers/cooking/deep_basket
	name = "deep fryer basket"
	desc = "Cwispy! Warranty void if used."
	icon_state = "deepfryer_basket"
	lip = "deepfryer_basket_lip"
	removal_penalty = 5

/obj/item/reagent_containers/cooking/grill_grate
	name = "grill grate"
	desc = "Primarily used to grill meat, place this on a grill and enjoy an ancient human tradition."
	icon_state = "grill_grate"
	materials = list(MAT_METAL = 5)

/obj/item/reagent_containers/cooking/bowl
	name = "prep bowl"
	desc = "A bowl for mixing, or tossing a salad. Not to be eaten out of"
	icon_state = "bowl"
	lip = "bowl_lip"
	materials = list(MAT_PLASTIC = 5)
	removal_penalty = 2

/obj/item/reagent_containers/cooking/icecream_bowl
	name = "freezing bowl"
	desc = "A stainless steel bowl that fits into the ice cream mixer."
	icon_state = "ice_cream_bowl"
	lip = "ice_cream_bowl_lip"
	var/freezing_time = 0
