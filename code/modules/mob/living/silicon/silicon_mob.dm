/mob/living/silicon
	voice_name = "synthesized voice"
	bubble_icon = "machine"
	has_unlimited_silicon_privilege = TRUE
	weather_immunities = list("ash")
	mob_biotypes = MOB_ROBOTIC
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2

	// You can define armor as a list in datum definition (e.g. `armor = list("fire" = 80, "brute" = 10)`),
	// which would be converted to armor datum during initialization.
	// Setting `armor` to a list on an *existing* object would inevitably runtime. Use `getArmor()` instead.
	var/datum/armor/armor

	var/syndicate = FALSE
	var/const/MAIN_CHANNEL = "Main Frequency"
	var/lawchannel = MAIN_CHANNEL // Default channel on which to state laws
	var/list/stating_laws = list()// Channels laws are currently being stated on
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0)
	var/list/alarms_listened_for = list("Motion", "Fire", "Atmosphere", "Power")
	//var/list/hud_list[10]
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/designation = ""
	var/obj/item/camera/siliconcam/aiCamera = null //photography
	//Used in say.dm, allows for pAIs to have different say flavor text, as well as silicons, although the latter is not implemented.
	var/speak_statement = "states"
	var/speak_exclamation = "declares"
	var/speak_query = "queries"
	var/pose //Yes, now AIs can pose too.
	var/death_sound = 'sound/voice/borg_deathsound.ogg'

	var/static/list/restricted_hats = list(
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/snowman,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bomb_hood,
		/obj/item/clothing/head/blob,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/head/corgi,
		/obj/item/clothing/head/cueball,
		/obj/item/clothing/head/hardhat/pumpkinhead,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/papersack,
		/obj/item/clothing/head/human_head,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/hardhat/reindeer,
		/obj/item/clothing/head/cardborg
	)

	var/obj/item/silicon_hat
	var/hat_offset_y = -3
	/// For cyborgs with wide "heads", when false causes the hat icon to be stretched.
	var/is_centered = FALSE
	var/hat_icon_file = 'icons/mob/clothing/head.dmi'
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/can_be_hatted = FALSE
	var/can_wear_restricted_hats = FALSE

	//var/sensor_mode = 0 //Determines the current HUD.

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD)


	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_BASIC //There is only one kind of diag hud
	var/jani_hud = DATA_HUD_JANITOR
	var/datum/ui_module/atmos_control/atmos_control
	var/datum/ui_module/crew_monitor/crew_monitor
	var/datum/ui_module/law_manager/law_manager
	var/datum/ui_module/power_monitor/digital/power_monitor
	var/list/silicon_subsystems = list(/mob/living/silicon/proc/subsystem_law_manager)
	var/datum/ai_laws/laws = null
	var/list/additional_law_channels = list("State" = "")

	/// The delay used when toggling door bolts or electrification
	var/door_bolt_delay = 3 SECONDS

/mob/living/silicon/New()
	GLOB.silicon_mob_list |= src
	..()
	add_language("Galactic Common")
	init_subsystems()
	RegisterSignal(GLOB.alarm_manager, COMSIG_TRIGGERED_ALARM, PROC_REF(alarm_triggered))
	RegisterSignal(GLOB.alarm_manager, COMSIG_CANCELLED_ALARM, PROC_REF(alarm_cancelled))

/mob/living/silicon/Initialize(mapload)
	. = ..()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	if(islist(armor))
		armor = getArmor(arglist(armor))
	else if(!armor)
		armor = getArmor()
	else if(!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")
	regenerate_icons()


/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/Destroy()
	GLOB.silicon_mob_list -= src
	QDEL_NULL(atmos_control)
	QDEL_NULL(crew_monitor)
	QDEL_NULL(law_manager)
	QDEL_NULL(power_monitor)
	QDEL_NULL(aiCamera)
	return ..()

/mob/living/silicon/proc/can_instant_lockdown()
	if(isAntag(src))
		return TRUE
	return FALSE

/mob/living/silicon/proc/get_radio()
	return

/mob/living/silicon/proc/open_pda()
	return

/mob/living/silicon/proc/alarm_triggered(source, class, area/A, list/O, obj/alarmsource)
	return

/mob/living/silicon/proc/alarm_cancelled(source, class, area/A, obj/origin, cleared)
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = TRUE)
	var/in_cooldown = (length(alarms_to_show) > 0 || length(alarms_to_clear) > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(in_cooldown)
		return

	addtimer(CALLBACK(src, PROC_REF(show_alarms)), 3 SECONDS)

/mob/living/silicon/proc/show_alarms()
	if(length(alarms_to_show) < 5)
		for(var/msg in alarms_to_show)
			to_chat(src, msg)
	else if(length(alarms_to_show))

		var/list/msg = list("--- ")

		if(alarm_types_show["Tracking"])
			msg += "TRACKING: [alarm_types_show["Tracking"]] alarms detected. - "

		if(alarm_types_show["Burglar"])
			msg += "BURGLAR: [alarm_types_show["Burglar"]] alarms detected. - "

		if(alarm_types_show["Motion"])
			msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

		if(alarm_types_show["Fire"])
			msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

		if(alarm_types_show["Atmosphere"])
			msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

		if(alarm_types_show["Power"])
			msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

		msg += "<A href=byond://?src=[UID()];showalerts=1'>\[Show Alerts\]</a>"
		var/msg_text = msg.Join("")
		to_chat(src, msg_text)

	if(length(alarms_to_clear) < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(length(alarms_to_clear))
		var/list/msg = list("--- ")

		if(alarm_types_clear["Motion"])
			msg += "MOTION: [alarm_types_clear["Motion"]] alarms cleared. - "

		if(alarm_types_clear["Fire"])
			msg += "FIRE: [alarm_types_clear["Fire"]] alarms cleared. - "

		if(alarm_types_clear["Atmosphere"])
			msg += "ATMOSPHERE: [alarm_types_clear["Atmosphere"]] alarms cleared. - "

		if(alarm_types_clear["Power"])
			msg += "POWER: [alarm_types_clear["Power"]] alarms cleared. - "

		msg += "<A href=byond://?src=[UID()];showalerts=1'>\[Show Alerts\]</a>"

		var/msg_text = msg.Join("")
		to_chat(src, msg_text)


	alarms_to_show.Cut()
	alarms_to_clear.Cut()
	for(var/key in alarm_types_show)
		alarm_types_show[key] = 0
	for(var/key in alarm_types_clear)
		alarm_types_clear[key] = 0

/mob/living/silicon/rename_character(oldname, newname)
	if(!newname)
		return FALSE

	real_name = newname
	name = real_name
	if(mind?.is_original_mob(src))
		mind.set_original_mob(src) // update our original mind name, since this is our original mob.
		mind.name = newname
	return TRUE

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/put_in_l_hand(obj/item/W, skip_blocked_hands_check)
	return

/mob/living/silicon/put_in_r_hand(obj/item/W, skip_blocked_hands_check)
	return

/mob/living/silicon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return FALSE //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	..()
	switch(severity)
		if(EMP_HEAVY)
			take_organ_damage(20)
		if(EMP_LIGHT)
			take_organ_damage(10)
	flash_eyes(affect_silicon = 1)
	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")


/mob/living/silicon/proc/damage_mob(brute = 0, fire = 0, tox = 0)
	return

/mob/living/silicon/can_inject(mob/user, error_msg, target_zone, penetrate_thick)
	if(error_msg)
		to_chat(user, "<span class='alert'>[p_their(TRUE)] outer shell is too tough.</span>")
	return FALSE

/mob/living/silicon/IsAdvancedToolUser()
	return TRUE

/mob/living/silicon/robot/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(user == src) //No self-repair dummy
		return
	. = TRUE
	if(!getBruteLoss())
		to_chat(user, "<span class='notice'>Nothing to fix!</span>")
		return
	else if(!getBruteLoss(TRUE))
		to_chat(user, "<span class='warning'>The damaged components are beyond saving!</span>")
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	adjustBruteLoss(-30)
	add_fingerprint(user)
	user.visible_message("<span class='alert'>[user] patches some dents on [src] with [I].</span>")


/mob/living/silicon/bullet_act(obj/item/projectile/Proj)
	if(!Proj.nodamage)
		var/damage = run_armor(Proj.damage, Proj.damage_type, Proj.flag, 0, Proj.armor_penetration_flat, Proj.armor_penetration_percentage)
		switch(Proj.damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)

	Proj.on_hit(src,2)

	return 2

/mob/living/silicon/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
		place_on_head(user.get_active_hand(), user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/silicon/attacked_by(obj/item/I, mob/living/user, def_zone)
	send_item_attack_message(I, user)
	if(I.force)
		var/bonus_damage = 0
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			bonus_damage = H.physiology.melee_bonus
		var/damage = run_armor(I.force + bonus_damage, I.damtype, MELEE, 0, I.armor_penetration_flat, I.armor_penetration_percentage)
		apply_damage(damage, I.damtype, def_zone)

///returns the damage value of the attack after processing the silicons's various armor protections
/mob/living/silicon/proc/run_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armor_penetration_flat = 0, armor_penetration_percentage = 0)
	if(damage_type != BRUTE && damage_type != BURN)
		return 0
	var/armor_protection
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection > 0)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp(armor_protection * (100 - armor_penetration_percentage) / 100 - armor_penetration_flat, 0, 100)
	return round(damage_amount * (100 - armor_protection) / 100, DAMAGE_PRECISION)

/mob/living/silicon/apply_effect(effect = 0, effecttype = STUN, blocked = 0)
	return FALSE //The only effect that can hit them atm is flashes and they still directly edit so this works for now

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if(bot.connected_ai == ai)
		return 1
	return 0


// this function shows the health of the pAI in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	return list("System integrity:", stat ? "Nonfunctional" : "[round((health / maxHealth) * 100)]%")


// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = show_system_integrity()

//Silicon mob language procs

/mob/living/silicon/can_speak_language(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(language, can_speak=1)
	if(..(language) && can_speak)
		speech_synthesizer_langs.Add(GLOB.all_languages[language])
		return 1

/mob/living/silicon/remove_language(rem_language)
	..(rem_language)

	for(var/datum/language/L in speech_synthesizer_langs)
		if(L.name == rem_language)
			speech_synthesizer_langs -= L

/mob/living/silicon/check_lang_data()
	. = ""

	if(default_language)
		. += "Current default language: [default_language] - <a href='byond://?src=[UID()];default_lang=reset'>reset</a><br><br>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			var/default_str
			if(L == default_language)
				default_str = " - default - <a href='byond://?src=[UID()];default_lang=reset'>reset</a>"
			else
				default_str = " - <a href='byond://?src=[UID()];default_lang=[L]'>set default</a>"

			var/synth = (L in speech_synthesizer_langs)
			. += "<b>[L.name] (:[L.key])</b>[synth ? default_str : null]<br>Speech Synthesizer: <i>[synth ? "YES" : "NOT SUPPORTED"]</i><br>[L.desc]<br><br>"


// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	GLOB.generic_crew_manifest.ui_interact(usr)

/mob/living/silicon/assess_threat() //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose = tgui_input_text(usr, "This is [src]. It...", "Pose", pose)

/mob/living/silicon/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/proc/remove_med_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	var/datum/atom_hud/janisensor = GLOB.huds[jani_hud]
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)
	diagsensor.remove_hud_from(src)
	janisensor.remove_hud_from(src)


/mob/living/silicon/proc/add_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	secsensor.add_hud_to(src)

/mob/living/silicon/proc/add_med_hud()
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	medsensor.add_hud_to(src)

/mob/living/silicon/proc/add_diag_hud()
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	diagsensor.add_hud_to(src)

/mob/living/silicon/proc/add_jani_hud()
	var/datum/atom_hud/janisensor = GLOB.huds[jani_hud]
	janisensor.add_hud_to(src)

/mob/living/silicon/proc/toggle_sensor_mode()
	to_chat(src, "<span class='notice'>Please select sensor type.</span>")
	var/static/list/sensor_choices = list("Security" = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "securityhud"),
							"Medical" = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "healthhud"),
							"Diagnostic" = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "diagnostichud"),
							"Janitor" = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "janihud"),
							"None" = image(icon = 'icons/mob/screen_gen.dmi', icon_state = "x"))
	var/sensor_type = show_radial_menu(src, src, sensor_choices)
	if(!sensor_type)
		return
	remove_med_sec_hud()
	switch(sensor_type)
		if("Security")
			add_sec_hud()
			to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
		if("Medical")
			add_med_hud()
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if("Diagnostic")
			add_diag_hud()
			to_chat(src, "<span class='notice'>Robotics diagnostic overlay enabled.</span>")
		if("Janitor")
			add_jani_hud()
			to_chat(src, "<span class='notice'>Janitorial filth overlay enabled.</span>")
		if("None")
			to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/adjustToxLoss(amount)
	return STATUS_UPDATE_NONE

/mob/living/silicon/get_access()
	return IGNORE_ACCESS //silicons always have access

/mob/living/silicon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/stretch/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/is_mechanical()
	return 1

/mob/living/silicon/is_literate()
	return 1

/////////////////////////////////// EAR DAMAGE ////////////////////////////////////
/mob/living/silicon/can_hear()
	. = TRUE

/mob/living/silicon/on_floored_start()
	return // Silicons are always standing by default.

/mob/living/silicon/on_floored_end()
	return // Silicons are always standing by default.

/mob/living/silicon/on_lying_down()
	return // Silicons are always standing by default.

/mob/living/silicon/on_standing_up()
	return // Silicons are always standing by default.

/mob/living/silicon/throw_impact(atom/hit_atom, throwingdatum, speed = 1)
	. = ..()
	var/damage = 10 + 1.5 * speed
	hit_atom.hit_by_thrown_mob(src, throwingdatum, damage, FALSE, FALSE)

/mob/living/silicon/proc/update_hat_icons()
	if(!silicon_hat)
		return
	var/image/head_icon

	if(silicon_hat.worn_icon)
		hat_icon_file = silicon_hat.worn_icon
	if(!hat_icon_state)
		hat_icon_state = silicon_hat.icon_state
	if(isnull(hat_alpha))
		hat_alpha = silicon_hat.alpha
	if(!hat_color)
		hat_color = silicon_hat.color

	head_icon = get_hat_overlay()

	add_overlay(head_icon)

/mob/living/silicon/proc/get_hat_overlay()
	if(!(hat_icon_file || hat_icon_state))
		return
	var/image/borgI = image(hat_icon_file, hat_icon_state)
	borgI.alpha = hat_alpha
	borgI.color = hat_color
	borgI.pixel_y = hat_offset_y
	if(!is_centered)
		borgI.transform = matrix(1.125, 0, 0.5, 0, 1, 0)
	return borgI

/**
  * Attempts to put an item on a silicon's head.
  *
  * Arguments:
  * * item_to_add - The item we're attempting to place on a silicon.
  * * user - Mob trying to put a hat on a silicon.
  * Returns boolean reflecting if a hat was succesfully placed on the silicon.
  */
/mob/living/silicon/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(flags_2 & HOLOGRAM_2)
		return FALSE

	if(!item_to_add)
		user.visible_message(
			"<span class='notice'>[user] pats [src] on the head.</span>",
			"<span class='notice'>You pat [src] on the head.</span>")
		return FALSE

	if(!istype(item_to_add, /obj/item/clothing/head))
		to_chat(user, "<span class='warning'>[item_to_add] cannot be worn on the head by [src]!</span>")
		return FALSE

	if(!can_be_hatted)
		to_chat(user, "<span class='notice'>No matter how hard you try you don't seem to be able to put a hat on [src]!</span>")
		return FALSE

	if(silicon_hat)
		to_chat(user, "<span class='warning'>[src] can't wear more than one hat!</span>")
		return FALSE

	if(!can_wear_restricted_hats && is_type_in_list(item_to_add, restricted_hats))
		to_chat(user, "<span class='warning'>[item_to_add] does not fit on the head of [src]!</span>")
		return FALSE

	if(!user.transfer_item_to(item_to_add, src))
		to_chat(user, "<span class='warning'>[item_to_add] is stuck to your hand, you cannot put it on [src]!</span>")
		return FALSE

	user.visible_message(
		"<span class='notice'>[user] puts [item_to_add] on [real_name].</span>",
		"<span class='notice'>You put [item_to_add] on [real_name].</span>"
	)
	silicon_hat = item_to_add
	update_icons()

	return TRUE

/**
  * Attempts to remove any hats a silicon is wearing.
  *
  * Arguments:
  * * user - Mob trying to remove a silicon's hat.
  * Returns boolean reflecting if a hat was successfully removed from the silicon.
  */
/mob/living/silicon/proc/remove_from_head(mob/user)
	if(!silicon_hat)
		to_chat(user, "<span class='warning'>[src] isn't wearing anything on their head!</span>")
		return FALSE
	if(silicon_hat.flags & NODROP)
		to_chat(user, "<span class='warning'>[silicon_hat.name] is stuck on [src]'s head, it is impossible to remove!</span>")
		return FALSE

	to_chat(user, "<span class='warning'>You remove [silicon_hat.name] from [src]'s head.</span>")
	user.put_in_hands(silicon_hat)

	null_hat()
	update_icons()

	return TRUE

/mob/living/silicon/proc/drop_hat()
	if(silicon_hat)
		drop_item_to_ground(silicon_hat)
		null_hat()
		update_icons()
		return TRUE

/mob/living/silicon/proc/null_hat()
	silicon_hat = null
	hat_icon_file = initial(hat_icon_file)
	hat_icon_state = null
	hat_alpha = null
	hat_color = null

/mob/living/silicon/examine(mob/user)
	. = ..()
	if(silicon_hat)
		. += "<span class='notice'>They are wearing a [bicon(silicon_hat)] [silicon_hat.name].<span>"
		. += "<span class='notice'>Use an empty hand on [src] on grab mode to remove [silicon_hat].<span>"

/mob/living/silicon/plushify(plushie_override, curse_time)
	. = ..(/obj/item/toy/plushie/borgplushie, curse_time)
