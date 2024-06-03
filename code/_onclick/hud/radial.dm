#define NEXT_PAGE_ID "__next__"
#define DEFAULT_CHECK_DELAY 20

GLOBAL_LIST_EMPTY(radial_menus)

/atom/movable/screen/radial
	icon = 'icons/mob/radial.dmi'
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	var/datum/radial_menu/parent

/atom/movable/screen/radial/Destroy()
	parent.current_user.screen -= src
	parent = null
	return ..()

/atom/movable/screen/radial/slice
	icon_state = "radial_slice"
	var/choice
	var/next_page = FALSE

/atom/movable/screen/radial/slice/MouseEntered(location, control, params)
	. = ..()
	icon_state = "radial_slice_focus"
	openToolTip(usr, src, params, title = name)

/atom/movable/screen/radial/slice/MouseExited(location, control, params)
	. = ..()
	icon_state = "radial_slice"
	closeToolTip(usr)

/atom/movable/screen/radial/slice/Click(location, control, params)
	if(usr.client == parent.current_user)
		if(next_page)
			parent.next_page()
		else
			parent.element_chosen(choice,usr)

/atom/movable/screen/radial/center
	name = "Close Menu"
	icon_state = "radial_center"

/atom/movable/screen/radial/center/Click(location, control, params)
	if(usr.client == parent.current_user)
		parent.finished = TRUE

/atom/movable/screen/radial/center/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr, src, params, title = name)

/atom/movable/screen/radial/center/MouseExited(location, control, params)
	. = ..()
	closeToolTip(usr)

/datum/radial_menu
	var/list/choices = list() //List of choice id's
	var/list/choices_icons = list() //choice_id -> icon
	var/list/choices_values = list() //choice_id -> choice
	var/list/page_data = list() //list of choices per page


	var/selected_choice
	var/list/atom/movable/screen/elements = list()
	var/atom/movable/screen/radial/center/close_button
	var/client/current_user
	var/atom/movable/anchor
	var/pixel_x_difference
	var/pixel_y_difference
	var/finished = FALSE
	var/datum/callback/custom_check_callback
	var/next_check = 0
	var/check_delay = DEFAULT_CHECK_DELAY

	var/radius = 32
	var/starting_angle = 0
	var/ending_angle = 360
	var/zone = 360
	var/min_angle = 45 //Defaults are setup for this value, if you want to make the menu more dense these will need changes.
	var/max_elements
	var/pages = 1
	var/current_page = 1

	var/hudfix_method = TRUE //TRUE to change anchor to user, FALSE to shift by py_shift
	var/py_shift = 0


/datum/radial_menu/proc/setup_menu()
	if(ending_angle > starting_angle)
		zone = ending_angle - starting_angle
	else
		zone = 360 - starting_angle + ending_angle

	max_elements = round(zone / min_angle)
	var/paged = max_elements < length(choices)
	if(length(elements) < max_elements)
		var/elements_to_add = max_elements - length(elements)
		for(var/i in 1 to elements_to_add) //Create all elements
			var/atom/movable/screen/radial/new_element = new /atom/movable/screen/radial/slice
			new_element.parent = src
			elements += new_element

	var/page = 1
	page_data = list(null)
	var/list/current = list()
	var/list/choices_left = choices.Copy()
	while(length(choices_left))
		if(length(current) == max_elements)
			page_data[page] = current
			page++
			page_data.len++
			current = list()
		if(paged && length(current) == max_elements - 1)
			current += NEXT_PAGE_ID
			continue
		else
			current += popleft(choices_left)
	if(paged && length(current) < max_elements)
		current += NEXT_PAGE_ID

	page_data[page] = current
	pages = page
	current_page = 1
	update_screen_objects()

/datum/radial_menu/proc/update_screen_objects()
	var/list/page_choices = page_data[current_page]
	var/angle_per_element = round(zone / length(page_choices))
	if(current_user.mob.z && anchor.z)
		pixel_x_difference = ((world.icon_size * anchor.x) + anchor.step_x + anchor.pixel_x) - ((world.icon_size * current_user.mob.x) + current_user.mob.step_x + current_user.mob.pixel_x)
		pixel_y_difference = ((world.icon_size * anchor.y) + anchor.step_y + anchor.pixel_y) - ((world.icon_size * current_user.mob.y) + current_user.mob.step_y + current_user.mob.pixel_y)
	for(var/i in 1 to length(elements))
		var/atom/movable/screen/radial/E = elements[i]
		var/angle = WRAP(starting_angle + (i - 1) * angle_per_element, 0, 360)
		if(i > length(page_choices))
			HideElement(E)
		else
			SetElement(E,page_choices[i], angle)

/datum/radial_menu/proc/HideElement(atom/movable/screen/radial/slice/E)
	E.cut_overlays()
	E.alpha = 0
	E.name = "None"
	E.maptext = null
	E.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	E.choice = null
	E.next_page = FALSE

/datum/radial_menu/proc/SetElement(atom/movable/screen/radial/slice/E, choice_id, angle)
	//Position
	E.pixel_y = round(cos(angle) * radius) + py_shift
	E.pixel_x = round(sin(angle) * radius)
	E.screen_loc = "CENTER:[E.pixel_x + pixel_x_difference],CENTER:[E.pixel_y + pixel_y_difference]"

	current_user.screen += E

	//Visuals
	E.alpha = 255
	E.mouse_opacity = MOUSE_OPACITY_ICON
	E.cut_overlays()
	if(choice_id == NEXT_PAGE_ID)
		E.name = "Next Page"
		E.next_page = TRUE
		E.add_overlay("radial_next")
	else
		if(istext(choices_values[choice_id]))
			E.name = choices_values[choice_id]
		else
			var/atom/movable/AM = choices_values[choice_id] //Movables only
			E.name = AM.name
		E.choice = choice_id
		E.maptext = null
		E.next_page = FALSE
		if(choices_icons[choice_id])
			E.add_overlay(choices_icons[choice_id])

/datum/radial_menu/New()
	close_button = new
	close_button.parent = src

/datum/radial_menu/proc/Reset()
	choices.Cut()
	choices_icons.Cut()
	choices_values.Cut()
	current_page = 1
	QDEL_NULL(custom_check_callback)

/datum/radial_menu/proc/element_chosen(choice_id,mob/user)
	selected_choice = choices_values[choice_id]

/datum/radial_menu/proc/get_next_id()
	return "c_[length(choices)]"

/datum/radial_menu/proc/set_choices(list/new_choices)
	if(length(choices))
		Reset()
	for(var/E in new_choices)
		var/id = get_next_id()
		choices += id
		choices_values[id] = E
		if(new_choices[E])
			var/I = extract_image(new_choices[E])
			if(I)
				choices_icons[id] = I
	setup_menu()


/datum/radial_menu/proc/extract_image(E)
	var/mutable_appearance/MA = new /mutable_appearance(E)
	if(MA)
		MA.layer = ABOVE_HUD_LAYER
		MA.appearance_flags |= RESET_TRANSFORM
	return MA


/datum/radial_menu/proc/next_page()
	if(pages > 1)
		current_page = WRAP(current_page + 1, 1, pages + 1)
		update_screen_objects()

/datum/radial_menu/proc/show_to(mob/M)
	if(!M.client || !anchor)
		return
	close_button.screen_loc = "CENTER:[pixel_x_difference],CENTER:[pixel_y_difference]"
	current_user.screen += close_button

/datum/radial_menu/proc/wait(mob/user, atom/anchor, require_near = FALSE)
	var/last_location = user.loc
	while(current_user && !finished && !selected_choice)
		if(require_near)
			var/turf/our_turf = get_turf(user)
			if(!our_turf.Adjacent(get_turf(anchor)))
				return
			if(last_location != user.loc)
				update_screen_objects()
				close_button.screen_loc = "CENTER:[pixel_x_difference],CENTER:[pixel_y_difference]"
				last_location = user.loc
		if(custom_check_callback && next_check < world.time)
			if(!custom_check_callback.Invoke())
				return
			else
				next_check = world.time + check_delay
		// if you're wondering why your radial menus aren't clickable while debugging:
		// it's probably the stoplag call here, try it again without any breakpoints
		stoplag(1)

/datum/radial_menu/Destroy()
	Reset()
	QDEL_LIST_CONTENTS(elements)
	QDEL_NULL(close_button)
	anchor = null
	return ..()

/*
	Presents radial menu to user anchored to anchor (or user if the anchor is currently in users screen)
	Choices should be a list where list keys are movables or text used for element names and return value
	and list values are movables/icons/images used for element icons
*/
/proc/show_radial_menu(mob/user, atom/anchor, list/choices, uniqueid, radius, datum/callback/custom_check, require_near = FALSE)
	if(!user || !anchor || !length(choices))
		return
	if(!uniqueid)
		uniqueid = "defmenu_[user.UID()]_[anchor.UID()]"
	if(GLOB.radial_menus[uniqueid]) // Calls the close button an already existing radial menu.
		var/datum/radial_menu/existing_menu = GLOB.radial_menus[uniqueid]
		existing_menu.finished = TRUE
		return

	var/datum/radial_menu/menu = new
	GLOB.radial_menus[uniqueid] = menu
	if(radius)
		menu.radius = radius
	if(istype(custom_check))
		menu.custom_check_callback = custom_check
	if(anchor in user.client.screen)
		menu.anchor = user
	else
		menu.anchor = anchor
	menu.current_user = user.client
	menu.set_choices(choices)
	menu.show_to(user)
	menu.wait(user, anchor, require_near)
	var/answer = menu.selected_choice
	qdel(menu)
	GLOB.radial_menus -= uniqueid
	return answer

/**
 * Similar to show_radial_menu, but choices is a list of atoms, for which icons will be automatically generated.
 * Supports multiple items of the same name, 2 soaps will become soap (1) and soap (2) to the user.
 * Otherwise, has the exact same arguments as show_radial_menu
 */
/proc/radial_menu_helper(mob/user, atom/anchor, list/choices, uniqueid, radius, datum/callback/custom_check, require_near = FALSE)
	var/list/duplicate_amount = list()
	for(var/atom/atom in choices)
		if(!duplicate_amount.Find(atom.name))
			duplicate_amount[atom.name] = 0
		else
			duplicate_amount[atom.name]++
	var/list/duplicate_indexes = duplicate_amount.Copy()

	var/list/icon_state_choices = list()
	var/list/return_choices = list()
	for(var/atom/possible_atom in choices)
		if(!istype(possible_atom))
			stack_trace("radial_menu_helper was passed a non-atom (\"[possible_atom]\", [possible_atom.type]) as a choice")
			continue
		var/mutable_appearance/atom_appearance = mutable_appearance(possible_atom.icon, possible_atom.icon_state, possible_atom.layer)

		var/hover_outline_index = possible_atom.get_filter("hover_outline")
		if(!isnull(hover_outline_index))
			atom_appearance.filters.Cut(hover_outline_index, hover_outline_index + 1)

		var/key = possible_atom.name
		if(duplicate_amount[key])
			var/number = duplicate_amount[key] - duplicate_indexes[key]
			duplicate_indexes[key]--
			key = "[key] ([number + 1])"

		icon_state_choices[key] = atom_appearance
		return_choices[key] = possible_atom

	var/chosen_key = show_radial_menu(user, anchor, icon_state_choices, uniqueid, radius, custom_check, require_near)

	if(!chosen_key)
		return

	return return_choices[chosen_key]

#undef NEXT_PAGE_ID
#undef DEFAULT_CHECK_DELAY
