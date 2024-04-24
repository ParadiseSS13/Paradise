/datum/asset/spritesheet/stack_recipes
	name = "stack_recipes"

/datum/asset/spritesheet/stack_recipes/create_spritesheets()
	var/list/allowed_sheets = list()
	for(var/obj/item/stack/sheet/sheet as anything in subtypesof(/obj/item/stack/sheet))
		if(length(sheet.recipes) < 1)
			continue
		allowed_sheets |= sheet

	for(var/obj/item/stack/sheet/sheet as anything in allowed_sheets)
		for(var/datum/stack_recipe/recipe in sheet.recipes)
			var/obj/item/result = recipe.result_type
			var/result_icon = icon(icon = initial(result.icon), icon_state = initial(result.icon_state))
			var/imgid = replacetext(replacetext("[result]", "/obj/item/", ""), "/", "-")
			Insert(imgid, result_icon)
