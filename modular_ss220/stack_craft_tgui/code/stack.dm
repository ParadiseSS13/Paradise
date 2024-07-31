/obj/item/stack/Topic(href, href_list)
	return

/obj/item/stack/list_recipes(mob/user, recipes_sublist)
	return

/obj/item/stack/attack_self(mob/user)
	ui_interact(user)

/obj/item/stack/attack_self_tk(mob/user)
	ui_interact(user)

/obj/item/stack/attack_tk(mob/user)
	if(user.stat || !isturf(loc))
		return
	// Allow remote stack splitting, because telekinetic inventory managing
	// is really cool
	if(!(src in user.tkgrabbed_objects))
		..()
		return

	var/obj/item/stack/material = split(user, 1)
	material.attack_tk(user)
	if(src && user.machine == src)
		ui_interact(user)

/obj/item/stack/attack_hand(mob/user)
	if(!user.is_in_inactive_hand(src) && get_amount() > 1)
		..()
		return

	change_stack(user, 1)
	if(src && user.machine == src)
		ui_interact(user)


/obj/item/stack/change_stack(mob/user,amount)
	. = ..()
	SStgui.update_uis(src)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	. = ..()
	SStgui.update_uis(src)

/obj/item/stack/proc/make(mob/user, datum/stack_recipe/recipe_to_make, multiplier)
	if(get_amount() < 1 && !is_cyborg)
		qdel(src)
		return FALSE

	if(!validate_build(user, recipe_to_make, multiplier))
		return FALSE

	if(recipe_to_make.time)
		to_chat(user, span_notice("Изготовление [recipe_to_make.title]..."))
		if(!do_after(user, recipe_to_make.time, target = user))
			return FALSE

		if(!validate_build(user, recipe_to_make, multiplier))
			return FALSE

	var/atom/created
	var/atom/drop_location = user.drop_location()
	if(recipe_to_make.max_res_amount > 1) //Is it a stack?
		created = new recipe_to_make.result_type(drop_location, recipe_to_make.res_amount * multiplier)
	else
		created = new recipe_to_make.result_type(drop_location)
	created.setDir(user.dir)

	use(recipe_to_make.req_amount * multiplier)

	recipe_to_make.post_build(user, src, created)
	if(isitem(created))
		user.put_in_hands(created)

	created.add_fingerprint(user)

	//BubbleWrap - so newly formed boxes are empty
	if(isstorage(created))
		for(var/obj/item/thing in created)
			qdel(thing)
	//BubbleWrap END

	return TRUE

/obj/item/stack/proc/validate_build(mob/builder, datum/stack_recipe/recipe_to_build, multiplier)
	if(!multiplier || multiplier <= 0 || multiplier > 50 || !IS_INT(multiplier)) // Href exploit checks
		message_admins("[key_name_admin(builder)] just attempted to href exploit sheet crafting with an invalid multiplier. Ban highly advised.")
		return FALSE

	if(get_amount() < recipe_to_build.req_amount * multiplier)
		if(recipe_to_build.req_amount * multiplier > 1)
			to_chat(builder, span_warning("У тебя недостаточно [src] для создания [recipe_to_build.req_amount * multiplier] [recipe_to_build.title]!"))
		else
			to_chat(builder, span_warning("У тебя недостаточно [src] для создания [recipe_to_build.title]!"))
		return FALSE

	var/turf/target_turf = get_turf(src)
	if(recipe_to_build.window_checks && !valid_window_location(target_turf, builder.dir))
		to_chat(builder, span_warning("[recipe_to_build.title] не помещается здесь!"))
		return FALSE

	if(recipe_to_build.one_per_turf && (locate(recipe_to_build.result_type) in target_turf))
		to_chat(builder, span_warning("Тут уже есть [recipe_to_build.title]!"))
		return FALSE

	if(recipe_to_build.on_floor && !issimulatedturf(target_turf))
		to_chat(builder, span_warning("[recipe_to_build.title] должно быть собрано на полу!"))
		return FALSE

	if(recipe_to_build.on_floor_or_lattice && !(issimulatedturf(target_turf) || locate(/obj/structure/lattice) in target_turf))
		to_chat(builder, span_warning("[recipe_to_build.title] должно быть собрано на полу или решётке!"))
		return FALSE

	if(recipe_to_build.cult_structure)
		if(builder.holy_check())
			return FALSE

		if(!is_level_reachable(builder.z))
			to_chat(builder, span_warning("Энергия этого места вмешивается в процесс сборки!"))
			return FALSE

	return TRUE
