/mob/living/basic/bot/secbot/honkbot
	name = "\improper Honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon_state = "honkbot"
	base_icon_state = "honkbot"
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	req_access = list(ACCESS_ROBOTICS, ACCESS_THEATRE, ACCESS_CLOWN)
	ai_controller = /datum/ai_controller/basic_controller/bot/honkbot
	radio_channel = "Service"
	bot_type = HONK_BOT
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_AUTOPATROL | BOT_MODE_ROUNDSTART_POSSESSION
	hackables = "sound control systems"
	path_image_color = "#FF69B4"
	data_hud_type = TRAIT_SECURITY_HUD
	possessed_message = "You are a honkbot! Make sure the crew are having a great time!"
	security_mode_flags = parent_type::security_mode_flags | HONKBOT_MODE_SLIP
	/// our voicelines
	var/static/list/honkbot_sounds = list(
		HONKBOT_VOICED_HONK_HAPPY = 'sound/items/bikehorn.ogg',
		HONKBOT_VOICED_HONK_SAD = 'sound/misc/sadtrombone.ogg',
	)
	stun_sound = 'sound/items/airhorn.ogg'
	baton_type = /obj/item/bikehorn/airhorn
	cuff_type = /obj/item/restraints/handcuffs/toy

/mob/living/basic/bot/secbot/honkbot/Initialize(mapload)
	. = ..()
	var/static/list/clown_friends = typecacheof(list(
		/mob/living/carbon/human,
		/mob/living/silicon/robot,
	))
	ai_controller.set_blackboard_key(BB_CLOWNS_LIST, clown_friends)
	var/static/list/slippery_items = typecacheof(list(
		/obj/item/grown/bananapeel,
		/obj/item/soap,
	))
	ai_controller.set_blackboard_key(BB_SLIPPERY_ITEMS, slippery_items)

	var/datum/action/cooldown/mob_cooldown/bot/honk/bike_honk = new(src)
	bike_honk.Grant(src)
	bike_honk.post_honk_callback = CALLBACK(src, PROC_REF(set_attacking_state))
	ai_controller.set_blackboard_key(BB_HONK_ABILITY, bike_honk)

	AddComponent(/datum/component/slippery,\
		knockdown = 6 SECONDS,\
		paralyze = 3 SECONDS,\
		on_slip_callback = CALLBACK(src, PROC_REF(post_slip)),\
		can_slip_callback = CALLBACK(src, PROC_REF(pre_slip)),\
	)

/mob/living/basic/bot/secbot/honkbot/generate_speak_list()
	return honkbot_sounds

/mob/living/basic/bot/secbot/honkbot/proc/pre_slip()
	return (prob(70) && ai_controller?.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))

/mob/living/basic/bot/secbot/honkbot/proc/post_slip()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/basic/bot, speak), HONKBOT_VOICED_HONK_SAD)
	set_attacking_state()

/mob/living/basic/bot/secbot/honkbot/proc/set_attacking_state()
	icon_state = "[base_icon_state]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 0.2 SECONDS)

/mob/living/basic/bot/secbot/honkbot/post_arrest(mob/living/carbon/current_target)
	var/emagged_sounds = list(
		'sound/effects/pray.ogg',
		'sound/items/airhorn.ogg',
		'sound/items/airhorn2.ogg',
		'sound/items/bikehorn.ogg',
		'sound/items/weeoo1.ogg',
		'sound/machines/buzz-sigh.ogg',
		'sound/machines/ping.ogg',
		'sound/magic/fireball.ogg',
		'sound/misc/sadtrombone.ogg',
		'sound/voice/beepsky/creep.ogg',
		'sound/voice/beepsky/iamthelaw.ogg',
		'sound/voice/hiss1.ogg',
		'sound/weapons/bladeslice.ogg',
		'sound/weapons/flashbang.ogg',
	)
	playsound(src, (bot_access_flags & BOT_COVER_EMAGGED ? pick(emagged_sounds) : 'sound/items/bikehorn.ogg'), 50, FALSE)
	icon_state = bot_access_flags & BOT_COVER_EMAGGED ? "[base_icon_state]-e" : "[base_icon_state]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	audible_message(SPAN_DANGER("[src] gives out an evil laugh!"))
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter

/mob/living/basic/bot/secbot/honkbot/retrieve_emag_message()
	audible_message(SPAN_DANGER("[src] gives out an evil laugh!"))
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter

/mob/living/basic/bot/secbot/honkbot/post_stun(mob/living/carbon/current_target)
	if(!istype(current_target))
		return

	if(current_target.check_ear_prot() >= HEARING_PROTECTION_MAJOR)
		return
	if(HAS_TRAIT(current_target, TRAIT_DEAF))
		return
	current_target.SetStuttering(40 SECONDS) // stammer
	current_target.Deaf(5 SECONDS) // far less damage than the H.O.N.K.
	current_target.Jitter(100 SECONDS)
	current_target.Weaken(10 SECONDS)
	set_attacking_state()

/mob/living/basic/bot/secbot/honkbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || issilicon(user))
		data["custom_controls"]["slip_people"] = security_mode_flags & HONKBOT_MODE_SLIP
		data["custom_controls"]["fake_cuff"] = security_mode_flags & SECBOT_HANDCUFF_TARGET
		data["custom_controls"]["check_ids"] = security_mode_flags & SECBOT_CHECK_IDS
		data["custom_controls"]["check_records"] = security_mode_flags & SECBOT_CHECK_RECORDS
	return data

/mob/living/basic/bot/secbot/honkbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || !isliving(user) || (bot_access_flags & BOT_COVER_LOCKED) && !issilicon(user))
		return
	switch(action)
		if("slip_people")
			security_mode_flags ^= HONKBOT_MODE_SLIP
		if("fake_cuff")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
		if("check_ids")
			security_mode_flags ^= SECBOT_CHECK_IDS
		if("check_records")
			security_mode_flags ^= SECBOT_CHECK_RECORDS

/mob/living/basic/bot/secbot/honkbot/retrieve_secbot_drops(atom/drop_location)
	new /obj/item/assembly/prox_sensor(drop_location)
	drop_part(baton_type, drop_location)

/mob/living/basic/bot/secbot/honkbot/nopatrol
	bot_mode_flags = parent_type::bot_mode_flags & ~BOT_MODE_AUTOPATROL
