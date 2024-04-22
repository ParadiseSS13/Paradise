/datum/component/caltrop
	///Minimum damage when crossed
	var/min_damage

	///Maximum damage when crossed
	var/max_damage

	///Probability of stunning and doing daamge
	var/probability

	///Duration of weaken when crossed
	var/weaken_duration

	///Shoebypassing, walking interaction, silence
	var/flags

	var/cooldown = 0

/datum/component/caltrop/Initialize(_min_damage = 0, _max_damage = 0, _probability = 100, _weaken_duration = 6 SECONDS, _flags = NONE)
	src.min_damage = _min_damage
	src.max_damage = max(_min_damage, _max_damage)
	src.probability = _probability
	src.weaken_duration = _weaken_duration
	src.flags = _flags

/datum/component/caltrop/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, PROC_REF(Crossed))

/datum/component/caltrop/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent
	if(!has_gravity(A))
		return

	if(!prob(probability))
		return

	if(!ishuman(AM))
		return

	var/mob/living/carbon/human/H = AM

	if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
		return

	if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
		return

	var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/organ/external/O = H.get_organ(picked_def_zone)

	if(!istype(O))
		return

	if(O.is_robotic())
		return

	var/feet_cover = ((H?.wear_suit?.body_parts_covered & FEET)) || ((H?.w_uniform?.body_parts_covered & FEET))
	var/bypass_shoes = flags & CALTROP_BYPASS_SHOES

	// doesn't penetrate if feet are covered
	if(!bypass_shoes && (H.shoes || feet_cover))
		return

	// check if shoes or outer suit can be punctured
	if(bypass_shoes && ((H?.shoes?.flags & THICKMATERIAL) || (H?.wear_suit?.flags & THICKMATERIAL)))
		return

	if(H.flying || H.floating || H.buckled)
		return

	if(IS_HORIZONTAL(H) && HAS_TRAIT(H, TRAIT_CONTORTED_BODY))
		return TRUE

	var/damage = rand(min_damage, max_damage)
	H.apply_damage(damage, BRUTE, picked_def_zone)

	if(cooldown < world.time - 10) //cooldown to avoid message spam.
		if(!H.incapacitated(ignore_restraints = TRUE))
			H.visible_message("<span class='danger'>[H] steps on [A].</span>", "<span class='userdanger'>You step on [A]!</span>")
		else
			H.visible_message("<span class='danger'>[H] slides on [A]!</span>", "<span class='userdanger'>You slide on [A]!</span>")

		cooldown = world.time
	H.Weaken(weaken_duration)
