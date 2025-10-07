///MOD Module - A special device installed in a MODsuit allowing the suit to do new stuff.
/obj/item/mod/module
	name = "MOD module"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "module"
	/// If it can be removed
	var/removable = TRUE
	/// If it's passive, togglable, usable or active
	var/module_type = MODULE_PASSIVE
	/// Is the module active
	var/active = FALSE
	/// How much space it takes up in the MOD
	var/complexity = 0
	/// Power use when idle
	var/idle_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// Power use when active
	var/active_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// Power use when used, we call it manually
	var/use_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// ID used by their TGUI
	var/tgui_id
	/// Linked MODsuit
	var/obj/item/mod/control/mod
	/// If we're an active module, what item are we?
	var/obj/item/device
	/// Overlay given to the user when the module is inactive
	var/overlay_state_inactive
	/// Overlay given to the user when the module is active
	var/overlay_state_active
	/// Overlay given to the user when the module is used, lasts until cooldown finishes
	var/overlay_state_use
	/// Icon file for the overlay.
	var/overlay_icon_file = 'icons/mob/clothing/modsuit/mod_modules.dmi'
	/// Does the overlay use the control unit's colors?
	var/use_mod_colors = FALSE
	///Does the mod overide the colour in some way?
	var/mod_color_overide
	/// What modules are we incompatible with?
	var/list/incompatible_modules = list()
	/// Cooldown after use
	var/cooldown_time = 0
	/// The mouse button needed to use this module
	var/used_signal
	/// List of UID()s mobs we are pinned to, linked with their action buttons
	var/list/pinned_to = list()
	/// flags that let the module ability be used in odd circumstances
	var/allow_flags = NONE
	/// Timer for the cooldown
	COOLDOWN_DECLARE(cooldown_timer) //sohtgdoiuduhnfipguhndshnfigdnghd
	///The UID of the module. Don't ask.
	var/module_UID = null
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/modsuit/species/grey_mod_modules.dmi',
		"Vulpkanin" = 'icons/mob/clothing/modsuit/species/modules_vulp.dmi',
		"Tajaran" = 'icons/mob/clothing/modsuit/species/modules_taj.dmi',
		"Unathi" = 'icons/mob/clothing/modsuit/species/modules_unathi.dmi',
		"Vox" = 'icons/mob/clothing/modsuit/species/modules_vox.dmi'
		)

/obj/item/mod/module/Initialize(mapload)
	. = ..()
	module_UID = UID()
	if(module_type != MODULE_ACTIVE)
		return
	if(ispath(device))
		device = new device(src)
		device.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
		device.slot_flags = null
		device.w_class = WEIGHT_CLASS_HUGE
		device.materials = null
		RegisterSignal(device, COMSIG_PARENT_QDELETING, PROC_REF(on_device_deletion))
		RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))

/obj/item/mod/module/Destroy()
	mod?.uninstall(src)
	if(device)
		UnregisterSignal(device, COMSIG_PARENT_QDELETING)
		QDEL_NULL(device)
	return ..()

/obj/item/mod/module/examine(mob/user)
	. = ..()
	. += "Complexity level: [complexity]"


/// Called when the module is selected from the TGUI, radial or the action button
/obj/item/mod/module/proc/on_select()
	if(((!mod.active || mod.activating) && !(allow_flags & MODULE_ALLOW_INACTIVE)) || module_type == MODULE_PASSIVE)
		if(mod.wearer)
			to_chat(mod.wearer, "<span class='warning'>Module is not active!</span>")
		return
	if(module_type != MODULE_USABLE)
		if(active)
			on_deactivation()
		else
			on_activation()
	else
		on_use()
	SEND_SIGNAL(mod, COMSIG_MOD_MODULE_SELECTED, src)

/// Called when the module is activated
/obj/item/mod/module/proc/on_activation()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		to_chat(mod.wearer, "<span class='warning'>Module is on cooldown!</span>")
		return FALSE
	if(!mod.active || mod.activating || !mod.get_charge())
		to_chat(mod.wearer, "<span class='warning'>Module is unpowered!</span>")
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MODULE_TRIGGERED, mod.wearer) & MOD_ABORT_USE)
		return FALSE
	if(module_type == MODULE_ACTIVE)
		if(mod.selected_module && !mod.selected_module.on_deactivation(display_message = FALSE))
			return FALSE
		mod.selected_module = src
		if(device)
			if(mod.wearer.put_in_hands(device))
				to_chat(mod.wearer, "<span class='notice'>[device] extended.</span>")
				RegisterSignal(mod.wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
				RegisterSignal(mod.wearer, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(dropkey))
			else
				to_chat(mod.wearer, "<span class='warning'>You cannot extend [device]!</span>")
				if(device.loc != src)
					device.forceMove(src)
				return FALSE
		else
			var/used_button = "Middle Click"
			if(!mod.wearer || !(mod.wearer.client.prefs.toggles2 & PREFTOGGLE_2_MOD_ACTIVATION_METHOD))
				used_button = "Alt Click"
			update_signal(used_button)
			to_chat(mod.wearer, "<span class='notice'>[src] activated, [used_button] to use.</span>")
	else
		COOLDOWN_START(src, cooldown_timer, cooldown_time) //We don't want to put active modules on cooldown when selected
		to_chat(mod.wearer, "<span class='notice'>[src] activated.</span>")
	active = TRUE
	mod.update_mod_overlays()
	//mod.wearer.update_clothing(mod.slot_flags)
	SEND_SIGNAL(src, COMSIG_MODULE_ACTIVATED)
	return TRUE

/// Called when the module is deactivated
/obj/item/mod/module/proc/on_deactivation(display_message = TRUE, deleting = FALSE)
	active = FALSE
	if(module_type == MODULE_ACTIVE)
		mod.selected_module = null
		if(display_message && device)
			to_chat(mod.wearer, "<span class='notice'>[device] retracted.</span>")
		else if(display_message)
			to_chat(mod.wearer, "<span class='notice'>[src] deactivated.</span>")

		if(device)
			mod.wearer.transfer_item_to(device, src, force = TRUE)
			UnregisterSignal(mod.wearer, COMSIG_ATOM_EXITED)
			UnregisterSignal(mod.wearer, COMSIG_MOB_WILLINGLY_DROP)
		else
			UnregisterSignal(mod.wearer, used_signal)
			used_signal = null
	else if(display_message)
		to_chat(mod.wearer, "<span class='notice'>[src] deactivated.</span>")
	//mod.wearer.update_clothing(mod.slot_flags)
	SEND_SIGNAL(src, COMSIG_MODULE_DEACTIVATED, mod.wearer)
	mod.update_mod_overlays()
	return TRUE

/// Called when the module is used
/obj/item/mod/module/proc/on_use()
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		to_chat(mod.wearer, "<span class='warning'>Module is on cooldown!</span>")
		return FALSE
	if(!check_power(use_power_cost))
		to_chat(mod.wearer, "<span class='warning'>Module costs too much power to use!</span>")
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MODULE_TRIGGERED, mod.wearer) & MOD_ABORT_USE)
		return FALSE
	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	//addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/mob, update_clothing), mod.slot_flags), cooldown_time+1) //need to run it a bit after the cooldown starts to avoid conflicts
	//mod.wearer.update_clothing(mod.slot_flags)
	SEND_SIGNAL(src, COMSIG_MODULE_USED)
	return TRUE

/// Called when an activated module without a device is used
/obj/item/mod/module/proc/on_select_use(atom/target)
	if(!(allow_flags & MODULE_ALLOW_INCAPACITATED) && mod.wearer.incapacitated())
		return FALSE
	mod.wearer.face_atom(target)
	if(!on_use())
		return FALSE
	return TRUE

/// Called when an activated module without a device is active and the user alt/middle-clicks
/obj/item/mod/module/proc/on_special_click(mob/source, atom/target)
	SIGNAL_HANDLER
	on_select_use(target)
	return COMSIG_MOB_CANCEL_CLICKON

/// Called on the MODsuit's process
/obj/item/mod/module/proc/on_process()
	if(active)
		if(!drain_power(active_power_cost))
			on_deactivation()
			return FALSE
		on_active_process()
	else
		drain_power(idle_power_cost)
	return TRUE

/// Called on the MODsuit's process if it is an active module
/obj/item/mod/module/proc/on_active_process()
	return

/// Called from MODsuit's install() proc, so when the module is installed.
/obj/item/mod/module/proc/on_install()
	return

/// Called from MODsuit's uninstall() proc, so when the module is uninstalled.
/obj/item/mod/module/proc/on_uninstall(deleting = FALSE)
	mod.update_mod_overlays()
	return

/// Called when the MODsuit is activated
/obj/item/mod/module/proc/on_suit_activation()
	mod.update_mod_overlays()
	return

/// Called when the MODsuit is deactivated
/obj/item/mod/module/proc/on_suit_deactivation(deleting = FALSE)
	mod.update_mod_overlays()
	return

/// Called when the MODsuit is equipped
/obj/item/mod/module/proc/on_equip()
	mod.update_mod_overlays()
	return

/// Called when the MODsuit is unequipped
/obj/item/mod/module/proc/on_unequip()
	return

/// Drains power from the suit charge
/obj/item/mod/module/proc/drain_power(amount)
	if(!check_power(amount))
		return FALSE
	mod.subtract_charge(amount)
	mod.update_charge_alert()
	return TRUE

/// Checks if there is enough power in the suit
/obj/item/mod/module/proc/check_power(amount)
	return mod.check_charge(amount)

/// Adds additional things to the MODsuit ui_data()
/obj/item/mod/module/proc/add_ui_data()
	return list()

/// Creates a list of configuring options for this module
/obj/item/mod/module/proc/get_configuration()
	return list()

/// Generates an element of the get_configuration list with a display name, type and value
/obj/item/mod/module/proc/add_ui_configuration(display_name, type, value, list/values)
	return list("display_name" = display_name, "type" = type, "value" = value, "values" = values)

/// Receives configure edits from the TGUI and edits the vars
/obj/item/mod/module/proc/configure_edit(key, value)
	return

/// Called when the device moves to a different place on active modules
/obj/item/mod/module/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(!active)
		return
	if(part.loc == src)
		return
	if(part.loc == mod.wearer)
		return
	if(part == device)
		on_deactivation(display_message = FALSE)

/// Called when the device gets deleted on active modules
/obj/item/mod/module/proc/on_device_deletion(datum/source)
	SIGNAL_HANDLER

	if(source == device)
		device = null
		qdel(src)

/// Adds the worn overlays to the suit.
/obj/item/mod/module/proc/add_module_overlay(mob/living/user)
	user.add_overlay(generate_worn_overlay(user))

/// Generates an icon to be used for the suit's worn overlays
/obj/item/mod/module/proc/generate_worn_overlay(mob/living/carbon/human/user)
	. = list()
	if(!mod.active)
		return
	var/used_overlay
	if(overlay_state_use && !COOLDOWN_FINISHED(src, cooldown_timer))
		used_overlay = overlay_state_use
	else if(overlay_state_active && active)
		used_overlay = overlay_state_active
	else if(overlay_state_inactive)
		used_overlay = overlay_state_inactive
	else
		return
	var/image/final_overlay
	if(sprite_sheets && sprite_sheets[user.dna.species.sprite_sheet_name])
		final_overlay = image(icon = sprite_sheets[user.dna.species.sprite_sheet_name], icon_state = used_overlay, layer = -HEAD_LAYER + 0.1)
	else
		final_overlay = image(icon = overlay_icon_file, icon_state = used_overlay, layer = -HEAD_LAYER + 0.1)
	if(mod_color_overide)
		final_overlay.color = mod_color_overide
	. += final_overlay
	mod.mod_overlays += final_overlay

/// Updates the signal used by active modules to be activated
/obj/item/mod/module/proc/update_signal(value)
	switch(value)
		if("Middle Click")
			mod.selected_module.used_signal = COMSIG_MOB_MIDDLECLICKON
		if("Alt Click")
			mod.selected_module.used_signal = COMSIG_MOB_ALTCLICKON
	RegisterSignal(mod.wearer, mod.selected_module.used_signal, TYPE_PROC_REF(/obj/item/mod/module, on_special_click))

/// Pins the module to the user's action buttons
/obj/item/mod/module/proc/pin(mob/user)
	if(module_type == MODULE_PASSIVE)
		return
	if(length(pinned_to))
		for(var/datum/action/item_action/mod/pinned_module/M in user.actions)
			if(M.module == src)
				qdel(M)
		pinned_to = list()
		return
	var/datum/action/item_action/mod/pinned_module/new_action = new(Target = mod, linked_module = src, user = user)
	to_chat(user, "[new_action] is now pinned to the UI!")


/// On drop key, concels a device item.
/obj/item/mod/module/proc/dropkey(mob/living/user)
	SIGNAL_HANDLER

	if(user.get_active_hand() != device)
		return
	on_deactivation()
	return

///Anomaly Locked - Causes the module to not function without an anomaly.
/obj/item/mod/module/anomaly_locked
	name = "MOD anomaly locked module"
	desc = "A form of a module, locked behind an anomalous core to function."
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked)
	/// The core item the module runs off.
	var/obj/item/assembly/signaler/anomaly/core
	/// Accepted types of anomaly cores.
	var/list/accepted_anomalies = list(/obj/item/assembly/signaler/anomaly)
	/// If this one starts with a core in.
	var/prebuilt = FALSE

/obj/item/mod/module/anomaly_locked/Initialize(mapload)
	. = ..()
	if(!prebuilt || !length(accepted_anomalies))
		return
	var/core_path = pick(accepted_anomalies)
	core = new core_path(src)
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod/module/anomaly_locked/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/mod/module/anomaly_locked/examine(mob/user)
	. = ..()
	if(!length(accepted_anomalies))
		return
	if(core)
		. += "There is a [core.name] installed in it. You could remove it with a <b>screwdriver</b>..."
	else
		var/list/core_list = list()
		for(var/path in accepted_anomalies)
			var/atom/core_path = path
			core_list += initial(core_path.name)
		. +="You need to insert \a [english_list(core_list, and_text = " or ")] for this module to function."

/obj/item/mod/module/anomaly_locked/on_select()
	if(!core)
		to_chat(mod.wearer, "<span class='warning'>ERROR. NO CORE INSTALLED!</span>")
		return
	return ..()

/obj/item/mod/module/anomaly_locked/on_process()
	. = ..()
	if(!core)
		return FALSE

/obj/item/mod/module/anomaly_locked/on_active_process()
	if(!core)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/attackby__legacy__attackchain(obj/item/item, mob/living/user, params)
	if(item.type in accepted_anomalies)
		if(core)
			to_chat(user, "<span class='warning'>A core is already installed!</span>")
			return
		if(!user.drop_item())
			return
		core = item
		to_chat(user, "<span class='notice'>You install [item].</span>")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_icon(UPDATE_ICON_STATE)
		core.forceMove(src)
	else
		return ..()

/obj/item/mod/module/anomaly_locked/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		to_chat(user, "<span class='warning'>A core is not installed!</span>")
		return
	if(!do_after(user, 3 SECONDS, target = src))
		return
	to_chat(user, "<span class='notice'>You remove [core].</span>")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod/module/anomaly_locked/update_icon_state()
	icon_state = initial(icon_state) + (core ? "-core" : "")
	return ..()
