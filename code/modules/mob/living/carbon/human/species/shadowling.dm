/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"

	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_shadowling.dmi'
	blacklisted = TRUE

	blood_color = "#555555"
	flesh_color = "#222222"

	species_traits = list(NO_BLOOD, NO_BREATHE, RADIMMUNE, NOGUNS, NO_HUNGER, NO_EXAMINE) //Can't use guns due to muzzle flash
	burn_mod = 1.5 //1.5x burn damage, 2x is excessive
	heatmod = 1.5

	silent_steps = 1
	grant_vision_toggle = 0

	has_organ = list(
		"brain" =    /obj/item/organ/internal/brain,
		"eyes" =     /obj/item/organ/internal/eyes)

/datum/species/shadow/ling/handle_life(mob/living/carbon/human/H)
	if(!H.weakeyes)
		H.weakeyes = 1 //Makes them more vulnerable to flashes and flashbangs
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move) //Can survive in very small light levels. Also doesn't take damage while incorporeal, for shadow walk purposes
			H.throw_alert("lightexposure", /obj/screen/alert/lightexposure)
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			if(H.stat != DEAD)
				to_chat(H, "<span class='userdanger'>The light burns you!</span>")//Message spam to say "GET THE FUCK OUT"
				H << 'sound/weapons/sear.ogg'
		else if(light_amount < LIGHT_HEAL_THRESHOLD)
			H.clear_alert("lightexposure")
			var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.receive_damage(-1)
			H.heal_overall_damage(5, 5)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25) //Shad O. Ling gibbers, "CAN U BE MY THRALL?!!"
			H.AdjustEyeBlurry(-1)
			H.CureNearsighted()
			H.CureBlind()
			H.adjustCloneLoss(-1)
			H.SetWeakened(0)
			H.SetStunned(0)
	..()


/datum/species/shadow/ling/lesser //Empowered thralls. Obvious, but powerful
	name = "Lesser Shadowling"

	icobase = 'icons/mob/human_races/r_lshadowling.dmi'
	deform = 'icons/mob/human_races/r_lshadowling.dmi'

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"

	species_traits = list(NO_BLOOD, NO_BREATHE, RADIMMUNE, NO_HUNGER, NO_EXAMINE)
	burn_mod = 1.1
	heatmod = 1.1

/datum/species/shadow/ling/lesser/handle_life(mob/living/carbon/human/H)
	if(!H.weakeyes)
		H.weakeyes = 1 //Makes them more vulnerable to flashes and flashbangs
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move)
			H.throw_alert("lightexposure", /obj/screen/alert/lightexposure)
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN/2)
		else if(light_amount < LIGHT_HEAL_THRESHOLD)
			H.clear_alert("lightexposure")
			H.heal_overall_damage(2,2)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25)
			H.adjustCloneLoss(-1)
	..()
