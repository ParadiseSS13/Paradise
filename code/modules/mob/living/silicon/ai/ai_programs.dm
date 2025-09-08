// The datum and interface for the AI powers menu
/datum/program_picker
	/// Associated AI
	var/mob/living/silicon/ai/assigned_ai
	/// List of programs that can be bought
	var/list/possible_programs
	/// How much memory is available
	var/memory = 3
	/// How much total memory does the system have?
	var/total_memory = 3
	/// How much bandwidth is available
	var/bandwidth = 1
	/// How much total bandwidth does the system have?
	var/total_bandwidth = 1
	/// How many nanites are available?
	var/nanites = 50
	/// What is the maximum number of nanites?
	var/max_nanites = 100
	/// Handles extra information displayed
	var/temp

/datum/program_picker/New(mob/living/silicon/ai/A)
	if(!istype(A))
		return
	assigned_ai = A
	possible_programs = list()
	for(var/type in subtypesof(/datum/ai_program))
		var/datum/ai_program/program = new type
		if(program.power_type || program.upgrade)
			possible_programs += program

/datum/program_picker/proc/modify_resource(key, amount)
	switch(key)
		if("memory")
			memory += amount
			total_memory += amount
			if(memory < 0)
				refund_purchases()
		if("bandwidth")
			bandwidth += amount
			total_bandwidth += amount
			if(bandwidth < 0)
				refund_upgrades()

/datum/program_picker/proc/get_installed_programs()
	var/list/installed_programs = list()
	for(var/datum/ai_program/program in possible_programs)
		if(program.installed)
			installed_programs += program
	return installed_programs

/datum/program_picker/proc/refund_purchases()
	var/list/potential_losses = get_installed_programs()
	while(memory < 0)
		if(!length(potential_losses))
			return
		var/datum/ai_program/program = pick_n_take(potential_losses)
		program.uninstall(assigned_ai)

/datum/program_picker/proc/refund_upgrades()
	var/list/potential_losses = get_installed_programs()
	while(bandwidth < 0)
		if(!length(potential_losses))
			return
		var/datum/ai_program/program = pick_n_take(potential_losses)
		if(!program.upgrade_level)
			continue
		while(program.upgrade_level > 0 && bandwidth < 0)
			program.downgrade(assigned_ai)

/datum/program_picker/proc/reset_programs()
	var/list/programs = get_installed_programs()
	for(var/datum/ai_program/program in programs)
		program.uninstall(assigned_ai)

/datum/program_picker/ui_host()
	return assigned_ai ? assigned_ai : src

/datum/program_picker/proc/spend_nanites(amount)
	if(nanites - amount < 0)
		return FALSE
	else
		nanites -= amount
		return TRUE

/datum/program_picker/proc/refund_nanites(amount)
	nanites = min(max_nanites, nanites + amount)

/datum/program_picker/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AIProgramPicker", "AI Program Menu")
		ui.open()

/datum/program_picker/ui_data(mob/user)
	var/list/data = list()
	data["program_list"] = list()
	for(var/datum/ai_program/program in possible_programs)
		var/list/program_data = list(
			"name" = program.program_name,
			"UID" = program.UID(),
			"description" = program.description,
			"memory_cost" = program.cost,
			"installed" = program.installed,
			"upgrade_level" = program.upgrade_level,
			"is_passive" = program.upgrade
		)
		data["program_list"] += list(program_data)
	var/mob/living/silicon/ai/AI = user
	data["ai_info"] = list(
		"memory" = AI.program_picker.memory,
		"bandwidth" = AI.program_picker.bandwidth
	)
	return data

/datum/program_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = FALSE

	if(!is_ai(ui.user))
		return
	var/mob/living/silicon/ai/A = ui.user
	if(A.stat == DEAD)
		to_chat(A, "<span class='warning'>You are dead!</span>")
		return

	switch(action)
		if("select")
			var/datum/ai_program/program = locateUID(params["uid"])
			if(!program.installed) // Handle installing any program here.
				if(program.cost > memory)
					to_chat(A, "<span class='warning'>You cannot afford this program.</span>")
					return FALSE
				memory -= program.cost
				program.installed = TRUE
				SSblackbox.record_feedback("tally", "ai_program_install", 1, "[program.type]")

			// Active programs
			if(!program.upgrade)
				var/datum/spell/ai_spell/new_spell = new program.power_type
				// Upgrading an existing active program
				for(var/datum/spell/ai_spell/selected_program in A.mob_spell_list)
					if(new_spell.type == selected_program.type)
						if(selected_program.spell_level >= selected_program.level_max)
							to_chat(A, "<span class='warning'>This program cannot be upgraded further.</span>")
							return FALSE
						else
							if(bandwidth < 1)
								to_chat(A, "<span class='warning'>You cannot afford this upgrade!</span>")
								return FALSE
							selected_program.name = initial(selected_program.name)
							selected_program.spell_level++
							if(selected_program.spell_level >= selected_program.level_max)
								to_chat(A, "<span class='notice'>This program cannot be upgraded any further.</span>")
							selected_program.on_purchase_upgrade()
							program.upgrade(A)
							return TRUE

				// No same active program found, install the new active power.
				new_spell.program = program
				new_spell.desc_update()
				program.upgrade(A, first_install = TRUE) // Usually does nothing for actives, but is needed for hybrid abilities like the enhanced tracker
				A.AddSpell(new_spell)
				to_chat(A, program.unlock_text)
				A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
				return TRUE

			// Passive programs
			if(program.upgrade_level > program.max_level)
				to_chat(A, "<span class='notice'>This program cannot be upgraded any further.</span>")
				return FALSE
			if(!program.upgrade_level)
				program.upgrade(A, first_install = TRUE)
			else
				if(bandwidth < 1)
					to_chat(A, "<span class='warning'>You cannot afford this upgrade!</span>")
					return FALSE
				program.upgrade(A)
			to_chat(A, program.unlock_text)
			A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
			return TRUE

/// The base program type, which holds info about each ability.
/datum/ai_program
	var/program_name
	var/description = ""
	/// Internal ID of the program
	var/program_id
	/// How much memory does the program cost?
	var/cost = 1
	/// How much does this program cost to use?
	var/nanite_cost = 0
	/// How many upgrades have been bought of this program?
	var/bandwidth_used = 0
	/// If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/power_type = /datum/spell/ai_spell
	/// If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/upgrade = FALSE
	/// The level of the upgrade for passives
	var/upgrade_level = 0
	/// Max level for passive upgrades
	var/max_level = 5
	/// Text shown when an ability is unlocked
	var/unlock_text = "<span class='notice'>Hello World!</span>"
	/// Sound played when an ability is unlocked
	var/unlock_sound
	/// The cooldown when the ability is used
	var/cooldown = 30 SECONDS
	/// Is this program installed?
	var/installed = FALSE
	/// Is this program only installable through disk?
	var/external = FALSE

/datum/ai_program/New()
	. = ..()
	if(nanite_cost)
		description += " Costs [nanite_cost] Nanites to use."

/datum/spell/ai_spell/choose_program
	name = "Choose Programs"
	desc = "Spend your memory and bandwidth to gain a variety of different abilities."
	action_icon = 'icons/mob/ai.dmi'
	action_icon_state = "ai"
	auto_use_uses = FALSE // This is an infinite ability.
	create_attack_logs = FALSE

/datum/ai_program/proc/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	if(!istype(user))
		return
	upgrade_level++
	if(!first_install)
		SSblackbox.record_feedback("tally", "ai_program_upgrade", 1, "[src.type]")
		bandwidth_used++
		user.program_picker.bandwidth--

/datum/ai_program/proc/downgrade(mob/living/silicon/ai/user)
	if(!istype(user))
		return
	upgrade_level--
	if(!upgrade_level <= 0)
		uninstall(user)
		return
	to_chat(user, "<span class='warning'>Program update data lost: [src.program_name]!</span>")
	user.program_picker.bandwidth++
	if(!upgrade) // Passives need to be handled in their own procs
		var/datum/spell/ai_spell/removed_spell = new power_type
		for(var/datum/spell/ai_spell/aspell in user.mob_spell_list)
			if(removed_spell.type == aspell.type)
				aspell.name = initial(aspell.name)
				aspell.spell_level--
				aspell.on_purchase_upgrade() // It's a downgrade, but we still need to recalculate values
	return

/datum/ai_program/proc/uninstall(mob/living/silicon/ai/user)
	upgrade_level = 0
	installed = FALSE
	if(!istype(user))
		return
	user.program_picker.bandwidth += bandwidth_used
	bandwidth_used = 0
	user.program_picker.memory += cost
	to_chat(user, "<span class='userdanger'>Program core data lost: [src.program_name]!</span>")
	if(!upgrade) // Passives need to be handled in their own procs
		var/datum/spell/ai_spell/removed_spell = new power_type
		for(var/datum/spell/ai_spell/aspell in user.mob_spell_list)
			if(removed_spell.type == aspell.type)
				user.RemoveSpell(aspell)
	return

/datum/spell/ai_spell/choose_program/cast(list/targets, mob/living/silicon/ai/user)
	. = ..()
	if(istype(user.loc, /obj/machinery/power/apc))
		to_chat(user, "<span class='warning'>Error: APCs do not have enough processing power to handle programs!</span>")
		return
	if(istype(user.loc, /obj/item/aicard))
		to_chat(user, "<span class='warning'>Error: InteliCards do not have enough processing power to handle programs!</span>")
		return
	user.program_picker.ui_interact(user)

//////////////////////////////
// MARK: RGB Lighting
//////////////////////////////

/datum/ai_program/rgb_lighting
	program_name = "RGB Lighting"
	program_id = "rgb_lighting"
	description = "Recolor a light to a desired color. At significantly high efficiency, it can change the color of an entire room's lighting by targeting the APC."
	nanite_cost = 5
	power_type = /datum/spell/ai_spell/ranged/rgb_lighting
	unlock_text = "RGB Lighting installation complete!"

/datum/spell/ai_spell/ranged/rgb_lighting
	name = "RGB Lighting"
	desc = "Changes the color of a selected light."
	action_icon = 'icons/effects/random_spawners.dmi'
	action_icon_state = "glowstick"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You hook into the station's lighting controller...</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the request from the lighting controller.</span>"

/datum/spell/ai_spell/ranged/rgb_lighting/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/obj/machinery/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!istype(target, /obj/machinery/light) && !istype(target, /obj/machinery/power/apc))
		to_chat(user, "<span class='warning'>You can only recolor lights!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	// Color selection
	var/color_picked = tgui_input_color(user, "Please select a light color.", "RGB Lighting Color")
	var/list/hsl = rgb2hsl(hex2num(copytext(color_picked, 2, 4)), hex2num(copytext(color_picked, 4, 6)), hex2num(copytext(color_picked, 6, 8)))
	hsl[3] = max(hsl[3], 0.4)
	var/list/rgb = hsl2rgb(arglist(hsl))
	var/new_color = "#[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]"
	if(istype(target, /obj/machinery/power/apc))
		if(spell_level < 3) // If you haven't upgraded it 3 times, you have to color lights individually.
			to_chat(user, "<span class='warning'>Your coloring subsystem is not strong enough to target an entire room!</span>")
			AI.program_picker.refund_nanites(program.nanite_cost)
			revert_cast()
			return
		var/obj/machinery/power/apc/A = target
		for(var/obj/machinery/light/L in A.apc_area)
			L.color = new_color
			L.brightness_color = new_color
			L.update(TRUE, TRUE, FALSE)
	else
		var/obj/machinery/light/L = target
		L.color = new_color
		L.brightness_color = new_color
		L.update(TRUE, TRUE, FALSE)
	AI.play_sound_remote(target, 'sound/effects/spray.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/rgb_lighting/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (spell_level * 5 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Power Shunt
//////////////////////////////

/datum/ai_program/power_shunt
	program_name = "Power Shunt"
	program_id = "power_shunt"
	description = "Recharge an APC, Borg, or Mech with power directly from your SMES!"
	nanite_cost = 20
	power_type = /datum/spell/ai_spell/ranged/power_shunt
	unlock_text = "Power Shunt installation complete!"

/datum/spell/ai_spell/ranged/power_shunt
	name = "Power Shunt"
	desc = "Recharge an APC, Borg, or Mech with power directly from your SMES."
	action_icon = 'icons/obj/power.dmi'
	action_icon_state = "smes-o"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 120 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 7
	selection_activated_message = "<span class='notice'>You tap into the station's powernet...</span>"
	selection_deactivated_message = "<span class='notice'>You release your hold on the powernet.</span>"
	var/power_sent = 2500

/datum/spell/ai_spell/ranged/power_shunt/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!isrobot(target) && !isapc(target) && !ismecha(target) && !ismachineperson(target))
		to_chat(user, "<span class='warning'>You can only recharge borgs, mechs, and APCs!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(ismachineperson(target)  && !AI.universal_adapter)
		to_chat(user, "<span class='warning'>This software lacks the required upgrade to recharge IPCs!</span>")
		revert_cast()
		return
	var/area/A = get_area(user)
	if(A == null)
		to_chat(user, "<span class='warning'>No SMES detected to power from!</span>")
		revert_cast()
		return
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	if(ismecha(target))
		var/obj/mecha/T = target
		T.cell.give(power_sent)
	if(isrobot(target))
		var/mob/living/silicon/robot/T = target
		T.cell.give(power_sent)
	if(isapc(target))
		var/obj/machinery/power/apc/T = target
		T.cell.give(power_sent)
	if(ismachineperson(target))
		var/mob/living/carbon/human/machine/T = target
		T.adjust_nutrition(clamp(AI.adapter_efficiency * (power_sent / 10), 0, (NUTRITION_LEVEL_FULL - T.nutrition)))

	// Handles draining the SMES
	for(var/obj/machinery/power/smes/power_source in A)
		if(power_source.charge < power_sent)
			continue
		power_source.charge -= power_sent
		break
	AI.play_sound_remote(target, 'sound/goonstation/misc/fuse.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/power_shunt/on_purchase_upgrade()
	power_sent = min(10000, 2500 + (spell_level * 2500))
	cooldown_handler.recharge_duration = max(base_cooldown - (max(spell_level - 3, 0) * 30 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Repair Nanites
//////////////////////////////

/datum/ai_program/repair_nanites
	program_name = "Repair Nanites"
	program_id = "repair_nanites"
	description = "Repair an APC, Borg, or Mech with large numbers of robotic nanomachines!"
	cost = 2
	nanite_cost = 75
	power_type = /datum/spell/ai_spell/ranged/repair_nanites
	unlock_text = "Repair nanomachine firmware installation complete!"

/datum/spell/ai_spell/ranged/repair_nanites
	name = "Repair Nanites"
	desc = "Repair an APC, Borg, or Mech with large numbers of robotic nanomachines!"
	action_icon = 'icons/obj/surgery.dmi'
	action_icon_state = "tube"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 150 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 7
	selection_activated_message = "<span class='notice'>You prepare to order your nanomachines to repair...</span>"
	selection_deactivated_message = "<span class='notice'>You rescind the order.</span>"

/datum/spell/ai_spell/ranged/repair_nanites/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!isrobot(target) && !isapc(target) && !ismecha(target) && !ismachineperson(target) && !isbot(target))
		to_chat(user, "<span class='warning'>You can only repair borgs, mechs, and APCs!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(ismachineperson(target) && !AI.universal_adapter)
		to_chat(user, "<span class='warning'>This software lacks the required upgrade to repair IPCs!</span>")
		revert_cast()
		return
	if(isbot(target) && spell_level < 2)
		to_chat(user, "<span class='warning'>This software is not upgraded enough to repair the robot!</span>")
		revert_cast()
		return
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	if(ismecha(target)|| isapc(target))
		var/obj/T = target
		T.obj_integrity = min(T.max_integrity, T.obj_integrity + (T.max_integrity * (0.2 + min(0.3, (0.1 * spell_level)))))
	if(isrobot(target))
		var/mob/living/silicon/robot/T = target
		var/damage_healed = 20 + (min(30, (10 * spell_level)))
		T.heal_overall_damage(damage_healed, damage_healed)
	if(ismachineperson(target))
		var/mob/living/carbon/human/machine/T = target
		var/damage_healed = AI.adapter_efficiency * (20 + (min(30, (10 * spell_level))))
		T.heal_overall_damage(damage_healed, damage_healed, TRUE, 0, 1)
	AI.play_sound_remote(target, 'sound/goonstation/misc/fuse.ogg', 50)
	camera_beam(target, "medbeam", 'icons/effects/beam.dmi', 10)

/datum/spell/ai_spell/ranged/repair_nanites/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (max(spell_level - 3, 0) * 30 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Universal Adapter
//////////////////////////////

/datum/ai_program/universal_adapter
	program_name = "Universal Adapter"
	program_id = "universal_adapter"
	description = "Upgraded firmware allows IPCs to be valid targets for Power Shunt and Repair Nanites, at half efficiency."
	unlock_text = "Universal adapter installation complete!"
	upgrade = TRUE

/datum/ai_program/universal_adapter/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	..()
	if(!istype(user))
		return
	user.universal_adapter = TRUE
	user.adapter_efficiency = 0.5 + (0.1 * upgrade_level)
	installed = TRUE

/datum/ai_program/universal_adapter/downgrade(mob/living/silicon/ai/user)
	..()
	if(!istype(user))
		return
	user.adapter_efficiency = 0.5 + (0.1 * upgrade_level)

/datum/ai_program/universal_adapter/uninstall(mob/living/silicon/ai/user)
	..()
	if(!istype(user))
		return
	user.adapter_efficiency = 0.5
	user.universal_adapter = FALSE

//////////////////////////////
// MARK: Airlock Restoration
//////////////////////////////

/datum/ai_program/airlock_restoration
	program_name = "Airlock Restoration"
	program_id = "airlock_restoration"
	description = "Repair an airlock's wires, if the AI control wire is not cut."
	cost = 2
	nanite_cost = 25
	power_type = /datum/spell/ai_spell/ranged/airlock_restoration
	unlock_text = "Door repair and override firmware installation complete!"

/datum/spell/ai_spell/ranged/airlock_restoration
	name = "Airlock Restoration"
	desc = "Repair the wires in an airlock that still has an intact AI control wire."
	action_icon = 'icons/obj/doors/doorint.dmi'
	action_icon_state = "door_closed"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 60 SECONDS
	cooldown_min = 60 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You prepare to deploy repairing nanites to a door...</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the request.</span>"

/datum/spell/ai_spell/ranged/airlock_restoration/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/obj/machinery/door/airlock/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!istype(target))
		to_chat(user, "<span class='warning'>You can only repair airlocks!</span>")
		revert_cast()
		return

	if(target.wires.is_cut(WIRE_AI_CONTROL))
		to_chat(user, "<span class='warning'>Error: Null Connection to Airlock!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	var/turf/T = get_turf(target)
	var/duration = (6 - spell_level) SECONDS
	AI.playsound_local(user, 'sound/items/deconstruct.ogg', 50, FALSE, use_reverb = FALSE)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)
	var/obj/effect/temp_visual/rcd_effect/spawning_effect = new(T)
	spawning_effect.duration = duration
	QDEL_IN(spawning_effect, duration)
	if(do_after_once(user, duration, target = target, allow_moving = TRUE))
		target.wires.repair()
		playsound(T, 'sound/items/deconstruct.ogg', 100, TRUE)
		if(spell_level >= 5)
			target.emagged = FALSE
			target.electronics = initial(target.electronics)

/datum/spell/ai_spell/ranged/airlock_restoration/on_purchase_upgrade()
	if(spell_level == 5)
		desc += " Firmware version sufficient enough to repair damage caused by a cryptographic sequencer."

//////////////////////////////
// MARK: Automated Extinguisher
//////////////////////////////

/datum/ai_program/extinguishing_system
	program_name = "Automated Extinguishing System"
	program_id = "extinguishing_system"
	description = "Deploy a nanofrost globule to a target to rapidly extinguish plasmafires."
	nanite_cost = 50
	power_type = /datum/spell/ai_spell/ranged/extinguishing_system
	unlock_text = "Nanofrost synthesizer online."

/datum/spell/ai_spell/ranged/extinguishing_system
	name = "Automated Extinguishing System"
	desc = "Deploy a nanofrost globule to a target to rapidly extinguish plasmafires."
	action_icon = 'icons/effects/effects.dmi'
	action_icon_state = "frozen_smoke_capsule"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 60 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 3
	selection_activated_message = "<span class='notice'>You prepare to synthesize a nanofrost globule...</span>"
	selection_deactivated_message = "<span class='notice'>You let the nanofrost dissipate.</span>"

/datum/spell/ai_spell/ranged/extinguishing_system/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/turf/target = get_turf(targets[1])
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!isturf(target))
		to_chat(user, "<span class='warning'>Invalid location for nanofrost deployment!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	var/obj/effect/nanofrost_container/nanofrost = new /obj/effect/nanofrost_container(target)
	log_game("[key_name(user)] used Nanofrost at [get_area(target)] ([target.x], [target.y], [target.z]).")
	AI.play_sound_remote(src, 'sound/items/syringeproj.ogg', 40)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)
	addtimer(CALLBACK(nanofrost, TYPE_PROC_REF(/obj/effect/nanofrost_container, Smoke)), 5 SECONDS)

/datum/spell/ai_spell/ranged/extinguishing_system/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (spell_level * 15 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Bluespace Miner
//////////////////////////////

/datum/ai_program/bluespace_miner
	program_name = "Bluespace Miner Subsystem"
	program_id = "bluespace_miner"
	description = "You link yourself to a miniature bluespace harvester, generating income for the science account at the cost of increasing your core's power needs."
	unlock_text = "Bluespace miner installation complete!"
	upgrade = TRUE

/datum/ai_program/bluespace_miner/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	..()
	if(!istype(user))
		return
	user.bluespace_miner_rate = 100 + (100 * upgrade_level)
	user.next_payout = 10 MINUTES + world.time
	user.bluespace_miner = TRUE
	installed = TRUE

/datum/ai_program/bluespace_miner/downgrade(mob/living/silicon/ai/user)
	..()
	if(!istype(user))
		return
	user.bluespace_miner_rate = 100 + (100 * upgrade_level)

/datum/ai_program/bluespace_miner/uninstall(mob/living/silicon/ai/user)
	..()
	if(!istype(user))
		return
	user.bluespace_miner_rate = 100

//////////////////////////////
// MARK: Multimarket Analysis
//////////////////////////////

/datum/ai_program/multimarket_analyser
	program_name = "Multimarket Analysis Subsystem"
	program_id = "multimarket_analyser"
	description = "You connect to a digital marketplace to price-check all orders from the station, ensuring you get the best prices! This reduces the cost of crates in cargo!"
	unlock_text = "Online marketplace detected... connected!"
	max_level = 6
	upgrade = TRUE
	/// Track the original modifier
	var/original_price_mod

/datum/ai_program/multimarket_analyser/New()
	..()
	original_price_mod = SSeconomy.pack_price_modifier

/datum/ai_program/multimarket_analyser/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	..()
	SSeconomy.pack_price_modifier = original_price_mod * (0.95 - (0.05 * upgrade_level))
	installed = TRUE

/datum/ai_program/multimarket_analyser/downgrade(mob/living/silicon/ai/user)
	..()
	SSeconomy.pack_price_modifier = original_price_mod * (0.95 - (0.05 * upgrade_level))

/datum/ai_program/multimarket_analyser/uninstall(mob/living/silicon/ai/user)
	..()
	SSeconomy.pack_price_modifier = original_price_mod

//////////////////////////////
// MARK: Light Synthesizer
//////////////////////////////

/datum/ai_program/light_repair
	program_name = "Light Synthesizer"
	program_id = "light_repair"
	description = "Replace damaged or missing lightbulbs."
	nanite_cost = 5
	power_type = /datum/spell/ai_spell/ranged/light_repair
	unlock_text = "Light replacer configuration installed."

/datum/spell/ai_spell/ranged/light_repair
	name = "Light Synthesizer"
	desc = "Replace damaged or missing lightbulbs."
	action_icon = 'icons/obj/janitor.dmi'
	action_icon_state = "lightreplacer0"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You prepare to synthesize a lightbulb...</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the request.</span>"

/datum/spell/ai_spell/ranged/light_repair/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/obj/machinery/light/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!istype(target))
		to_chat(user, "<span class='warning'>You can only repair lights!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	// Handle repairs here since we're using a spell and not a tool
	target.status = LIGHT_OK
	target.switchcount = 0
	target.emagged = FALSE
	target.on = target.has_power()
	target.update(TRUE, TRUE, FALSE)
	AI.play_sound_remote(target, 'sound/machines/ding.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/light_repair/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (spell_level * 5 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Nanosurgeon Deployment
//////////////////////////////

/datum/ai_program/nanosurgeon_deployment
	program_name = "Nanosurgeon Deployment"
	program_id = "nanosurgeon_deployment"
	description = "Heal a crew member with large numbers of robotic nanomachines!"
	cost = 3
	nanite_cost = 75
	power_type = /datum/spell/ai_spell/ranged/nanosurgeon_deployment
	unlock_text = "Surgical nanomachine firmware installation complete!"

/datum/spell/ai_spell/ranged/nanosurgeon_deployment
	name = "Nanosurgeon Deployment"
	desc = "Heal a crew member with large numbers of robotic nanomachines!"
	action_icon = 'icons/obj/surgery.dmi'
	action_icon_state = "scalpel_laser1_on"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 150 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 10
	selection_activated_message = "<span class='notice'>You prepare to order your nanomachines to perform organic repairs...</span>"
	selection_deactivated_message = "<span class='notice'>You rescind the order.</span>"

/datum/spell/ai_spell/ranged/nanosurgeon_deployment/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/mob/living/carbon/human/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	if(!istype(target) || ismachineperson(target))
		to_chat(user, "<span class='warning'>You can only heal organic crew!</span>")
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	AI.play_sound_remote(target, 'sound/magic/magic_block.ogg', 50)
	camera_beam(target, "medbeam", 'icons/effects/beam.dmi', 5 SECONDS)
	// Only allow moving targets if the program is max level.
	var/allow_moving = FALSE
	if(spell_level == level_max)
		allow_moving = TRUE
		to_chat(target, "<span class='notice'>You feel a flow of healing nanites stream to you from a nearby camera.</span>")
	else
		to_chat(target, "<span class='notice'>You feel a flow of healing nanites stream to you from a nearby camera. Hold still for them to work!</span>")
	if(do_after(AI, 5 SECONDS, target = target, allow_moving_target = allow_moving))
		// Check camera vision again.
		if(!check_camera_vision(user, target))
			AI.program_picker.refund_nanites(program.nanite_cost)
			revert_cast()
			return
		var/damage_healed = 20 + (min(30, (10 * spell_level)))
		target.heal_overall_damage(damage_healed, damage_healed)
		if(spell_level >= 5)
			for(var/obj/item/organ/external/E in target.bodyparts)
				if(prob(10 * spell_level))
					E.mend_fracture()
					E.fix_internal_bleeding()
					E.fix_burn_wound()
	else
		AI.program_picker.refund_nanites(program.nanite_cost)
		revert_cast()

/datum/spell/ai_spell/ranged/nanosurgeon_deployment/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (max(spell_level - 3, 0) * 30 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Enhanced Door Controls
//////////////////////////////

/datum/ai_program/enhanced_doors
	program_name = "Enhanced Door Controls"
	program_id = "enhanced_doors"
	description = "You enhance the subroutines that let you control doors, speeding up response times!"
	unlock_text = "Doors connected and optimized. You feel right at home."
	upgrade = TRUE
	/// Track the original delay
	var/original_door_delay = 3 SECONDS

/datum/ai_program/enhanced_doors/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	..()
	if(!istype(user))
		return
	user.door_bolt_delay = original_door_delay * (1 - (upgrade_level * 0.1))
	installed = TRUE

/datum/ai_program/enhanced_doors/downgrade(mob/living/silicon/ai/user)
	..()
	user.door_bolt_delay = original_door_delay * (1 - (upgrade_level * 0.1))

/datum/ai_program/enhanced_doors/uninstall(mob/living/silicon/ai/user)
	..()
	user.door_bolt_delay = original_door_delay


//////////////////////////////
// MARK: Experimental Research Subsystem
//////////////////////////////

/datum/ai_program/research_subsystem
	program_name = "Experimental Research Subsystem"
	program_id = "research_subsystem"
	description = "Put your processors to work spinning centrifuges and studying results. You unlock a new point of research in a random field."
	cost = 5
	max_level = 10
	unlock_text = "Research and Discovery submodule installation complete. Automated information gathering enabled."
	upgrade = TRUE

/datum/ai_program/research_subsystem/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	..()
	if(!istype(user))
		return
	user.research_level = upgrade_level
	user.research_time = 10 MINUTES - (30 SECONDS * upgrade_level)
	if(first_install)
		user.last_research_time = 10 MINUTES - (30 SECONDS * upgrade_level)
	user.research_subsystem = TRUE
	installed = TRUE

/datum/ai_program/research_subsystem/downgrade(mob/living/silicon/ai/user)
	..()
	if(!istype(user))
		return
	user.research_level = upgrade_level
	user.research_time = 10 MINUTES - (30 SECONDS * upgrade_level)

/datum/ai_program/research_subsystem/uninstall(mob/living/silicon/ai/user)
	..()
	if(!istype(user))
		return
	user.research_time = 10 MINUTES
	user.research_subsystem = FALSE

//////////////////////////////
// MARK: Emergency Sealant
//////////////////////////////

/datum/ai_program/emergency_sealant
	program_name = "Emergency Sealant"
	program_id = "emergency_sealant"
	description = "Deploy an area of metal foam to rapidly repair and seal hull breaches."
	cost = 2
	nanite_cost = 50
	power_type = /datum/spell/ai_spell/ranged/emergency_sealant
	unlock_text = "Metal foam synthesizer online."

/datum/spell/ai_spell/ranged/emergency_sealant
	name = "Emergency Sealant"
	desc = "Deploy an area of metal foam to rapidly repair and seal hull breaches."
	action_icon = 'icons/obj/structures.dmi'
	action_icon_state = "reinforced"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 180 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You fill a canister with metal foam...</span>"
	selection_deactivated_message = "<span class='notice'>You dissolve the unused canister.</span>"

/datum/spell/ai_spell/ranged/emergency_sealant/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	AI.play_sound_remote(target, 'sound/effects/bubbles2.ogg', 50)
	new /obj/effect/temp_visual/ai_sealant(get_turf(target))
	addtimer(CALLBACK(src, PROC_REF(do_metal_foam), user, target), 10 SECONDS)

/datum/spell/ai_spell/ranged/emergency_sealant/proc/do_metal_foam(mob/user, target)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 15)
	var/obj/effect/particle_effect/foam/metal/F = new /obj/effect/particle_effect/foam/metal(get_turf(target), TRUE)
	F.spread_amount = 2

/datum/spell/ai_spell/ranged/emergency_sealant/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(min(base_cooldown, base_cooldown - (spell_level * 30)), 30 SECONDS)
	cooldown_handler.recharge_duration = max(base_cooldown - (spell_level * 30 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Holosign Deployer
//////////////////////////////

/datum/ai_program/holosign_displayer
	program_name = "Holosign Displayer"
	program_id = "holosign_displayer"
	description = "Deploy a holographic sign to alert crewmembers to potential hazards."
	nanite_cost = 10
	power_type = /datum/spell/ai_spell/ranged/holosign_displayer
	unlock_text = "Metal foam synthesizer online."

/datum/spell/ai_spell/ranged/holosign_displayer
	name = "Holosign Displayer"
	desc = "Deploy a holographic sign to alert crewmembers to potential hazards."
	action_icon = 'icons/obj/device.dmi'
	action_icon_state = "signmaker"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 30 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 8
	selection_activated_message = "<span class='notice'>You spool up your projector...</span>"
	selection_deactivated_message = "<span class='notice'>You stop spooling the projector.</span>"
	/// Types of holosigns the AI can deploy
	var/sign_choices = list(
		"Engineering",
		"Security",
		"Wet Floor"
	)
	/// List of currently active signs
	var/signs = list()

/datum/spell/ai_spell/ranged/holosign_displayer/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	var/sign_id = tgui_input_list(usr, "Select a holosign!", "AI", sign_choices)
	if(!sign_id)
		return
	var/sign_type
	switch(sign_id)
		if("Engineering")
			sign_type = /obj/structure/holosign/barrier/engineering
		if("Wet Floor")
			sign_type = /obj/structure/holosign/wetsign
		if("Security")
			sign_type = /obj/structure/holosign/barrier
		else
			revert_cast()
			return
	var/H = new sign_type(get_turf(target), src)
	addtimer(CALLBACK(src, PROC_REF(sign_timer_complete), H), (60 + 30 * spell_level) SECONDS, TIMER_UNIQUE)
	AI.play_sound_remote(target, 'sound/machines/click.ogg', 20)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/holosign_displayer/proc/sign_timer_complete(obj/structure/holosign/H)
	playsound(H.loc, 'sound/machines/chime.ogg', 20, 1)
	qdel(H)

//////////////////////////////
// MARK: HONK Subsystem
//////////////////////////////

/datum/ai_program/honk_subsystem
	program_name = "Honk Subsystem"
	program_id = "honk_subsystem"
	description = "Download a program from Clowns.NT to be able to play bike horn sounds on demand."
	nanite_cost = 5
	power_type = /datum/spell/ai_spell/ranged/honk_subsystem
	unlock_text = "Honker.exe installed."

/datum/spell/ai_spell/ranged/honk_subsystem
	name = "Honk Subsystem"
	desc = "Download a program from Clowns.NT to be able to play bike horn sounds on demand."
	action_icon = 'icons/obj/items.dmi'
	action_icon_state = "bike_horn"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 30 SECONDS
	cooldown_min = 15 SECONDS
	level_max = 10
	selection_activated_message = "<span class='notice'>You prepare to honk...</span>"
	selection_deactivated_message = "<span class='notice'>You reduce the amount of humor in your subsystems.</span>"

/datum/spell/ai_spell/ranged/honk_subsystem/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/target = targets[1]
	if(!target)
		return
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	if(spell_level >= 10)
		AI.play_sound_remote(target, 'sound/items/airhorn.ogg', 50,)
	else
		AI.play_sound_remote(target, 'sound/items/bikehorn.ogg', 50)

/datum/spell/ai_spell/ranged/honk_subsystem/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (spell_level * 15 SECONDS), cooldown_min)
	if(cooldown_handler.is_on_cooldown())
		cooldown_handler.start_recharge()

//////////////////////////////
// MARK: Enhanced Tracker
//////////////////////////////

/datum/ai_program/enhanced_tracker
	program_name = "Enhanced Tracking Subsystem"
	program_id = "enhanced_tracker"
	description = "New camera firmware allows automated alerts when an individual of interest enters camera view."
	cost = 5
	power_type = /datum/spell/ai_spell/enhanced_tracker
	unlock_text = "Tag and track software online."
	max_level = 8

/datum/ai_program/enhanced_tracker/upgrade(mob/living/silicon/ai/user, first_install = FALSE)
	..()
	if(!istype(user))
		return
	user.enhanced_tracking = TRUE
	user.alarms_listened_for += "Tracking"
	user.enhanced_tracking_delay = initial(user.enhanced_tracking_delay) - (upgrade_level * 1 SECONDS)

/datum/ai_program/enhanced_tracker/downgrade(mob/living/silicon/ai/user)
	..()
	user.enhanced_tracking_delay = initial(user.enhanced_tracking_delay) - (upgrade_level * 1 SECONDS)

/datum/ai_program/enhanced_tracker/uninstall(mob/living/silicon/ai/user)
	..()
	user.enhanced_tracking = FALSE
	user.alarms_listened_for -= "Tracking"
	user.enhanced_tracking_delay = initial(user.enhanced_tracking_delay)

/datum/spell/ai_spell/enhanced_tracker
	name = "Enhanced Tracking Subsystem"
	desc = "Select a target of interest to be alerted to their presence on cameras."
	action_icon = 'icons/obj/items.dmi'
	action_icon_state = "videocam"
	auto_use_uses = FALSE
	base_cooldown = 10 SECONDS
	cooldown_min = 10 SECONDS
	level_max = 8

/datum/spell/ai_spell/enhanced_tracker/cast(list/targets, mob/living/silicon/ai/user)
	if(!istype(user))
		return
	// Pick a mob to track
	var/target_name = tgui_input_list(user, "Pick a trackable target...", "AI", user.trackable_mobs())
	if(!target_name)
		user.tracked_mob = null
		return
	user.tracked_mob = (isnull(user.track.humans[target_name]) ? user.track.others[target_name] : user.track.humans[target_name])

/mob/living/silicon/ai/proc/raise_tracking_alert(area/A, mob/target)
	var/obj/machinery/camera/closest_camera
	for(var/obj/machinery/camera/C in A)
		if(closest_camera == null)
			closest_camera = C
			continue
		if(get_dist(closest_camera, target) > get_dist(C, target))
			closest_camera = C
			continue
	closest_camera.visible_message("<span class='warning'>A purple light flashes on [closest_camera]!</span>")
	if(GLOB.alarm_manager.trigger_alarm("Tracking", A, A.cameras, closest_camera))
		// Cancel alert after 1 minute
		addtimer(CALLBACK(GLOB.alarm_manager, TYPE_PROC_REF(/datum/alarm_manager, cancel_alarm), "Tracking", A, closest_camera), 1 MINUTES)

/mob/living/silicon/ai/proc/reset_tracker_cooldown()
	tracker_alert_cooldown = FALSE

//////////////////////////////
// MARK: Holopointer
//////////////////////////////

/datum/ai_program/pointer
	program_name = "Holopointer"
	program_id = "holopointer"
	description = "Illuminate a hologram to notify or beckon crew."
	nanite_cost = 5
	power_type = /datum/spell/ai_spell/ranged/pointer
	unlock_text = "Hologram emitters online."

/datum/spell/ai_spell/ranged/pointer
	name = "Holopointer"
	desc = "Illuminate a hologram to notify or beckon crew."
	action_icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	action_icon_state = "target_circle"
	ranged_mousepointer = 'icons/mouse_icons/mecha_mouse.dmi'
	base_cooldown = 15 SECONDS
	cooldown_min = 15 SECONDS
	level_max = 1
	selection_activated_message = "<span class='notice'>You prepare to illuminate a hologram...</span>"
	selection_deactivated_message = "<span class='notice'>You spool down your projector.</span>"

/datum/spell/ai_spell/ranged/pointer/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No valid target!</span>")
		revert_cast()
		return
	var/target = targets[1]
	if(!check_camera_vision(user, target))
		revert_cast()
		return
	var/mob/living/silicon/ai/AI = user
	if(!AI.program_picker.spend_nanites(program.nanite_cost))
		to_chat(user, "<span class='warning'>Not enough nanites!</span>")
		revert_cast()
		return
	new /obj/effect/temp_visual/ai_pointer(get_turf(target))
