/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */
/obj/item/stack
	origin_tech = "materials=1"
	/// Whether this stack is a `/cyborg` subtype or not.
	var/is_cyborg = FALSE
	/// The storage datum that will be used with this stack. Used only with `/cyborg` type stacks.
	var/datum/robot_storage/source
	/// Which `robot_energy_storage` to choose when this stack is created in cyborgs. Used only with `/cyborg` type stacks.
	var/energy_type
	/// How much energy using 1 sheet from the stack costs. Used only with `/cyborg` type stacks.
	var/cost = 1
	/// A list of recipes buildable with this stack.
	var/list/recipes = list()
	/// The singular name of this stack.
	var/singular_name
	/// The current amount of this stack.
	var/amount = 1
	var/to_transfer = 0
	/// The maximum amount of this stack. Also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/max_amount = 50
	/// The path and its children that should merge with this stack, defaults to src.type.
	var/merge_type
	/// The type of table that is made when applying this stack to a frame.
	var/table_type
	/// Whether this stack has a dynamic icon_state based on amount / max_amount.
	var/dynamic_icon_state = FALSE
	/// Whether this stack can't stack with subtypes.
	var/parent_stack = FALSE

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE)
	if(dynamic_icon_state && isnull(inhand_icon_state)) //If we have a dynamic icon state, we don't want inhand icon states to follow the same pattern.
		inhand_icon_state = initial(icon_state)

	if(new_amount != null)
		amount = new_amount

	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)

	if(!merge_type)
		merge_type = type

	. = ..()
	if(merge)
		for(var/obj/item/stack/item_stack in loc)
			if(item_stack == src)
				continue
			if(can_merge(item_stack))
				INVOKE_ASYNC(src, PROC_REF(merge_without_del), item_stack)
				// we do not want to qdel during initialization, so we just check whether or not we're a 0 count stack and let the hint handle deletion
				if(is_zero_amount(FALSE))
					return INITIALIZE_HINT_QDEL

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/update_icon_state()
	. = ..()
	if(!dynamic_icon_state)
		return

	var/state = CEILING((amount/max_amount) * 3, 1)
	if(state <= 1)
		icon_state = initial(icon_state)
		return

	icon_state = "[initial(icon_state)]_[state]"

/obj/item/stack/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	// Edge case. This signal will also be sent when src has entered the turf. Don't want to merge with ourselves.
	if(entered == src)
		return

	if(amount >= max_amount || ismob(loc)) // Prevents unnecessary call. Also prevents merging stack automatically in a mob's inventory
		return

	if(!entered.throwing && can_merge(entered))
		INVOKE_ASYNC(src, PROC_REF(merge), entered)

/obj/item/stack/hitby(atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(can_merge(hitting, inhand = TRUE))
		merge(hitting)
	. = ..()

/obj/item/stack/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		return

	if(is_cyborg)
		if(singular_name)
			. += "There is enough energy for [get_amount()] [singular_name]\s."
		else
			. += "There is enough energy for [get_amount()]."
		return

	if(singular_name)
		. += "There are [amount] [singular_name]\s in the stack."
	else
		. += "There are [amount] [name]\s in the stack."
	. +="<span class='notice'>Alt-click to take a custom amount.</span>"

/obj/item/stack/proc/add(newamount)
	if(is_cyborg)
		source.add_charge(newamount * cost)
	else
		amount += newamount
	update_icon(UPDATE_ICON_STATE)

/** Checks whether this stack can merge itself into another stack.
 *
 * Arguments:
 * - check: The [/obj/item/stack] to check for mergeability.
 * - inhand: `TRUE` if the stack should check should act like it's in a mob's hand, `FALSE` otherwise.
 */
/obj/item/stack/proc/can_merge(obj/item/stack/check, inhand = FALSE)
	// We don't only use istype here, since that will match subtypes, and stack things that shouldn't stack
	if(!istype(check, merge_type) || check.merge_type != merge_type)
		return FALSE
	if(amount <= 0 || check.amount <= 0) // no merging empty stacks that are in the process of being qdel'd
		return FALSE
	if(is_cyborg) // No merging cyborg stacks into other stacks
		return FALSE
	if(ismob(loc) && !inhand) // no merging with items that are on the mob
		return FALSE
	return TRUE

/obj/item/stack/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/stack/attack_self_tk(mob/user)
	ui_interact(user)

/obj/item/stack/attack_tk(mob/user)
	if(user.stat || !isturf(loc))
		return
	// Allow remote stack splitting, because telekinetic inventory managing
	// is really cool
	if(!(src in user.tkgrabbed_objects))
		..()
		return

	var/obj/item/stack/material = split(user, 1)
	material.attack_tk(user)
	if(src && user.machine == src)
		ui_interact(user)

/obj/item/stack/attack_hand(mob/user)
	if(!user.is_in_inactive_hand(src) && get_amount() > 1)
		..()
		return

	change_stack(user, 1)
	if(src && user.machine == src)
		ui_interact(user)

/obj/item/stack/attackby__legacy__attackchain(obj/item/thing, mob/user, params)
	if(!can_merge(thing, TRUE))
		return ..()

	var/obj/item/stack/material = thing
	if(merge(material))
		to_chat(user, "<span class='notice'>Your [material.name] stack now contains [material.get_amount()] [material.singular_name]\s.</span>")

/obj/item/stack/use(used, check = TRUE)
	if(check && is_zero_amount(TRUE))
		return FALSE

	if(is_cyborg)
		return source.use_charge(used * cost)

	if(amount < used)
		return FALSE

	amount -= used
	if(check && is_zero_amount(TRUE))
		return TRUE

	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	if(!in_range(src, user) || !ishuman(usr) || amount < 1 || is_cyborg)
		return

	// Get amount from user
	var/min = 0
	var/max = get_amount()
	var/stackmaterial = tgui_input_number(user, "How many sheets do you wish to take out of this stack? (Max: [max])", "Stack Split", max_value = max)
	if(isnull(stackmaterial) || stackmaterial <= min || stackmaterial > get_amount())
		return

	if(!Adjacent(user, 1))
		return

	change_stack(user,stackmaterial)
	to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack.</span>")

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackCraft", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(recipes)
	return data

/obj/item/stack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE

	var/mob/living/user = usr
	var/obj/item/stack/material = src
	switch(action)
		if("make")
			var/datum/stack_recipe/recipe = locateUID(params["recipe_uid"])
			var/multiplier = text2num(params["multiplier"])
			if(!recipe.try_build(user, material, multiplier))
				return FALSE

			var/obj/result
			result = recipe.do_build(user, material, multiplier, result)
			if(!result)
				return FALSE

			recipe.post_build(user, material, result)
			return TRUE

/**
 * Recursively builds the recipes data for the given list of recipes, iterating through each recipe.
 * If recipe is of type /datum/stack_recipe, it adds the recipe data to the recipes_data list with the title as the key.
 * If recipe is of type /datum/stack_recipe_list, it recursively calls itself, scanning the entire list and adding each recipe to its category.
 */
/obj/item/stack/proc/recursively_build_recipes(list/recipes_to_iterate)
	var/list/recipes_data = list()
	for(var/recipe in recipes_to_iterate)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/single_recipe = recipe
			recipes_data["[single_recipe.title]"] = build_recipe_data(single_recipe)

		else if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/recipe_list = recipe
			recipes_data["[recipe_list.title]"] = recursively_build_recipes(recipe_list.recipes)

	return recipes_data

/obj/item/stack/proc/build_recipe_data(datum/stack_recipe/recipe)
	var/list/data = list()
	var/obj/result = recipe.result_type

	data["uid"] = recipe.UID()
	data["required_amount"] = recipe.req_amount
	data["result_amount"] = recipe.res_amount
	data["max_result_amount"] = recipe.max_res_amount
	data["icon"] = result.icon
	data["icon_state"] = result.icon_state

	// DmIcon cannot paint images. So, if we have grayscale sprite, we need ready base64 image.
	if(recipe.result_image)
		data["image"] = recipe.result_image

	return data

/obj/item/stack/proc/get_amount()
	if(!is_cyborg)
		return amount

	if(!source) // The energy source has not yet been initializied
		return FALSE

	return round(source.amount / cost)

/obj/item/stack/proc/get_max_amount()
	return max_amount

/obj/item/stack/proc/get_amount_transferred()
	return to_transfer

/obj/item/stack/proc/split(mob/user, amount)
	var/obj/item/stack/material = new type(loc, amount, FALSE)
	material.copy_evidences(src)
	if(isliving(user))
		add_fingerprint(user)
		material.add_fingerprint(user)

	use(amount)
	return material

/obj/item/stack/proc/change_stack(mob/user,amount)
	var/obj/item/stack/material = new type(user, amount, FALSE)
	. = material
	material.copy_evidences(src)
	user.put_in_hands(material)
	add_fingerprint(user)
	material.add_fingerprint(user)
	use(amount)
	SStgui.update_uis(src)

/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/obj/item/stack/proc/is_zero_amount(delete_if_zero = TRUE)
	if(is_cyborg)
		return source.amount < cost

	if(amount < 1)
		if(delete_if_zero)
			qdel(src)
		return TRUE
	return FALSE

/**
 * Merges as much of src into material as possible.
 *
 * This calls use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/obj/item/stack/proc/merge_without_del(obj/item/stack/material)
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(QDELETED(material))
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(QDELETED(src))
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(material == src)
		CRASH("Stack attempted to merge into itself.")

	var/transfer = get_amount()
	if(material.is_cyborg)
		transfer = min(transfer, round((material.source.max_amount - material.source.amount) / material.cost))
	else
		transfer = min(transfer, material.max_amount - material.amount)

	if(pulledby)
		pulledby.start_pulling(material)

	material.copy_evidences(src)
	use(transfer, FALSE)
	material.add(transfer)

	return transfer

/**
 * Merges as much of src into material as possible.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/obj/item/stack/proc/merge(obj/item/stack/material)
	. = merge_without_del(material)
	is_zero_amount(TRUE)

/obj/item/stack/proc/copy_evidences(obj/item/stack/material)
	blood_DNA			= material.blood_DNA
	fingerprints		= material.fingerprints
	fingerprintshidden	= material.fingerprintshidden
	fingerprintslast	= material.fingerprintslast
