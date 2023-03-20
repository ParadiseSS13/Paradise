/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	gender = PLURAL
	organ_tag = "ears"
	parent_organ = "head"
	slot = "ears"

	// `deaf` measures "ticks" of deafness. While > 0, the person is deaf.
	var/deaf = 0

	// `damage` measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `damage` decrease
	// without external aid (earmuffs, drugs)
	damage = 0

/obj/item/organ/internal/ears/on_life()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	// genetic deafness prevents the body from using the ears, even if healthy
	if(DEAF in C.mutations)
		deaf = max(deaf, 1)
	else
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if((H.l_ear && H.l_ear.flags_2 & HEALS_EARS_2) || (H.r_ear && H.r_ear.flags_2 & HEALS_EARS_2))
				deaf = max(deaf - 1, 1)
				damage = max(damage - 0.10, 0)
		// natural healing if not broken
		if(damage < min_broken_damage)
			damage = max(damage - 0.05, 0)
			deaf = max(deaf - 1, 0)

/obj/item/organ/internal/ears/proc/RestoreEars()
	deaf = 0
	damage = 0

	var/mob/living/carbon/C = owner
	if(istype(C) && (DEAF in C.mutations))
		deaf = 1

/obj/item/organ/internal/ears/proc/AdjustEarDamage(ddmg, ddeaf)
	damage = max(damage + ddmg, 0)
	deaf = max(deaf + ddeaf, 0)

/obj/item/organ/internal/ears/proc/MinimumDeafTicks(value)
	deaf = max(deaf, value)

/obj/item/organ/internal/ears/surgeryize()
	RestoreEars()

// Mob procs
/mob/living/carbon/RestoreEars()
	var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)
	if(ears)
		ears.RestoreEars()

/mob/living/carbon/AdjustEarDamage(ddmg, ddeaf)
	var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)
	if(ears)
		ears.AdjustEarDamage(ddmg, ddeaf)

/mob/living/carbon/MinimumDeafTicks(value)
	var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)
	if(ears)
		ears.MinimumDeafTicks(value)

/obj/item/organ/internal/ears/cybernetic
	name = "cybernetic ears"
	icon_state = "ears-c"
	desc = "a basic cybernetic designed to mimic the operation of ears."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT

/obj/item/organ/internal/ears/cybernetic/emp_act(severity)
	if(emp_proof)
		return
	..()
	AdjustEarDamage(30, 120)
