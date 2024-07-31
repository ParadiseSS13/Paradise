/datum/stack_recipe
	var/image

/datum/stack_recipe/post_build(mob/user, obj/item/stack/S, obj/item/stack/created)
	return

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
	. = ..()
	var/obj/item/result = result_type
	var/icon/result_icon = icon(result::icon, result::icon_state, SOUTH, 1)
	var/paint = result::color

	result_icon.Scale(32, 32)
	if(!isnull(paint) && paint != COLOR_WHITE)
		result_icon.Blend(paint, ICON_MULTIPLY)

	image = "[icon2base64(result_icon)]"
