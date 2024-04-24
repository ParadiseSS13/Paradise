/datum/asset/spritesheet/stack_recipes
	name = "stack_recipes"

/datum/asset/spritesheet/stack_recipes/create_spritesheets()
	var/static/list/allowed_items = list()
	if(!length(allowed_items))
		for(var/obj/item/stack/sheet/thing as anything in subtypesof(/obj/item/stack/sheet))
			if(thing.amount > 1 || thing.is_cyborg)
				continue
			thing = new thing()
			for(var/each in thing.recipes)
				if(istype(each, /datum/stack_recipe_list))
					var/datum/stack_recipe_list/recipes_list = each
					for(var/each_item in recipes_list.recipes)
						var/datum/stack_recipe/recipe = each_item
						if(isnull(recipe) || is_type_in_list(recipe.result_type, allowed_items))
							continue
						allowed_items |= recipe.result_type
				else
					var/datum/stack_recipe/recipe = each
					if(isnull(recipe) || is_type_in_list(recipe.result_type, allowed_items))
						continue
					allowed_items |= recipe.result_type
			qdel(thing)

	for(var/thing in allowed_items)
		var/obj/item/result = thing
		var/icon/result_icon = icon(icon = result.icon, icon_state = result.icon_state)
		var/paint = initial(result.color)
		if(!isnull(paint) && paint != COLOR_WHITE)
			result_icon.Blend(paint, ICON_MULTIPLY)
		var/imgid = replacetext(replacetext("[result]", "/obj/item/", ""), "/", "-")
		Insert(imgid, result_icon)
