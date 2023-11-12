/datum/personal_crafting
	var/busy
	var/viewing_category = 1 //typical powergamer starting on the Weapons tab
	var/viewing_subcategory = 1
	var/list/categories = list(
				CAT_WEAPONRY,
				CAT_ROBOT,
				CAT_MISC,
				CAT_PRIMAL,
				CAT_FOOD,
				CAT_DECORATIONS,
				CAT_CLOTHING)
	var/list/subcategories = list(
						list(	//Weapon subcategories
							CAT_WEAPON,
							CAT_AMMO),
						CAT_NONE, //Robot subcategories
						CAT_NONE, //Misc subcategories
						CAT_NONE, //Tribal subcategories
						list(	//Food subcategories
							CAT_CAKE,
							CAT_SUSHI,
							CAT_SANDWICH),
						list(	//Decoration subcategories
							CAT_DECORATION,
							CAT_HOLIDAY,
							CAT_LARGE_DECORATIONS),
						CAT_CLOTHING) //Clothing subcategories
	var/display_craftable_only = FALSE
	var/display_compact = TRUE





/*	This is what procs do:
	get_environment - gets a list of things accessable for crafting by user
	get_surroundings - takes a list of things and makes a list of key-types to values-amounts of said type in the list
	check_contents - takes a recipe and a key-type list and checks if said recipe can be done with available stuff
	check_tools - takes recipe, a key-type list, and a user and checks if there are enough tools to do the stuff, checks bugs one level deep
	construct_item - takes a recipe and a user, call all the checking procs, calls do_after, checks all the things again, calls requirements_deletion, creates result, calls CheckParts of said result with argument being list returned by deel_reqs
	requirements_deletion - takes recipe and a user, loops over the recipes reqs var and tries to find everything in the list make by get_environment and delete it/add to parts list, then returns the said list
*/




/datum/personal_crafting/proc/check_contents(datum/crafting_recipe/R, list/contents)
	contents = contents["other"]
	main_loop:
		for(var/A in R.reqs)
			var/needed_amount = R.reqs[A]
			for(var/B in contents)
				if(ispath(B, A))
					if(R.blacklist.Find(B))
						continue
					if(contents[B] >= R.reqs[A])
						continue main_loop
					else
						needed_amount -= contents[B]
						if(needed_amount <= 0)
							continue main_loop
						else
							continue
			return 0
	for(var/A in R.chem_catalysts)
		if(contents[A] < R.chem_catalysts[A])
			return 0
	return 1

/datum/personal_crafting/proc/get_environment(mob/user)
	. = list()
	. += user.r_hand
	. += user.l_hand
	if(!isturf(user.loc))
		return
	var/list/L = block(get_step(user, SOUTHWEST), get_step(user, NORTHEAST))
	for(var/A in L)
		var/turf/T = A
		if(T.Adjacent(user))
			for(var/B in T)
				var/atom/movable/AM = B
				if(AM.flags_2 & HOLOGRAM_2)
					continue
				. += AM
	for(var/slot in list(SLOT_HUD_RIGHT_STORE, SLOT_HUD_LEFT_STORE))
		. += user.get_item_by_slot(slot)


/datum/personal_crafting/proc/get_surroundings(mob/user)
	. = list()
	.["other"] = list() //paths go in here
	.["toolsother"] = list() // items go in here
	for(var/obj/item/I in get_environment(user))
		if(I.flags_2 & HOLOGRAM_2)
			continue
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			.["other"][I.type] += S.amount
		else
			if(istype(I, /obj/item/reagent_containers))
				var/obj/item/reagent_containers/RC = I
				if(RC.is_drainable())
					for(var/datum/reagent/A in RC.reagents.reagent_list)
						.["other"][A.type] += A.volume
			.["other"][I.type] += 1
		.["toolsother"][I] += 1

/datum/personal_crafting/proc/check_tools(mob/user, datum/crafting_recipe/R, list/contents)
	if(!R.tools.len) //does not run if no tools are needed
		return TRUE
	var/list/possible_tools = list()
	var/list/tools_used = list()
	for(var/obj/item/I in user.contents) //searchs the inventory of the mob
		if(isstorage(I))
			for(var/obj/item/SI in I.contents)
				if(SI.tool_behaviour) //filters for tool behaviours
					possible_tools += SI
		if(I.tool_behaviour)
			possible_tools += I

	possible_tools |= contents["toolsother"] // this add contents to possible_tools
	main_loop: // checks if all tools found are usable with the recipe
		for(var/A in R.tools)
			for(var/obj/item/I in possible_tools)
				if(A == I.tool_behaviour)
					tools_used += I
					continue main_loop
			return FALSE
	for(var/obj/item/T in tools_used)
		if(!T.tool_start_check(null, user, 0)) //Check if all our tools are valid for their use
			return FALSE
	return TRUE

/datum/personal_crafting/proc/check_pathtools(mob/user, datum/crafting_recipe/R, list/contents)
	if(!R.pathtools.len) //does not run if no tools are needed
		return TRUE
	var/list/other_possible_tools = list()
	for(var/obj/item/I in user.contents) // searchs the inventory of the mob
		if(isstorage(I))
			for(var/obj/item/SI in I.contents)
				other_possible_tools += SI.type	// filters type paths
		other_possible_tools += I.type

	other_possible_tools |= contents["other"] // this adds contents to the other_possible_tools
	main_loop: // checks if all tools found are usable with the recipe
		for(var/A in R.pathtools)
			for(var/I in other_possible_tools)
				if(ispath(I,A))
					continue main_loop
			return FALSE
	return TRUE

/datum/personal_crafting/proc/construct_item(mob/user, datum/crafting_recipe/recipe)
	var/list/contents = get_surroundings(user)
	var/send_feedback = 1
	if(!check_contents(recipe, contents))
		return ", missing component."
	if(!check_tools(user, recipe, contents))
		return ", missing tool."
	if(!check_pathtools(user, recipe, contents))
		return ", missing tool."

	if(!do_after(user, recipe.time, target = user))
		return "."
	contents = get_surroundings(user)

	if(!check_contents(recipe, contents))
		return ", missing component."
	if(!check_tools(user, recipe, contents))
		return ", missing tool."
	if(!check_pathtools(user, recipe, contents))
		return ", missing tool."

	var/list/parts = requirements_deletion(recipe, user)
	if(!parts)
		return ", missing component."

	for(var/possible_result in recipe.result)
		var/atom/movable/craft_result = new possible_result (get_turf(user.loc))
		craft_result.CheckParts(parts, recipe)
		if(isitem(craft_result))
			user.put_in_hands(craft_result)

		if(send_feedback)
			SSblackbox.record_feedback("tally", "object_crafted", 1, craft_result.type)
	return 0

/*
 * requirements_deletion() is a function that takes crafting_recipe and user mob as input, returns the list of parts the crafting_recipe result is consists of
 * Firstly it process the surroundings adding the right amount of ingredients to the appropriate lists, combining splitted items into new recipe result part
 * Then it deletes everything it used to create recipe result part and returns the list of parts
*/

/datum/personal_crafting/proc/requirements_deletion(datum/crafting_recipe/recipe, mob/user)
	var/list/surroundings = get_environment(user)
	var/list/parts_used = list()
	var/list/item_stacks_for_deletion = list()
	var/list/reagent_list_for_deletion = list()

	for(var/thing in recipe.reqs)
		var/needed_amount = recipe.reqs[thing]
		if(ispath(thing, /datum/reagent))
			var/datum/reagent/part_reagent = locate(thing) in parts_used
			if(!part_reagent)
				part_reagent = new thing()
				parts_used += part_reagent

			for(var/obj/item/reagent_containers/container in surroundings)
				var/datum/reagent/contained_reagent = container.reagents.get_reagent(thing)
				if(!contained_reagent)
					continue

				var/extracted_amount = min(contained_reagent.volume, needed_amount)
				reagent_list_for_deletion[thing] += list(list(container, extracted_amount))
				part_reagent.volume += extracted_amount
				part_reagent.data += contained_reagent.data
				needed_amount -= extracted_amount
				if(needed_amount <= 0)
					break

			if(needed_amount > 0)
				stack_trace("While crafting [recipe], some of [thing] went missing (still need [needed_amount])!")
				continue // ignore the error, and continue crafting for player's benefit

		else if(ispath(thing, /obj/item/stack))
			var/obj/item/stack/part_stack = locate(thing) in parts_used
			if(!part_stack)
				part_stack = new thing()
				part_stack.amount = 0
				parts_used += part_stack

			for(var/obj/item/stack/item_stack in (surroundings - item_stacks_for_deletion))
				if(!istype(item_stack, thing))
					continue

				var/extracted_amount = min(item_stack.amount, needed_amount)
				item_stacks_for_deletion[item_stack] = extracted_amount
				part_stack.amount += extracted_amount
				needed_amount -= extracted_amount
				if(needed_amount <= 0)
					break

			if(needed_amount > 0)
				stack_trace("While crafting [recipe], some of [thing] went missing (still need [needed_amount])!")
				continue

		else
			for(var/i in 1 to needed_amount)
				var/atom/movable/part_atom
				for(var/atom/movable/candidate as anything in (surroundings - parts_used))
					if(istype(candidate, thing) && !is_type_in_list(candidate, recipe.blacklist))
						part_atom = candidate
						break

				if(!part_atom)
					stack_trace("While crafting [recipe], the [thing] went missing!")
					continue
				parts_used += part_atom

	for(var/datum/reagent/reagent_to_delete as anything in reagent_list_for_deletion)
		for(var/list/reagent_info in reagent_list_for_deletion[reagent_to_delete])
			var/obj/item/reagent_containers/container = reagent_info[1]
			var/amount_to_delete = reagent_info[2]

			container.reagents.remove_reagent(reagent_to_delete.id, amount_to_delete)

	for(var/obj/item/stack/stack_to_delete as anything in item_stacks_for_deletion)
		var/amount_to_delete = item_stacks_for_deletion[stack_to_delete]
		stack_to_delete.use(amount_to_delete)

	// Sort out the used parts into the ones we need to return (denoted by recipe.parts),
	// and the ones we need to delete (the rest of recipe.reqs)
	var/parts_returned = list()
	for(var/part_path in recipe.parts)
		for(var/i in 1 to recipe.parts[part_path])
			var/part = locate(part_path) in parts_used
			if(!part)
				stack_trace("Part [part_path] went missing")
			parts_returned += part
			parts_used -= part
	QDEL_LIST_CONTENTS(parts_used)

	return parts_returned


/datum/personal_crafting/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.not_incapacitated_turf_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PersonalCrafting", "Crafting Menu", 700, 800, master_ui, state)
		ui.open()

/datum/personal_crafting/proc/close(mob/user)
	var/datum/tgui/ui = SStgui.get_open_ui(user, src, "main")
	if(ui)
		ui.close()

/datum/personal_crafting/ui_data(mob/user)
	var/list/data = list()
	var/list/subs = list()
	var/cur_subcategory = CAT_NONE

	var/cur_category = categories[viewing_category]
	if(islist(subcategories[viewing_category]))
		subs = subcategories[viewing_category]
		cur_subcategory = subs[viewing_subcategory]

	data["busy"] = busy
	data["prev_cat"] = categories[prev_cat()]
	data["prev_subcat"] = subs[prev_subcat()]
	data["category"] = cur_category
	data["subcategory"] = cur_subcategory
	data["next_cat"] = categories[next_cat()]
	data["next_subcat"] = subs[next_subcat()]
	data["display_craftable_only"] = display_craftable_only
	data["display_compact"] = display_compact

	var/list/surroundings = get_surroundings(user)
	var/list/can_craft = list()
	var/list/cant_craft = list()

	for(var/rec in GLOB.crafting_recipes)
		var/datum/crafting_recipe/R = rec

		if(!R.always_available && !(R.type in user?.mind?.learned_recipes)) //User doesn't actually know how to make this.
			continue

		if((R.category != cur_category) || (R.subcategory != cur_subcategory))
			continue
		if(check_contents(R, surroundings))
			can_craft += list(build_recipe_data(R))
		else
			cant_craft += list(build_recipe_data(R))

	data["can_craft"] = can_craft
	data["cant_craft"] = cant_craft
	return data

/datum/personal_crafting/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("make")
			var/datum/crafting_recipe/TR = locate(params["make"]) in GLOB.crafting_recipes
			if(!istype(TR))
				return
			busy = TRUE
			SStgui.update_uis(src)
			var/fail_msg = construct_item(usr, TR)
			if(!fail_msg)
				to_chat(usr, "<span class='notice'>[TR.name] constructed.</span>")
				if(TR.alert_admins_on_craft)
					message_admins("[key_name_admin(usr)] has created a [TR.name] at [ADMIN_COORDJMP(usr)]")
			else
				to_chat(usr, "<span class='warning'>Construction failed[fail_msg]</span>")
			busy = FALSE
			SStgui.update_uis(src)

		if("forwardCat")
			viewing_category = next_cat(FALSE)

		if("backwardCat")
			viewing_category = prev_cat(FALSE)

		if("forwardSubCat")
			viewing_subcategory = next_subcat()

		if("backwardSubCat")
			viewing_subcategory = prev_subcat()

		if("toggle_recipes")
			display_craftable_only = !display_craftable_only

		if("toggle_compact")
			display_compact = !display_compact

//Next works nicely with modular arithmetic
/datum/personal_crafting/proc/next_cat(readonly = TRUE)
	if(!readonly)
		viewing_subcategory = 1
	. = viewing_category % categories.len + 1

/datum/personal_crafting/proc/next_subcat()
	if(islist(subcategories[viewing_category]))
		var/list/subs = subcategories[viewing_category]
		. = viewing_subcategory % subs.len + 1


//Previous can go fuck itself
/datum/personal_crafting/proc/prev_cat(readonly = TRUE)
	if(!readonly)
		viewing_subcategory = 1
	if(viewing_category == categories.len)
		. = viewing_category-1
	else
		. = viewing_category % categories.len - 1
	if(. <= 0)
		. = categories.len

/datum/personal_crafting/proc/prev_subcat()
	if(islist(subcategories[viewing_category]))
		var/list/subs = subcategories[viewing_category]
		if(viewing_subcategory == subs.len)
			. = viewing_subcategory-1
		else
			. = viewing_subcategory % subs.len - 1
		if(. <= 0)
			. = subs.len
	else
		. = null

/datum/personal_crafting/proc/build_recipe_data(datum/crafting_recipe/R)
	var/list/data = list()
	data["name"] = R.name
	data["ref"] = "\ref[R]"
	var/req_text = ""
	var/tool_text = ""
	var/catalyst_text = ""

	for(var/a in R.reqs)
		//We just need the name, so cheat-typecast to /atom for speed (even tho Reagents are /datum they DO have a "name" var)
		//Also these are typepaths so sadly we can't just do "[a]"
		var/atom/A = a
		req_text += " [R.reqs[A]] [initial(A.name)],"
	req_text = replacetext(req_text, ",", "", -1)
	data["req_text"] = req_text

	for(var/a in R.chem_catalysts)
		var/atom/A = a //cheat-typecast
		catalyst_text += " [R.chem_catalysts[A]] [initial(A.name)],"
	catalyst_text = replacetext(catalyst_text, ",", "", -1)
	data["catalyst_text"] = catalyst_text

	for(var/a in R.pathtools)
		if(ispath(a, /obj/item))
			var/obj/item/b = a
			tool_text += " [initial(b.name)],"
		else
			tool_text += " [a],"
	for(var/a in R.tools)
		var/b = a
		tool_text += " [b],"
	tool_text = replacetext(tool_text, ",", "", -1)
	data["tool_text"] = tool_text

	return data

//Mind helpers

/datum/mind/proc/teach_crafting_recipe(R)
	if(!learned_recipes)
		learned_recipes = list()
	learned_recipes |= R
