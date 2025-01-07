// The datum and interface for the AI powers menu
/datum/program_picker
	/// List of programs that can be bought
	var/list/possible_programs
	/// List of purchased programs
	var/list/installed_programs
	/// List of purchased program upgrades
	var/list/purchased_upgrades
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
		dat += "<A href='byond://?src=[UID()];[program.program_id]=1'>[program.program_name]</A><A href='byond://?src=[UID()];showdesc=[program.program_id]'>\[?\]</A> ([program.installed ? "[program.cost] TB" : "1 TBPS"])<BR>"
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

			// Cost check
			if(program.cost > bandwidth)
				temp = "You cannot afford this module."
				break

			// Purchase a program
			if(!program.installed)
				if(program.upgrade)
					program.upgrade(A)
				else
					var/datum/spell/ai_spell/AC = new program.power_type
					A.AddSpell(AC)
					temp = program.description
				if(program.unlock_text)
					to_chat(A, program.unlock_text)
				if(program.unlock_sound)
					A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
				memory -= program.cost
				installed_programs += program
				program.installed = TRUE
			// Upgrade a program
			else
				if(program.power_type.spell_level >= program.power_type.level_max)
					to_chat(user, "<span class='warning'>This program cannot be updated further.</span>")
					return FALSE
				to_chat(A, "[program] has been updated!")
				if(program.unlock_sound)
					A.playsound_local(A, program.unlock_sound, 50, FALSE, use_reverb = FALSE)
				bandwidth -= 1
				program.bandwidth_used++
				program.power_type.spell_level++
				purchased_upgrades += program
				program.upgrade()

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
	/// Has the program been bought?
	var/installed = FALSE
	/// How many upgrades have been bought of this program?
	var/bandwidth_used = 0
	/// If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/power_type = /datum/spell/ai_spell
	/// If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/upgrade = FALSE
	/// Text shown when an ability is unlocked
	var/unlock_text = "<span class='notice'>Hello World!</span>"
	/// Sound played when an ability is unlocked
	var/unlock_sound
	/// The cooldown when the ability is used
	var/cooldown = 30 SECONDS

/datum/ai_program/proc/upgrade(mob/living/silicon/ai/AI)
	return

/datum/spell/ai_spell/choose_program
	name = "Choose Programs"
	desc = "Spend your memory and bandwidth to gain a variety of different abilities."
	action_icon = "icons/mob/ai.dmi"
	action_icon_state = "ai"
	auto_use_uses = FALSE // This is an infinite ability.
	create_attack_logs = FALSE

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

/datum/ai_program/rgb_lighting/upgrade()
	power_type.cooldown_handler.recharge_duration = power_type.base_cooldown - (power_type.spell_level * 5)

/datum/spell/ai_spell/ranged/rgb_lighting
	name = "RGB Lighting"
	desc = "Changes the color of a selected light"
	action_icon_state = "light"
	ranged_mousepointer = 'icons/mecha/mecha_mouse.dmi'
	auto_use_uses = FALSE
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS
	level_max = 5

/datum/spell/ai_spell/ranged/rgb_lighting/cast(list/targets, mob/user)
	var/obj/machinery/target = targets[1]
	if(!istype(target, obj/machinery/light) && !istype(target, obj/machinery/power/apc))
		to_chat(user, "<span class='warning'>You can only recolor lights!</span>")
		return
	if(istype(target, obj/machinery/power/apc))
		if(spell_level < 3) // If you haven't upgraded it 3 times, you have to color lights individually.
			to_chat(user, "<span class='warning'>Your coloring subsystem is not strong enough to target an entire room!</span>")
			return
		for(var/obj/machinery/light/L in target.apc_area)
			L.brightness_color = tgui_input_color(user,"Please select a light color.","RGB Lighting Color")
	else
		target.brightness_color = tgui_input_color(user,"Please select a light color.","RGB Lighting Color")
	user.playsound_local(user, "sound/effects/spray.ogg", 50, FALSE, use_reverb = FALSE)
	playsound(target, 'sound/effects/spray.ogg', 50, FALSE, use_reverb = FALSE)
	var/obj/machine/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)

