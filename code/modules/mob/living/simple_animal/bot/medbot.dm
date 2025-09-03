#define MEDBOT_MIN_HEALING_THRESHOLD 5
#define MEDBOT_MAX_HEALING_THRESHOLD 75
#define MEDBOT_MIN_INJECTION_AMOUNT 5
#define MEDBOT_MAX_INJECTION_AMOUNT 15

//Medbot
/mob/living/simple_animal/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon_state = "medibot0"
	density = FALSE
	pass_flags = PASSMOB

	radio_channel = "Medical"

	bot_type = MED_BOT
	bot_filter = RADIO_MEDBOT
	model = "Medibot"
	bot_purpose = "seek out hurt crewmembers and ensure that they are healed"
	req_access = list(ACCESS_MEDICAL, ACCESS_ROBOTICS)
	window_id = "automed"
	window_name = "Automatic Medical Unit v1.1"
	data_hud_type = DATA_HUD_MEDICAL_ADVANCED

	var/list/idle_phrases = list(
		MEDIBOT_VOICED_MASK_ON = 'sound/voice/mradar.ogg',
		MEDIBOT_VOICED_ALWAYS_A_CATCH = 'sound/voice/mcatch.ogg',
		MEDIBOT_VOICED_PLASTIC_SURGEON = 'sound/voice/msurgeon.ogg',
		MEDIBOT_VOICED_LIKE_FLIES = 'sound/voice/mflies.ogg',
		MEDIBOT_VOICED_DELICIOUS = 'sound/voice/mdelicious.ogg',
	)

	var/list/finish_healing_phrases = list(
		MEDIBOT_VOICED_ALL_PATCHED_UP = 'sound/voice/mpatchedup.ogg',
		MEDIBOT_VOICED_APPLE_A_DAY = 'sound/voice/mapple.ogg',
		MEDIBOT_VOICED_FEEL_BETTER = 'sound/voice/mfeelbetter.ogg',
	)

	var/list/located_patient_phrases = list(
		MEDIBOT_VOICED_HOLD_ON = 'sound/voice/mcoming.ogg',
		MEDIBOT_VOICED_WANT_TO_HELP = 'sound/voice/mhelp.ogg',
		MEDIBOT_VOICED_YOU_ARE_INJURED = 'sound/voice/minjured.ogg',
	)

	var/list/patient_died_phrases = list(
		MEDIBOT_VOICED_STAY_WITH_ME = 'sound/voice/mno.ogg',
		MEDIBOT_VOICED_LIVE = 'sound/voice/mlive.ogg',
		MEDIBOT_VOICED_NEVER_LOST = 'sound/voice/mlost.ogg',
	)

	var/list/frustration_phrases = list(
		MEDIBOT_VOICED_FUCK_YOU = 'sound/voice/mfuck_you.ogg',
	)

	/// The above lists joined into one, for one-place lookups
	var/list/all_phrases

	var/obj/item/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/mob/living/carbon/patient = null
	/// UID of the previous patient. Used to avoid running selection checks on them if we failed to heal them.
	var/previous_patient

	var/oldloc = null
	var/last_found = 0
	var/last_warning = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = FALSE //Use reagents in beaker instead of default treatment agents.
	var/declare_crit = TRUE //If active, the bot will transmit a critical patient alert to MedHUD users.
	var/declare_cooldown = FALSE //Prevents spam of critical patient alerts.
	var/stationary_mode = FALSE //If enabled, the Medibot will not move automatically.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	var/treat_virus = TRUE //If on, the bot will attempt to treat viral infections, curing them if possible.
	var/shut_up = FALSE //self explanatory :)
	var/syndicate_aligned = FALSE // Will it only treat operatives?
	var/drops_parts = TRUE

/mob/living/simple_animal/bot/medbot/tox
	skin = "tox"

/mob/living/simple_animal/bot/medbot/o2
	skin = "o2"

/mob/living/simple_animal/bot/medbot/brute
	skin = "brute"

/mob/living/simple_animal/bot/medbot/fire
	skin = "ointment"

/mob/living/simple_animal/bot/medbot/adv
	skin = "adv"

/mob/living/simple_animal/bot/medbot/fish
	skin = "fish"

/mob/living/simple_animal/bot/medbot/machine
	skin = "machine"

/mob/living/simple_animal/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"

/mob/living/simple_animal/bot/medbot/syndicate
	name = "Suspicious Medibot"
	desc = "You'd better have insurance!"
	skin = "bezerk"
	faction = list("syndicate")
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	syndicate_aligned = TRUE
	req_access = list(ACCESS_SYNDICATE)
	control_freq = BOT_FREQ + 1000 // make it not show up on lists
	radio_channel = "Syndicate"
	radio_config = list("Common" = 1, "Medical" = 1, "Syndicate" = 1)

/mob/living/simple_animal/bot/medbot/syndicate/Initialize(mapload)
	. = ..()
	Radio.syndiekey = new /obj/item/encryptionkey/syndicate

/mob/living/simple_animal/bot/medbot/syndicate/emagged
	emagged = TRUE
	declare_crit = FALSE
	drops_parts = FALSE

/mob/living/simple_animal/bot/medbot/update_icon_state()
	if(!on)
		icon_state = "medibot0"
		return
	if(mode == BOT_HEALING)
		icon_state = "medibots[stationary_mode]"
		return
	else if(stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "medibot2"
	else
		icon_state = "medibot1"

/mob/living/simple_animal/bot/medbot/update_overlays()
	. = ..()
	if(skin)
		. += "medskin_[skin]"

/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	var/datum/job/doctor/J = new /datum/job/doctor
	access_card.access += J.get_access()
	prev_access = access_card.access
	qdel(J)

	all_phrases = idle_phrases + located_patient_phrases + finish_healing_phrases + patient_died_phrases + frustration_phrases

	if(new_skin)
		skin = new_skin
	update_icon()

/mob/living/simple_animal/bot/medbot/bot_reset()
	..()
	patient = null
	previous_patient = null
	oldloc = null
	last_found = world.time
	declare_cooldown = FALSE
	frustration = 0
	update_icon()

/mob/living/simple_animal/bot/medbot/proc/soft_reset() //Allows the medibot to still actively perform its medical duties without being completely halted as a hard reset does.
	path = list()
	patient = null
	set_mode(BOT_IDLE)
	last_found = world.time
	frustration = 0
	update_icon()

/mob/living/simple_animal/bot/medbot/set_custom_texts()
	text_hack = "You corrupt [name]'s reagent processor circuits."
	text_dehack = "You reset [name]'s reagent processor circuits."
	text_dehack_fail = "[name] seems damaged and does not respond to reprogramming!"

/mob/living/simple_animal/bot/medbot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/medbot/ui_state(mob/user)
	return GLOB.default_state

/mob/living/simple_animal/bot/medbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotMed", name)
		ui.open()

/mob/living/simple_animal/bot/medbot/ui_data(mob/user)
	var/list/data = ..()
	data["shut_up"] = shut_up
	data["declare_crit"] = declare_crit
	data["stationary_mode"] = stationary_mode
	data["heal_threshold"] = list(
		"value" = heal_threshold,
		"min" = MEDBOT_MIN_HEALING_THRESHOLD,
		"max" = MEDBOT_MAX_HEALING_THRESHOLD,
	)
	data["injection_amount"] = list(
		"value" = injection_amount,
		"min" = MEDBOT_MIN_INJECTION_AMOUNT,
		"max" = MEDBOT_MAX_INJECTION_AMOUNT,
	)
	data["use_beaker"] = use_beaker
	data["treat_virus"] = treat_virus
	data["reagent_glass"] = !reagent_glass ? null : list(
		"amount" = reagent_glass.reagents.total_volume,
		"max_amount" = reagent_glass.reagents.maximum_volume,
	)
	return data

/mob/living/simple_animal/bot/medbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(topic_denied(usr))
		to_chat(usr, "<span class='warning'>[src]'s interface is not responding!</span>")
		return
	add_fingerprint(usr)
	. = TRUE
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
		if("autopatrol")
			auto_patrol = !auto_patrol
			bot_reset()
		if("hack")
			handle_hacking(usr)
		if("disableremote")
			remote_disabled = !remote_disabled
		if("toggle_speaker")
			shut_up = !shut_up
		if("toggle_critical_alerts")
			declare_crit = !declare_crit
		if("set_heal_threshold")
			var/new_heal_threshold = text2num(params["target"])
			if(new_heal_threshold == null)
				return
			heal_threshold = clamp(new_heal_threshold, MEDBOT_MIN_HEALING_THRESHOLD, MEDBOT_MAX_HEALING_THRESHOLD)
		if("set_injection_amount")
			var/new_injection_amount = text2num(params["target"])
			if(new_injection_amount == null)
				return
			injection_amount = clamp(new_injection_amount, MEDBOT_MIN_INJECTION_AMOUNT, MEDBOT_MAX_INJECTION_AMOUNT)
		if("toggle_use_beaker")
			use_beaker = !use_beaker
		if("toggle_treat_viral")
			treat_virus = !treat_virus
		if("toggle_stationary_mode")
			stationary_mode = !stationary_mode
			path = list()
			update_icon()
		if("eject_reagent_glass")
			reagent_glass.forceMove(get_turf(src))
			reagent_glass = null

/mob/living/simple_animal/bot/medbot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/reagent_containers/glass))
		if(locked)
			to_chat(user, "<span class='warning'>You cannot insert a beaker because the panel is locked!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!isnull(reagent_glass))
			to_chat(user, "<span class='warning'>There is already a beaker loaded!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE

		W.forceMove(src)
		reagent_glass = W
		to_chat(user, "<span class='notice'>You insert [W].</span>")
		ui_interact(user)

		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/simple_animal/bot/medbot/attacked_by(obj/item/attacker, mob/living/user)
	var/current_health = health
	. = ..()
	if(health < current_health) //if medbot took some damage
		step_to(src, (get_step_away(src,user)))

/mob/living/simple_animal/bot/medbot/emag_act(mob/user)
	..()
	if(emagged)
		declare_crit = FALSE
		if(user)
			to_chat(user, "<span class='notice'>You short out [src]'s reagent synthesis circuits.</span>")
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		flick("medibot_spark", src)
		if(user)
			previous_patient = user.UID()

/mob/living/simple_animal/bot/medbot/process_scan(mob/living/carbon/human/H)
	if(buckled)
		if((last_warning + 300) < world.time)
			speak("Movement restrained! Unit on standby!")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, FALSE)
			last_warning = world.time
		return
	if(H.stat == DEAD)
		return

	if((H.UID() == previous_patient) && (world.time < last_found + 200))
		return

	if(assess_patient(H))
		last_found = world.time
		if((last_newpatient_speak + 30 SECONDS) < world.time) //Don't spam these messages!
			medbot_phrase(pick(located_patient_phrases), H)
			last_newpatient_speak = world.time
		return H
	else
		return

/mob/living/simple_animal/bot/medbot/handle_automated_action()
	if(!..())
		return

	switch(mode)
		if(BOT_HEALING)
			return

	if(frustration > 5)
		previous_patient = patient.UID()
		soft_reset()
		medbot_phrase(MEDIBOT_VOICED_FUCK_YOU)

	if(!patient)
		if(!shut_up && prob(1))
			medbot_phrase(pick(idle_phrases))

		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		patient = scan(/mob/living/carbon/human, scan_range = scan_range)

	if(patient)
		if((get_dist(src,patient) <= 1)) //Patient is next to us, begin treatment!
			if(mode != BOT_HEALING)
				set_mode(BOT_HEALING)
				update_icon()
				medicate_patient(patient)
			return

		else if(stationary_mode) //Since we cannot move in this mode, ignore the patient and wait for another.
			soft_reset()
			return

		//Patient has moved away from us!
		else if(!length(path) || (length(path) && (get_dist(patient, path[length(path)]) > 2)))
			path = list()
			set_mode(BOT_IDLE)
			last_found = world.time

		if(!length(path) && (get_dist(src,patient) > 1))
			set_mode(BOT_PATHING)
			path = get_path_to(src, patient, 30, access = access_card.access)
			set_mode(BOT_MOVING)
			if(!length(path)) //try to get closer if you can't reach the patient directly
				path = get_path_to(src, patient, 30, 1, access = access_card.access)
				if(!length(path)) //Do not chase a patient we cannot reach.
					add_to_ignore(patient)
					soft_reset()

		if(length(path))
			frustration++
			if(!bot_move(path[length(path)]))
				previous_patient = patient.UID()
				soft_reset()
			return


	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()


/mob/living/simple_animal/bot/medbot/proc/assess_beaker_injection(mob/living/carbon/C)
	//If we have and are using a medicine beaker, return any reagent the patient is missing
	if(use_beaker && reagent_glass?.reagents.total_volume)
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R.id))
				return R.id

/mob/living/simple_animal/bot/medbot/proc/assess_viruses(mob/living/carbon/C)
	. = FALSE

	if(!treat_virus)
		return

	for(var/datum/disease/D as anything in C.viruses)
		if((!(D.visibility_flags & VIRUS_HIDDEN_SCANNER) || (D.GetDiseaseID() in GLOB.detected_advanced_diseases["[z]"])) && D.severity != VIRUS_NONTHREAT && (D.stage > 1 || D.spread_flags & SPREAD_AIRBORNE))
			return TRUE //Medbots see viruses that aren't fully hidden and have developed enough/are airborne, ignoring safe viruses

/mob/living/simple_animal/bot/medbot/proc/select_medication(mob/living/carbon/C, beaker_injection)
	var/treatable_virus = assess_viruses(C)
	var/treatable_brute = C.getBruteLoss() >= heal_threshold
	var/treatable_fire = C.getFireLoss() >= heal_threshold
	var/treatable_oxy = C.getOxyLoss() >= (heal_threshold + 15)
	var/treatable_tox = C.getToxLoss() >= heal_threshold

	if((!C.has_organic_damage() || !(treatable_brute || treatable_fire || treatable_oxy || treatable_tox)) && !treatable_virus)
		return //No organic damage or injuries aren't severe enough, and no virus to treat; abort mission

	if(beaker_injection)
		return beaker_injection //Custom beaker injections have priority

	if(treatable_virus && !C.reagents.has_reagent(treatment_virus))
		return treatment_virus
	if(treatable_brute && !C.reagents.has_reagent(treatment_brute))
		return treatment_brute
	if(treatable_fire && !C.reagents.has_reagent(treatment_fire))
		return treatment_fire
	if(treatable_oxy && !C.reagents.has_reagent(treatment_oxy))
		return treatment_oxy
	if(treatable_tox && !C.reagents.has_reagent(treatment_tox))
		return treatment_tox

/mob/living/simple_animal/bot/medbot/proc/assess_patient(mob/living/carbon/C)
	//Time to see if they need medical help!
	if(C.stat == DEAD)
		return FALSE //welp too late for them!

	if(C.suiciding)
		return FALSE //Kevorkian school of robotic medical assistants.

	// is secretly a silicon
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.dna.species && H.dna.species.reagent_tag == PROCESS_SYN)
			return FALSE

	if(emagged || hijacked) //Everyone needs our medicine. (Our medicine is toxins)
		return TRUE

	if(syndicate_aligned && !("syndicate" in C.faction))
		return FALSE

	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare(C)

	if(!isnull(select_medication(C, assess_beaker_injection(C))))
		return TRUE //If a valid medicine option for the patient exists, they require treatment

/mob/living/simple_animal/bot/medbot/UnarmedAttack(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		patient = C
		set_mode(BOT_HEALING)
		update_icon()
		medicate_patient(C)
		update_icon()
	else
		..()

/mob/living/simple_animal/bot/medbot/examinate(atom/A as mob|obj|turf in view())
	..()
	if(has_vision(information_only=TRUE))
		chemscan(src, A)

/mob/living/simple_animal/bot/medbot/proc/medicate_patient(mob/living/carbon/C)
	set waitfor = FALSE

	if(!on)
		return

	if(!istype(C))
		previous_patient = patient.UID()
		soft_reset()
		return

	if(C.stat == DEAD || HAS_TRAIT(C, TRAIT_FAKEDEATH))
		medbot_phrase(pick(patient_died_phrases), C)
		previous_patient = patient.UID()
		soft_reset()
		return

	var/reagent_id
	var/beaker_injection //If and what kind of beaker reagent needs to be injected

	if(emagged || hijacked) //Emagged! Time to poison everybody.
		reagent_id = "pancuronium"
	else
		beaker_injection = assess_beaker_injection(C)
		reagent_id = select_medication(C, beaker_injection)

	if(!reagent_id) //If they don't need any of that they're probably cured!
		medbot_phrase(pick(finish_healing_phrases), C)
		bot_reset()
		return

	if(!emagged && !hijacked && check_overdose(patient, reagent_id, injection_amount))
		soft_reset()
		return

	C.visible_message(
		"<span class='danger'>[src] is trying to inject [patient]!</span>",
		"<span class='userdanger'>[src] is trying to inject you!</span>"
	)

	if(!do_after(src, 3 SECONDS, target = C) || !on || (get_dist(src, patient) > 1) || !assess_patient(patient))
		soft_reset()
		visible_message("[src] retracts its syringe.")
		return

	if(!isnull(beaker_injection))
		if(use_beaker && reagent_glass?.reagents.total_volume)
			var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
			reagent_glass.reagents.reaction(patient, REAGENT_INGEST, fraction)
			reagent_glass.reagents.trans_to(patient, injection_amount) //Inject from beaker instead.
	else
		patient.reagents.add_reagent(reagent_id, injection_amount)

	C.visible_message(
		"<span class='danger'>[src] injects [patient] with its syringe!</span>",
		"<span class='userdanger'>[src] injects you with its syringe!</span>"
	)

	// Don't soft reset here, we already have a patient, only soft reset if we fail to heal them.
	set_mode(BOT_IDLE)

/mob/living/simple_animal/bot/medbot/proc/check_overdose(mob/living/carbon/patient,reagent_id,injection_amount)
	var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
	if(!R.overdose_threshold)
		return FALSE
	var/current_volume = patient.reagents.get_reagent_amount(reagent_id)
	if(current_volume + injection_amount > R.overdose_threshold)
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/medbot/explode()
	on = FALSE
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	if(drops_parts)
		switch(skin)
			if("ointment")
				new /obj/item/storage/firstaid/fire/empty(Tsec)
			if("tox")
				new /obj/item/storage/firstaid/toxin/empty(Tsec)
			if("o2")
				new /obj/item/storage/firstaid/o2/empty(Tsec)
			if("brute")
				new /obj/item/storage/firstaid/brute/empty(Tsec)
			if("adv")
				new /obj/item/storage/firstaid/adv/empty(Tsec)
			if("bezerk")
				var/obj/item/storage/firstaid/tactical/empty/T = new(Tsec)
				T.syndicate_aligned = syndicate_aligned //This is a special case since Syndicate medibots and the mysterious medibot look the same; we also dont' want crew building Syndicate medibots if the mysterious medibot blows up.
			if("fish")
				new /obj/item/storage/firstaid/aquatic_kit(Tsec)
			if("machine")
				new /obj/item/storage/firstaid/machine/empty(Tsec)
			else
				new /obj/item/storage/firstaid/regular/empty(Tsec)

		new /obj/item/assembly/prox_sensor(Tsec)

		new /obj/item/healthanalyzer(Tsec)

		if(prob(50))
			drop_part(robot_arm, Tsec)

	if(reagent_glass)
		reagent_glass.forceMove(Tsec)
		reagent_glass = null

	if(emagged && prob(25))
		playsound(loc, 'sound/voice/minsult.ogg', 50, FALSE)

	do_sparks(3, TRUE, src)
	..()

/mob/living/simple_animal/bot/medbot/proc/declare(crit_patient)
	if(declare_cooldown)
		return
	if(syndicate_aligned)
		return
	var/area/location = get_area(src)
	speak("Medical emergency! [crit_patient ? "<b>[crit_patient]</b>" : "A patient"] is in critical condition at [location]!", radio_channel)
	declare_cooldown = TRUE
	spawn(200) //Twenty seconds
		declare_cooldown = FALSE

/// Given a proper medbot phrase key, say the line with any replacements, and play its sound.
/mob/living/simple_animal/bot/medbot/proc/medbot_phrase(phrase, mob/target)
	var/sound_path = all_phrases[phrase]
	if(target)
		phrase = replacetext(phrase, "%TARGET%", "[target]")

	speak(phrase)
	playsound(src, sound_path, 75, FALSE)

#undef MEDBOT_MIN_HEALING_THRESHOLD
#undef MEDBOT_MAX_HEALING_THRESHOLD
#undef MEDBOT_MIN_INJECTION_AMOUNT
#undef MEDBOT_MAX_INJECTION_AMOUNT
