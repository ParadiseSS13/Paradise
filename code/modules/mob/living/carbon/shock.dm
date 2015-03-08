/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	src.traumatic_shock = 			\
	1	* src.getOxyLoss() + 		\
	1	* src.getToxLoss() + 		\
	1	* src.getFireLoss() + 		\
	1	* src.getBruteLoss() + 		\
	1	* src.getCloneLoss() + 		\
	1	* src.halloss

	if(reagents.has_reagent("alkysine"))
		src.traumatic_shock -= 5
	if(reagents.has_reagent("inaprovaline"))
		src.traumatic_shock -= 15
	if(reagents.has_reagent("synaptizine"))
		src.traumatic_shock -= 30
	if(reagents.has_reagent("paracetamol"))
		src.traumatic_shock -= 40
	if(reagents.has_reagent("tramadol"))
		src.traumatic_shock -= 60
	if(reagents.has_reagent("oxycodone"))
		src.traumatic_shock -= 200
	if(src.slurring)
		src.traumatic_shock -= 10
	if(src.analgesic)
		src.traumatic_shock = 0

	// broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/datum/organ/external/organ in M.organs)
			if (!organ)
				continue
			if((organ.status & ORGAN_DESTROYED) && !organ.amputated)
				src.traumatic_shock += 30
			else if(organ.status & ORGAN_BROKEN || organ.open)
				src.traumatic_shock += 15
				if(organ.status & ORGAN_SPLINTED)
					src.traumatic_shock -= 15

	if(src.traumatic_shock < 0)
		src.traumatic_shock = 0

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()
