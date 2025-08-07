/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0

	/// This is the icon state state for the BACKGROUND underlay icon of the button
	/// (If set to ACTION_BUTTON_DEFAULT_BACKGROUND, uses the hud's default background)
	var/background_icon = 'icons/mob/actions/actions.dmi'
	/// Icon state of screen object background
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

	/// This is the file for the icon that appears on the button
	var/button_icon = 'icons/mob/actions/actions.dmi'
	/// This is the icon state for the icon that appears on the button
	var/button_icon_state = ACTION_BUTTON_DEFAULT_OVERLAY

	/// This is the file for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon = 'icons/mob/actions/actions.dmi'
	/// This is the icon state for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon_state
	var/buttontooltipstyle = ""
	var/transparent_when_unavailable = TRUE
	var/mob/owner
	/// Where any buttons we create should be by default. Accepts screen_loc and location defines
	var/default_button_position = SCRN_OBJ_IN_LIST
	/// Map of huds viewing a button with our action -> their button
	var/list/viewers = list()
	/// Whether or not this will be shown to observers
	var/show_to_observers = TRUE
	/// Toggles whether this action is usable or not
	var/action_disabled = FALSE
	/// The appearance used as an overlay for when the action is unavailable
	var/mutable_appearance/unavailable_effect
	/// If False, the owner of this action does not get a hud and cannot activate it on their own
	var/owner_has_control = TRUE

/datum/action/New(target)
	link_to(target)

/// Links the passed target to our action, registering any relevant signals
/datum/action/proc/link_to(target_)
	target = target_
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	if(isatom(target))
		RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_target_icon_update))

/datum/action/proc/should_draw_cooldown()
	return !IsAvailable()

/datum/action/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == target)
		qdel(src)

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	if(target)
		target = null
	QDEL_LIST_ASSOC_VAL(viewers) // Qdel the buttons in the viewers list **NOT THE HUDS**
	return ..()

/datum/action/proc/Grant(mob/M)
	if(!M)
		Remove(owner)
		return
	if(owner)
		if(owner == M)
			return
		Remove(owner)
	owner = M
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)
	SEND_SIGNAL(src, COMSIG_ACTION_GRANTED, owner)
	SEND_SIGNAL(owner, COMSIG_MOB_GRANTED_ACTION, src)
	GiveAction(M)

/datum/action/proc/Remove(mob/remove_from)
	for(var/datum/hud/hud in viewers)
		if(!hud.mymob)
			continue
		HideFrom(hud.mymob)

	remove_from?.actions -= src // We aren't always properly inserted into the viewers list, gotta make sure that action's cleared
	viewers = list()
	// owner = null

	if(isnull(owner))
		return

	SEND_SIGNAL(src, COMSIG_ACTION_REMOVED, owner)
	SEND_SIGNAL(owner, COMSIG_MOB_REMOVED_ACTION, src)

	if(target == owner)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)
	if(owner == remove_from)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner = null

/// Builds / updates all buttons we have shared or given out
/datum/action/proc/build_all_button_icons(update_flags = ALL, force)
	for(var/datum/hud/hud as anything in viewers)
		build_button_icon(viewers[hud], update_flags, force)

/datum/action/proc/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

/datum/action/proc/AltTrigger()
	Trigger()
	return FALSE

/datum/action/proc/IsAvailable(show_message = TRUE) // returns 1 if all checks pass
	if(!owner)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return FALSE
	if(check_flags & AB_CHECK_STUNNED)
		if(isliving(owner))
			var/mob/living/L = owner
			if(L.IsStunned() || L.IsWeakened())
				return FALSE
	if(check_flags & AB_CHECK_LYING)
		if(isliving(owner))
			var/mob/living/L = owner
			if(IS_HORIZONTAL(L))
				return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	if(check_flags & AB_CHECK_TURF)
		if(!isturf(owner.loc))
			return FALSE
	return TRUE

/**
 * Builds the icon of the button.
 *
 * Concept:
 * - Underlay (Background icon)
 * - Icon (button icon)
 * - Maptext
 * - Overlay (Background border)
 *
 * button - which button we are modifying the icon of
 * force - whether we're forcing a full update
 */
/datum/action/proc/build_button_icon(atom/movable/screen/movable/action_button/button, update_flags = ALL, force = FALSE)
	if(!button)
		return

	if(update_flags & UPDATE_BUTTON_NAME)
		update_button_name(button, force)

	if(update_flags & UPDATE_BUTTON_BACKGROUND)
		apply_button_background(button, force)

	if(update_flags & UPDATE_BUTTON_ICON)
		apply_button_icon(button, force)

	if(update_flags & UPDATE_BUTTON_OVERLAY)
		apply_button_overlay(button, force)

	if(update_flags & UPDATE_BUTTON_STATUS)
		update_button_status(button, force)

/**
 * Updates the name and description of the button to match our action name and discription.
 *
 * button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/update_button_name(atom/movable/screen/movable/action_button/button, force = FALSE)
	button.name = name
	if(desc)
		button.desc = desc

/**
 * Any other miscellaneous "status" updates within the action button is handled here,
 * such as redding out when unavailable or modifying maptext.
 *
 * button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	button.overlays -= unavailable_effect
	button.maptext = ""
	if(IsAvailable(show_message = FALSE))
		button.color = rgb(255, 255, 255, 255)
	if(should_draw_cooldown())
		apply_unavailable_effect(button)

//Give our action button to the player
/datum/action/proc/GiveAction(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(viewers[our_hud]) // Already have a copy of us? go away
		return
	viewer.actions |= src // Move this in
	ShowTo(viewer)

//Adds our action button to the screen of a player
/datum/action/proc/ShowTo(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(!our_hud || viewers[our_hud]) // There's no point in this if you have no hud in the first place
		return


	var/atom/movable/screen/movable/action_button/button = create_button()
	SetId(button, viewer)

	button.our_hud = our_hud
	viewers[our_hud] = button
	if(viewer.client)
		viewer.client.screen += button

	button.load_position(viewer)
	viewer.update_action_buttons()


//Removes our action button from the screen of a player
/datum/action/proc/HideFrom(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	var/atom/movable/screen/movable/action_button/button = viewers[our_hud]
	viewer.actions -= src
	if(button)
		button.clean_up_keybinds(viewer)
		qdel(button)


/datum/action/proc/create_button()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	build_button_icon(button, ALL, force = TRUE)
	// TODO: Pull all of this into the build button structure somehow later
	button.actiontooltipstyle = buttontooltipstyle
	var/list/our_description = list()
	our_description += desc
	our_description += button.desc
	button.desc = our_description.Join(" ")
	return button

/datum/action/proc/SetId(atom/movable/screen/movable/action_button/our_button, mob/owner)
	//button id generation
	var/bitfield = 0
	for(var/datum/action/action in owner.actions)
		if(action == src) // This could be us, which is dumb
			continue
		var/atom/movable/screen/movable/action_button/button = action.viewers[owner.hud_used]
		if(action.name == name && button?.id)
			bitfield |= button.id

	bitfield = ~bitfield // Flip our possible ids, so we can check if we've found a unique one
	for(var/i in 0 to 23) // We get 24 possible bitflags in dm
		var/bitflag = 1 << i // Shift us over one
		if(bitfield & bitflag)
			our_button.id = bitflag
			return

/datum/action/proc/apply_unavailable_effect(atom/movable/screen/movable/action_button/button)
	if(isnull(unavailable_effect))
		unavailable_effect = mutable_appearance('icons/mob/screen_white.dmi', icon_state = "template")
		unavailable_effect.alpha = 200
		unavailable_effect.appearance_flags = RESET_COLOR | RESET_ALPHA
		unavailable_effect.color = "#000000"
		unavailable_effect.plane = FLOAT_PLANE + 1
	button.overlays |= unavailable_effect

/**
 * Applies any overlays to our button
 *
 * button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_overlay(atom/movable/screen/movable/action_button/button, force = FALSE)
	SEND_SIGNAL(src, COMSIG_ACTION_OVERLAY_APPLY, button, force)

	if(!overlay_icon || !overlay_icon_state || (button.active_overlay_icon_state == overlay_icon_state && !force))
		return

	button.cut_overlay(button.button_overlay)
	button.button_overlay = mutable_appearance(icon = overlay_icon, icon_state = overlay_icon_state, appearance_flags = (RESET_COLOR|RESET_ALPHA))
	button.add_overlay(button.button_overlay)
	button.active_overlay_icon_state = overlay_icon_state

/// Checks if our action is actively selected. Used for selecting icons primarily.
/datum/action/proc/is_action_active(atom/movable/screen/movable/action_button/button)
	return FALSE

/**
 * Creates the background underlay for the button
 *
 * button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_background(atom/movable/screen/movable/action_button/button, force = FALSE)
	if(!background_icon || !background_icon_state || (button.active_underlay_icon_state == background_icon_state && !force))
		return

	// What icons we use for our background
	var/list/icon_settings = list(
		// The icon file
		"bg_icon" = background_icon,
		// The icon state, if is_action_active() returns FALSE
		"bg_state" = background_icon_state,
		// The icon state, if is_action_active() returns TRUE
		"bg_state_active" = background_icon_state,
	)

	// If background_icon_state is ACTION_BUTTON_DEFAULT_BACKGROUND instead use our hud's action button scheme
	if(background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND && owner?.hud_used)
		icon_settings = owner.hud_used.get_action_buttons_icons()

	// Determine which icon to use
	var/used_icon_key = is_action_active(button) ? "bg_state_active" : "bg_state"

	// Make the underlay
	button.underlays.Cut()
	var/image/underlay = image(icon = icon_settings["bg_icon"], icon_state = icon_settings[used_icon_key])
	button.underlays += underlay
	button.active_underlay_icon_state = icon_settings[used_icon_key]

/**
 * Applies our button icon and icon state to the button
 *
 * button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_icon(atom/movable/screen/movable/action_button/button, force = FALSE)
	if(!button_icon || !button_icon_state || (button.icon_state == button_icon_state && !force))
		return

	button.icon = button_icon
	button.icon_state = button_icon_state

/// Updates our buttons if our target's icon was updated
/datum/action/proc/on_target_icon_update(datum/source, updates, updated)
	SIGNAL_HANDLER // COMSIG_ATOM_UPDATED_ICON

	var/update_flag = NONE
	var/forced = FALSE
	if(updates & UPDATE_ICON_STATE)
		update_flag |= UPDATE_BUTTON_ICON
		forced = TRUE
	if(updates & UPDATE_OVERLAYS)
		update_flag |= UPDATE_BUTTON_OVERLAY
		forced = TRUE
	if(updates & (UPDATE_NAME|UPDATE_DESC))
		update_flag |= UPDATE_BUTTON_NAME
	// Status is not relevant, and background is not relevant. Neither will change

	// Force the update if an icon state or overlay change was done
	build_all_button_icons(update_flag, forced)
