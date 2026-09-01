/mob/living/basic/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot. He looks less than thrilled."
	icon_state = "secbot0"
	base_icon_state = "secbot"
	light_color = "#f56275"
	light_power = 0.8
	gender = MALE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, STAMINA = 0, OXY = 0)

	req_one_access = list(ACCESS_SECURITY)
	radio_channel = "Security" // Security channel
	bot_type = SEC_BOT
	bot_mode_flags = ~BOT_MODE_CAN_BE_SAPIENT
	data_hud_type = TRAIT_SECURITY_HUD
	hackables = "target identification systems"
	path_image_color = COLOR_RED
	possessed_message = "You are a securitron! Guard the station to the best of your ability!"

	ai_controller = /datum/ai_controller/basic_controller/bot/secbot

	/// The type of baton the secbot will use
	var/baton_type = /obj/item/melee/baton/infinite_cell
	/// The baton this Secbot will use
	var/obj/item/baton
	/// The threat level of the BOT, will arrest anyone at threatlevel 4 or above
	var/threatlevel = 0

	/// Flags SecBOTs use on what to check on targets when arresting, and whether they should announce it to security/handcuff their target
	/// Look at the security_mode_flags bitfield for more information on what's togglable here.
	var/security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET

	/// On arrest, charges the violator this much.
	/// If they don't have that much in their account, they will get beaten instead
	var/price_arrest = 0
	/// Charged each time the violator is stunned on detain
	var/price_detain = 0
	/// The department the secbot will deposit collected money into
	var/payment_department = DEPARTMENT_SECURITY
	/// The type of cuffs we use on criminals after making arrests
	var/cuff_type = /obj/item/restraints/handcuffs/cable/zipties/used
	/// Are we arresting someone?
	var/arresting = FALSE

/mob/living/basic/bot/secbot/Initialize(mapload)
	. = ..()
	baton = new baton_type(src)
	update_appearance(UPDATE_ICON)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/basic/bot/secbot/Destroy()
	QDEL_NULL(baton)
	return ..()

/mob/living/basic/bot/secbot/update_icon_state()
	if(mode == BOT_HUNT)
		icon_state = "[base_icon_state]-c"
	return ..()

/mob/living/basic/bot/secbot/turn_off()
	..()
	update_bot_mode(new_mode = BOT_IDLE)

/mob/living/basic/bot/secbot/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)// shocks only make him angry
	if(speed >= initial(speed) - 3)
		return
	speed -= 3
	addtimer(VARSET_CALLBACK(src, speed, speed + 3), 6 SECONDS)
	playsound(src, 'sound/machines/defib_zap.ogg', 50)
	visible_message(SPAN_WARNING("[src] shakes and speeds up!"))

/mob/living/basic/bot/secbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == baton)
		baton = null
		update_appearance()

// Variables sent to TGUI
/mob/living/basic/bot/secbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || issilicon(user))
		data["custom_controls"]["check_id"] = security_mode_flags & SECBOT_CHECK_IDS
		data["custom_controls"]["check_weapons"] = security_mode_flags & SECBOT_CHECK_WEAPONS
		data["custom_controls"]["check_warrants"] = security_mode_flags & SECBOT_CHECK_RECORDS
		data["custom_controls"]["handcuff_targets"] = security_mode_flags & SECBOT_HANDCUFF_TARGET
		data["custom_controls"]["arrest_alert"] = security_mode_flags & SECBOT_DECLARE_ARRESTS
	return data

/mob/living/basic/bot/secbot/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(!early_melee_attack(target, modifiers, ignore_cooldown))
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!iscarbon(target))
		..()
	var/mob/living/carbon/C = target
	face_atom(C)
	if(!emagged) // This keeps it from harm batonning
		a_intent = INTENT_HELP
	if(istype(baton, /obj/item/melee/baton)) // We need to do this so beepsky can stun but things like honkbots will be fine
		var/obj/item/melee/baton/stunner = baton
		stunner.melee_attack_chain(src, C)
	else
		baton.melee_attack_chain(src, C)

	var/threat = 5 || ai_controller.blackboard[BB_CURRENT_CRIMINAL_ASSESSMENT]
	if(security_mode_flags & SECBOT_DECLARE_ARRESTS)
		var/area/location = get_area(src)
		speak("[security_mode_flags & SECBOT_HANDCUFF_TARGET ? "Arresting" : "Detaining"] level [threat] scumbag [target] in [location].", radio_channel)

	var/mob/living/basic/bot/secbot/honkbot/honker = src
	if((C.IsWeakened() || istype(honker)) && !arresting)
		arresting = TRUE
		post_stun(C)
		arresting = FALSE
	return TRUE

// Actions received from TGUI
/mob/living/basic/bot/secbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || (bot_access_flags & BOT_COVER_LOCKED && !issilicon(user)))
		return

	switch(action)
		if("check_id")
			security_mode_flags ^= SECBOT_CHECK_IDS
			return TRUE
		if("check_weapons")
			security_mode_flags ^= SECBOT_CHECK_WEAPONS
			return TRUE
		if("check_warrants")
			security_mode_flags ^= SECBOT_CHECK_RECORDS
			return TRUE
		if("handcuff_targets")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
			return TRUE
		if("arrest_alert")
			security_mode_flags ^= SECBOT_DECLARE_ARRESTS
			return TRUE


/mob/living/basic/bot/secbot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	// Turns an oversight into a feature. Beepsky will now announce when pacifists taunt him over sec comms.
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		user.visible_message(SPAN_NOTICE("[user] taunts [src], daring [p_them()] to give chase!"), \
			SPAN_NOTICE("You taunt [src], daring [p_them()] to chase you!"), SPAN_HEAR("You hear someone shout a daring taunt!"))
		speak("Taunted by pacifist scumbag [user] in [get_area(src)].", radio_channel)

		// Interrupt the attack chain. We've already handled this scenario for pacifists.
		return

	return ..()

/mob/living/basic/bot/secbot/proc/retrieve_emag_message()
	audible_message(SPAN_DANGER("[src] buzzes oddly!"))

/mob/living/basic/bot/secbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		return

	retrieve_emag_message()
	security_mode_flags &= ~SECBOT_DECLARE_ARRESTS
	update_appearance()
	return TRUE

/mob/living/basic/bot/secbot/proc/post_arrest(mob/living/carbon/current_target)
	var/sound = pick(list(
		'sound/voice/beepsky/god.ogg',
		'sound/voice/beepsky/creep.ogg',
		'sound/voice/beepsky/iamthelaw.ogg',
		'sound/voice/beepsky/secureday.ogg',
		'sound/voice/beepsky/insult.ogg',
		'sound/voice/beepsky/radio.ogg'
	))

	playsound(src, sound, 50, FALSE)

/mob/living/basic/bot/secbot/proc/post_stun(mob/living/carbon/current_target, harm = FALSE)
	flick("[base_icon_state]-c", src)
	payment_check(current_target)
	update_bot_mode(new_mode = BOT_PREP_ARREST)
	if(security_mode_flags & SECBOT_HANDCUFF_TARGET)
		if(!iscarbon(current_target))
			return
		if(current_target.handcuffed)
			return
		playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE)
		current_target.visible_message(SPAN_DANGER("[src] is trying to put zipties on [current_target]!"),\
			SPAN_DANGER("[src] is trying to put zipties on you!"))

		if(!do_after(src, 4 SECONDS, current_target))
			return
		current_target.handcuffed = new cuff_type(current_target)
		current_target.update_handcuffed()
		post_arrest(current_target)

/mob/living/basic/bot/secbot/explode()
	var/atom/drop_location = drop_location()
	retrieve_secbot_drops(drop_location)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	return ..()

/mob/living/basic/bot/secbot/proc/retrieve_secbot_drops(atom/drop_location)
	var/obj/item/bot_assembly/secbot/secbot_assembly = new(drop_location)
	secbot_assembly.build_step = ASSEMBLY_FIRST_STEP
	secbot_assembly.add_overlay("hs_hole")
	secbot_assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_location)
	new /obj/item/melee/baton(drop_location)

/mob/living/basic/bot/secbot/proc/on_entered(datum/source, atom/movable/to_be_tripped)
	SIGNAL_HANDLER
	var/mob/living/possible_target = ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!has_gravity() || !ismob(to_be_tripped) || !possible_target)
		return
	var/mob/living/carbon/tripped_mob = to_be_tripped
	if(istype(tripped_mob) && !in_range(src, possible_target))
		knockOver(tripped_mob)

/// Returns true if the current target is unable to pay to be detained/arrested
/mob/living/basic/bot/secbot/proc/payment_check(mob/living/carbon/human/human_target)
	var/fair_market_price = (security_mode_flags & SECBOT_HANDCUFF_TARGET) ? price_arrest : price_detain
	if(fair_market_price <= 0)
		return FALSE
	if(!ishuman(human_target))
		return FALSE
	var/obj/item/card/id/target_id = human_target.get_idcard()
	if(!target_id)
		say("Unable to pay fine: No ID card found.")
		return TRUE
	var/datum/money_account/D = GLOB.station_money_database.find_user_account(target_id.associated_account_number, include_departments = FALSE)
	if(!D)
		say("Unable to pay fine: No bank account found.")
		return TRUE
	if(!GLOB.station_money_database.charge_account(D, -fair_market_price, "Securitron fine", src, FALSE, FALSE))
		say("Unable to pay fine: Not enough funds in account.")
		return TRUE

	var/datum/money_account_database/main_station/account_database = GLOB.station_money_database
	var/linked_account = account_database.get_account_by_department(payment_department)
	GLOB.station_money_database.credit_account(linked_account, -fair_market_price, "Security Fine", src, FALSE)
	say("Fine paid: Thank you for your compliance. Your account been charged [fair_market_price] credits.")
	return FALSE

/mob/living/basic/bot/secbot/generate_speak_list()
	var/static/list/secbot_lines = list(
		BEEPSKY_VOICED_CRIMINAL_DETECTED = 'sound/voice/beepsky/criminal.ogg',
		BEEPSKY_VOICED_FREEZE = 'sound/voice/beepsky/freeze.ogg',
		BEEPSKY_VOICED_JUSTICE = 'sound/voice/beepsky/justice.ogg',
		BEEPSKY_VOICED_YOUR_MOVE = 'sound/voice/beepsky/creep.ogg',
		BEEPSKY_VOICED_I_AM_THE_LAW = 'sound/voice/beepsky/iamthelaw.ogg',
		BEEPSKY_VOICED_SECURE_DAY = 'sound/voice/beepsky/secureday.ogg',
		BEEPSKY_VOICED_INSULT = 'sound/voice/beepsky/insult.ogg',
		BEEPSKY_VOICED_RADIO = 'sound/voice/beepsky/radio.ogg'
	)
	return secbot_lines


/mob/living/basic/bot/secbot/proc/judgement_criteria()
	var/final = FALSE
	if(bot_access_flags & BOT_COVER_EMAGGED)
		final |= JUDGE_EMAGGED
	if(security_mode_flags & SECBOT_CHECK_IDS)
		final |= JUDGE_IDCHECK
	if(security_mode_flags & SECBOT_CHECK_RECORDS)
		final |= JUDGE_RECORDCHECK
	if(security_mode_flags & SECBOT_CHECK_WEAPONS)
		final |= JUDGE_WEAPONCHECK
	if(security_mode_flags & SECBOT_SABOTEUR_AFFECTED)
		final |= JUDGE_CHILLOUT
	return final

/mob/living/basic/bot/secbot/proc/knockOver(mob/living/carbon/C)
	if(C.key)
		C.visible_message(SPAN_WARNING(pick( \
						"[C] dives out of [src]'s way!", \
						"[C] stumbles over [src]!", \
						"[C] jumps out of [src]'s path!", \
						"[C] trips over [src] and falls!", \
						"[C] topples over [src]!", \
						"[C] leaps out of [src]'s way!")))
	C.AdjustParalysis(4 SECONDS)
