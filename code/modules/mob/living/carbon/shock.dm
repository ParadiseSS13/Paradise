/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	src.traumatic_shock = 			\
	1	* src.getOxyLoss() + 		\
	1	* src.getToxLoss() + 		\
	1	* src.getFireLoss() + 		\
	1	* src.getBruteLoss() + 		\
	1	* src.getCloneLoss()

	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.shock_reduction)
				src.traumatic_shock -= R.shock_reduction // now you too can varedit cyanide to reduce shock by 1000 - Iamgoofball
	if(src.slurring)
		src.traumatic_shock -= 10

	// broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/obj/item/organ/external/organ in M.organs)
			if(!organ)
				continue
			else if(organ.status & ORGAN_BROKEN || organ.open)
				src.traumatic_shock += 15
				if(organ.status & ORGAN_SPLINTED)
					src.traumatic_shock -= 15

	if(src.traumatic_shock < 0)
		src.traumatic_shock = 0

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()
