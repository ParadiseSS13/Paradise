/datum/component/caltrop
	var/min_damage
	var/max_damage
	var/probability
	var/flags

	var/cooldown = 0

/datum/component/caltrop/Initialize(_min_damage = 0, _max_damage = 0, _probability = 100,  _flags = NONE)
	min_damage = _min_damage
	max_damage = max(_min_damage, _max_damage)
	probability = _probability
	flags = _flags

	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), PROC_REF(Crossed))

/datum/component/caltrop/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent
	if(!has_gravity(A))
		return

	if(!prob(probability))
		return

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			return

		if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
			return

		var/picked_def_zone
		if(flags & CALTROP_SAFE_VERTICAL)
			picked_def_zone = pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
		else
			picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/organ/external/O = H.get_organ(picked_def_zone)
		if(!istype(O))
			return
		if(O.is_robotic())
			return

		var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

		if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
			return

		if(H.flying || H.floating || H.buckled)
			return

		var/damage = rand(min_damage, max_damage)

		H.apply_damage(damage, BRUTE, picked_def_zone)

		if(cooldown < world.time - 10) //cooldown to avoid message spam.
			if(!H.incapacitated(ignore_restraints = TRUE))
				H.visible_message("<span class='danger'>[H] steps on [A].</span>", "<span class='userdanger'>You step on [A]!</span>")
			else
				H.visible_message("<span class='danger'>[H] slides on [A]!</span>", "<span class='userdanger'>You slide on [A]!</span>")

			cooldown = world.time
		if(flags & CALTROP_SAFE_VERTICAL)
			if(!IS_HORIZONTAL(H))
				return
			else
				H.apply_damage(30, BRUTE, spread_damage = TRUE)
				A.atom_say("Hobo detected, activating anti-hobo measures")
		H.Weaken(6 SECONDS)
