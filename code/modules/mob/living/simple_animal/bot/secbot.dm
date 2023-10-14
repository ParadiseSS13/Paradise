#define BATON_COOLDOWN 3.5 SECONDS

/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	density = FALSE
	anchored = FALSE
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
	var/weaponscheck = FALSE //If true, arrest people for weapons if they lack access
	var/check_records = TRUE //Does it check security records?
	var/arrest_type = FALSE //If true, don't handcuff
	var/harmbaton = FALSE //If true, beat instead of stun
	var/flashing_lights = FALSE //If true, flash lights
	var/baton_delayed = FALSE
	var/prev_flashing_lights = FALSE
	allow_pai = FALSE

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey."
	idcheck = FALSE
	weaponscheck = FALSE
	auto_patrol = TRUE

/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/turf/Tsec = get_turf(src)
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/S = new(Tsec)
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
	idcheck = FALSE
	weaponscheck = TRUE
	auto_patrol = TRUE

/mob/living/simple_animal/bot/secbot/buzzsky
	name = "Officer Buzzsky"
	desc = "It's Officer Buzzsky! Rusted and falling apart, he seems less than thrilled with the crew for leaving him in his current state."
	base_icon = "rustbot"
	icon_state = "rustbot0"
	declare_arrests = FALSE
	arrest_type = TRUE
	harmbaton = TRUE
	emagged = 2

/mob/living/simple_animal/bot/secbot/armsky
	name = "Sergeant-at-Armsky"
	health = 100
	maxHealth = 100
	idcheck = TRUE
	arrest_type = TRUE
	weaponscheck = TRUE

/mob/living/simple_animal/bot/secbot/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon][on]"

	var/datum/job/detective/J = new/datum/job/detective
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/secbot/turn_on()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = FALSE
	walk_to(src,0)
	set_path(null)
	last_found = world.time

/mob/living/simple_animal/bot/secbot/set_custom_texts()
	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/secbot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/secbot/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BotSecurity", name, 500, 500)
		ui.open()

/mob/living/simple_animal/bot/secbot/ui_data(mob/user)
	var/list/data = ..()
	data["check_id"] = idcheck
	data["check_weapons"] = weaponscheck
	data["check_warrant"] = check_records
	data["arrest_mode"] = arrest_type // detain or arrest
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
			weaponscheck = !weaponscheck
		if("authid")
			idcheck = !idcheck
		if("authwarrant")
			check_records = !check_records
		if("arrtype")
			arrest_type = !arrest_type
		if("arrdeclare")
			declare_arrests = !declare_arrests
		if("ejectpai")
			ejectpai()

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = H.assess_threat(src)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM || H.a_intent == INTENT_DISARM)
		retaliate(H)
	return ..()

/mob/living/simple_animal/bot/secbot/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weldingtool) && user.a_intent != INTENT_HARM) // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(!isscrewdriver(W) && !locked && (W.force) && (!target) && (W.damtype != STAMINA))//If the target is locked, they are recieving damage from the screwdriver
		retaliate(user)

/mob/living/simple_animal/bot/secbot/emag_act(mob/user)
	..()
	if(emagged == 2)
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
		if((!C.IsWeakened() || arrest_type) && !baton_delayed)
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
	mode = BOT_ARREST
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
	C.visible_message("<span class='danger'>[src] is trying to put zipties on [C]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	INVOKE_ASYNC(src, PROC_REF(cuff_callback), C)

/mob/living/simple_animal/bot/secbot/proc/cuff_callback(mob/living/carbon/C)
	if(do_after(src, 60, target = C))
		if(!C.handcuffed && on)
			C.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(C)
			C.update_handcuffed()
			playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
			back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/C)
	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)
	if(harmbaton)
		playsound(loc, 'sound/weapons/genhit1.ogg', 50, 1, -1)
	do_attack_animation(C)
	icon_state = "[base_icon]-c"
	addtimer(VARSET_CALLBACK(src, icon_state, "[base_icon][on]"), 2)
	var/threat = C.assess_threat(src)
	if(ishuman(C) && harmbaton) // Bots with harmbaton enabled become shitcurity. - Dave
		C.apply_damage(10, BRUTE)
	C.SetStuttering(10 SECONDS)
	C.adjustStaminaLoss(60)
	baton_delayed = TRUE
	C.apply_status_effect(STATUS_EFFECT_DELAYED, 2.5 SECONDS, CALLBACK(C, TYPE_PROC_REF(/mob/living/, KnockDown), 10 SECONDS), COMSIG_LIVING_CLEAR_STUNS)
	addtimer(VARSET_CALLBACK(src, baton_delayed, FALSE), BATON_COOLDOWN)
	add_attack_logs(src, C, "batoned")
	if(declare_arrests)
		var/area/location = get_area(src)
		speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)
	C.visible_message("<span class='danger'>[src] has [harmbaton ? "beaten" : "stunned"] [C]!</span>",\
							"<span class='userdanger'>[src] has [harmbaton ? "beaten" : "stunned"] you!</span>")

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
	set src = usr

	flashing_lights = !flashing_lights

/mob/living/simple_animal/bot/secbot/handle_automated_action()
	if(!..())
		return

	flashing_lights = mode == BOT_HUNT

	switch(mode)
		if(BOT_IDLE)		// idle
			walk_to(src,0)
			set_path(null)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				walk_to(src,0)
				set_path(null)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc) && !baton_delayed)	// if right next to perp
					stun_attack(target)

					mode = BOT_PREP_ARREST
					anchored = TRUE
					target_lastloc = target.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target,1,4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_PREP_ARREST)		// preparing to arrest target
			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if(!Adjacent(target) || !isturf(target.loc) || world.time - target.stam_regen_start_time < 4 SECONDS && target.getStaminaLoss() <= 100)
				back_to_hunt()
				return

			if(iscarbon(target) && target.canBeHandcuffed())
				if(!arrest_type)
					if(!target.handcuffed)  //he's not cuffed? Try to cuff him!
						cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(BOT_ARREST)
			if(!target)
				anchored = FALSE
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.AmountWeakened() < 4 SECONDS)) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else //Try arresting again if the target escapes.
				mode = BOT_PREP_ARREST
				anchored = FALSE

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	anchored = FALSE
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))

/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	anchored = FALSE
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/secbot/proc/look_for_perp()
	anchored = FALSE
	for(var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(src)

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
			break
		else
			continue
/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0


/mob/living/simple_animal/bot/secbot/explode()
	walk_to(src,0)
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
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/Crossed(atom/movable/AM, oldloc)
	if(ismob(AM) && target)
		var/mob/living/carbon/C = AM
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
	..()

#undef BATON_COOLDOWN
