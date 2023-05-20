/datum/action/item_action/mod
	background_icon_state = "bg_mod"
	button_icon_state = "bg_mod_border"
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/mod/New(Target)
	..()
	if(!istype(Target, /obj/item/mod/control))
		qdel(src)
		return

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
		addtimer(CALLBACK(src, PROC_REF(reset_ready)), 3 SECONDS)
		return
	var/obj/item/mod/control/mod = target
	reset_ready()
	mod.toggle_activate(usr)

/// Resets the state requiring to be doubleclicked again.
/datum/action/item_action/mod/activate/proc/reset_ready()
	ready = FALSE
	button_icon_state = initial(button_icon_state)

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

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A ref to the mob we are pinned to.
	var/pinner_uid

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	button_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	..()
	module = linked_module
	if(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED)
		// clears check hands and check conscious
		check_flags = NONE
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."

/datum/action/item_action/mod/pinned_module/Destroy()
	UnregisterSignal(module, list(COMSIG_MODULE_ACTIVATED, COMSIG_MODULE_DEACTIVATED, COMSIG_MODULE_USED))
	module.pinned_to -= pinner_uid
	module = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	var/user_uid = UID(user)
	if(!pinner_uid)
		pinner_uid = user_uid
		module.pinned_to[pinner_uid] = src
	else if(pinner_uid != user_uid)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	module.on_select()
