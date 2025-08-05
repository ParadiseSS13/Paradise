/mob/living/simple_animal/bot/honkbot
	name = "honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon_state = "honkbot"
	density = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB
	radio_channel = "Service" //Service
	bot_type = HONK_BOT
	bot_filter = RADIO_HONKBOT
	model = "Honkbot"
	req_access = list(ACCESS_CLOWN, ACCESS_ROBOTICS, ACCESS_MIME)
	window_id = "autohonk"
	window_name = "Honkomatic Bike Horn Unit v1.0.7"
	data_hud_type = DATA_HUD_SECURITY_BASIC // show jobs

	var/honksound = 'sound/items/bikehorn.ogg' //customizable sound
	var/spam_flag = FALSE
	var/cooldowntime = 3 SECONDS
	var/cooldowntimehorn = 1 SECONDS
	var/mob/living/carbon/target
	var/oldtarget_name
	var/target_lastloc = FALSE	//Loc of target when arrested.
	var/last_found = FALSE	//There's a delay
	var/threatlevel = FALSE
	var/no_handcuffs = FALSE

/mob/living/simple_animal/bot/honkbot/Initialize(mapload)
	. = ..()
	update_icon()
	auto_patrol = TRUE
	var/datum/job/clown/J = new /datum/job/clown()
	access_card.access += J.get_access()
	prev_access = access_card.access
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/bot/honkbot/proc/sensor_blink()
	icon_state = "honkbot-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 5, TIMER_OVERRIDE|TIMER_UNIQUE)

//honkbots react with sounds.
/mob/living/simple_animal/bot/honkbot/proc/react_ping()
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE, -1) //the first sound upon creation!
	spam_flag = TRUE
	sensor_blink()
	addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), 1.8 SECONDS)

/mob/living/simple_animal/bot/honkbot/proc/react_buzz()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	sensor_blink()

/mob/living/simple_animal/bot/honkbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = FALSE
	GLOB.move_manager.stop_looping(src)
	last_found = world.time
	spam_flag = FALSE

/mob/living/simple_animal/bot/honkbot/set_custom_texts()
	text_hack = "You overload [name]'s sound control system"
	text_dehack = "You reboot [name] and restore the sound control system."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/honkbot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/honkbot/ui_state(mob/user)
	return GLOB.default_state

/mob/living/simple_animal/bot/honkbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotHonk", name)
		ui.open()

/mob/living/simple_animal/bot/honkbot/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/mob/user = ui.user
	if(topic_denied(user))
		to_chat(user, "<span class='warning'>[src]'s interface is not responding!</span>")
		return
	add_fingerprint(user)
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
			handle_hacking(user)
		if("disableremote")
			remote_disabled = !remote_disabled

/mob/living/simple_animal/bot/honkbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = 6
	target = H
	set_mode(BOT_HUNT)

/mob/living/simple_animal/bot/honkbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM)
		retaliate(H)
		addtimer(CALLBACK(src, PROC_REF(react_buzz)), 5)
	return ..()

/mob/living/simple_animal/bot/honkbot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	// If the target is locked, they are recieving damage from the screwdriver
	if(!isscrewdriver(W) && !locked && (W.force) && (!target) && (W.damtype != STAMINA))
		retaliate(user)
		addtimer(CALLBACK(src, PROC_REF(react_buzz)), 5)
		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/simple_animal/bot/honkbot/emag_act(mob/user)
	..()
	if(emagged)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits. It gives out an evil laugh!!</span>")
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] gives out an evil laugh!</span>")
		playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter
		update_icon()

/mob/living/simple_animal/bot/honkbot/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return FALSE
	if(locked || !open)
		to_chat(user, "<span class='warning'>Unlock and open it with a screwdriver first!</span>")
		return FALSE

	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	remote_disabled = TRUE
	locked = TRUE
	open = FALSE
	bot_reset()
	turn_on()
	if(user)
		to_chat(user, "<span class='notice'>You smear bananium ooze all over [src]'s circuitry!</span>")
		add_attack_logs(user, src, "Cmagged")
	show_laws()
	return TRUE

/mob/living/simple_animal/bot/honkbot/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		. += "<span class='warning'>Yellow ooze seems to be seeping from the case...</span>"

/mob/living/simple_animal/bot/honkbot/bullet_act(obj/item/projectile/Proj)
	if((istype(Proj,/obj/item/projectile/beam)) || (istype(Proj,/obj/item/projectile/bullet) && (Proj.damage_type == BURN))||(Proj.damage_type == BRUTE) && (!Proj.nodamage && Proj.damage < health && ishuman(Proj.firer)))
		retaliate(Proj.firer)
	..()

/mob/living/simple_animal/bot/honkbot/UnarmedAttack(atom/A)
	if(!on)
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!emagged)
			honk_attack(A)
		else
			if(!C.IsStunned() || no_handcuffs)
				stun_attack(A)
		..()
	else if(!spam_flag) //honking at the ground
		bike_horn(A)

/mob/living/simple_animal/bot/honkbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		playsound(src, honksound, 50, TRUE, -1)
		var/obj/item/I = AM
		var/mob/thrower = locateUID(I.thrownby)
		if(I.throwforce < src.health && ishuman(thrower))
			retaliate(thrower)
	..()

/mob/living/simple_animal/bot/honkbot/proc/bike_horn() //use bike_horn
	if(!emagged)
		if(!spam_flag)
			playsound(src, honksound, 50, TRUE, -1)
			spam_flag = TRUE //prevent spam
			sensor_blink()
			addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)
	else //emagged honkbots will spam short and memorable sounds.
		if(!spam_flag)
			playsound(src, "honkbot_e", 50, 0)
			spam_flag = TRUE // prevent spam
			icon_state = "honkbot-e"
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 30, TIMER_OVERRIDE|TIMER_UNIQUE)
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)

/mob/living/simple_animal/bot/honkbot/proc/honk_attack(mob/living/carbon/C) // horn attack
	if(!spam_flag)
		playsound(loc, honksound, 50, TRUE, -1)
		spam_flag = TRUE // prevent spam
		sensor_blink()
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)

/mob/living/simple_animal/bot/honkbot/proc/cuff_callback(mob/living/carbon/C)
	set_mode(BOT_ARREST)
	sleep(1 SECONDS)
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	C.visible_message("<span class='danger'>[src] is trying to put zipties on [C]!</span>",
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	if(!do_after(src, 6 SECONDS, target = C) || !on)
		set_mode(BOT_IDLE)
		return
	if(!C.handcuffed)
		C.handcuffed = new /obj/item/restraints/handcuffs/twimsts(C)
		C.update_handcuffed()
	C.SetDeaf(0)
	playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/bcreep.ogg'), 50, FALSE)
	set_mode(BOT_IDLE)

/mob/living/simple_animal/bot/honkbot/proc/stun_attack(mob/living/carbon/C) // airhorn stun
	if(spam_flag)
		return
	playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1) //HEEEEEEEEEEEENK!!
	sensor_blink()

	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		var/area/location = get_area(src)
		speak("Arresting level 4 scumbag <b>[C]</b> in [location].", radio_channel)

	if(!ishuman(C))
		C.Stuttering(40 SECONDS)
		C.Stun(20 SECONDS)
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)
		return
	var/mob/living/carbon/human/H = C
	if(H.check_ear_prot() >= HEARING_PROTECTION_MAJOR)
		return
	C.SetStuttering(40 SECONDS) //stammer
	C.Deaf(5 SECONDS) //far less damage than the H.O.N.K.
	C.Jitter(100 SECONDS)
	C.Weaken(10 SECONDS)
	if(client) //prevent spam from players..
		spam_flag = TRUE
	if(!emagged) //HONK once, then leave
		threatlevel -= 6
		target = oldtarget_name
	else // you really don't want to hit an emagged honkbot
		threatlevel = 6 // will never let you go
	addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)
	add_attack_logs(src, C, "honked by [src]")
	C.visible_message("<span class='danger'>[src] has honked [C]!</span>",
			"<span class='userdanger'>[src] has honked you!</span>")
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		INVOKE_ASYNC(src, PROC_REF(cuff_callback), C)


/mob/living/simple_animal/bot/honkbot/handle_automated_action()
	if(!..())
		return
	switch(mode)
		if(BOT_IDLE)		// idle
			GLOB.move_manager.stop_looping(src)
			if(find_new_target())
				return
			if(!mode && auto_patrol)
				set_mode(BOT_START_PATROL)
		if(BOT_HUNT)
			// if can't reach perp for long enough, go idle
			if(frustration >= 5) //gives up easier than beepsky
				GLOB.move_manager.stop_looping(src)
				playsound(loc, 'sound/misc/sadtrombone.ogg', 25, TRUE, -1)
				back_to_idle()
				return

			if(!target)		// make sure target exists
				back_to_idle()
				return

			if(Adjacent(target) && isturf(target.loc))
				if(threatlevel <= 4)
					honk_attack(target)
				else
					if(threatlevel >= 6)
						target_lastloc = target.loc
						stun_attack(target)
						anchored = FALSE
				return

			try_chasing_target(target)

		if(BOT_START_PATROL)
			if(find_new_target())
				return
			start_patrol()

		if(BOT_PATROL)
			if(find_new_target())
				return
			bot_patrol()
	return

/mob/living/simple_animal/bot/honkbot/proc/back_to_idle()
	anchored = FALSE
	set_mode(BOT_IDLE)
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action)) //responds quickly

/mob/living/simple_animal/bot/honkbot/proc/back_to_hunt()
	anchored = FALSE
	frustration = 0
	set_mode(BOT_HUNT)
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action)) // responds quickly

/mob/living/simple_animal/bot/honkbot/proc/find_new_target()
	anchored = FALSE
	for(var/mob/living/carbon/C in view(7, src))
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			threatlevel = 6
		if(threatlevel < 4)
			if(emagged) // actually emagged
				bike_horn()
			else
				if((C in view(4, src)) && !spam_flag) //keep the range short for patrolling
					bike_horn()
			continue

		if(spam_flag && !emagged)
			continue

		target = C
		oldtarget_name = C.name
		bike_horn()
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			speak("Level 4 infraction alert!")
			playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, FALSE)
			visible_message("<b>[src]</b> points at [C.name]!")
		else
			speak("Honk!")
			visible_message("<b>[src]</b> starts chasing [C.name]!")
		set_mode(BOT_HUNT)
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/honkbot/explode()	//doesn't drop cardboard nor its assembly, since its a very frail material.
	GLOB.move_manager.stop_looping(src)
	visible_message("<span class='boldannounceic'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	new /obj/item/bikehorn(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(3, 1, src)
	s.start()
	..()

/mob/living/simple_animal/bot/honkbot/attack_alien(mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		set_mode(BOT_HUNT)

/mob/living/simple_animal/bot/honkbot/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(ismob(entered) && on) //only if its online
		if(prob(30)) //you're far more likely to trip on a honkbot
			var/mob/living/carbon/C = entered
			if(!istype(C) || !C || in_range(src, target))
				return
			C.visible_message("<span class='warning'>[pick( \
							"[C] dives out of [src]'s way!", \
							"[C] stumbles over [src]!", \
							"[C] jumps out of [src]'s path!", \
							"[C] trips over [src] and falls!", \
							"[C] topples over [src]!", \
							"[C] leaps out of [src]'s way!")]</span>")
			C.KnockDown(10 SECONDS)
			playsound(loc, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
			if(!client)
				speak("Honk!")
			sensor_blink()
