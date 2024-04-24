/datum/asset/spritesheet/stack_recipes
	name = "stack_recipes"

/datum/asset/spritesheet/stack_recipes/create_spritesheets()
	var/static/list/allowed_items = list()
	if(isnull(allowed_items))
		for(var/obj/item/stack/sheet/thing as anything in subtypesof(/obj/item/stack/sheet))
			thing = new thing()
			for(var/each in thing.recipes)
				var/datum/stack_recipe/recipe = each
				if(isnull(recipe) || !istype(recipe, /datum/stack_recipe) || is_type_in_list(recipe.result_type, allowed_items))
					continue
				allowed_items |= recipe.result_type
			qdel(thing)

	for(var/thing in allowed_items)
		var/obj/item/result = thing
		var/result_icon = icon(icon = initial(result.icon), icon_state = initial(result.icon_state))
		var/imgid = replacetext(replacetext("[result]", "/obj/item/", ""), "/", "-")
		Insert(imgid, result_icon)
