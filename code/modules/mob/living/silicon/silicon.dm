/mob/living/silicon
	gender = NEUTER
	robot_talk_understand = 1
	voice_name = "synthesized voice"
	has_unlimited_silicon_privilege = 1
	var/syndicate = 0
	var/const/MAIN_CHANNEL = "Main Frequency"
	var/lawchannel = MAIN_CHANNEL // Default channel on which to state laws
	var/list/stating_laws = list()// Channels laws are currently being stated on
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	//var/list/hud_list[10]
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/list/alarm_handlers = list() // List of alarm handlers this silicon is registered to
	var/designation = ""
	var/obj/item/camera/siliconcam/aiCamera = null //photography
//Used in say.dm, allows for pAIs to have different say flavor text, as well as silicons, although the latter is not implemented.
	var/speak_statement = "states"
	var/speak_exclamation = "declares"
	var/speak_query = "queries"
	var/pose //Yes, now AIs can pose too.
	var/death_sound = 'sound/voice/borg_deathsound.ogg'

	//var/sensor_mode = 0 //Determines the current HUD.

	var/next_alarm_notice
	var/list/datum/alarm/queued_alarms = new()

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD)


	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED //There is only one kind of diag hud

	var/obj/item/radio/common_radio

/mob/living/silicon/New()
	GLOB.silicon_mob_list |= src
	..()
	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	add_language("Galactic Common")
	init_subsystems()

/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/Destroy()
	GLOB.silicon_mob_list -= src
	for(var/datum/alarm_handler/AH in alarm_handlers)
		AH.unregister(src)
	return ..()

/mob/living/silicon/rename_character(oldname, newname)
	// we actually don't want it changing minds and stuff
	if(!newname)
		return 0

	real_name = newname
	name = real_name
	return 1

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	return FALSE //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_organ_damage(20)
			Stun(8)
		if(2)
			src.take_organ_damage(10)
			Stun(3)
	flash_eyes(affect_silicon = 1)
	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()


/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/can_inject(mob/user, error_msg)
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


/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)


	if(!Proj.nodamage)
		switch(Proj.damage_type)
			if(BRUTE)
				adjustBruteLoss(Proj.damage)
			if(BURN)
				adjustFireLoss(Proj.damage)

	Proj.on_hit(src,2)

	return 2

/mob/living/silicon/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0, var/negate_armor = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now
/*
	if(!effect || (blocked >= 2))	return 0
	switch(effecttype)
		if(STUN)
			Stun(effect / (blocked + 1))
		if(WEAKEN)
			Weaken(effect / (blocked + 1))
		if(PARALYZE)
			Paralyse(effect / (blocked + 1))
		if(IRRADIATE)
			radiation += min((effect - (effect*getarmor(null, "rad"))), 0)//Rads auto check armor
		if(STUTTER)
			stuttering = max(stuttering,(effect/(blocked+1)))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry,(effect/(blocked+1)))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	updatehealth()
	return 1*/

/proc/islinked(var/mob/living/silicon/robot/bot, var/mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if(bot.connected_ai == ai)
		return 1
	return 0


// this function shows the health of the pAI in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	if(!src.stat)
		stat(null, text("System integrity: [round((health/maxHealth)*100)]%"))
	else
		stat(null, text("Systems nonfunctional"))


// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/Stat()
	..()
	if(statpanel("Status"))
		show_stat_emergency_shuttle_eta()
		show_system_integrity()

//Silicon mob language procs

/mob/living/silicon/can_speak_language(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(var/language, var/can_speak=1)
	if(..(language) && can_speak)
		speech_synthesizer_langs.Add(GLOB.all_languages[language])
		return 1

/mob/living/silicon/remove_language(var/rem_language)
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
	var/dat
	dat += "<h4>Crew Manifest</h4>"
	if(GLOB.data_core)
		dat += GLOB.data_core.get_manifest(1) // make it monochrome
	dat += "<br>"
	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/assess_threat() //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(copytext(input(usr, "This is [src]. It is...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

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
	for(var/datum/atom_hud/data/diagnostic/diagsensor in GLOB.huds)
		diagsensor.remove_hud_from(src)
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)


/mob/living/silicon/proc/add_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	secsensor.add_hud_to(src)

/mob/living/silicon/proc/add_med_hud()
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	medsensor.add_hud_to(src)

/mob/living/silicon/proc/add_diag_hud()
	for(var/datum/atom_hud/data/diagnostic/diagsensor in GLOB.huds)
		diagsensor.add_hud_to(src)


/mob/living/silicon/proc/toggle_sensor_mode()
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Security", "Medical","Diagnostic","Disable")
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
		if("Disable")
			to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/proc/receive_alarm(var/datum/alarm_handler/alarm_handler, var/datum/alarm/alarm, was_raised)
	if(!next_alarm_notice)
		next_alarm_notice = world.time + SecondsToTicks(10)

	var/list/alarms = queued_alarms[alarm_handler]
	if(was_raised)
		// Raised alarms are always set
		alarms[alarm] = 1
	else
		// Alarms that were raised but then cleared before the next notice are instead removed
		if(alarm in alarms)
			alarms -= alarm
		// And alarms that have only been cleared thus far are set as such
		else
			alarms[alarm] = -1

/mob/living/silicon/proc/process_queued_alarms()
	if(next_alarm_notice && (world.time > next_alarm_notice))
		next_alarm_notice = 0

		var/alarm_raised = 0
		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == 1)
					if(!reported)
						reported = 1
						to_chat(src, "<span class='warning'>--- [AH.category] Detected ---</span>")
					raised_alarm(A)

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == -1)
					if(!reported)
						reported = 1
						to_chat(src, "<span class='notice'>--- [AH.category] Cleared ---</span>")
					to_chat(src, "\The [A.alarm_name()].")

		if(alarm_raised)
			to_chat(src, "<A HREF=?src=[UID()];showalerts=1>\[Show Alerts\]</A>")

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			alarms.Cut()

/mob/living/silicon/proc/raised_alarm(var/datum/alarm/A)
	to_chat(src, "[A.alarm_name()]!")

/mob/living/silicon/ai/raised_alarm(var/datum/alarm/A)
	var/cameratext = ""
	for(var/obj/machinery/camera/C in A.cameras())
		cameratext += "[(cameratext == "")? "" : "|"]<A HREF=?src=[UID()];switchcamera=\ref[C]>[C.c_tag]</A>"
	to_chat(src, "[A.alarm_name()]! ([(cameratext)? cameratext : "No Camera"])")

/mob/living/silicon/adjustToxLoss(var/amount)
	return STATUS_UPDATE_NONE

/mob/living/silicon/get_access()
	return IGNORE_ACCESS //silicons always have access

/mob/living/silicon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/is_mechanical()
	return 1

/mob/living/silicon/is_literate()
	return 1

/////////////////////////////////// EAR DAMAGE ////////////////////////////////////
/mob/living/silicon/can_hear()
	. = TRUE

