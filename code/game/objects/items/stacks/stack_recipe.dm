
/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = 0
	var/on_floor = 0

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor

/datum/stack_recipe/proc/post_build(var/obj/item/stack/S, var/obj/result)
	return

/* Special Recipes */

/datum/stack_recipe/cable_restraints
/datum/stack_recipe/cable_restraints/post_build(var/obj/item/stack/S, var/obj/result)
	if(istype(result, /obj/item/weapon/restraints/handcuffs/cable))
		result.color = S.color
	..()

/datum/stack_recipe/rods
/datum/stack_recipe/rods/post_build(var/obj/item/stack/S, var/obj/result)
	if(istype(result, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = result
		R.update_icon()
	..()

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1

/datum/stack_recipe_list/New(title, recipes, req_amount = 1)
	src.title = title
	src.recipes = recipes
	src.req_amount = req_amount

