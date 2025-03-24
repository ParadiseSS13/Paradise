// The datum and interface for the AI powers menu
/datum/program_picker
	/// Associated AI
	var/mob/living/silicon/ai/assigned_ai
	/// List of programs that can be bought
	var/list/possible_programs
	/// How much memory is available
	var/memory = 1
	/// How much total memory does the system have?
	var/total_memory = 1
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
	if(key == "memory")
		memory += amount
		total_memory += amount
		if(memory < 0)
			refund_purchases()
	if(key == "bandwidth")
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

/datum/program_picker/ui_host()
	return assigned_ai ? assigned_ai : src

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
								temp = "You cannot afford this upgrade!"
								return FALSE
							selected_program.name = initial(selected_program.name)
							selected_program.spell_level++
							program.upgrade_level++
							program.bandwidth_used++
							bandwidth--
							if(selected_program.spell_level >= selected_program.level_max)
								to_chat(A, "<span class='notice'>This program cannot be upgraded any further.</span>")
							selected_program.on_purchase_upgrade()
							program.upgrade(A)
							return TRUE

				// No same active program found, install
				if(program.cost > memory)
					to_chat(A, "<span class='notice'>You cannot afford this program.</span>")
					return FALSE
				memory -= program.cost
				SSblackbox.record_feedback("tally", "ai_program_installed", 1, new_spell.name)
				program.upgrade(A) // Usually does nothing for actives, but is needed for hybrid abilities like the enhanced tracker
				A.AddSpell(new_spell)
				to_chat(A, program.unlock_text)
				A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
				program.installed = TRUE
				return TRUE
			// Passive programs
			if(program.upgrade_level > program.max_level)
				to_chat(A, "<span class='notice'>This program cannot be upgraded any further.</span>")
				return FALSE
			program.upgrade(A)
			to_chat(A, program.unlock_text)
			A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
			return TRUE

// The base program type, which holds info about each ability.
/datum/ai_program
	var/program_name
	var/description = ""
	/// Internal ID of the program
	var/program_id
	/// How much memory does the program cost?
	var/cost = 1
	/// How much does this program cost to use?
	var/nanite_cost = 10
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

/datum/spell/ai_spell/choose_program
	name = "Choose Programs"
	desc = "Spend your memory and bandwidth to gain a variety of different abilities."
	action_icon = 'icons/mob/ai.dmi'
	action_icon_state = "ai"
	auto_use_uses = FALSE // This is an infinite ability.
	create_attack_logs = FALSE

/datum/ai_program/proc/upgrade(mob/living/silicon/ai/user)
	if(!istype(user))
		return

/datum/ai_program/proc/downgrade(mob/living/silicon/ai/user)
	if(!istype(user))
		return
	upgrade_level--
	if(!upgrade_level <= 0)
		uninstall(user)
		return
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
	if(!upgrade) // Passives need to be handled in their own procs
		var/datum/spell/ai_spell/removed_spell = new power_type
		for(var/datum/spell/ai_spell/aspell in user.mob_spell_list)
			if(removed_spell.type == aspell.type)
				user.RemoveSpell(aspell)
	return

/datum/spell/ai_spell/choose_program/cast(list/targets, mob/living/silicon/ai/user)
	. = ..()
	// user.program_picker.use(user) // WebUI call. Replace with TGUI call below.
	user.program_picker.ui_interact(user)

// RGB Lighting - Recolors Lights
/datum/ai_program/rgb_lighting
	program_name = "RGB Lighting"
	program_id = "rgb_lighting"
	description = "Recolor a light to a desired color. At significantly high efficiency, it can change the color of an entire room's lighting by targeting the APC."
	nanite_cost = 5
	power_type = /datum/spell/ai_spell/ranged/rgb_lighting
	unlock_text = "RGB Lighting installation complete!"

/datum/spell/ai_spell/ranged/rgb_lighting
	name = "RGB Lighting"
	desc = "Changes the color of a selected light"
	action_icon = 'icons/obj/lighting.dmi'
	action_icon_state = "random_glowstick"
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You hook into the station's lighting controller...</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the request from the lighting controller.</span>"

/datum/spell/ai_spell/ranged/rgb_lighting/cast(list/targets, mob/user)
	var/obj/machinery/target = targets[1]
	if(!istype(target, /obj/machinery/light) && !istype(target, /obj/machinery/power/apc))
		to_chat(user, "<span class='warning'>You can only recolor lights!</span>")
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
			return
		var/obj/machinery/power/apc/A = target
		for(var/obj/machinery/light/L in A.apc_area)
			L.color = new_color
			L.brightness_color = new_color
	else
		var/obj/machinery/light/L = target
		L.color = new_color
		L.brightness_color = new_color
	var/mob/living/silicon/ai/AI = user
	AI.program_picker.nanites -= 5
	AI.play_sound_remote(target, 'sound/effects/spray.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/rgb_lighting/on_purchase_upgrade()
	cooldown_handler.recharge_duration = base_cooldown - (spell_level * 5)

// Power Shunt - Recharges things from your SMES
/datum/ai_program/power_shunt
	program_name = "Power Shunt"
	program_id = "power_shunt"
	description = "Recharge an APC, Borg, or Mech with power directly from your SMES!"
	nanite_cost = 20
	power_type = /datum/spell/ai_spell/ranged/power_shunt
	unlock_text = "Power Shunt installation complete!"

/datum/spell/ai_spell/ranged/power_shunt
	name = "Power Shunt"
	desc = "Recharge an APC, Borg, or Mech with power directly from your SMES"
	action_icon = 'icons/obj/power.dmi'
	action_icon_state = "smes-o"
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 300 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 7
	selection_activated_message = "<span class='notice'>You tap into the station's powernet...</span>"
	selection_deactivated_message = "<span class='notice'>You release your hold on the powernet.</span>"
	var/power_sent = 2500

/datum/spell/ai_spell/ranged/power_shunt/cast(list/targets, mob/user)
	var/target = targets[1]
	if(!istype(target, /mob/living/silicon/robot) && !istype(target, /obj/machinery/power/apc) && !istype(target, /obj/mecha) && !istype(target, /mob/living/carbon/human/machine))
		to_chat(user, "<span class='warning'>You can only recharge borgs, mechs, and APCs!</span>")
		return
	var/mob/living/silicon/ai/AI = user
	if(istype(target, /mob/living/carbon/human/machine)  && !AI.universal_adapter)
		to_chat(user, "<span class='warning'>This software lacks the required upgrade to recharge IPCs!</span>")
		return
	var/area/A = get_area(user)
	if(A == null)
		to_chat(user, "<span class='warning'>No SMES detected to power from!</span>")
		return
	if(istype(target, /obj/mecha))
		var/obj/mecha/T = target
		T.cell.give(power_sent)
	if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/T = target
		T.cell.give(power_sent)
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/T = target
		T.cell.give(power_sent)
	if(istype(target, /mob/living/carbon/human/machine))
		var/mob/living/carbon/human/machine/T = target
		T.adjust_nutrition(AI.adapter_efficiency * (power_sent / 10))

	// Handles draining the SMES
	for(var/obj/machinery/power/smes/power_source in A)
		if(power_source.charge < power_sent)
			continue
		power_source.charge -= power_sent
		break
	AI.program_picker.nanites -= 20
	AI.play_sound_remote(target, 'sound/goonstation/misc/fuse.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/power_shunt/on_purchase_upgrade()
	power_sent = min(10000, 2500 + (spell_level * 2500))
	cooldown_handler.recharge_duration = max(min(base_cooldown, base_cooldown - ((spell_level-3) * 60)), 30 SECONDS)

// Repair Nanites - Uses large numbers of nanites to repair things
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
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 450 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 10
	selection_activated_message = "<span class='notice'>You prepare to order your nanomachines to repair...</span>"
	selection_deactivated_message = "<span class='notice'>You rescind the order.</span>"

/datum/spell/ai_spell/ranged/repair_nanites/cast(list/targets, mob/user)
	var/target = targets[1]
	if(!istype(target, /mob/living/silicon/robot) && !istype(target, /obj/machinery/power/apc) && !istype(target, /obj/mecha) && !istype(target, /mob/living/carbon/human/machine))
		to_chat(user, "<span class='warning'>You can only recharge borgs, mechs, and APCs!</span>")
		return
	var/mob/living/silicon/ai/AI = user
	if(istype(target, /mob/living/carbon/human/machine)  && !AI.universal_adapter)
		to_chat(user, "<span class='warning'>This software lacks the required upgrade to recharge IPCs!</span>")
		return
	if(istype(target, /obj/mecha)|| istype(target, /obj/machinery/power/apc))
		var/obj/T = target
		T.obj_integrity += min(T.max_integrity, T.max_integrity * (0.2 +  min(0.3, (0.1 * spell_level))))
	if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/T = target
		var/damage_healed = 20 + (min(30, (10 * spell_level)))
		T.heal_overall_damage(damage_healed, damage_healed)
	if(istype(target, /mob/living/carbon/human/machine))
		var/mob/living/carbon/human/machine/T = target
		var/damage_healed = AI.adapter_efficiency * (20 + (min(30, (10 * spell_level))))
		T.heal_overall_damage(damage_healed, damage_healed, TRUE, 0, 1)
	AI.program_picker.nanites -= 75
	AI.play_sound_remote(target, 'sound/goonstation/misc/fuse.ogg', 50)
	camera_beam(target, "medbeam", 'icons/effects/beam.dmi', 10)

/datum/spell/ai_spell/ranged/repair_nanites/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(min(base_cooldown, base_cooldown - ((spell_level-3) * 60)), 30 SECONDS)

// Universal Adapter - Unlocks usage of repair nanites and power shunt for IPCs
/datum/ai_program/universal_adapter
	program_name = "Universal Adapter"
	program_id = "universal_adapter"
	description = "Upgraded firmware allows IPCs to be valid targets for Power Shunt and Repair Nanites, at half efficiency."
	nanite_cost = 0
	unlock_text = "Universal adapter installation complete!"
	upgrade = TRUE

/datum/ai_program/universal_adapter/upgrade(mob/living/silicon/ai/user)
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

// Door Override - Repairs door wires if the AI wire is not cut
/datum/ai_program/door_override
	program_name = "Door Override"
	program_id = "door_override"
	description = "Repair an airlocks's wires, if the AI control wire is not cut."
	cost = 2
	nanite_cost = 25
	power_type = /datum/spell/ai_spell/ranged/door_override
	unlock_text = "Door repair and override firmware installation complete!"

/datum/spell/ai_spell/ranged/door_override
	name = "Door Override"
	desc = "Repair the wires in an airlock that still has an intact AI control wire."
	action_icon = 'icons/obj/doors/doorint.dmi'
	action_icon_state = "door_closed"
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 60 SECONDS
	cooldown_min = 60 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You hook into the station's lighting controller...</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the request from the lighting controller.</span>"

/datum/spell/ai_spell/ranged/door_override/cast(list/targets, mob/user)
	var/obj/machinery/door/airlock/target = targets[1]
	if(!istype(target))
		to_chat(user, "<span class='warning'>You can only repair airlocks!</span>")
		return

	if(target.wires.is_cut(WIRE_AI_CONTROL))
		to_chat(user, "<span class='warning'>Error: Null Connection to Airlock!</span>")
		return

	var/turf/T = get_turf(target)
	var/mob/living/silicon/ai/AI = user
	var/duration = (6 - spell_level) SECONDS
	AI.program_picker.nanites -= 25
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

/datum/spell/ai_spell/ranged/door_override/on_purchase_upgrade()
	if(spell_level == 5)
		desc += " Firmware version sufficient enough to repair damage caused by a cryptographic sequencer."

// Automated Extinguishing System: Deploys nanofrost to a target tile
/datum/ai_program/extinguishing_system
	program_name = "Automated Extinguishing System"
	program_id = "extinguishing_system"
	description = "Deploy a nanofrost globule to a target to rapidly extinguish plasmafires."
	cost = 3
	nanite_cost = 50
	power_type = /datum/spell/ai_spell/ranged/extinguishing_system
	unlock_text = "Nanofrost synthesizer online."

/datum/spell/ai_spell/ranged/extinguishing_system
	name = "Automated Extinguishing System"
	desc = "Deploy a nanofrost globule to a target to rapidly extinguish plasmafires."
	action_icon = 'icons/effects/effects.dmi'
	action_icon_state = "frozen_smoke_capsule"
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 300 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 7
	selection_activated_message = "<span class='notice'>You prepare to synthesize a nanofrost globule...</span>"
	selection_deactivated_message = "<span class='notice'>You let the nanofrost dissipate.</span>"

/datum/spell/ai_spell/ranged/extinguishing_system/cast(list/targets, mob/user)
	var/turf/target = get_turf(targets[1])
	if(!isturf(target))
		to_chat(user, "<span class='warning'>Invalid location for nanofrost deployment!</span>")
		return

	var/obj/effect/nanofrost_container/nanofrost = new /obj/effect/nanofrost_container(target)
	log_game("[key_name(user)] used Nanofrost at [get_area(target)] ([target.x], [target.y], [target.z]).")
	var/mob/living/silicon/ai/AI = user
	AI.program_picker.nanites -= 50
	AI.play_sound_remote(src, 'sound/items/syringeproj.ogg', 40)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)
	addtimer(CALLBACK(nanofrost, TYPE_PROC_REF(/obj/effect/nanofrost_container, Smoke)), 5 SECONDS)

/datum/spell/ai_spell/ranged/extinguishing_system/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(min(base_cooldown, base_cooldown - (spell_level * 30)), 30 SECONDS)

// Bluespace Miner Subsystem - Makes money for science, at the cost of extra power drain
/datum/ai_program/bluespace_miner
	program_name = "Bluespace Miner Subsystem"
	program_id = "bluespace_miner"
	description = "You link yourself to a miniature bluespace harvester, generating income for the science account at the cost of increasing your core's power needs."
	nanite_cost = 0
	max_level = 5
	unlock_text = "Bluespace miner installation complete!"
	upgrade = TRUE

/datum/ai_program/bluespace_miner/upgrade(mob/living/silicon/ai/user)
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

// Multimarket Analysis Subsystem: Reduce prices of things at cargo
/datum/ai_program/multimarket_analyser
	program_name = "Multimarket Analysis Subsystem"
	program_id = "multimarket_analyser"
	description = "You connect to a digital marketplace to price-check all orders from the station, ensuring you get the best prices! This reduces the cost of crates in cargo!"
	nanite_cost = 0
	unlock_text = "Online marketplace detected... connected!"
	max_level = 6
	upgrade = TRUE
	/// Track the original modifier
	var/original_price_mod

/datum/ai_program/multimarket_analyser/New()
	..()
	original_price_mod = SSeconomy.pack_price_modifier

/datum/ai_program/multimarket_analyser/upgrade(mob/living/silicon/ai/user)
	SSeconomy.pack_price_modifier = original_price_mod * (0.95 - (0.05 * upgrade_level))
	upgrade_level++
	installed = TRUE

/datum/ai_program/multimarket_analyser/downgrade(mob/living/silicon/ai/user)
	..()
	SSeconomy.pack_price_modifier = original_price_mod * (0.95 - (0.05 * upgrade_level))

/datum/ai_program/multimarket_analyser/uninstall(mob/living/silicon/ai/user)
	..()
	SSeconomy.pack_price_modifier = original_price_mod

// Light Synthesizer - Fixes lights
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
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You prepare to synthesize a lightbulb...</span>"
	selection_deactivated_message = "<span class='notice'>You cancel the request.</span>"

/datum/spell/ai_spell/ranged/light_repair/cast(list/targets, mob/user)
	var/obj/machinery/light/target = targets[1]
	if(!istype(target))
		to_chat(user, "<span class='warning'>You can only repair lights!</span>")
		return
	var/mob/living/silicon/ai/AI = user
	// Handle repairs here since we're using a spell and not a tool
	target.status = LIGHT_OK
	target.switchcount = 0
	target.emagged = FALSE
	target.on = target.has_power()
	AI.program_picker.nanites -= 5
	AI.play_sound_remote(target, 'sound/machines/ding.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/rgb_lighting/on_purchase_upgrade()
	cooldown_handler.recharge_duration = base_cooldown - (spell_level * 5)

// Nanosurgeon Deployment - Uses large numbers of nanites to heal things
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
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 450 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 8
	selection_activated_message = "<span class='notice'>You prepare to order your nanomachines to perform surgery...</span>"
	selection_deactivated_message = "<span class='notice'>You rescind the order.</span>"

/datum/spell/ai_spell/ranged/nanosurgeon_deployment/cast(list/targets, mob/user)
	var/mob/living/carbon/human/target = targets[1]
	if(!istype(target) || istype(target, /mob/living/carbon/human/machine))
		to_chat(user, "<span class='warning'>You can only heal organic crew!</span>")
		return
	var/mob/living/silicon/ai/AI = user
	AI.program_picker.nanites -= 75
	AI.play_sound_remote(target, 'sound/goonstation/misc/fuse.ogg', 50)
	camera_beam(target, "medbeam", 'icons/effects/beam.dmi', 10)
	if(do_after_once(AI, 5 SECONDS, target = target, allow_moving = TRUE))
		var/damage_healed = 20 + (min(30, (10 * spell_level)))
		target.heal_overall_damage(damage_healed, damage_healed)
		if(spell_level >= 5)
			for(var/obj/item/organ/external/E in target.bodyparts)
				if(prob(5 * spell_level))
					E.mend_fracture()
					E.fix_internal_bleeding()
					E.fix_burn_wound()

// Enhanced Door Controls: Reduces delay in bolting and shocking doors
/datum/ai_program/enhanced_doors
	program_name = "Enhanced Door Controls"
	program_id = "enhanced_doors"
	description = "You enhance the subroutines that let you control doors, speeding up response times!"
	nanite_cost = 0
	unlock_text = "Doors connected and optimized. You feel right at home."
	max_level = 5
	upgrade = TRUE
	/// Track the original delay
	var/original_door_delay = 3 SECONDS

/datum/ai_program/enhanced_doors/upgrade(mob/living/silicon/ai/user)
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


// Experimental Research Subsystem - Knowledge is power
/datum/ai_program/research_subsystem
	program_name = "Experimental Research Subsystem"
	program_id = "research_subsystem"
	description = "Put your processors to work spinning centrifuges and studying results. You unlock a new point of research in a random field."
	cost = 5
	nanite_cost = 60
	power_type = /datum/spell/ai_spell/research_subsystem
	unlock_text = "Research and Discovery submodule installation complete."

/datum/spell/ai_spell/research_subsystem
	name = "Experimental Research Subsystem"
	desc = "Heal a crew member with large numbers of robotic nanomachines!"
	action_icon = 'icons/obj/machines/research.dmi'
	action_icon_state = "tdoppler"
	auto_use_uses = FALSE
	base_cooldown = 900 SECONDS
	cooldown_min = 600 SECONDS
	starts_charged = FALSE
	level_max = 10
	selection_activated_message = "<span class='notice'>You spool up your research tools...</span>"
	var/rnd_server = "station_rnd"

/datum/spell/ai_spell/research_subsystem/cast(list/targets, mob/user)
	// First, find the RND server
	var/network_manager_uid = null
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == rnd_server)
			network_manager_uid = RNC.UID()
			break
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(!RNC) // Could not find the RND server. It probably blew up.
		return

	var/upgraded = FALSE
	var/datum/research/files = RNC.research_files
	if(!files)
		return
	var/list/possible_tech = list()
	for(var/datum/tech/T in files.possible_tech)
		possible_tech += T
	while(!upgraded)
		var/datum/tech/tech_to_upgrade = pick_n_take(possible_tech)
		// If there are no possible techs to upgrade, stop the program
		if(!tech_to_upgrade)
			to_chat(user, "<span class='notice'>Current research cannot be discovered any further.</span>")
			return
		// No illegals until level 10
		if(spell_level < 10 && istype(tech_to_upgrade, /datum/tech/syndicate))
			continue
		// No alien research
		if(istype(tech_to_upgrade, /datum/tech/abductor))
			continue
		var/datum/tech/current = files.find_possible_tech_with_id(tech_to_upgrade.id)
		if(!current)
			continue
		// If the tech is level 7 and the program too weak, don't upgrade
		if(current.level >= 7 && spell_level < 5)
			continue
		// Nothing beyond 8
		if(current.level >= 8)
			continue
		files.UpdateTech(tech_to_upgrade.id, current.level + 1)
		to_chat(user, "<span class='notice'>Discovered innovations have led to an increase in the field of [current]!</span>")
		upgraded = TRUE

/datum/spell/ai_spell/research_subsystem/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(min(base_cooldown, base_cooldown - (spell_level * 30)), 600 SECONDS)

// Emergency Sealant - Patches holes with metal foam
/datum/ai_program/research_semergency_sealantubsystem
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
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 180 SECONDS
	cooldown_min = 30 SECONDS
	level_max = 5
	selection_activated_message = "<span class='notice'>You fill a canister with metal foam...</span>"
	selection_deactivated_message = "<span class='notice'>You dissolve the unused canister.</span>"

/datum/spell/ai_spell/ranged/emergency_sealant/cast(list/targets, mob/user)
	var/target = targets[1]
	var/mob/living/silicon/ai/AI = user
	AI.program_picker.nanites -= 50
	AI.play_sound_remote(target, 'sound/effects/bubbles2.ogg', 50)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 15)
	var/obj/effect/particle_effect/foam/metal/F = new /obj/effect/particle_effect/foam/metal(get_turf(target), TRUE)
	F.spread_amount = 2

/datum/spell/ai_spell/ranged/door_override/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(min(base_cooldown, base_cooldown - (spell_level * 30)), 30 SECONDS)

// Holosign Deployment - Deploys a holosign on the selected turf
/datum/ai_program/holosign_displayer
	program_name = "Holosign Displayer"
	program_id = "holosign_displayer"
	description = "Deploy a holographic sign to alert crewmembers to potential hazards."
	cost = 1
	nanite_cost = 10
	power_type = /datum/spell/ai_spell/ranged/holosign_displayer
	unlock_text = "Metal foam synthesizer online."

/datum/spell/ai_spell/ranged/holosign_displayer
	name = "Holosign Displayer"
	desc = "Deploy a holographic sign to alert crewmembers to potential hazards."
	action_icon = 'icons/obj/device.dmi'
	action_icon_state = "signmaker"
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
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
	var/sign_id = tgui_input_list(usr, "Select an holosgn!", "AI", sign_choices)
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
			return
	var/target = targets[1]
	var/mob/living/silicon/ai/AI = user
	AI.program_picker.nanites -= 10
	var/H = new sign_type(get_turf(target), src)
	addtimer(CALLBACK(src, PROC_REF(sign_timer_complete), H), (60 + 30 * spell_level) SECONDS, TIMER_UNIQUE)
	AI.play_sound_remote(target, 'sound/machines/click.ogg', 20)
	camera_beam(target, "rped_upgrade", 'icons/effects/effects.dmi', 5)

/datum/spell/ai_spell/ranged/holosign_displayer/proc/sign_timer_complete(obj/structure/holosign/H)
	playsound(H.loc, 'sound/machines/chime.ogg', 20, 1)
	qdel(H)

// HONK Subsystem - HONK
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
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS
	level_max = 10
	selection_activated_message = "<span class='notice'>You prepare to honk...</span>"
	selection_deactivated_message = "<span class='notice'>You reduce the amount of humor in your subsystems.</span>"

/datum/spell/ai_spell/ranged/honk_subsystem/cast(list/targets, mob/user)
	var/target = targets[1]
	if(!target)
		return
	var/mob/living/silicon/ai/AI = user
	AI.program_picker.nanites -= 5
	if(spell_level >= 10)
		AI.play_sound_remote(user, 'sound/items/airhorn.ogg', 50,)
	else
		AI.play_sound_remote(user, 'sound/items/bikehorn.ogg', 50)

/datum/spell/ai_spell/ranged/honk_subsystem/on_purchase_upgrade()
	cooldown_handler.recharge_duration = max(base_cooldown - (spell_level * 15) SECONDS, 15 SECONDS)

// Enhanced Tracking System - Select a target. Get alerted after a delay whenever that target enters camera sight
/datum/ai_program/enhanced_tracker
	program_name = "Enhanced Tracking Subsystem"
	program_id = "enhanced_tracker"
	description = "New camera firmware allows automated alerts when an individual of interest enters camera view."
	cost = 5
	nanite_cost = 0
	power_type = /datum/spell/ai_spell/enhanced_tracker
	unlock_text = "Tag and track software online."
	max_level = 8

/datum/ai_program/enhanced_tracker/upgrade(mob/living/silicon/ai/user)
	if(!istype(user))
		return
	user.enhanced_tracking = TRUE
	user.alarms_listened_for += "Tracking"
	user.enhanced_tracking_delay = initial(user.enhanced_tracking_delay) - (upgrade_level * 2 SECONDS)

/datum/ai_program/enhanced_tracker/downgrade(mob/living/silicon/ai/user)
	..()
	user.enhanced_tracking_delay = initial(user.enhanced_tracking_delay) - (upgrade_level * 2 SECONDS)

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
	level_max = 0

/datum/spell/ai_spell/enhanced_tracker/cast(list/targets, mob/living/silicon/ai/user)
	if(!istype(user))
		return
	// Pick a mob to track
	var/target_name = tgui_input_list(user, "Pick a trackable target...", "AI", user.trackable_mobs())
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
