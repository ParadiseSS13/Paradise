/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	gender = PLURAL
	organ_tag = "ears"
	parent_organ = "head"

/obj/item/organ/internal/ears/on_life()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner

	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(C, TRAIT_DEAF, EAR_DAMAGE))
		return

	if(status & ORGAN_DEAD)
		C.Deaf(2 SECONDS)
	else
		if((damage > 10) && prob(damage / 30))
			C.Deaf(8 SECONDS)
			SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))



/obj/item/organ/internal/ears/surgeryize()
	owner.SetDeaf(0)
	heal_internal_damage(100)

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
	damage += 40 / severity
