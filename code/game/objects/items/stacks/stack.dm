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
	/// The energy storage datum that will be used with this stack. Used only with `/cyborg` type stacks.
	var/datum/robot_energy_storage/source
	/// Which `robot_energy_storage` to choose when this stack is created in cyborgs. Used only with `/cyborg` type stacks.
	var/energy_type
	/// How much energy using 1 sheet from the stack costs. Used only with `/cyborg` type stacks.
	var/cost = 1
	/// A list of recipes buildable with this stack.
	var/list/recipes = list()
	var/singular_name
	var/amount = 1
	var/to_transfer = 0
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	/// This path and its children should merge with this stack, defaults to src.type
	var/merge_type = null
	/// What sort of table is made when applying this stack to a frame?
	var/table_type
	/// If this stack has a dynamic icon_state based on amount / max_amount
	var/dynamic_icon_state = FALSE
	/// if true, then this item can't stack with subtypes
	var/parent_stack = FALSE

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	if(dynamic_icon_state) //If we have a dynamic icon state, we don't want item states to follow the same pattern.
		item_state = initial(icon_state)
	if(new_amount != null)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)
	if(!merge_type)
		merge_type = type
	if(merge && !(amount >= max_amount))
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				merge(S)
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

/obj/item/stack/Crossed(obj/O, oldloc)
	if(amount >= max_amount || ismob(loc)) // Prevents unnecessary call. Also prevents merging stack automatically in a mob's inventory
		return
	if(istype(O, merge_type) && !O.throwing)
		merge(O)
	..()

/obj/item/stack/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, merge_type) && !(amount >= max_amount))
		merge(AM)
	. = ..()

/obj/item/stack/Destroy()
	if(usr && usr.machine == src)
		usr << browse(null, "window=stack")
	return ..()

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

/obj/item/stack/attack_self(mob/user)
	ui_interact(user)

/obj/item/stack/attack_self_tk(mob/user)
	ui_interact(user)

/obj/item/stack/attack_tk(mob/user)
	if(user.stat || !isturf(loc)) return
	// Allow remote stack splitting, because telekinetic inventory managing
	// is really cool
	if(src in user.tkgrabbed_objects)
		var/obj/item/stack/F = split(user, 1)
		F.attack_tk(user)
		if(src && user.machine == src)
			spawn(0)
				interact(user)
	else
		..()

/obj/item/stack/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state = GLOB.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "StackCraft", name, 400, 400, master_ui, state)
		ui.set_autoupdate(TRUE)
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

	switch(action)
		if("make")
			var/datum/stack_recipe/recipe = locateUID(params["recipe_uid"])
			var/multiplier = text2num(params["multiplier"])
			return make(usr, recipe, multiplier)


/obj/item/stack/proc/recursively_build_recipes(list/recipes_to_iterate)
	var/list/recipes_data = list()
	for(var/recipe in recipes_to_iterate)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/single_recipe = recipe
			recipes_data["[single_recipe.title]"] = build_recipe_data(single_recipe)

		else if (istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/recipe_list = recipe
			recipes_data["[recipe_list.title]"] = recursively_build_recipes(recipe_list.recipes)

	to_chat(world, json_encode(recipes_data))

	return recipes_data

/obj/item/stack/proc/build_recipe_data(datum/stack_recipe/recipe)
	var/list/data = list()
	data["uid"] = recipe.UID()
	data["required_amount"] = recipe.req_amount
	data["result_amount"] = recipe.res_amount
	data["max_result_amount"] = recipe.max_res_amount
	return data

/obj/item/stack/use(used, check = TRUE)
	if(check && zero_amount())
		return FALSE
	if(is_cyborg)
		return source.use_charge(used * cost)
	if(amount < used)
		return FALSE
	amount -= used
	if(check)
		zero_amount()
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/stack/proc/make(mob/user, datum/stack_recipe/recipe_to_make, multiplier)
	if(get_amount() < 1 && !is_cyborg)
		qdel(src)
		return FALSE

	if(!validate_build(user, recipe_to_make, multiplier))
		return FALSE

	if(recipe_to_make.time)
		to_chat(usr, "<span class='notice'>Building [recipe_to_make.title]...</span>")
		if(!do_after(usr, recipe_to_make.time, target = user))
			return FALSE

		if(!validate_build(user, recipe_to_make, multiplier))
			return FALSE

	var/atom/created
	var/atom/drop_location = user.drop_location()
	if(recipe_to_make.max_res_amount > 1) //Is it a stack?
		created = new recipe_to_make.result_type(drop_location, recipe_to_make.res_amount * multiplier)
	else
		created = new recipe_to_make.result_type(drop_location)
	created.setDir(user.dir)

	use(recipe_to_make.req_amount * multiplier)

	recipe_to_make.post_build(src, created)
	if(isitem(created))
		user.put_in_hands(created)

	created.add_fingerprint(user)

	//BubbleWrap - so newly formed boxes are empty
	if(isstorage(created))
		for(var/obj/item/thing in created)
			qdel(thing)
	//BubbleWrap END

	return TRUE

/obj/item/stack/proc/validate_build(mob/builder, datum/stack_recipe/recipe_to_build, multiplier)
	if(!multiplier || multiplier <= 0 || multiplier > 50 || !IS_INT(multiplier)) // Href exploit checks
		message_admins("[key_name_admin(builder)] just attempted to href exploit sheet crafting with an invalid multiplier. Ban highly advised.")
		return FALSE

	if(get_amount() < recipe_to_build.req_amount * multiplier)
		if(recipe_to_build.req_amount * multiplier > 1)
			to_chat(builder, "<span class='warning'>You haven't got enough [src] to build \the [recipe_to_build.req_amount * multiplier] [recipe_to_build.title]\s!</span>")
		else
			to_chat(builder, "<span class='warning'>You haven't got enough [src] to build \the [recipe_to_build.title]!</span>")
		return FALSE

	var/turf/target_turf = get_turf(src)
	if(recipe_to_build.window_checks && !valid_window_location(target_turf, builder.dir))
		to_chat(builder, "<span class='warning'>\The [recipe_to_build.title] won't fit here!</span>")
		return FALSE

	if(recipe_to_build.one_per_turf && (locate(recipe_to_build.result_type) in target_turf))
		to_chat(builder, "<span class='warning'>There is another [recipe_to_build.title] here!</span>")
		return FALSE

	if(recipe_to_build.on_floor && !issimulatedturf(target_turf))
		to_chat(builder, "<span class='warning'>\The [recipe_to_build.title] must be constructed on the floor!</span>")
		return FALSE

	if(recipe_to_build.on_floor_or_lattice && !(issimulatedturf(target_turf) || locate(/obj/structure/lattice) in target_turf))
		to_chat(builder, "<span class='warning'>\The [recipe_to_build.title] must be constructed on the floor or lattice!</span>")
		return FALSE

	if(recipe_to_build.cult_structure)
		if(builder.holy_check())
			return FALSE

		if(!is_level_reachable(builder.z))
			to_chat(builder, "<span class='warning'>The energies of this place interfere with the metal shaping!</span>")
			return FALSE

	return TRUE

/obj/item/stack/proc/get_amount()
	if(!is_cyborg)
		return amount

	if(!source) // The energy source has not yet been initializied
		return 0
	return round(source.energy / cost)

/obj/item/stack/proc/get_max_amount()
	return max_amount

/obj/item/stack/proc/get_amount_transferred()
	return to_transfer

/obj/item/stack/proc/split(mob/user, amt)
	var/obj/item/stack/F = new type(loc, amt)
	F.copy_evidences(src)
	if(isliving(user))
		add_fingerprint(user)
		F.add_fingerprint(user)
	use(amt)
	return F

/obj/item/stack/attack_hand(mob/user)
	if(user.is_in_inactive_hand(src) && get_amount() > 1)
		change_stack(user, 1)
		if(src && usr.machine == src)
			spawn(0)
				interact(usr)
	else
		..()

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(is_cyborg)
		return
	if(!ishuman(usr))
		return
	if(amount < 1)
		return
	//get amount from user
	var/min = 0
	var/max = get_amount()
	var/stackmaterial = round(input(user, "How many sheets do you wish to take out of this stack? (Maximum: [max])") as null|num)
	if(stackmaterial == null || stackmaterial <= min || stackmaterial > get_amount())
		return
	change_stack(user,stackmaterial)
	to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack.</span>")

/obj/item/stack/proc/change_stack(mob/user,amount)
	var/obj/item/stack/F = new type(user, amount, FALSE)
	. = F
	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if((!parent_stack && istype(W, merge_type)) || (parent_stack && W.type == type))
		var/obj/item/stack/S = W
		merge(S)
		to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
	else
		return ..()

// Returns TRUE if the stack amount is zero.
// Also qdels the stack gracefully if it is.
/obj/item/stack/proc/zero_amount()
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		if(ismob(loc))
			var/mob/living/L = loc // At this stage, stack code is so horrible and atrocious, I wouldn't be all surprised ghosts can somehow have stacks. If this happens, then the world deserves to burn.
			L.unEquip(src, TRUE)
		if(amount < 1)
			// If you stand on top of a stack, and drop a - different - 0-amount stack on the floor,
			// the two get merged, so the amount of items in the stack can increase from the 0 that it had before.
			// Check the amount again, to be sure we're not qdeling healthy stacks.
			qdel(src)
		return TRUE
	return FALSE

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return FALSE
	var/transfer = get_amount()
	if(S.is_cyborg)
		transfer = min(transfer, round((S.source.max_energy - S.source.energy) / S.cost))
	else
		transfer = min(transfer, S.max_amount - S.amount)
	if(transfer <= 0)
		return
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	S.add(transfer)
	use(transfer)
	return transfer

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	blood_DNA			= from.blood_DNA
	fingerprints		= from.fingerprints
	fingerprintshidden	= from.fingerprintshidden
	fingerprintslast	= from.fingerprintslast
