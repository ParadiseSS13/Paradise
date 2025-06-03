/*
 * Recipe datum
 */
/datum/stack_recipe
	/// Visible title of recipe
	var/title = "ERROR"
	/// Resulting typepath of crafted atom
	var/result_type
	/// Generated base64 image. Used only if result has color
	var/result_image
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

/datum/stack_recipe/New(
		title,
		result_type,
		req_amount = 1,
		res_amount = 1,
		max_res_amount = 1,
		time = 0,
		one_per_turf = FALSE,
		on_floor = FALSE,
		on_floor_or_lattice = FALSE,
		window_checks = FALSE,
		cult_structure = FALSE
	)
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

	// We create base64 image only if item have color. Otherwise use icon_ref for TGUI
	var/obj/item/result = result_type
	var/paint = result::color
	if(!isnull(paint) && paint != COLOR_WHITE)
		var/icon/result_icon = icon(result::icon, result::icon_state, SOUTH, 1)
		result_icon.Scale(32, 32)
		result_icon.Blend(paint, ICON_MULTIPLY)
		src.result_image = "[icon2base64(result_icon)]"

/// Returns TRUE if the recipe can be built, otherwise returns FALSE. This proc is only meant as a series of tests to check if construction is possible; the actual creation of the resulting atom should be handled in do_build()
/datum/stack_recipe/proc/try_build(mob/user, obj/item/stack/material, multiplier)
	if(material.get_amount() < req_amount * multiplier)
		if(req_amount * multiplier > 1)
			to_chat(user, "<span class='warning'>You haven't got enough [material] to build [res_amount * multiplier] [title]\s!</span>")
		else
			to_chat(user, "<span class='warning'>You haven't got enough [material] to build [title]!</span>")
		return FALSE

	if(window_checks && !valid_window_location(get_turf(material), user.dir))
		to_chat(user, "<span class='warning'>[title] won't fit here!</span>")
		return FALSE

	if(one_per_turf && (locate(result_type) in get_turf(material)))
		to_chat(user, "<span class='warning'>There is another [title] here!</span>")
		return FALSE

	if(on_floor && !issimulatedturf(get_turf(material)))
		to_chat(user, "<span class='warning'>[title] must be constructed on the floor!</span>")
		return FALSE
	if(on_floor_or_lattice && !(issimulatedturf(get_turf(material)) || locate(/obj/structure/lattice) in get_turf(material)))
		to_chat(user, "<span class='warning'>[title] must be constructed on the floor or lattice!</span>")
		return FALSE

	if(cult_structure)
		if(user.holy_check())
			return FALSE
		if(!is_level_reachable(user.z))
			to_chat(user, "<span class='warning'>The energies of this place interfere with the metal shaping!</span>")
			return FALSE
		if(locate(/obj/structure/cult) in get_turf(material))
			to_chat(user, "<span class='warning'>There is a structure here!</span>")
			return FALSE

	return TRUE

/// Creates the atom defined by the recipe. Should always return the object it creates or FALSE. This proc assumes that the construction is already possible; for checking whether a recipe *can* be built before construction, use try_build()
/datum/stack_recipe/proc/do_build(mob/user, obj/item/stack/material, multiplier, atom/result)
	if(time)
		to_chat(user, "<span class='notice'>Building [title]...</span>")
		if(!do_after(user, time, target = material.loc))
			return FALSE

	if(material.get_amount() < req_amount * multiplier) // Check they still have enough.
		return FALSE

	if(cult_structure && locate(/obj/structure/cult) in get_turf(material)) // Check again after do_after to prevent queuing construction exploit.
		to_chat(user, "<span class='warning'>There is a structure here!</span>")
		return FALSE

	if(one_per_turf && (locate(result_type) in get_turf(material))) // Yes, we need to do this twice. Once during try_build, and when we build the actual thing, in case it was on a do-after and there's now a structure here.
		to_chat(user, "<span class='warning'>There is another [title] here!</span>")
		return FALSE

	if(max_res_amount > 1) // Is it a stack?
		result = new result_type(get_turf(material), res_amount * multiplier)
	else
		result = new result_type(get_turf(material))

	result.setDir(user.dir)
	result.update_icon(UPDATE_OVERLAYS)
	material.use(req_amount * multiplier)
	material.updateUsrDialog()
	return result

/// What should be done after the object is built? obj/item/stack/result might not actually be a stack, but this proc needs access to merge() to work, which is on obj/item/stack, so declare it as obj/item/stack anyways.
/datum/stack_recipe/proc/post_build(mob/user, obj/item/stack/material, obj/item/stack/result)
	result.add_fingerprint(user)

	if(isitem(result))
		if(isstack(result) && istype(result, user.get_inactive_hand()))
			// Make sure the result hasn't already gotten sucked into another stack while initializing
			if(!QDELETED(result))
				result.merge(user.get_inactive_hand())
		user.put_in_hands(result)

	// BubbleWrap - so newly formed boxes are empty
	if(isstorage(result))
		for(var/obj/item/thing in result)
			qdel(thing)
	// BubbleWrap END

// Special Recipes
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

