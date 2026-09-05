#define TEND_DAMAGE_INTERACTION "tend_damage_interaction"

/mob/living/basic/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon_state = "medbot_generic_idle"
	base_icon_state = "medbot"
	health = 20
	maxHealth = 20
	speed = 2
	light_power = 0.8
	light_color = "#99ccff"
	status_flags = (CANPUSH | CANSTUN)
	ai_controller = /datum/ai_controller/basic_controller/bot/medbot

	req_one_access = list(ACCESS_ROBOTICS, ACCESS_MEDICAL)
	radio_channel = "Medical"
	bot_type = MED_BOT
	data_hud_type = TRAIT_MEDICAL_HUD
	hackables = "health processor circuits"
	possessed_message = "You are a medbot! Ensure good health among the crew to the best of your ability!"

	announcement_type = /datum/action/cooldown/bot_announcement/medbot
	path_image_color = "#d9d9f4"

	/// Reagent Beaker
	var/obj/item/reagent_containers/glass/reagent_glass = null
	/// Do we use the beaker reagents instead?
	var/use_beaker = FALSE
	/// Do we treat viruses
	var/treat_virus = TRUE

	/// announcements when we find a target to heal
	var/static/list/wait_announcements = list(
		MEDIBOT_VOICED_HOLD_ON = 'sound/voice/medbot/coming.ogg',
		MEDIBOT_VOICED_WANT_TO_HELP = 'sound/voice/medbot/help.ogg',
		MEDIBOT_VOICED_YOU_ARE_INJURED = 'sound/voice/medbot/injured.ogg',
	)

	/// announcements after we heal someone
	var/static/list/afterheal_announcements = list(
		MEDIBOT_VOICED_ALL_PATCHED_UP = 'sound/voice/medbot/patchedup.ogg',
		MEDIBOT_VOICED_APPLE_A_DAY = 'sound/voice/medbot/apple.ogg',
		MEDIBOT_VOICED_FEEL_BETTER = 'sound/voice/medbot/feelbetter.ogg',
	)

	/// announcements when we are healing someone near death
	var/static/list/near_death_announcements = list(
		MEDIBOT_VOICED_STAY_WITH_ME = 'sound/voice/medbot/no.ogg',
		MEDIBOT_VOICED_LIVE = 'sound/voice/medbot/live.ogg',
		MEDIBOT_VOICED_NEVER_LOST = 'sound/voice/medbot/lost.ogg',
	)
	/// announcements when we are idle
	var/static/list/idle_lines = list(
		MEDIBOT_VOICED_DELICIOUS = 'sound/voice/medbot/delicious.ogg',
		MEDIBOT_VOICED_PLASTIC_SURGEON = 'sound/voice/medbot/surgeon.ogg',
		MEDIBOT_VOICED_MASK_ON = 'sound/voice/medbot/radar.ogg',
		MEDIBOT_VOICED_ALWAYS_A_CATCH = 'sound/voice/medbot/catch.ogg',
		MEDIBOT_VOICED_LIKE_FLIES = 'sound/voice/medbot/flies.ogg',
		MEDIBOT_VOICED_SUFFER = 'sound/voice/medbot/why.ogg',
	)
	/// announcements when we are emagged
	var/static/list/emagged_announcements = list(
		MEDIBOT_VOICED_FUCK_YOU = 'sound/voice/medbot/fuck_you.ogg',
		MEDIBOT_VOICED_INSULT = 'sound/voice/medbot/insult.ogg',
		MEDIBOT_VOICED_IM_DIFFERENT = 'sound/voice/medbot/im_different.ogg',
	)
	/// announcements when we are being tipped
	var/static/list/tipped_announcements = list(
		MEDIBOT_VOICED_WAIT = 'sound/voice/medbot/hey_wait.ogg',
		MEDIBOT_VOICED_DONT = 'sound/voice/medbot/please_dont.ogg',
		MEDIBOT_VOICED_TRUSTED_YOU = 'sound/voice/medbot/i_trusted_you.ogg',
		MEDIBOT_VOICED_NO_SAD = 'sound/voice/medbot/nooo.ogg',
		MEDIBOT_VOICED_OH_FUCK = 'sound/voice/medbot/oh_fuck.ogg',
	)
	/// announcements when we are being untipped
	var/static/list/untipped_announcements = list(
		MEDIBOT_VOICED_FORGIVE = 'sound/voice/medbot/forgive.ogg',
		MEDIBOT_VOICED_THANKS = 'sound/voice/medbot/thank_you.ogg',
		MEDIBOT_VOICED_GOOD_PERSON = 'sound/voice/medbot/youre_good.ogg',
	)
	/// announcements when we are worried
	var/static/list/worried_announcements = list(
		MEDIBOT_VOICED_PUT_BACK = 'sound/voice/medbot/please_put_me_back.ogg',
		MEDIBOT_VOICED_IM_SCARED = 'sound/voice/medbot/please_im_scared.ogg',
		MEDIBOT_VOICED_NEED_HELP = 'sound/voice/medbot/dont_like.ogg',
		MEDIBOT_VOICED_THIS_HURTS = 'sound/voice/medbot/pain_is_real.ogg',
		MEDIBOT_VOICED_THE_END = 'sound/voice/medbot/is_this_the_end.ogg',
		MEDIBOT_VOICED_NOOO = 'sound/voice/medbot/nooo.ogg',
	)
	var/static/list/misc_announcements= list(
		MEDIBOT_VOICED_CHICKEN = 'sound/voice/medbot/i_am_chicken.ogg',
	)
	/// drop determining variable
	var/health_analyzer = /obj/item/healthanalyzer
	/// drop determining variable
	var/medkit_type = /obj/item/storage/firstaid/regular/empty
	///based off medkit_X skins in aibots.dmi for your selection; X goes here IE medskin_tox means skin var should be "tox"
	var/skin = "generic"
	// Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	/// Start healing when they have this much damage in a category
	var/heal_threshold = 10
	/// What damage type does this bot support. Because the default is brute, if the medkit is brute-oriented there is a slight bonus to healing. set to "all" for it to heal any of the 4 base damage types
	var/damage_type_healer = BRUTE
	/// How much reagent do we inject at a time?
	var/injection_amount = 15

	/// Flags Medbots use to decide how they should be acting.
	var/medical_mode_flags = MEDBOT_DECLARE_CRIT | MEDBOT_SPEAK_MODE
	// Selections:  MEDBOT_DECLARE_CRIT | MEDBOT_STATIONARY_MODE | MEDBOT_SPEAK_MODE | MEDBOT_TIPPED_MODE

	/// our tipper
	var/tipper

/mob/living/basic/bot/medbot/proc/set_speech_keys()
	if(isnull(ai_controller))
		return
	ai_controller.set_blackboard_key(BB_NEAR_DEATH_SPEECH, near_death_announcements)
	ai_controller.set_blackboard_key(BB_WAIT_SPEECH, wait_announcements)
	ai_controller.set_blackboard_key(BB_AFTERHEAL_SPEECH, afterheal_announcements)
	ai_controller.set_blackboard_key(BB_IDLE_SPEECH, idle_lines)
	ai_controller.set_blackboard_key(BB_EMAGGED_SPEECH, emagged_announcements)
	ai_controller.set_blackboard_key(BB_WORRIED_ANNOUNCEMENTS, worried_announcements)

/mob/living/basic/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	set_speech_keys()

	if(!isnull(new_skin))
		skin = new_skin
		update_appearance()
	AddComponent(/datum/component/tippable, \
		tip_time = 3 SECONDS, \
		untip_time = 3 SECONDS, \
		self_right_time = 3.5 MINUTES, \
		pre_tipped_callback = CALLBACK(src, PROC_REF(pre_tip_over)), \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_tip_over)), \
		post_untipped_callback = CALLBACK(src, PROC_REF(after_righted)))

	var/static/list/hat_offsets = list(4,-9)
	var/static/list/remove_hat = list(SIGNAL_ADDTRAIT(TRAIT_MOB_TIPPED))
	var/static/list/prevent_checks = list(TRAIT_MOB_TIPPED)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack), TRUE)

	update_appearance()
	if(prob(50))
		name += ", PhD."

	return INITIALIZE_HINT_LATELOAD

/mob/living/basic/bot/medbot/update_icon_state()
	. = ..()

	var/mode_suffix = mode == BOT_HEALING ? "active" : "idle"
	icon_state = "[base_icon_state]_[skin]_[mode_suffix]"

/mob/living/basic/bot/medbot/update_overlays()
	. = ..()

	if(!(medical_mode_flags & MEDBOT_STATIONARY_MODE))
		. += mutable_appearance(icon, "[base_icon_state]_overlay_wheels")

	var/mode_suffix = mode == BOT_HEALING ? "active" : "idle"
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, "[base_icon_state]_overlay_incapacitated")
		. += emissive_appearance(icon, "[base_icon_state]_overlay_incapacitated", src, alpha = src.alpha)
	else
		. += mutable_appearance(icon, "[base_icon_state]_overlay_on_[mode_suffix]")
		. += emissive_appearance(icon, "[base_icon_state]_overlay_on_[mode_suffix]", src, alpha = src.alpha)

// this is sin
/mob/living/basic/bot/medbot/generate_speak_list()
	var/static/list/finalized_speak_list = (idle_lines + wait_announcements + afterheal_announcements + near_death_announcements + emagged_announcements + tipped_announcements + untipped_announcements + worried_announcements + misc_announcements)
	return finalized_speak_list

// Variables sent to TGUI
/mob/living/basic/bot/medbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || issilicon(user))
		data["custom_controls"]["heal_threshold"] = heal_threshold
		data["custom_controls"]["speaker"] = medical_mode_flags & MEDBOT_SPEAK_MODE
		data["custom_controls"]["crit_alerts"] = medical_mode_flags & MEDBOT_DECLARE_CRIT
		data["custom_controls"]["stationary_mode"] = medical_mode_flags & MEDBOT_STATIONARY_MODE
	return data

// Actions received from TGUI
/mob/living/basic/bot/medbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || !isliving(ui.user) || (bot_access_flags & BOT_COVER_LOCKED) && !issilicon(user))
		return
	switch(action)
		if("heal_threshold")
			var/adjust_num = round(text2num(params["threshold"]))
			heal_threshold = adjust_num
			if(heal_threshold < 5)
				heal_threshold = 5
			if(heal_threshold > 75)
				heal_threshold = 75
		if("speaker")
			medical_mode_flags ^= MEDBOT_SPEAK_MODE
		if("crit_alerts")
			medical_mode_flags ^= MEDBOT_DECLARE_CRIT
		if("stationary_mode")
			medical_mode_flags ^= MEDBOT_STATIONARY_MODE

	update_appearance()

/mob/living/basic/bot/medbot/emag_effects(mob/user)
	medical_mode_flags &= ~MEDBOT_DECLARE_CRIT
	to_chat(user, SPAN_WARNING("Reagent synthesis circuits shorted!"))
	audible_message(SPAN_DANGER("[src] buzzes oddly!"))
	flick_overlay_view(mutable_appearance(icon, "[base_icon_state]_spark"), 1 SECONDS)
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/mob/living/basic/bot/medbot/examine()
	. = ..()
	if(!(medical_mode_flags & MEDBOT_TIPPED_MODE))
		return
	var/static/list/panic_state = list(
		"It appears to be tipped over, and is quietly waiting for someone to set it right.",
		"It is tipped over and requesting help.",
		"They are tipped over and appear visibly distressed.",
		SPAN_WARNING("They are tipped over and visibly panicking!"),
		SPAN_WARNING(SPAN_BOLD("They are freaking out from being tipped over!"))
	)
	. += pick(panic_state)
/*
 * Proc used in a callback for before this medibot is tipped by the tippable component.
 *
 * user - the mob who is tipping us over
 */
/mob/living/basic/bot/medbot/proc/pre_tip_over(mob/user)
	speak(pick(worried_announcements))

/*
 * Proc used in a callback for after this medibot is tipped by the tippable component.
 *
 * user - the mob who tipped us over
 */
/mob/living/basic/bot/medbot/proc/after_tip_over(mob/user)
	medical_mode_flags |= MEDBOT_TIPPED_MODE
	tipper = user
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
	if(prob(10))
		speak("PSYCH ALERT: Crewmember [user.name] recorded displaying antisocial tendencies torturing bots in [get_area(src)]. Please schedule psych evaluation.", radio_channel)

/mob/living/basic/bot/medbot/explode()
	var/atom/our_loc = drop_location()
	drop_part(medkit_type, our_loc)
	drop_part(health_analyzer, our_loc)
	return ..()

/*
 * Proc used in a callback for after this medibot is righted, either by themselves or by a mob, by the tippable component.
 *
 * user - the mob who righted us. Can be null.
 */
/mob/living/basic/bot/medbot/proc/after_righted(mob/user)
	var/mob/tipper_mob = isnull(user) ? null : tipper
	tipper = null
	medical_mode_flags &= ~MEDBOT_TIPPED_MODE
	if(isnull(tipper_mob))
		return
	if(tipper_mob == user)
		speak(MEDIBOT_VOICED_FORGIVE)
		return
	speak(pick(untipped_announcements))

/mob/living/basic/bot/medbot/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(!iscarbon(target))
		return
	INVOKE_ASYNC(src, PROC_REF(medicate_patient), target)
	return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/bot/medbot/proc/medicate_patient(mob/living/carbon/human/C)
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		if((C.get_total_damage() <= heal_threshold))
			to_chat(src, "[C] is healthy! Your programming prevents you from tending the wounds of anyone with less than [heal_threshold + 1] total damage.")
			return

	update_bot_mode(new_mode = BOT_HEALING, update_hud = FALSE)
	var/reagent_id
	var/beaker_injection // If and what kind of beaker reagent needs to be injected

	if(bot_access_flags & BOT_COVER_EMAGGED) // Emagged! Time to poison everybody.
		reagent_id = "pancuronium"
	else
		beaker_injection = assess_beaker_injection(C)
		reagent_id = assess_medication(C, beaker_injection)

	if(!reagent_id)
		bot_reset()
		return

	if(!(bot_access_flags & BOT_COVER_HACKED) && !(bot_access_flags & BOT_COVER_EMAGGED) && check_overdose(C, reagent_id, injection_amount))
		bot_reset()
		return

	C.visible_message(
		SPAN_DANGER("[src] is trying to inject [C]!"),
		SPAN_USERDANGER("[src] is trying to inject you!")
	)

	if(!do_after(src, 3 SECONDS, target = C) || !(bot_mode_flags & BOT_MODE_ON) || (get_dist(src, C) > 1))
		bot_reset()
		visible_message("[src] retracts its syringe.")
		return

	if(!isnull(beaker_injection))
		if(use_beaker && reagent_glass?.reagents.total_volume)
			var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
			reagent_glass.reagents.reaction(C, REAGENT_INGEST, fraction)
			reagent_glass.reagents.trans_to(C, injection_amount) //Inject from beaker instead.
	else
		C.reagents.add_reagent(reagent_id, injection_amount)

	var/datum/action/cooldown/bot_announcement/announcement = ai_controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(ai_controller.blackboard[BB_AFTERHEAL_SPEECH]))

	C.visible_message(
		SPAN_DANGER("[src] injects [C] with its syringe!"),
		SPAN_USERDANGER("[src] injects you with its syringe!")
	)

/mob/living/basic/bot/medbot/proc/assess_medication(mob/living/carbon/C, beaker_injection)
	var/treatable_virus = assess_viruses(C)
	var/treatable_brute = C.getBruteLoss() >= heal_threshold
	var/treatable_fire = C.getFireLoss() >= heal_threshold
	var/treatable_oxy = C.getOxyLoss() >= (heal_threshold + 15)
	var/treatable_tox = C.getToxLoss() >= heal_threshold

	if((!C.has_organic_damage() || !(treatable_brute || treatable_fire || treatable_oxy || treatable_tox)) && !treatable_virus)
		return // No organic damage or injuries aren't severe enough, and no virus to treat; abort mission

	if(beaker_injection)
		return beaker_injection // Custom beaker injections have priority

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

/mob/living/basic/bot/medbot/proc/assess_viruses(mob/living/carbon/C)
	. = FALSE

	if(!treat_virus)
		return

	for(var/datum/disease/D as anything in C.viruses)
		if((!(D.visibility_flags & VIRUS_HIDDEN_SCANNER) || (D.GetDiseaseID() in GLOB.detected_advanced_diseases["[z]"])) && D.severity != VIRUS_NONTHREAT && (D.stage > 1 || D.spread_flags & SPREAD_AIRBORNE))
			return TRUE // Medbots see viruses that aren't fully hidden and have developed enough/are airborne, ignoring safe viruses

/mob/living/basic/bot/medbot/proc/assess_beaker_injection(mob/living/carbon/C)
	// If we have and are using a medicine beaker, return any reagent the patient is missing
	if(use_beaker && reagent_glass?.reagents.total_volume)
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R.id))
				return R.id

/mob/living/basic/bot/medbot/proc/check_overdose(mob/living/carbon/patient, reagent_id, injection_amount)
	var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
	if(!R.overdose_threshold)
		return FALSE
	var/current_volume = patient.reagents.get_reagent_amount(reagent_id)
	if(current_volume + injection_amount > R.overdose_threshold)
		return TRUE
	return FALSE

/mob/living/basic/bot/medbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_ROUNDSTART_POSSESSION

/mob/living/basic/bot/medbot/stationary
	medical_mode_flags = MEDBOT_DECLARE_CRIT | MEDBOT_STATIONARY_MODE | MEDBOT_SPEAK_MODE

/mob/living/basic/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"

/mob/living/basic/bot/medbot/derelict
	name = "\improper Old Medibot"
	desc = "Looks like it hasn't been modified since the late 2080s."
	skin = "bezerk"
	medical_mode_flags = MEDBOT_SPEAK_MODE

/mob/living/basic/bot/medbot/syndicate
	name = "Suspicious Medibot"
	desc = "A medibot stolen from a Nanotrasen station and upgraded by the Syndicate. Despite their best efforts at reprogramming, it still appears visibly upset near nuclear explosives."
	health = 40
	maxHealth = 40
	skin = "bezerk"
	req_one_access = list(ACCESS_SYNDICATE)
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED
	radio_channel = "Syndicate"
	faction = list("syndicate")
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"

/mob/living/basic/bot/medbot/syndicate/proc/nuke_disarm()
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(speak), pick(untipped_announcements))

/mob/living/basic/bot/medbot/syndicate/proc/nuke_arm()
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(speak), pick(worried_announcements))

/mob/living/basic/bot/medbot/syndicate/proc/nuke_detonate()
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(speak), pick(emagged_announcements))

/mob/living/basic/bot/medbot/syndicate/emagged
	bot_access_flags = BOT_COVER_LOCKED | BOT_COVER_EMAGGED

#undef TEND_DAMAGE_INTERACTION
