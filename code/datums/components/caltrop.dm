/datum/component/caltrop
	///Minimum damage when crossed
	var/min_damage

	///Maximum damage when crossed
	var/max_damage

	///Probability of stunning and doing daamge
	var/probability

	///Duration of weaken when crossed
	var/weaken_duration // TODO: this is going to break without default probably

	///Shoebypassing, walking interaction, silence
	var/flags

	///TODO: soundfile?

	var/cooldown = 0

/datum/component/caltrop/Initialize(min_damage = 0, max_damage = 0, probability = 100, weaken_duration = 6 SECONDS, flags = NONE)
	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.flags = flags
	src.weaken_duration = weaken_duration

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

	var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))
	if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
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
