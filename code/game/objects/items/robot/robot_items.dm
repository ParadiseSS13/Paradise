/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'

/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 30

/obj/item/borg/stun/attack(mob/living/M, mob/living/silicon/robot/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(0, "[M]'s [name]", src, MELEE_ATTACK))
			playsound(M, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0

	if(isrobot(user))
		if(!user.cell.use(charge_cost))
			return

	user.do_attack_animation(M)
	M.Weaken(5)
	M.apply_effect(STUTTER, 5)
	M.Stun(5)

	M.visible_message("<span class='danger'>[user] has prodded [M] with [src]!</span>", \
					"<span class='userdanger'>[user] has prodded you with [src]!</span>")

	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	add_logs(user, M, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

#define BORG_HUG 0
#define BORG_HUG_SUPER 1
#define BORG_HUG_SHOCK 2
#define BORG_HUG_CRUSH 3

/obj/item/borg/cyborghug
	name = "Hugging Module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = BORG_HUG //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = FALSE//Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged && shockallowed)
			if(mode < BORG_HUG_CRUSH)
				mode++
			else
				mode = BORG_HUG
		else if(mode < BORG_HUG_SUPER)
			mode++
		else
			mode = BORG_HUG
	switch(mode)
		if(BORG_HUG)
			to_chat(user, "<span class='notice'>Power reset. Hugs!</span>")
		if(BORG_HUG_SUPER)
			to_chat(user, "<span class='notice'>Power increased!</span>")
		if(BORG_HUG_SHOCK)
			to_chat(user, "<span class='warning'>BZZT. Electrifying arms...</span>")
		if(BORG_HUG_CRUSH)
			to_chat(user, "<span class='warning'>ERROR: ARM ACTUATORS OVERLOADED.</span>")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user)
	if(M == user)
		return
	switch(mode)
		if(BORG_HUG)
			if(M.health >= config.health_threshold_crit)
				if(user.zone_sel.selecting == "head")
					user.visible_message("<span class='notice'>[user] playfully boops [M] on the head!</span>", \
									"<span class='notice'>You playfully boop [M] on the head!</span>")
					user.do_attack_animation(M)
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
				else if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get \him up!</span>", \
										"<span class='notice'>You shake [M] trying to get \him up!</span>")
					else
						user.visible_message("<span class='notice'>[user] hugs [M] to make \him feel better!</span>", \
								"<span class='notice'>You hug [M] to make \him feel better!</span>")
					if(M.resting)
						M.resting = FALSE
						M.update_canmove()
				else
					user.visible_message("<span class='notice'>[user] pets [M]!</span>", \
							"<span class='notice'>You pet [M]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(BORG_HUG_SUPER)
			if(M.health >= config.health_threshold_crit)
				if(ishuman(M))
					if(M.lying)
						user.visible_message("<span class='notice'>[user] shakes [M] trying to get \him up!</span>", \
										"<span class='notice'>You shake [M] trying to get \him up!</span>")
					else if(user.zone_sel.selecting == "head")
						user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
										"<span class='warning'>You bop [M] on the head!</span>")
						user.do_attack_animation(M)
					else
						user.visible_message("<span class='warning'>[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable...</span>", \
								"<span class='warning'>You hug [M] firmly to make \him feel better! [M] looks uncomfortable...</span>")
					if(M.resting)
						M.resting = FALSE
						M.update_canmove()
				else
					user.visible_message("<span class='warning'>[user] bops [M] on the head!</span>", \
							"<span class='warning'>You bop [M] on the head!</span>")
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		if(BORG_HUG_SHOCK)
			if(!scooldown)
				if(M.health >= config.health_threshold_crit)
					if(ishuman(M))
						M.electrocute_act(5, "[user]", safety = 1)
						user.visible_message("<span class='userdanger'>[user] electrocutes [M] with their touch!</span>", \
							"<span class='danger'>You electrocute [M] with your touch!</span>")
						M.update_canmove()
					else
						if(!isrobot(M))
							M.adjustFireLoss(10)
							user.visible_message("<span class='userdanger'>[user] shocks [M]!</span>", \
								"<span class='danger'>You shock [M]!</span>")
						else
							user.visible_message("<span class='userdanger'>[user] shocks [M]. It does not seem to have an effect</span>", \
								"<span class='danger'>You shock [M] to no effect.</span>")
					playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, -1)
					user.cell.charge -= 500
					scooldown = TRUE
					spawn(20)
						scooldown = FALSE
		if(BORG_HUG_CRUSH)
			if(!ccooldown)
				if(M.health >= config.health_threshold_crit)
					if(ishuman(M))
						user.visible_message("<span class='userdanger'>[user] crushes [M] in their grip!</span>", \
							"<span class='danger'>You crush [M] in your grip!</span>")
					else
						user.visible_message("<span class='userdanger'>[user] crushes [M]!</span>", \
								"<span class='danger'>You crush [M]!</span>")
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1, -1)
					M.adjustBruteLoss(15)
					user.cell.charge -= 300
					ccooldown = TRUE
					spawn(10)
						ccooldown = FALSE

#undef BORG_HUG
#undef BORG_HUG_SUPER
#undef BORG_HUG_SHOCK
#undef BORG_HUG_CRUSH

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/device/harmalarm
	name = "Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH"
	icon_state = "megaphone"
	var/cooldown = 0
	var/emagged = FALSE

/obj/item/device/harmalarm/emag_act(mob/user)
	emagged = !emagged
	if(emagged)
		to_chat(user, "<span class='warning'>You short out the safeties on the [src]!</span>")
	else
		to_chat(user, "<span class='warning'>You reset the safeties on the [src]!</span>")

/obj/item/device/harmalarm/attack_self(mob/user)
	var/safety = !emagged
	if(cooldown > world.time)
		to_chat(user, "<span class='warning'>The device is still recharging!</span>")
		return

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.charge < 1200)
			to_chat(user, "<span class='warning'>You don't have enough charge to do this!</span>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE

	if(safety)
		user.visible_message("<span class='danger'>[user] blares out a near-deafening siren from its speakers!</span>")
		for(var/mob/living/carbon/M in get_mobs_in_view(9, user))
			if(!M.check_ear_prot())
				M.AdjustConfused(6)
				to_chat(M, "<span class='userdanger'>The siren pierces your hearing!</span>")
		audible_message("<span class='biggerdanger'>HUMAN HARM</span>")
		playsound(get_turf(src), 'sound/AI/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		log_game("[key_name(user)] used a Cyborg Harm Alarm in ([user.x],[user.y],[user.z])")
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><span class='notice'>NOTICE - Peacekeeping 'HARM ALARM' used by: [user]</span><br>")

		return

	user.audible_message("<span class='biggerdanger'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</span>")
	for(var/mob/living/carbon/human/H in get_mobs_in_view(9, user))
		if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs) || H.ear_deaf)
			continue
		var/earsafety = FALSE
		if(H.check_ear_prot())
			earsafety = TRUE

		if(earsafety)
			H.AdjustConfused(5)
			H.AdjustStuttering(10)
			H.Jitter(10)
		else
			H.Weaken(2)
			H.AdjustConfused(10)
			H.AdjustStuttering(15)
			H.Jitter(25)

	playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
	cooldown = world.time + 600
	log_game("[key_name(user)] used an emagged Cyborg Harm Alarm in ([user.x],[user.y],[user.z])")
