/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackCraft220", name)
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

		else if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/recipe_list = recipe
			recipes_data["[recipe_list.title]"] = recursively_build_recipes(recipe_list.recipes)

	return recipes_data

/obj/item/stack/proc/build_recipe_data(datum/stack_recipe/recipe)
	var/list/data = list()

	data["uid"] = recipe.UID()
	data["required_amount"] = recipe.req_amount
	data["result_amount"] = recipe.res_amount
	data["max_result_amount"] = recipe.max_res_amount
	data["image"] = recipe.image

	return data
