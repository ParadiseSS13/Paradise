/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/caution/proximity_sign
	var/timing = FALSE
	var/armed = FALSE
	var/timepassed = 0
	var/datum/proximity_monitor/proximity_monitor

/obj/item/caution/proximity_sign/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)

/obj/item/caution/proximity_sign/attack_self__legacy__attackchain(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.mind.has_antag_datum(/datum/antagonist/traitor) && !IS_MINDSLAVE(H))
			return
		if(armed)
			armed = FALSE
			to_chat(user, "<span class='notice'>You disarm \the [src].</span>")
			return
		timing = !timing
		if(timing)
			START_PROCESSING(SSobj, src)
		else
			armed = FALSE
			timepassed = 0
		to_chat(H, "<span class='notice'>You [timing ? "activate \the [src]'s timer, you have 15 seconds." : "de-activate \the [src]'s timer."]</span>")

/obj/item/caution/proximity_sign/process()
	if(!timing)
		STOP_PROCESSING(SSobj, src)
	timepassed++
	if(timepassed >= 15 && !armed)
		armed = TRUE
		timing = FALSE

/obj/item/caution/proximity_sign/HasProximity(atom/movable/AM)
	if(armed)
		if(iscarbon(AM) && !isbrain(AM))
			var/mob/living/carbon/C = AM
			if(C.m_intent != MOVE_INTENT_WALK)
				visible_message("[src] beeps, \"Sign says walk, asshole.\"")
				playsound(src, 'sound/misc/sign_says_walk.ogg', 40)
				explosion(src.loc,-1,0,2, cause = "Exploding wet floor sign")
				if(ishuman(C))
					dead_legs(C)
				if(src)
					qdel(src)

/obj/item/caution/proximity_sign/proc/dead_legs(mob/living/carbon/human/H as mob)
	var/obj/item/organ/external/l = H.get_organ("l_leg")
	var/obj/item/organ/external/r = H.get_organ("r_leg")
	if(l)
		l.droplimb(0, DROPLIMB_SHARP)
	if(r)
		r.droplimb(0, DROPLIMB_SHARP)

/obj/item/stack/caution/proximity_sign/malf //Malf module
	name = "proximity mine dispenser"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	energy_type = /datum/robot_storage/energy/jani_landmine
	is_cyborg = TRUE

/obj/item/stack/caution/proximity_sign/malf/afterattack__legacy__attackchain(atom/target, mob/user, proximity)
	if(!check_allowed_items(target, 1))
		return
	if(!proximity)
		return
	var/turf/T = get_turf(target)

	if(T.is_blocked_turf(exclude_mobs = TRUE)) //can't put mines on a tile that has dense stuff
		to_chat(user, "<span class='notice'>The space is occupied! You cannot place a mine there!</span>")
		return
	if(!use(1)) //Can't place a landmine if you don't have a landmine
		to_chat(user, "<span class='notice'>[src] is out of landmines! It can be refilled at a cyborg charger.</span>")
		return
	playsound(src.loc, 'sound/machines/click.ogg', 20, TRUE)
	var/obj/item/caution/proximity_sign/M = new /obj/item/caution/proximity_sign(get_turf(target), src)
	M.timing = TRUE
	START_PROCESSING(SSobj, M)
	to_chat(user, "<span class='notice'>You place a landmine with [src]. You have 15 seconds until it is armed.</span>")
	return M

