/datum/asset/spritesheet/stack_craft
	name = "stack_craft"

/datum/asset/spritesheet/stack_craft/create_spritesheets()
	var/obj/item/stack/stack
	for(var/datum/stack_recipe/recipe as anything in subtypesof(stack.recipes))
		var/obj/item/recipe_item = recipe.result_type
		var/recipe_icon = icon(icon = initial(recipe_item.icon), icon_state = initial(recipe_item.icon_state))
		var/imgid = replacetext(replacetext("[recipe_item]", "/obj/item/", ""), "/", "-")
		Insert(imgid, recipe_icon)

/datum/asset/spritesheet/stack_craft/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(32, 32)
	return pre_asset
