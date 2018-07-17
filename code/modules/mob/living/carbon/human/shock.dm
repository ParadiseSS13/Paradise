/mob/living/carbon/human/var/traumatic_shock = 0
/mob/living/carbon/human/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/human/proc/updateshock()
	traumatic_shock = getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss()

	// broken or ripped off organs will add quite a bit of pain
	for(var/thing in bodyparts)
		var/obj/item/organ/external/BP = thing
		if(BP.status & ORGAN_BROKEN && !(BP.status & ORGAN_SPLINTED) || BP.open)
			traumatic_shock += 15

	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.shock_reduction)
				traumatic_shock = max(0, traumatic_shock - R.shock_reduction) // now you too can varedit cyanide to reduce shock by 1000 - Iamgoofball
	if(drunk)
		traumatic_shock = max(0, traumatic_shock - 10)

	return traumatic_shock

/mob/living/carbon/human/proc/handle_shock()
	if(status_flags & GODMODE) //godmode
		return
	if(NO_PAIN in dna.species.species_traits)
		return

	updateshock()

	if(health <= config.health_threshold_softcrit)// health 0 makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 100)
		shock_stage += 1
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage-1, 0)
		return

	if(shock_stage == 10)
		to_chat(src, "<font color='red'><b>"+pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!"))

	if(shock_stage >= 30)
		if(shock_stage == 30)
			custom_emote(1,"is having trouble keeping [p_their()] eyes open.")
		EyeBlurry(2)
		Stuttering(5)

	if(shock_stage == 40)
		to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))

	if(shock_stage >=60)
		if(shock_stage == 60)
			custom_emote(1,"falls limp.")
		if(prob(2))
			to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))
			Weaken(20)

	if(shock_stage >= 80)
		if(prob(5))
			to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))
			Weaken(20)

	if(shock_stage >= 120)
		if(prob(2))
			to_chat(src, "<font color='red'><b>"+pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness."))
			Paralyse(5)

	if(shock_stage == 150)
		custom_emote(1,"can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)