#define BATON_COOLDOWN 3.5 SECONDS
#define BOT_REBATON_THRESHOLD 5 SECONDS

/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot. He looks less than thrilled."
	icon_state = "secbot0"
	density = FALSE
	health = 60
	maxHealth = 60
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_channel = "Security" //Security channel
	bot_type = SEC_BOT
	bot_filter = RADIO_SECBOT
	model = "Securitron"
	bot_purpose = "seek out criminals, handcuff them, and report their location to security"
	req_access = list(ACCESS_SECURITY)
	window_id = "autosec"
	window_name = "Automatic Security Unit v1.6"
	data_hud_type = DATA_HUD_SECURITY_ADVANCED

	var/base_icon = "secbot"
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/declare_arrests = TRUE //When making an arrest, should it notify everyone on the security channel?
	var/idcheck = FALSE //If true, arrest people with no IDs
	var/weapons_check = FALSE //If true, arrest people for weapons if they lack access
	var/check_records = TRUE //Does it check security records?
	var/no_handcuffs = FALSE //If true, don't handcuff
	var/harmbaton = FALSE //If true, beat instead of stun
	var/flashing_lights = FALSE //If true, flash lights
	var/baton_delayed = FALSE
	var/prev_flashing_lights = FALSE
	allow_pai = FALSE
	var/obj/item/melee/baton/infinite_cell/baton = null // stunbaton bot uses to melee attack
	var/currently_cuffing = FALSE // TRUE if we're cuffing someone right now
	var/played_sound_this_hunt = FALSE // used to make beepsky beep when it lost its target

/mob/living/simple_animal/bot/secbot/Initialize(mapload)
	. = ..()
	baton = new(src)
	icon_state = "[base_icon][on]"
	var/datum/job/detective/J = new/datum/job/detective
	access_card.access += J.get_access()
	prev_access = access_card.access
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/bot/secbot/Destroy()
	QDEL_NULL(baton)
	return ..()

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey."
	auto_patrol = TRUE

/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/turf/Tsec = get_turf(src)
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/drinks/drinkingglass/S = new(Tsec)
	S.reagents.add_reagent("whiskey", 15)
	S.on_reagent_change()
	..()

/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_channel = "AI Private"

/mob/living/simple_animal/bot/secbot/ofitser
	name = "Prison Ofitser"
	desc = "It's Prison Ofitser! Powered by the tears and sweat of prisoners."
	weapons_check = TRUE
	auto_patrol = TRUE

/mob/living/simple_animal/bot/secbot/buzzsky
	name = "Officer Buzzsky"
	desc = "It's Officer Buzzsky! Rusted and falling apart, he seems less than thrilled with the crew for leaving him in his current state."
	base_icon = "rustbot"
	icon_state = "rustbot0"
	declare_arrests = FALSE
	no_handcuffs = TRUE
	harmbaton = TRUE
	emagged = TRUE

/mob/living/simple_animal/bot/secbot/armsky
	name = "Sergeant-at-Armsky"
	health = 100
	maxHealth = 100
	idcheck = TRUE
	no_handcuffs = TRUE
	weapons_check = TRUE


/mob/living/simple_animal/bot/secbot/turn_on()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	currently_cuffing = FALSE
	played_sound_this_hunt = FALSE
	target = null
	oldtarget_name = null
	anchored = FALSE
	GLOB.move_manager.stop_looping(src)
	set_path(null)
	last_found = world.time

/mob/living/simple_animal/bot/secbot/set_custom_texts()
	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/secbot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/secbot/ui_state(mob/user)
	return GLOB.default_state

/mob/living/simple_animal/bot/secbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotSecurity", name)
		ui.open()

/mob/living/simple_animal/bot/secbot/ui_data(mob/user)
	var/list/data = ..()
	data["check_id"] = idcheck
	data["check_weapons"] = weapons_check
	data["check_warrant"] = check_records
	data["arrest_mode"] = no_handcuffs // detain or arrest
	data["arrest_declare"] = declare_arrests // announce arrests on radio
	return data

/mob/living/simple_animal/bot/secbot/ui_act(action, params)
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
		if("authweapon")
			weapons_check = !weapons_check
		if("authid")
			idcheck = !idcheck
		if("authwarrant")
			check_records = !check_records
		if("arrtype")
			no_handcuffs = !no_handcuffs
		if("arrdeclare")
			declare_arrests = !declare_arrests
		if("ejectpai")
			ejectpai()

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = H.assess_threat(src)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		set_mode(BOT_HUNT)

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM || H.a_intent == INTENT_DISARM)
		retaliate(H)
	return ..()

/mob/living/simple_animal/bot/secbot/attacked_by(obj/item/W, mob/living/user)
	if(..())
		return FINISH_ATTACK

	if(W.force && !target && W.damtype != STAMINA)
		retaliate(user)

/mob/living/simple_animal/bot/secbot/emag_act(mob/user)
	..()
	if(emagged)
		if(user)
			to_chat(user, "<span class='danger'>You short out [src]'s target assessment circuits.</span>")
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		declare_arrests = FALSE
		icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health)
				retaliate(Proj.firer)
	..()

/mob/living/simple_animal/bot/secbot/projectile_hit_check(obj/item/projectile/P)
	return FALSE


/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/A)
	if(!on)
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if((!C.IsWeakened() || no_handcuffs) && !baton_delayed)
			stun_attack(A)
		else if(C.canBeHandcuffed() && !C.handcuffed)
			cuff(A)
	else
		..()


/mob/living/simple_animal/bot/secbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		var/obj/item/I = AM
		var/mob/thrower = locateUID(I.thrownby)
		if(I.throwforce < src.health && ishuman(thrower))
			retaliate(thrower)
	..()


/mob/living/simple_animal/bot/secbot/proc/cuff(mob/living/carbon/C)
	set_mode(BOT_ARREST)
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	C.visible_message("<span class='danger'>[src] is trying to put zipties on [C]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	INVOKE_ASYNC(src, PROC_REF(cuff_callback), C)

/mob/living/simple_animal/bot/secbot/proc/cuff_callback(mob/living/carbon/C)
	currently_cuffing = TRUE
	if(!do_after(src, 6 SECONDS, target = C))
		currently_cuffing = FALSE
		return
	currently_cuffing = FALSE
	if(!C.handcuffed && on)
		C.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(C)
		C.update_handcuffed()
		playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, FALSE)
	back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/C)
	var/threat = C.assess_threat(src)
	var/prev_intent = a_intent
	a_intent = harmbaton ? INTENT_HARM : INTENT_HELP
	baton.pre_attack(C, src)
	a_intent = prev_intent
	baton_delayed = TRUE
	addtimer(VARSET_CALLBACK(src, baton_delayed, FALSE), BATON_COOLDOWN)
	icon_state = "[base_icon]-c"
	addtimer(VARSET_CALLBACK(src, icon_state, "[base_icon][on]"), 2)
	if(declare_arrests)
		var/area/location = get_area(src)
		speak("[no_handcuffs ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)

/mob/living/simple_animal/bot/secbot/Life(seconds, times_fired)
	. = ..()
	if(flashing_lights)
		switch(light_color)
			if(LIGHT_COLOR_PURE_RED)
				light_color = LIGHT_COLOR_PURE_BLUE
			if(LIGHT_COLOR_PURE_BLUE)
				light_color = LIGHT_COLOR_PURE_RED
		update_light()
	else if(prev_flashing_lights)
		light_color = LIGHT_COLOR_PURE_RED
		update_light()

	prev_flashing_lights = flashing_lights

/mob/living/simple_animal/bot/secbot/verb/toggle_flashing_lights()
	set name = "Toggle Flashing Lights"
	set category = "Object"

	flashing_lights = !flashing_lights

/mob/living/simple_animal/bot/secbot/try_chasing_target()
	. = ..()
	if(lost_target && !played_sound_this_hunt && frustration > 2)
		playsound(loc, 'sound/machines/synth_no.ogg', 50, FALSE)
		played_sound_this_hunt = TRUE
	if(!lost_target && played_sound_this_hunt)
		playsound(loc, 'sound/machines/synth_yes.ogg', 50, FALSE)
		played_sound_this_hunt = FALSE

/mob/living/simple_animal/bot/secbot/handle_automated_action()
	if(!..())
		return

	flashing_lights = mode == BOT_HUNT

	switch(mode)
		if(BOT_IDLE)		// idle
			GLOB.move_manager.stop_looping(src)
			set_path(null)
			if(find_new_target())	// see if any criminals are in range
				return
			if(!mode && auto_patrol)	// still idle, and set to patrol
				set_mode(BOT_START_PATROL)	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				playsound(loc, 'sound/machines/buzz-two.ogg', 25, FALSE)
				GLOB.move_manager.stop_looping(src)
				set_path(null)
				back_to_idle()
				return

			if(!target)		// make sure target exists
				back_to_idle()
				return

			if(target.stat == DEAD)
				back_to_idle() // Stop beating up the dead guy
				return

			if(Adjacent(target) && isturf(target.loc) && !baton_delayed)	// if right next to perp
				stun_attack(target)
				set_mode(BOT_PREP_ARREST)
				anchored = TRUE
				target_lastloc = target.loc
				return

			try_chasing_target(target)

		if(BOT_PREP_ARREST)		// preparing to arrest target
			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if(!Adjacent(target) || !isturf(target.loc) || target.stam_regen_start_time - world.time <= BOT_REBATON_THRESHOLD|| target.getStaminaLoss() <= 100)
				back_to_hunt()
				return
			// target is stunned and nearby

			if(!(iscarbon(target) && target.canBeHandcuffed()))
				back_to_idle()
				return

			if(no_handcuffs) // should we not cuff?
				return

			if(currently_cuffing)
				return

			if(!target.handcuffed)
				cuff(target)
				return

			back_to_idle()

		if(BOT_ARREST) // Fun fact: This is not called
			if(!target || target.handcuffed)
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.stam_regen_start_time - world.time <= BOT_REBATON_THRESHOLD || target.getStaminaLoss() <= 100)) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			//Try arresting again if the target escapes.
			set_mode(BOT_PREP_ARREST)
			anchored = FALSE

		if(BOT_START_PATROL)
			if(find_new_target())
				return
			start_patrol()

		if(BOT_PATROL)
			if(find_new_target())
				return
			bot_patrol()

	return

/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	anchored = FALSE
	set_mode(BOT_IDLE)
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))

/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	anchored = FALSE
	frustration = 0
	set_mode(BOT_HUNT)
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/secbot/proc/find_new_target()
	anchored = FALSE
	for(var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 5 SECONDS))
			continue

		threatlevel = C.assess_threat(src)

		if(!threatlevel || threatlevel < 4)
			continue

		target = C
		oldtarget_name = C.name
		speak("Level [threatlevel] infraction alert!")
		playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, FALSE)
		visible_message("<b>[src]</b> points at [C.name]!")
		set_mode(BOT_HUNT)
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0


/mob/living/simple_animal/bot/secbot/explode()
	GLOB.move_manager.stop_looping(src)
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += "hs_hole"
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/melee/baton(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	..()

/mob/living/simple_animal/bot/secbot/attack_alien(mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		set_mode(BOT_HUNT)

/mob/living/simple_animal/bot/secbot/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(ismob(entered) && target)
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
		C.KnockDown(4 SECONDS)
		return

#undef BATON_COOLDOWN
#undef BOT_REBATON_THRESHOLD
