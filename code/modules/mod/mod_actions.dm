/datum/action/item_action/mod
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon_state = "bg_mod_border"
	background_icon = 'icons/mob/actions/actions_mod.dmi'
	background_icon_state = "bg_mod"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/mod/New(Target)
	..()
	if(!ismodcontrol(Target))
		qdel(src)

/datum/action/item_action/mod/Trigger(left_click, attack_self)
	if(!IsAvailable())
		return FALSE
	var/obj/item/mod/control/mod = target
	if(mod.malfunctioning && prob(75))
		to_chat(usr, "<span class='warning'>The module fails to activate!</span>")
		return FALSE
	return TRUE

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "LMB: Deploy/Undeploy full suit. MMB: Deploy/Undeploy part."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	if(left_click)
		mod.quick_deploy(usr)
	else
		mod.choose_deploy(usr)

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "LMB: Activate/Deactivate suit with prompt. MMB: Activate/Deactivate suit skipping prompt."
	button_icon_state = "activate"
	/// First time clicking this will set it to TRUE, second time will activate it.
	var/ready = FALSE

/datum/action/item_action/mod/activate/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	if(!ready && left_click)
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

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.quick_module(usr)

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.ui_interact(usr)

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	button_icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	button_icon_state = "module"
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A ref to the mob we are pinned to.
	var/pinner_uid

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	button_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."
	..()
	module = linked_module
	background_icon_state = ((module.module_type == MODULE_TOGGLE && module.active) ? "bg_mod_active" : "bg_mod")
	if(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED)
		// clears check hands
		check_flags = AB_CHECK_CONSCIOUS
	Grant(user)
	RegisterSignals(module, list(COMSIG_MODULE_ACTIVATED, COMSIG_MODULE_DEACTIVATED), PROC_REF(linked_button_update))

/datum/action/item_action/mod/pinned_module/Destroy()
	UnregisterSignal(module, list(COMSIG_MODULE_ACTIVATED, COMSIG_MODULE_DEACTIVATED, COMSIG_MODULE_USED))
	module.pinned_to -= pinner_uid
	module = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	var/user_uid = user.UID()
	if(!pinner_uid)
		pinner_uid = user_uid
		module.pinned_to[pinner_uid] = src
	else if(pinner_uid != user_uid)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	module.on_select()

/datum/action/item_action/mod/pinned_module/proc/linked_button_update()
	if(module.module_type != MODULE_PASSIVE)
		background_icon_state = (module.active ? "bg_mod_active" : "bg_mod")
		build_all_button_icons()
