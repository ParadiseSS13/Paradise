/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	/// Icon that our button screen object overlay and background
	var/button_overlay_icon = 'icons/mob/actions/actions.dmi'
	/// Icon state of screen object overlay
	var/button_overlay_icon_state = ACTION_BUTTON_DEFAULT_OVERLAY
	/// Icon that our button screen object background will have
	var/button_background_icon = 'icons/mob/actions/actions.dmi'
	/// Icon state of screen object background
	var/button_background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	var/buttontooltipstyle = ""
	var/transparent_when_unavailable = TRUE
	var/mob/owner
	/// Where any buttons we create should be by default. Accepts screen_loc and location defines
	var/default_button_position = SCRN_OBJ_IN_LIST
	/// Map of huds viewing a button with our action -> their button
	var/list/viewers = list()
	/// Whether or not this will be shown to observers
	var/show_to_observers = TRUE


/datum/action/New(Target)
	target = Target

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

/datum/action/proc/UpdateButtons(status_only, force)
	for(var/datum/hud/hud in viewers)
		var/atom/movable/screen/movable/button = viewers[hud]
		UpdateButton(button, status_only, force)

/datum/action/proc/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

/datum/action/proc/AltTrigger()
	Trigger()
	return FALSE

/datum/action/proc/IsAvailable()// returns 1 if all checks pass
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

/datum/action/proc/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	if(!button)
		return
	if(!status_only)
		button.name = name
		if(desc)
			button.desc = "[desc] [initial(button.desc)]"
		if(owner?.hud_used && button_background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
			var/list/settings = owner.hud_used.get_action_buttons_icons()
			if(button.icon != settings["bg_icon"])
				button.icon = settings["bg_icon"]
			if(button.icon_state != settings["bg_state"])
				button.icon_state = settings["bg_state"]
		else
			if(button.icon != button_background_icon)
				button.icon = button_background_icon
			if(button.icon_state != button_background_icon_state)
				button.icon_state = button_background_icon_state

		apply_button_overlay(button, force)

	if(should_draw_cooldown())
		apply_unavailable_effect(button)
	else
		return TRUE

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


	var/atom/movable/screen/movable/action_button/button = CreateButton()
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


/datum/action/proc/CreateButton()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	button.name = name
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

/datum/action/proc/apply_unavailable_effect(atom/movable/screen/movable/action_button/B)
	var/image/img = image('icons/mob/screen_white.dmi', icon_state = "template")
	img.alpha = 200
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	B.add_overlay(img)


/datum/action/proc/apply_button_overlay(atom/movable/screen/movable/action_button/current_button)
	current_button.cut_overlays()
	if(button_overlay_icon && button_overlay_icon_state)
		var/image/img = image(button_overlay_icon, current_button, button_overlay_icon_state)
		img.appearance_flags = RESET_COLOR | RESET_ALPHA
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.add_overlay(img)
