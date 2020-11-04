
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
	var/window_checks = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, window_checks = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.window_checks = window_checks

/datum/stack_recipe/proc/post_build(var/obj/item/stack/S, var/obj/result)
	return

/* Special Recipes */

/datum/stack_recipe/cable_restraints
/datum/stack_recipe/cable_restraints/post_build(var/obj/item/stack/S, var/obj/result)
	if(istype(result, /obj/item/restraints/handcuffs/cable))
		result.color = S.color
	..()


/datum/stack_recipe/dangerous
/datum/stack_recipe/dangerous/post_build(/obj/item/stack/S, /obj/result)
	var/turf/targ = get_turf(usr)
	message_admins("[title] made by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in [get_area(usr)] [ADMIN_COORDJMP(targ)]!",0,1)
	log_game("[title] made by [key_name_admin(usr)] at [get_area(usr)] [targ.x], [targ.y], [targ.z].")
	..()

/datum/stack_recipe/rods
/datum/stack_recipe/rods/post_build(var/obj/item/stack/S, var/obj/result)
	if(istype(result, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = result
		R.update_icon()
	..()

/datum/stack_recipe/window
/datum/stack_recipe/window/post_build(obj/item/stack/S, obj/result)
	if(istype(result, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = result
		W.ini_dir = W.dir
	else if(istype(result, /obj/structure/window))
		var/obj/structure/window/W = result
		W.ini_dir = W.dir
		W.anchored = FALSE
		W.state = WINDOW_OUT_OF_FRAME

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes

