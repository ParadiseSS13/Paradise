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
	action_icon_state = "light"
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
	user.playsound_local(user, "sound/effects/spray.ogg", 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/effects/spray.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)

/datum/spell/ai_spell/ranged/on_purchase_upgrade()
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
	action_icon_state = "light"
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
	user.playsound_local(user, "sound/goonstation/misc/fuse.ogg", 50, FALSE, use_reverb = FALSE)
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
	action_icon_state = "light"
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
	var/area/A = get_area(user)
	if(A == null)
		to_chat(user, "<span class='warning'>No SMES detected to power from!</span>")
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
