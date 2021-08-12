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
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/internal/ears/on_life()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	if(ear_damage < 100)
		AdjustEarDamage(-0.1)

	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(C, TRAIT_DEAF, EAR_DAMAGE))
		return

	if(ear_damage >= 100)
		deaf = max(deaf, 1) // if we're failing we always have at least 1 deaf stack (and thus deafness)
	else
		deaf = max(deaf - 1, 0)
		if((ear_damage > 10) && prob(ear_damage / 30))
			AdjustEarDamage(0, 4)
			SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

	if(deaf)
		ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)


/obj/item/organ/internal/ears/proc/RestoreEars()
	deaf = 0
	ear_damage = 0

/obj/item/organ/internal/ears/proc/AdjustEarDamage(ddmg, ddeaf)
	ear_damage = clamp(ear_damage + (ddmg * damage_multiplier), 0, 100)
	deaf = max(deaf + (ddeaf * damage_multiplier), 0)

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

/obj/item/organ/internal/ears/cybernetic
	name = "cybernetic ears"
	icon_state = "ears-c"
	desc = "a basic cybernetic designed to mimic the operation of ears."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	damage_multiplier = 0.9

/obj/item/organ/internal/ears/cybernetic/emp_act(severity)
	if(emp_proof)
		return
	..()
	ear_damage += 40 / severity
