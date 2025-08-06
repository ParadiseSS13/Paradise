/*
//////////////////////////////////////
Alopecia

	Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	transmissibility.
	Intense Level.

BONUS
	Makes the mob lose hair.

//////////////////////////////////////
*/

/datum/symptom/shedding

	name = "Alopecia"
	stealth = -1
	resistance = -1
	transmissibility = 2
	level = 4
	severity = 1

/datum/symptom/shedding/symptom_act(datum/disease/advance/A, unmitigated)
	if(!ishuman(A.affected_mob))
		return
	var/mob/living/carbon/human/H = A.affected_mob
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(!istype(head_organ))
		return
	to_chat(H, "<span class='warning'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>")
	if(NO_HAIR in H.dna.species.species_traits)
		return // Hair can't fall out if you don't have any
	switch(A.stage)
		if(3, 4)
			if(head_organ.h_style != "Bald" && head_organ.h_style != "Balding Hair")
				to_chat(H, "<span class='warning'>Your hair starts to fall out in clumps...</span>")
				addtimer(CALLBACK(src, PROC_REF(change_hair), H, head_organ, null, "Balding Hair"), 5 SECONDS)
		if(5)
			if((head_organ.f_style != "Shaved") || (head_organ.h_style != "Bald"))
				to_chat(H, "<span class='warning'>Your hair starts to fall out in clumps...</span>")
				addtimer(CALLBACK(src, PROC_REF(change_hair), H, head_organ, "Shaved", "Bald"), 5 SECONDS)

/datum/symptom/shedding/proc/change_hair(mob/living/carbon/human/H, obj/item/organ/external/head/head_organ, f_style, h_style)
	if(!H || !head_organ)
		return
	if(f_style)
		head_organ.f_style = f_style
		H.update_fhair()
	if(h_style)
		head_organ.h_style = h_style
		H.update_hair()
