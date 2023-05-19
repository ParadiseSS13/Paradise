/datum/action/item_action/mod
	background_icon_state = "bg_mod"
	button_icon_state = "bg_mod_border"
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// Whether this action is intended for the AI. Stuff breaks a lot if this is done differently.
	var/ai_action = FALSE

/datum/action/item_action/mod/New(Target)
	..()
	if(!istype(Target, /obj/item/mod/control))
		qdel(src)
		return

/datum/action/item_action/mod/Grant(mob/user)
	var/obj/item/mod/control/mod = target
	if(ai_action && user != mod.ai)
		return
	else if(!ai_action && user == mod.ai)
		return
	return ..()

/datum/action/item_action/mod/Remove(mob/user)
	var/obj/item/mod/control/mod = target
	if(ai_action && user != mod.ai)
		return
	else if(!ai_action && user == mod.ai)
		return
	return ..()

/datum/action/item_action/mod/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
	var/obj/item/mod/control/mod = target
	if(mod.malfunctioning && prob(75))
		to_chat(usr, "<span class='warning'>The module fails to activate!</span>")
		return FALSE
	return TRUE

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "Quick deploy / retract your suit"
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger()
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.quick_deploy(usr)

/datum/action/item_action/mod/deploy/ai
	ai_action = TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "Press this twice to activate the suit."
	button_icon_state = "activate"
	/// First time clicking this will set it to TRUE, second time will activate it.
	var/ready = FALSE

/datum/action/item_action/mod/activate/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(!ready)
		ready = TRUE
		button_icon_state = "activate-ready"
		build_all_button_icons()
		addtimer(CALLBACK(src, PROC_REF(reset_ready)), 3 SECONDS)
		return
	var/obj/item/mod/control/mod = target
	reset_ready()
	mod.toggle_activate(usr)

/// Resets the state requiring to be doubleclicked again.
/datum/action/item_action/mod/activate/proc/reset_ready()
	ready = FALSE
	button_icon_state = initial(button_icon_state)
	build_all_button_icons()

/datum/action/item_action/mod/activate/ai
	ai_action = TRUE

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.quick_module(usr)

/datum/action/item_action/mod/module/ai
	ai_action = TRUE

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.ui_interact(usr)

/datum/action/item_action/mod/panel/ai
	ai_action = TRUE

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A ref to the mob we are pinned to.
	var/pinner_ref

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	if(isAI(user))
		ai_action = TRUE
	button_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	..()
	module = linked_module
	if(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED)
		// clears check hands and check conscious
		check_flags = NONE
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."
	RegisterSignals(linked_module, list(COMSIG_MODULE_ACTIVATED, COMSIG_MODULE_DEACTIVATED, COMSIG_MODULE_USED), PROC_REF(module_interacted_with))

/datum/action/item_action/mod/pinned_module/Destroy()
	UnregisterSignal(module, list(COMSIG_MODULE_ACTIVATED, COMSIG_MODULE_DEACTIVATED, COMSIG_MODULE_USED))
	module.pinned_to -= pinner_ref
	module = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	var/user_ref = REF(user)
	if(!pinner_ref)
		pinner_ref = user_ref
		module.pinned_to[pinner_ref] = src
	else if(pinner_ref != user_ref)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	module.on_select()

/datum/action/item_action/mod/pinned_module/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	current_button.cut_overlays()
	if(override)
		return ..()

	var/obj/item/mod/control/mod = target
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))
	if(!COOLDOWN_FINISHED(module, cooldown_timer))
		var/image/cooldown_image = image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown")
		current_button.add_overlay(cooldown_image)
		addtimer(CALLBACK(current_button, TYPE_PROC_REF(/image, cut_overlay), cooldown_image), COOLDOWN_TIMELEFT(module, cooldown_timer))
	return ..()

/datum/action/item_action/mod/pinned_module/proc/module_interacted_with(datum/source)
	SIGNAL_HANDLER

	build_all_button_icons(UPDATE_BUTTON_OVERLAY|UPDATE_BUTTON_STATUS)
