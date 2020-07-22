/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	gender = PLURAL
	organ_tag = "ears"
	parent_organ = "head"
	slot = "ears"

	// `deaf` measures "ticks" of deafness. While > 0, the person is deaf.
	var/deaf = 0

	// `ear_damage` measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)
	var/ear_damage = 0

/obj/item/organ/internal/ears/on_life()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	// genetic deafness prevents the body from using the ears, even if healthy
	if(C.disabilities & DEAF)
		deaf = max(deaf, 1)
	else
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if((H.l_ear && H.l_ear.flags_2 & HEALS_EARS_2) || (H.r_ear && H.r_ear.flags_2 & HEALS_EARS_2))
				deaf = max(deaf - 1, 1)
				ear_damage = max(ear_damage - 0.10, 0)
		// if higher than UNHEALING_EAR_DAMAGE, no natural healing occurs.
		if(ear_damage < UNHEALING_EAR_DAMAGE)
			ear_damage = max(ear_damage - 0.05, 0)
			deaf = max(deaf - 1, 0)

/obj/item/organ/internal/ears/proc/RestoreEars()
	deaf = 0
	ear_damage = 0
	
	var/mob/living/carbon/C = owner
	if(istype(C) && C.disabilities & DEAF)
		deaf = 1

/obj/item/organ/internal/ears/proc/AdjustEarDamage(ddmg, ddeaf)
	ear_damage = max(ear_damage + ddmg, 0)
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

