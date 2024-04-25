
/*
 * Recipe datum
 */
/datum/stack_recipe
	/// Visible title of recipe
	var/title = "ERROR"
	/// Resulting typepath of crafted atom
	var/result_type
	/// Required stack amount to make
	var/req_amount = 1
	/// Amount of atoms made
	var/res_amount = 1
	/// Maximum amount of atoms made
	var/max_res_amount = 1
	/// Time to make
	var/time = 0
	/// Only one resulting atom is allowed per turf
	var/one_per_turf = FALSE
	/// Requires a floor underneath to make
	var/on_floor = FALSE
	/// Requires a floor OR lattice underneath to make
	var/on_floor_or_lattice = FALSE
	/// Requires a valid window location to make
	var/window_checks = FALSE
	/// Resulting atom is a cult structure
	var/cult_structure = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = FALSE, on_floor = FALSE, on_floor_or_lattice = FALSE, window_checks = FALSE, cult_structure = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.on_floor_or_lattice = on_floor_or_lattice
	src.window_checks = window_checks
	src.cult_structure = cult_structure

/// What should be done after the object is built? obj/item/stack/O might not actually be a stack, but this proc needs access to merge() to work, which is on obj/item/stack, so declare it as obj/item/stack anyways.
/datum/stack_recipe/proc/post_build(mob/user, obj/item/stack/S, obj/item/stack/created)
	return

/* Special Recipes */
/datum/stack_recipe/cable_restraints
/datum/stack_recipe/cable_restraints/post_build(mob/user, obj/item/stack/S, obj/result)
	if(istype(result, /obj/item/restraints/handcuffs/cable))
		result.color = S.color
	..()

/datum/stack_recipe/dangerous
/datum/stack_recipe/dangerous/post_build(mob/user, obj/item/stack/S, obj/result)
	var/turf/targ = get_turf(user)
	message_admins("[title] made by [key_name_admin(user)](<A href='byond://?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in [get_area(user)] [ADMIN_COORDJMP(targ)]!",0,1)
	log_game("[title] made by [key_name_admin(user)] at [get_area(user)] [targ.x], [targ.y], [targ.z].")
	..()

/datum/stack_recipe/rods
/datum/stack_recipe/rods/post_build(mob/user, obj/item/stack/S, obj/result)
	if(istype(result, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = result
		R.update_icon()
	..()

/datum/stack_recipe/window
/datum/stack_recipe/window/post_build(mob/user, obj/item/stack/S, obj/result)
	if(istype(result, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = result
		W.ini_dir = W.dir
	else if(istype(result, /obj/structure/window))
		var/obj/structure/window/W = result
		W.ini_dir = W.dir
		W.anchored = FALSE
		W.state = WINDOW_OUT_OF_FRAME
	..()

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes

