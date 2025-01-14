// The datum and interface for the AI powers menu
/datum/program_picker
	/// List of programs that can be bought
	var/list/possible_programs
	/// How much memory is available
	var/memory = 1
	/// How much bandwidth is available
	var/bandwidth = 1
	/// How many nanites are available?
	var/nanites = 50
	/// What is the maximum number of nanites?
	var/max_nanites = 100
	// Handles extra information displayed
	var/temp

/datum/program_picker/New()
	possible_programs = list()
	for(var/type in subtypesof(/datum/ai_program))
		var/datum/ai_program/program = new type
		if(program.power_type || program.upgrade)
			possible_programs += program

/datum/program_picker/proc/use(mob/user)
	var/dat
	dat += {"<B>Select program to install: (currently [memory] TB of memory and [bandwidth] TBPS of bandwidth left.)</B><BR>
			<HR>
			<B>Install Program:</B><BR>
			<I>The number afterwards is the amount of a given resource it consumes.</I><BR>"}
	for(var/datum/ai_program/program in possible_programs)
		dat += "<A href='byond://?src=[UID()];[program.program_id]=1'>[program.program_name]</A><A href='byond://?src=[UID()];showdesc=[program.program_id]'>\[?\]</A> ([program.installed ? "1 TBPS": "[program.cost] TB"])<BR>"
	dat += "<HR>"
	if(temp)
		dat += "[temp]"
	var/datum/browser/popup = new(user, "modpicker", "AI Program Menu", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/datum/program_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		to_chat(A, "<span class='warning'>You are dead!</span>")
		return

	for(var/datum/ai_program/program in possible_programs)
		if(href_list[program.program_id])

			if(!program.upgrade)
				var/datum/spell/ai_spell/new_spell = new program.power_type

				for(var/datum/spell/ai_spell/aspell in A.mob_spell_list)
					if(new_spell.type == aspell.type)
						if(aspell.spell_level >= aspell.level_max)
							to_chat(A, "<span class='warning'>This program cannot be upgraded further.</span>")
							return FALSE
						else
							if(bandwidth < 1)
								temp = "You cannot afford this upgrade!"
								return FALSE
							aspell.name = initial(aspell.name)
							aspell.spell_level++
							if(aspell.spell_level >= aspell.level_max)
								to_chat(A, "<span class='notice'>This program cannot be upgraded any further.</span>")
							aspell.on_purchase_upgrade()
							bandwidth--
							return TRUE
				// No same program found, install
				if(program.cost > memory)
					to_chat(A, "<span class='notice'>You cannot afford this program.</span>")
					return FALSE
				memory -= program.cost
				SSblackbox.record_feedback("tally", "ai_program_installed", 1, new_spell.name)
				A.AddSpell(new_spell)
				to_chat(A, program.unlock_text)
				A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
				program.installed = TRUE
				return TRUE

			// Upgrades below
			if(program.upgrade_level > program.max_level)
				to_chat(A, "<span class='notice'>This program cannot be upgraded any further.</span>")
				return FALSE
			program.upgrade(A)
			to_chat(A, program.unlock_text)
			A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
			return TRUE

		if(href_list["showdesc"])
			if(program.program_id == href_list["showdesc"])
				temp = program.description
	use(usr)

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

/datum/ai_program/proc/upgrade(mob/user)
	return

/datum/ai_program/proc/downgrade(mob/user)
	return

/datum/spell/ai_spell/choose_program/cast(list/targets, mob/living/silicon/ai/user)
	. = ..()
	user.program_picker.use(user)

// RGB Lighting - Recolors Lights
/datum/ai_program/rgb_lighting
	program_name = "RGB Lighting"
	program_id = "rgb_lighting"
	description = "Recolor a light to a desired color"
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
	var/color_picked = tgui_input_color(user,"Please select a light color.","RGB Lighting Color")
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
	user.playsound_local(user, 'sound/effects/spray.ogg', 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/effects/spray.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)

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
	user.playsound_local(user, 'sound/goonstation/misc/fuse.ogg', 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/goonstation/misc/fuse.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)

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
	user.playsound_local(user, "sound/goonstation/misc/fuse.ogg", 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/goonstation/misc/fuse.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "medbeam", icon = 'icons/effects/beam.dmi', time = 10)

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

/datum/ai_program/universal_adapter/upgrade(mob/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(user))
		return
	AI.universal_adapter = TRUE
	AI.adapter_efficiency = 0.5 + (0.1 * upgrade_level)
	upgrade_level++
	installed = TRUE

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
	user.playsound_local(user, 'sound/items/deconstruct.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = duration)
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
	user.playsound_local(user, 'sound/items/syringeproj.ogg', 40, FALSE, use_reverb = FALSE)
	playsound(src, 'sound/items/syringeproj.ogg', 40, TRUE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		sleep(5)
		nanofrost.Smoke()
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
	sleep(5)
	nanofrost.Smoke()

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

/datum/ai_program/bluespace_miner/upgrade(mob/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(user))
		return
	AI.bluespace_miner_rate = 100 + (100 * upgrade_level)
	AI.next_payout = 10 MINUTES + world.time
	AI.bluespace_miner = TRUE
	upgrade_level++
	installed = TRUE

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
	. = ..()
	original_price_mod = SSeconomy.pack_price_modifier

/datum/ai_program/multimarket_analyser/upgrade(mob/user)
	SSeconomy.pack_price_modifier = original_price_mod * (0.95 - (0.05 * upgrade_level))
	upgrade_level++
	installed = TRUE

// RGB Lighting - Recolors Lights
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
	user.playsound_local(user, 'sound/machines/ding.ogg',, 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/machines/ding.ogg',, 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)

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
	user.playsound_local(user, "sound/goonstation/misc/fuse.ogg", 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/goonstation/misc/fuse.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "medbeam", icon = 'icons/effects/beam.dmi', time = 10)
	if(do_after_once(AI, 5 SECONDS, target = target, allow_moving = TRUE))
		var/damage_healed = 20 + (min(30, (10 * spell_level)))
		target.heal_overall_damage(damage_healed, damage_healed)
		if(spell_level >= 5)
			for(var/obj/item/organ/external/E in target.bodyparts)
				if(prob(5*spell_level))
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

/datum/ai_program/enhanced_doors/upgrade(mob/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(user))
		return
	upgrade_level++
	AI.door_bolt_delay = original_door_delay * (1 - (upgrade_level * 0.1))
	installed = TRUE
