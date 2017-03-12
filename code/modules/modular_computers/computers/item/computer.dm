// This is the base type that does all the hardware stuff.
// Other types expand it - tablets use a direct subtypes, and
// consoles and laptops use "procssor" item that is held inside machinery piece
/obj/item/device/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."

	var/enabled = 0											// Whether the computer is turned on.
	var/screen_on = 1										// Whether the computer is active/opened/it's screen is on.
	var/datum/computer_file/program/active_program = null	// A currently active program running on the computer.
	var/hardware_flag = 0									// A flag that describes this device type
	var/last_power_usage = 0
	var/last_battery_percent = 0							// Used for deciding if battery percentage has chandged
	var/last_world_time = "00:00"
	var/list/last_header_icons
	var/emagged = 0											// Whether the computer is emagged.

	var/base_active_power_usage = 50						// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 5							// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop-open"
	var/icon_state_unpowered = null							// Icon state when the computer is turned off.
	var/icon_state_powered = null							// Icon state when the computer is turned on.
	var/icon_state_menu = "menu"							// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/max_hardware_size = 0								// Maximal hardware w_class. Tablets/PDAs have 1, laptops 2, consoles 4.
	var/steel_sheet_cost = 5								// Amount of steel sheets refunded when disassembling an empty frame of this computer.

	var/obj_integrity = 100
	var/integrity_failure = 50
	var/max_integrity = 100
	armor = list(melee = 0, bullet = 20, laser = 20, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 0, acid = 0)

	// Important hardware (must be installed for computer to work)

	// Optional hardware (improves functionality, but is not critical for computer to work)

	var/list/all_components							// List of "connection ports" in this computer and the components with which they are plugged

	var/list/idle_threads							// Idle programs on background. They still receive process calls but can't be interacted with.
	var/obj/physical = null									// Object that represents our computer. It's used for Adjacent() and UI visibility checks.



/obj/item/device/modular_computer/New()
	update_icon()
	if(!physical)
		physical = src
	..()
	processing_objects += src
	all_components = list()
	idle_threads = list()

/obj/item/device/modular_computer/Destroy()
	kill_program(forced = TRUE)
	for(var/H in all_components)
		var/obj/item/weapon/computer_hardware/CH = all_components[H]
		if(CH.holder == src)
			CH.on_remove(src)
			CH.holder = null
			all_components.Remove(CH.device_type)
			qdel(CH)
	physical = null
	processing_objects -= src
	return ..()


/obj/item/device/modular_computer/proc/add_verb(var/path)
	switch(path)
		if(MC_CARD)
			verbs += /obj/item/device/modular_computer/proc/eject_id
		if(MC_SDD)
			verbs += /obj/item/device/modular_computer/proc/eject_disk
		if(MC_AI)
			verbs += /obj/item/device/modular_computer/proc/eject_card

/obj/item/device/modular_computer/proc/remove_verb(path)
	switch(path)
		if(MC_CARD)
			verbs -= /obj/item/device/modular_computer/proc/eject_id
		if(MC_SDD)
			verbs -= /obj/item/device/modular_computer/proc/eject_disk
		if(MC_AI)
			verbs -= /obj/item/device/modular_computer/proc/eject_card

// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/device/modular_computer/proc/eject_id()
	set name = "Eject ID"
	set category = "Object"
	set src in view(1)

	if(issilicon(usr))
		return
	var/obj/item/weapon/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(!usr.incapacitated())
		card_slot.try_eject(null, usr)

// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/device/modular_computer/proc/eject_card()
	set name = "Eject Intellicard"
	set category = "Object"
	set src in view(1)

	if(issilicon(usr))
		return
	var/obj/item/weapon/computer_hardware/ai_slot/ai_slot = all_components[MC_AI]
	if(!usr.incapacitated())
		ai_slot.try_eject(null, usr, 1)


// Eject ID card from computer, if it has ID slot with card inside.
/obj/item/device/modular_computer/proc/eject_disk()
	set name = "Eject Data Disk"
	set category = "Object"
	set src in view(1)

	if(issilicon(usr))
		return

	if(!usr.incapacitated())
		var/obj/item/weapon/computer_hardware/hard_drive/portable/portable_drive = all_components[MC_SDD]
		if(uninstall_component(portable_drive, usr))
			portable_drive.verb_pickup()

/obj/item/device/modular_computer/AltClick(mob/user)
	..()
	if(issilicon(user))
		return

	if(!user.incapacitated() && Adjacent(user))
		var/obj/item/weapon/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
		var/obj/item/weapon/computer_hardware/ai_slot/ai_slot = all_components[MC_AI]
		var/obj/item/weapon/computer_hardware/hard_drive/portable/portable_drive = all_components[MC_SDD]
		if(portable_drive)
			if(uninstall_component(portable_drive, user))
				portable_drive.verb_pickup()
		else
			if(card_slot && card_slot.try_eject(null, user))
				return
			if(ai_slot)
				ai_slot.try_eject(null, user)


// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs.
/obj/item/device/modular_computer/GetAccess()
	var/obj/item/weapon/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetAccess()
	return ..()

/obj/item/device/modular_computer/GetID()
	var/obj/item/weapon/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetID()
	return ..()

/obj/item/device/modular_computer/attack_ai(mob/user)
	return attack_self(user)

/obj/item/device/modular_computer/attack_ghost(mob/dead/observer/user)
	if(enabled)
		ui_interact(user)
	else if(user.can_admin_interact())
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/device/modular_computer/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>\The [src] was already emagged.</span>")
		return 0
	else
		emagged = 1
		to_chat(user, "<span class='notice'>You emag \the [src]. It's screen briefly shows a \"OVERRIDE ACCEPTED: New software downloads available.\" message.</span>")
		return 1

/obj/item/device/modular_computer/examine(mob/user)
	..()
	if(obj_integrity <= integrity_failure)
		to_chat(user, "<span class='danger'>It is heavily damaged!</span>")
	else if(obj_integrity < max_integrity)
		to_chat(user, "<span class='warning'>It is damaged.</span>")

/obj/item/device/modular_computer/update_icon()
	overlays.Cut()
	if(!enabled)
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered
		if(active_program && active_program.program_state != PROGRAM_STATE_KILLED)
			overlays += active_program.program_icon_state ? active_program.program_icon_state : icon_state_menu
		else
			overlays += icon_state_menu

	if(obj_integrity <= integrity_failure)
		overlays += "bsod"
		overlays += "broken"


// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/device/modular_computer/attack_self(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

/obj/item/device/modular_computer/proc/turn_on(mob/user)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(obj_integrity <= integrity_failure)
		if(issynth)
			to_chat(user, "<span class='warning'>You send an activation signal to \the [src], but it responds with an error code. It must be damaged.</span>")
		else
			to_chat(user, "<span class='warning'>You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again.</span>")
		return

	// If we have a recharger, enable it automatically. Lets computer without a battery work.
	var/obj/item/weapon/computer_hardware/recharger/recharger = all_components[MC_CHARGE]
	if(recharger)
		recharger.enabled = 1

	if(all_components[MC_CPU] && use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, "<span class='notice'>You send an activation signal to \the [src], turning it on.</span>")
		else
			to_chat(user, "<span class='notice'>You press the power button and start up \the [src].</span>")
		enabled = 1
		update_icon()
		ui_interact(user)
	else // Unpowered
		if(issynth)
			to_chat(user, "<span class='warning'>You send an activation signal to \the [src] but it does not respond.</span>")
		else
			to_chat(user, "<span class='warning'>You press the power button but \the [src] does not respond.</span>")

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/device/modular_computer/process()
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return 0

	if(obj_integrity <= integrity_failure)
		shutdown_computer()
		return 0

	if(active_program && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature))
		active_program.event_networkfailure(0) // Active program requires NTNet to run but we've just lost connection. Crash.

	if(active_program)
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.process_tick()
			active_program.ntnet_status = get_ntnet_status()
		else
			active_program = null

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.program_state != PROGRAM_STATE_KILLED)
			if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
				P.event_networkfailure(1)
			P.process_tick()
			P.ntnet_status = get_ntnet_status()
		else
			idle_threads.Remove(P)

	handle_power() // Handles all computer power interaction

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/device/modular_computer/proc/kill_program(forced = FALSE)
	if(active_program && active_program.program_state != PROGRAM_STATE_KILLED)
		active_program.kill_program(forced)
		active_program = null
	var/mob/user = usr
	if(user && istype(user))
		ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
	update_icon()

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/device/modular_computer/proc/get_ntnet_status(specific_action = 0)
	var/obj/item/weapon/computer_hardware/network_card/network_card = all_components[MC_NET]
	if(network_card)
		return network_card.get_signal(specific_action)
	else
		return 0

/obj/item/device/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return FALSE
	var/obj/item/weapon/computer_hardware/network_card/network_card = all_components[MC_NET]
	return ntnet_global.add_log(text, network_card)

/obj/item/device/modular_computer/proc/shutdown_computer(loud = 1)
	if(enabled)
		kill_program(forced = TRUE)
		for(var/datum/computer_file/program/P in idle_threads)
			P.kill_program(forced = TRUE)
			idle_threads.Remove(P)
		if(loud)
			physical.visible_message("<span class='notice'>\The [src] shuts down.</span>")
		enabled = 0
		update_icon()


/obj/item/device/modular_computer/attackby(obj/item/weapon/W, mob/user)
	// Insert items into the components
	for(var/h in all_components)
		var/obj/item/weapon/computer_hardware/H = all_components[h]
		if(H.try_insert(W, user))
			return

	// Insert new hardware
	if(istype(W, /obj/item/weapon/computer_hardware))
		if(install_component(W, user))
			return

	if(istype(W, /obj/item/weapon/wrench))
		if(all_components.len)
			to_chat(user, "<span class='warning'>Remove all components from \the [src] before disassembling it.</span>")
			return
		new /obj/item/stack/sheet/metal(get_turf(loc), steel_sheet_cost)
		physical.visible_message("\The [src] has been disassembled by [user].")
		relay_qdel()
		qdel(src)
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			to_chat(user, "<span class='warning'>\The [W] is off.</span>")
			return

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>\The [src] does not require repairs.</span>")
			return

		to_chat(user, "<span class='notice'>You begin repairing damage to \the [src]...</span>")
		var/dmg = round(max_integrity - obj_integrity)
		if(WT.remove_fuel(round(dmg/75)) && do_after(usr, dmg/10))
			obj_integrity = max_integrity
			to_chat(user, "<span class='notice'>You repair \the [src].</span>")
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(!all_components.len)
			to_chat(user, "<span class='warning'>This device doesn't have any components installed.</span>")
			return
		var/list/component_names = list()
		for(var/h in all_components)
			var/obj/item/weapon/computer_hardware/H = all_components[h]
			component_names.Add(H.name)

		var/choice = input(user, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in component_names

		if(!choice)
			return

		if(!Adjacent(user))
			return

		var/obj/item/weapon/computer_hardware/H = find_hardware_by_name(choice)

		if(!H)
			return

		uninstall_component(H, user)
		return

	..()

// Used by processor to relay qdel() to machinery type.
/obj/item/device/modular_computer/proc/relay_qdel()
	return

// Perform adjacency checks on our physical counterpart, if any.
/obj/item/device/modular_computer/Adjacent(atom/neighbor)
	if(physical && physical != src)
		return physical.Adjacent(neighbor)
	return ..()
