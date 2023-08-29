/obj/item/verb/shift_position()
	set name = "Shift Item Pixel Position"
	set category = null
	set src in oview(1)

	if(!isturf(src.loc) || usr.incapacitated() || src.anchored || src.density)
		return

	if(!item_pixel_shift)
		item_pixel_shift = new(src)

	item_pixel_shift.ui_interact(usr)


/datum/ui_module/item_pixel_shift
	name = "Item Pixel Shift"
	var/pixels_per_click = 1
	var/random_drop_on = TRUE
	var/init_no_random_drop = FALSE


/datum/ui_module/item_pixel_shift/New(datum/_host)
	. = ..()
	var/obj/item/source = host
	if(istype(host) && (source.flags & NO_PIXEL_RANDOM_DROP))
		random_drop_on = FALSE
		init_no_random_drop = TRUE


/datum/ui_module/item_pixel_shift/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ItemPixelShift", name, 250, 160, master_ui, state)
		ui.open()


/datum/ui_module/item_pixel_shift/ui_data(mob/user)
	var/obj/item/source = host
	var/list/data = list(
		"pixel_x" = source.pixel_x,
		"pixel_y" = source.pixel_y,
		"max_shift_x" = (initial(source.pixel_x) + world.icon_size / 2),
		"max_shift_y" = (initial(source.pixel_y) + world.icon_size / 2),
		"random_drop_on" = random_drop_on,
	)
	return data


/datum/ui_module/item_pixel_shift/ui_act(action, list/params)
	if(..())
		return

	if(QDELETED(host))
		return

	var/obj/item/source = host

	if(!isturf(source.loc) || usr.incapacitated() || !in_range(usr, source) || source.anchored || source.density)
		return

	var/shift_max = world.icon_size / 2
	var/shift_limit_x = initial(source.pixel_x) + shift_max
	var/shift_limit_y = initial(source.pixel_y) + shift_max

	switch(action)
		if("shift_up")
			source.pixel_y = clamp(source.pixel_y + pixels_per_click, -shift_limit_y, shift_limit_y)

		if("shift_down")
			source.pixel_y = clamp(source.pixel_y - pixels_per_click, -shift_limit_y, shift_limit_y)

		if("shift_left")
			source.pixel_x = clamp(source.pixel_x - pixels_per_click, -shift_limit_x, shift_limit_x)

		if("shift_right")
			source.pixel_x = clamp(source.pixel_x + pixels_per_click, -shift_limit_x, shift_limit_x)

		if("custom_x")
			source.pixel_x = clamp(text2num(params["pixel_x"]), -shift_limit_x, shift_limit_x)

		if("custom_y")
			source.pixel_y = clamp(text2num(params["pixel_y"]), -shift_limit_y, shift_limit_y)

		if("move_to_top")
			var/turf/source_loc = source.loc
			source.loc = null
			source.loc = source_loc

		if("toggle")
			if(init_no_random_drop)
				to_chat(usr, span_warning("You can't change random drop flag on this item."))
				return

			if(random_drop_on)
				random_drop_on = FALSE
				source.flags |= NO_PIXEL_RANDOM_DROP
			else
				random_drop_on = TRUE
				source.flags &= ~NO_PIXEL_RANDOM_DROP

	. = TRUE

