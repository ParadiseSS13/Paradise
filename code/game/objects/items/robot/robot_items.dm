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
		if(H.check_shields(src, 0, "[M]'s [name]", MELEE_ATTACK))
			playsound(M, 'sound/weapons/genhit.ogg', 50, 1)
			return 0

	if(isrobot(user))
		if(!user.cell.use(charge_cost))
			return

	user.do_attack_animation(M)
	M.Weaken(10 SECONDS)
	M.apply_effect(STUTTER, 10 SECONDS)

	M.visible_message(span_danger("[user] has prodded [M] with [src]!"), \
					span_userdanger("[user] has prodded you with [src]!"))

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)
	add_attack_logs(user, M, "Stunned with [src] ([uppertext(user.a_intent)])")

#define CYBORG_HUGS 0
#define CYBORG_HUG 1
#define CYBORG_SHOCK 2
#define CYBORG_CRUSH 3

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = CYBORG_HUGS //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = FALSE //Can it be a stunarm when emagged. Only PK borgs get this by default.

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged && shockallowed)
			if(mode < CYBORG_CRUSH)
				mode++
			else
				mode = CYBORG_HUGS
		else if(mode < CYBORG_HUG)
			mode++
		else
			mode = CYBORG_HUGS
	switch(mode)
		if(CYBORG_HUGS)
			to_chat(user, "Power reset. Hugs!")
		if(CYBORG_HUG)
			to_chat(user, "Power increased!")
		if(CYBORG_SHOCK)
			to_chat(user, "BZZT. Electrifying arms...")
		if(CYBORG_CRUSH)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user, params)
	if(M == user)
		return
	switch(mode)
		if(CYBORG_HUGS)
			if(M.health >= 0)
				if(isanimal(M))
					var/list/modifiers = params2list(params)
					M.attack_hand(user, modifiers) //This enables borgs to get the floating heart icon and mob emote from simple_animal's that have petbonus == true.
					return
				if(user.zone_selected == BODY_ZONE_HEAD)
					user.visible_message(span_notice("[user] playfully boops [M] on the head!"), span_notice("You playfully boop [M] on the head!"))
					user.do_attack_animation(M, ATTACK_EFFECT_BOOP)
					playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
				else if(ishuman(M))
					if(M.resting)
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), span_notice("You shake [M] trying to get [M.p_them()] up!"))
						M.stand_up()
					else
						user.visible_message(span_notice("[user] hugs [M] to make [M.p_them()] feel better!"), span_notice("You hug [M] to make [M.p_them()] feel better!"))
				else
					user.visible_message(span_notice("[user] pets [M]!"), span_notice("You pet [M]!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if(CYBORG_HUG)
			if(M.health >= 0)
				if(ishuman(M))
					if(M.resting)
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), span_notice("You shake [M] trying to get [M.p_them()] up!"))
						M.resting = FALSE
						M.stand_up()
					else if(user.zone_selected == BODY_ZONE_HEAD)
						user.visible_message(span_warning("[user] bops [M] on the head!"), span_warning("You bop [M] on the head!"))
						user.do_attack_animation(M, ATTACK_EFFECT_PUNCH)
					else
						user.visible_message(span_warning("[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable..."), span_warning("You hug [M] firmly to make [M.p_them()] feel better! [M] looks uncomfortable..."))
				else
					user.visible_message(span_warning("[user] bops [M] on the head!"), span_warning("You bop [M] on the head!"))
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		if(CYBORG_SHOCK)
			if(scooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						M.electrocute_act(5, "[user]", flags = SHOCK_NOGLOVES)
						user.visible_message(span_userdanger("[user] electrocutes [M] with [user.p_their()] touch!"), span_danger("You electrocute [M] with your touch!"))
					else
						if(!isrobot(M))
							M.adjustFireLoss(10)
							user.visible_message(span_userdanger("[user] shocks [M]!"), span_danger("You shock [M]!"))
						else
							user.visible_message(span_userdanger("[user] shocks [M]. It does not seem to have an effect"), span_danger("You shock [M] to no effect."))
					playsound(loc, 'sound/effects/sparks2.ogg', 50, TRUE, -1)
					user.cell.use(500)
					scooldown = world.time + 20
		if(CYBORG_CRUSH)
			if(ccooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message(span_userdanger("[user] crushes [M] in [user.p_their()] grip!"), span_danger("You crush [M] in your grip!"))
					else
						user.visible_message(span_userdanger("[user] crushes [M]!"), span_danger("You crush [M]!"))
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
					M.adjustBruteLoss(15)
					user.cell.use(300)
					ccooldown = world.time + 10

#undef CYBORG_HUGS
#undef CYBORG_HUG
#undef CYBORG_SHOCK
#undef CYBORG_CRUSH

/obj/item/borg/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
