/datum/asset/spritesheet/stack_recipes
	name = "stack_recipes"

/datum/asset/spritesheet/stack_recipes/create_spritesheets()
	var/static/list/allowed_items = list()
	if(!length(allowed_items))
		for(var/obj/item/stack/material as anything in subtypesof(/obj/item/stack))
			if(material.amount > 1 || material.is_cyborg)
				continue
			material = new material()
			for(var/each in material.recipes)
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
			qdel(material)

	for(var/thing in allowed_items)
		var/obj/item/result = thing
		var/icon/result_icon = icon(icon = result.icon, icon_state = result.icon_state)
		var/paint = initial(result.color)
		if(!isnull(paint) && paint != COLOR_WHITE)
			result_icon.Blend(paint, ICON_MULTIPLY)
		var/imgid = replacetext(replacetext("[result]", "/obj/item/", ""), "/", "-")
		Insert(imgid, result_icon)

/datum/asset/spritesheet/stack_recipes/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(32, 32)
	return pre_asset
