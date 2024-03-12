/atom/movable/screen/movable/action_button
	desc = "CTRL-Shift click on this button to bind it to a hotkey."
	var/datum/action/linked_action
	var/actiontooltipstyle = ""
	screen_loc = null
	var/ordered = TRUE
	var/datum/keybinding/mob/trigger_action_button/linked_keybind
	/// The HUD this action button belongs to
	var/datum/hud/our_hud

	/// Where we are currently placed on the hud. SCRN_OBJ_DEFAULT asks the linked action what it thinks
	var/location = SCRN_OBJ_DEFAULT
	/// A unique bitflag, combined with the name of our linked action this lets us persistently remember any user changes to our position
	var/id
	/// UID of the last thing we hovered over
	var/last_hovered_ref

/atom/movable/screen/movable/action_button/Destroy()
	. = ..()
	if(our_hud)
		var/mob/viewer = our_hud.mymob
		our_hud.hide_action(src)
		viewer?.client?.screen -= src
		linked_action.viewers -= our_hud
		viewer.update_action_buttons()
		our_hud = null
	linked_action = null
	return ..()

/atom/movable/screen/movable/action_button/proc/can_use(mob/user)
	if(!linked_action)
		return TRUE
	return !isnull(linked_action.viewers[user.hud_used])

// Entered and Exited won't fire while you're dragging something, because you're still "holding" it
// Very much byond logic, but I want nice behavior, so we fake it with drag
/atom/movable/screen/movable/action_button/MouseDrag(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!can_use(usr))
		return

	var/atom/last_hovered = locateUID(last_hovered_ref)
	if(last_hovered == over_object)
		return
	else
		if(!istype(last_hovered))
			// no current ref, assume it was us. This is our "first go" location
			last_hovered = src
			var/datum/hud/our_hud = usr.hud_used
			our_hud?.generate_landings(src)
	if(last_hovered)
		last_hovered.MouseExited(over_location, over_control, params)
	last_hovered_ref = UID(over_object)
	over_object.MouseEntered(over_location, over_control, params)

/atom/movable/screen/movable/action_button/MouseDrop(over_object)
	last_hovered_ref = null
	if(!can_use(usr))
		return
	var/datum/hud/our_hud = usr.hud_used
	if(over_object == src)
		our_hud.hide_landings()
		return

	if(istype(over_object, /atom/movable/screen/action_landing))
		var/atom/movable/screen/action_landing/reserve = over_object
		reserve.hit_by(src)
		our_hud.hide_landings()
		save_position()
		return

	our_hud.hide_landings()

	if(istype(over_object, /atom/movable/screen/button_palette) || istype(over_object, /atom/movable/screen/palette_scroll))
		our_hud.position_action(src, SCRN_OBJ_IN_PALETTE)
		save_position()
		return
	if(istype(over_object, /atom/movable/screen/movable/action_button))
		var/atom/movable/screen/movable/action_button/button = over_object
		our_hud.position_action_relative(src, button)
		save_position()
		return

	. = ..()

	our_hud.position_action(src, screen_loc)
	save_position()
	// if(locked && could_be_click_lag()) // in case something bad happend and game realised we dragged our ability instead of pressing it
	// 	Click()
	// 	drag_start = 0
	// 	return
	// drag_start = 0
	// if(locked)
	// 	to_chat(usr, "<span class='warning'>Action button \"[name]\" is locked, unlock it first.</span>")
	// 	closeToolTip(usr)
	// 	return
	// if((istype(over_object, /atom/movable/screen/movable/action_button) && !istype(over_object, /atom/movable/screen/movable/action_button/hide_toggle)))
	// 	var/atom/movable/screen/movable/action_button/B = over_object
	// 	var/list/actions = usr.actions
	// 	actions.Swap(actions.Find(linked_action), actions.Find(B.linked_action))
	// 	moved = FALSE
	// 	ordered = TRUE
	// 	B.moved = FALSE
	// 	B.ordered = TRUE
	// 	closeToolTip(usr)
	// 	usr.update_action_buttons()
	// else if(istype(over_object, /atom/movable/screen/movable/action_button/hide_toggle))
	// 	closeToolTip(usr)
	// else
	// 	closeToolTip(usr)
	// 	return ..()


/atom/movable/screen/movable/action_button/proc/save_position()
	var/mob/user = our_hud.mymob
	if(!user?.client)
		return
	var/position_info = ""
	switch(location)
		if(SCRN_OBJ_FLOATING)
			position_info = screen_loc
		if(SCRN_OBJ_IN_LIST)
			position_info = SCRN_OBJ_IN_LIST
		if(SCRN_OBJ_IN_PALETTE)
			position_info = SCRN_OBJ_IN_PALETTE

	// TODO maybe???

	// user.client.prefs.action_buttons_screen_locs["[name]_[id]"] = position_info


/atom/movable/screen/movable/action_button/proc/load_position()
	var/mob/user = our_hud.mymob
	if(!user)
		return
	// TODO MAYBE???
	var/position_info = SCRN_OBJ_DEFAULT
	user.hud_used.position_action(src, position_info)

/atom/movable/screen/movable/action_button/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"] && modifiers["shift"])
		INVOKE_ASYNC(src, PROC_REF(set_to_keybind), usr)
		return TRUE
	if(usr.next_click > world.time)
		return FALSE
	usr.changeNext_click(1)
	if(modifiers["shift"])
		var/datum/hud/our_hud = usr.hud_used
		our_hud.position_action(src, SCRN_OBJ_DEFAULT)
	// 	if(locked)
	// 		to_chat(usr, "<span class='warning'>Action button \"[name]\" is locked, unlock it first.</span>")
	// 		return TRUE
	// 	moved = FALSE
	// 	usr.update_action_buttons(TRUE) //redraw buttons that are no longer considered "moved"
	// 	return TRUE
	// if(modifiers["ctrl"])
	// 	locked = !locked
	// 	to_chat(usr, "<span class='notice'>Action button \"[name]\" [locked ? "" : "un"]locked.</span>")
	// 	return TRUE
	if(modifiers["alt"])
		AltClick(usr)
		return TRUE
	if(modifiers["middle"])
		linked_action.Trigger(left_click = FALSE)
		return TRUE
	linked_action.Trigger(TRUE)
	transform = transform.Scale(0.8, 0.8)
	alpha = 200
	animate(src, transform = matrix(), time = 0.4 SECONDS, alpha = 255)
	return TRUE


/**
 * This is a silly proc used in hud code code to determine what icon and icon state we should be using
 * for hud elements (such as action buttons) that don't have their own icon and icon state set.
 *
 * It returns a list, which is pretty much just a struct of info
 */
/datum/hud/proc/get_action_buttons_icons()
	. = list()
	// todo
	.["bg_icon"] = ui_style2icon(mymob.client.prefs.UI_style)
	.["bg_state"] = "template"
	.["bg_state_active"] = "template_active"

/atom/movable/screen/movable/action_button/proc/set_to_keybind(mob/user)
	var/keybind_to_set_to = uppertext(input(user, "What keybind do you want to set this action button to?") as text)
	if(keybind_to_set_to)
		if(linked_keybind)
			clean_up_keybinds(user)
		var/datum/keybinding/mob/trigger_action_button/triggerer = new
		triggerer.linked_action = linked_action
		user.client.active_keybindings[keybind_to_set_to] += list(triggerer)
		linked_keybind = triggerer
		triggerer.binded_to = keybind_to_set_to
		to_chat(user, "<span class='info'>[src] has been binded to [keybind_to_set_to]!</span>")
	else if(linked_keybind)
		clean_up_keybinds(user)
		to_chat(user, "<span class='info'>Your active keybinding on [src] has been cleared.</span>")

/atom/movable/screen/movable/action_button/AltClick(mob/user)
	return linked_action.AltTrigger()

/atom/movable/screen/movable/action_button/proc/clean_up_keybinds(mob/owner)
	if(linked_keybind)
		owner.client.active_keybindings[linked_keybind.binded_to] -= (linked_keybind)
		if(!length(owner.client.active_keybindings[linked_keybind.binded_to]))
			owner.client.active_keybindings[linked_keybind.binded_to] = null
			owner.client.active_keybindings -= linked_keybind.binded_to
		QDEL_NULL(linked_keybind)

/atom/movable/screen/movable/action_button/MouseEntered(location, control, params)
	. = ..()
	if(!QDELETED(src))
		if(!linked_keybind)
			openToolTip(usr, src, params, title = name, content = desc, theme = actiontooltipstyle)
		else
			var/list/desc_information = list()
			desc_information += desc
			desc_information += "This action is currently bound to the [linked_keybind.binded_to] key."
			desc_information = desc_information.Join(" ")
			openToolTip(usr, src, params, title = name, content = desc_information, theme = actiontooltipstyle)

/atom/movable/screen/movable/action_button/MouseExited()
	closeToolTip(usr)
	return ..()

/mob/proc/update_action_buttons_icon(status_only = FALSE)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtons(status_only)

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	for(var/datum/action/action as anything in actions)
		var/atom/movable/screen/movable/action_button/button = action.viewers[hud_used]
		action.UpdateButtons()
		if(reload_screen)
			client.screen += button

	if(reload_screen)
		hud_used.update_our_owner()
	// This holds the logic for the palette buttons
	hud_used.palette_actions.refresh_actions()

	// else
	// 	for(var/datum/action/A in actions)
	// 		A.override_location() // If the action has a location override, call it
	// 		A.UpdateButtons()

	// 		var/atom/movable/screen/movable/action_button/B = A.button
	// 		if(B.ordered)
	// 			button_number++
	// 		if(!B.moved)
	// 			B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
	// 		else
	// 			B.screen_loc = B.moved
	// 		if(reload_screen)
	// 			client.screen += B

	// 	if(!button_number)
	// 		hud_used.hide_actions_toggle.screen_loc = null
	// 		return

	// if(!hud_used.hide_actions_toggle.moved)
	// 	hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
	// else
	// 	hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.moved
	// if(reload_screen)
	// 	client.screen += hud_used.hide_actions_toggle


#define AB_MAX_COLUMNS 10


/atom/movable/screen/button_palette
	desc = "<b>Drag</b> buttons to move them.<br><b>Shift-click</b> any button to reset it.<br><b>Alt-click</b> this to reset all buttons."
	icon = 'icons/hud/64x16_actions.dmi'
	icon_state = "screen_gen_palette"
	screen_loc = ui_action_palette
	var/datum/hud/our_hud
	var/expanded = FALSE
	/// Id of any currently running timers that set our color matrix
	var/color_timer_id

/atom/movable/screen/button_palette/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.toggle_palette = null
		our_hud = null
	return ..()

/atom/movable/screen/button_palette/Initialize(mapload)
	. = ..()
	update_appearance()

/atom/movable/screen/button_palette/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()

/atom/movable/screen/button_palette/update_name(updates)
	. = ..()
	if(expanded)
		name = "Hide Buttons"
	else
		name = "Show Buttons"


/atom/movable/screen/button_palette/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	var/list/settings = our_hud.get_action_buttons_icons()
	var/ui_icon = "[settings["bg_icon"]]"
	var/list/ui_segments = splittext(ui_icon, ".")
	var/list/ui_paths = splittext(ui_segments[1], "/")
	var/ui_name = ui_paths[length(ui_paths)]

	icon_state = "[ui_name]_palette"


/atom/movable/screen/button_palette/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	show_tooltip(params)

/atom/movable/screen/button_palette/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/button_palette/proc/show_tooltip(params)
	openToolTip(usr, src, params, title = name, content = desc)

GLOBAL_LIST_INIT(palette_added_matrix, list(0.4,0.5,0.2,0, 0,1.4,0,0, 0,0.4,0.6,0, 0,0,0,1, 0,0,0,0))
GLOBAL_LIST_INIT(palette_removed_matrix, list(1.4,0,0,0, 0.7,0.4,0,0, 0.4,0,0.6,0, 0,0,0,1, 0,0,0,0))

/atom/movable/screen/button_palette/proc/play_item_added()
	color_for_now(GLOB.palette_added_matrix)

/atom/movable/screen/button_palette/proc/play_item_removed()
	color_for_now(GLOB.palette_removed_matrix)

/atom/movable/screen/button_palette/proc/color_for_now(list/color)
	if(color_timer_id)
		return
	add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY) //We unfortunately cannot animate matrix colors. Curse you lummy it would be ~~non~~trivial to interpolate between the two valuessssssssss
	color_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_color), color), 2 SECONDS)

/atom/movable/screen/button_palette/proc/remove_color(list/to_remove)
	color_timer_id = null
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, to_remove)

/atom/movable/screen/button_palette/proc/can_use(mob/user)
	// if(isobserver(user))
	// 	var/mob/dead/observer/O = user
	// 	return !O.observetarget
	return TRUE

/atom/movable/screen/button_palette/Click(location, control, params)
	if(!can_use(usr))
		return

	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, ALT_CLICK))
		for(var/datum/action/action as anything in usr.actions) // Reset action positions to default
			for(var/datum/hud/hud as anything in action.viewers)
				var/atom/movable/screen/movable/action_button/button = action.viewers[hud]
				hud.position_action(button, SCRN_OBJ_DEFAULT)
		to_chat(usr, "<span class='notice'>Action button positions have been reset.</span>")
		return TRUE

	set_expanded(!expanded)

/atom/movable/screen/button_palette/proc/clicked_while_open(datum/source, atom/target, atom/location, control, params, mob/user)
	if(istype(target, /atom/movable/screen/movable/action_button) || istype(target, /atom/movable/screen/palette_scroll) || target == src) // If you're clicking on an action button, or us, you can live
		return
	set_expanded(FALSE)
	if(source)
		UnregisterSignal(source, COMSIG_CLIENT_CLICK)


/atom/movable/screen/button_palette/proc/set_expanded(new_expanded)
	var/datum/action_group/our_group = our_hud.palette_actions
	if(!length(our_group.actions)) //Looks dumb, trust me lad
		new_expanded = FALSE
	if(expanded == new_expanded)
		return

	expanded = new_expanded
	our_group.refresh_actions()
	update_appearance()

	if(!usr.client)
		return

	if(expanded)
		RegisterSignal(usr.client, COMSIG_CLIENT_CLICK, PROC_REF(clicked_while_open))
	else
		UnregisterSignal(usr.client, COMSIG_CLIENT_CLICK)

	closeToolTip(usr) //Our tooltips are now invalid, can't seem to update them in one frame, so here, just close them


/atom/movable/screen/palette_scroll
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = ui_palette_scroll
	/// How should we move the palette's actions?
	/// Positive scrolls down the list, negative scrolls back
	var/scroll_direction = 0
	var/datum/hud/our_hud

/atom/movable/screen/palette_scroll/proc/can_use(mob/user)
	// if(isobserver(user))
	// 	var/mob/dead/observer/O = user
	// 	return !O.observetarget
	return TRUE


/atom/movable/screen/palette_scroll/proc/set_hud(datum/hud/our_hud)
	src.our_hud = our_hud
	refresh_owner()

/atom/movable/screen/palette_scroll/proc/refresh_owner()
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src
	var/list/settings = our_hud.get_action_buttons_icons()
	icon = settings["bg_icon"]

/atom/movable/screen/palette_scroll/MouseEntered(location, control, params)
	. = ..()
	if(QDELETED(src))
		return
	openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/palette_scroll/Click(location, control, params)
	if(!can_use(usr))
		return
	our_hud.palette_actions.scroll(scroll_direction)

/atom/movable/screen/palette_scroll/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/palette_scroll/down
	name = "Scroll Down"
	desc = "<b>Click</b> on this to scroll the actions above down"
	icon_state = "scroll_down"
	scroll_direction = 1

/atom/movable/screen/palette_scroll/down/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_down = null
		our_hud = null
	return ..()

/atom/movable/screen/palette_scroll/up
	name = "Scroll Up"
	desc = "<b>Click</b> on this to scroll the actions above up"
	icon_state = "scroll_up"
	scroll_direction = -1

/atom/movable/screen/palette_scroll/up/Destroy()
	if(our_hud)
		our_hud.mymob?.client?.screen -= src
		our_hud.palette_up = null
		our_hud = null
	return ..()

/// Exists so you have a place to put your buttons when you move them around
/atom/movable/screen/action_landing
	name = "Button Space"
	desc = "<b>Drag and drop</b> a button into this spot<br>to add it to the group"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "reserved"
	// We want our whole 32x32 space to be clickable, so dropping's forgiving
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/datum/action_group/owner

/atom/movable/screen/action_landing/Destroy()
	if(owner)
		owner.landing = null
		owner?.owner?.mymob?.client?.screen -= src
		owner.refresh_actions()
		owner = null
	return ..()

/atom/movable/screen/action_landing/proc/set_owner(datum/action_group/owner)
	src.owner = owner
	refresh_owner()

/atom/movable/screen/action_landing/proc/refresh_owner()
	var/datum/hud/our_hud = owner.owner
	var/mob/viewer = our_hud.mymob
	if(viewer.client)
		viewer.client.screen |= src

	var/list/settings = our_hud.get_action_buttons_icons()
	icon = settings["bg_icon"]

/// Reacts to having a button dropped on it
/atom/movable/screen/action_landing/proc/hit_by(atom/movable/screen/movable/action_button/button)
	var/datum/hud/our_hud = owner.owner
	our_hud.position_action(button, owner.location)


/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number - 1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1

	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4 + 2 * col

	var/coord_row = "[row ? -row : "+0"]"

	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:-6"

/datum/hud/proc/SetButtonCoords(atom/movable/screen/button,number)
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/x_offset = 32*(col-1) + 4 + 2*col
	var/y_offset = -32*(row+1) + 26

	var/matrix/M = matrix()
	M.Translate(x_offset,y_offset)
	button.transform = M


/datum/hud/proc/position_action(atom/movable/screen/movable/action_button/button, position)
	if(button.location != SCRN_OBJ_DEFAULT)
		hide_action(button)
	switch(position)
		if(SCRN_OBJ_DEFAULT) // Reset to the default
			// button.dump_save() // Nuke any existing saves
			position_action(button, button.linked_action.default_button_position)
			return
		if(SCRN_OBJ_IN_LIST)
			listed_actions.insert_action(button)
		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.insert_action(button)
		else // If we don't have it as a define, this is a screen_loc, and we should be floating
			floating_actions += button
			button.screen_loc = position
			position = SCRN_OBJ_FLOATING

	button.location = position

/datum/hud/proc/position_action_relative(atom/movable/screen/movable/action_button/button, atom/movable/screen/movable/action_button/relative_to)
	if(button.location != SCRN_OBJ_DEFAULT)
		hide_action(button)
	switch(relative_to.location)
		if(SCRN_OBJ_IN_LIST)
			listed_actions.insert_action(button, listed_actions.index_of(relative_to))
		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.insert_action(button, palette_actions.index_of(relative_to))
		if(SCRN_OBJ_FLOATING) // If we don't have it as a define, this is a screen_loc, and we should be floating
			floating_actions += button
			var/client/our_client = mymob.client
			if(!our_client)
				position_action(button, button.linked_action.default_button_position)
				return
			var/client_view_size = getviewsize(our_client.view)
			button.screen_loc = get_valid_screen_location(relative_to.screen_loc, world.icon_size, client_view_size) // Asks for a location adjacent to our button that won't overflow the map

	button.location = relative_to.location

/// Removes the passed in action from its current position on the screen
/datum/hud/proc/hide_action(atom/movable/screen/movable/action_button/button)
	switch(button.location)
		if(SCRN_OBJ_DEFAULT) // Invalid
			CRASH("We just tried to hide an action buttion that somehow has the default position as its location, you done fucked up")
		if(SCRN_OBJ_FLOATING)
			floating_actions -= button
		if(SCRN_OBJ_IN_LIST)
			listed_actions.remove_action(button)
		if(SCRN_OBJ_IN_PALETTE)
			palette_actions.remove_action(button)
	button.screen_loc = null

/// Generates visual landings for all groups that the button is not a memeber of
/datum/hud/proc/generate_landings(atom/movable/screen/movable/action_button/button)
	listed_actions.generate_landing()
	palette_actions.generate_landing()

/// Clears all currently visible landings
/datum/hud/proc/hide_landings()
	listed_actions.clear_landing()
	palette_actions.clear_landing()

// Updates any existing "owned" visuals, ensures they continue to be visible
/datum/hud/proc/update_our_owner()
	toggle_palette.refresh_owner()
	palette_down.refresh_owner()
	palette_up.refresh_owner()
	listed_actions.update_landing()
	palette_actions.update_landing()

/// Ensures all of our buttons are properly within the bounds of our client's view, moves them if they're not
/datum/hud/proc/view_audit_buttons()
	var/our_view = mymob?.client?.view
	if(!our_view)
		return
	listed_actions.check_against_view()
	palette_actions.check_against_view()
	for(var/atom/movable/screen/movable/action_button/floating_button as anything in floating_actions)
		var/list/current_offsets = screen_loc_to_offset(floating_button.screen_loc)
		// We set the view arg here, so the output will be properly hemm'd in by our new view
		floating_button.screen_loc = offset_to_screen_loc(current_offsets[1], current_offsets[2], view = our_view)

/// Generates and fills new action groups with our mob's current actions
/datum/hud/proc/build_action_groups()
	listed_actions = new(src)
	palette_actions = new(src)
	floating_actions = list()
	for(var/datum/action/action as anything in mymob.actions)
		var/atom/movable/screen/movable/action_button/button = action.viewers[src]
		if(!button)
			action.ShowTo(mymob)
			button = action.viewers[src]
		position_action(button, button.location)

#undef AB_MAX_COLUMNS
