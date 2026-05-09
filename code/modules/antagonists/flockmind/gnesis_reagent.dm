/datum/reagent/gnesis
	name = "coagulated gnesis"
	id = "gnesis_tox"
	description = "A thick teal fluid of alien origin. It moves in ways that suggest it might be alive in some way."
	color =  "#4d736d"
	taste_description = "oily, with a sweet aftertaste"
	metabolization_rate = 0.2
	/// The color of the light to give off
	var/light_color = "#26ffe6"
	/// Reagent -> Blood-replacement rate per 2 seconds
	var/conversion_rate = 1
	/// Amount of gnesis required to turn the victim into a flockbit
	var/flocksplosion_threshold = 200

/datum/reagent/gnesis/on_mob_life(mob/living/M)
	if(volume > 20) // 2.5 bursts of the turret
		if(!ismachineperson(M))
			M.blood_volume -= 0.4
		M.reagents.add_reagent("gnesis_tox", conversion_rate)

	if(volume > flocksplosion_threshold)
		new /mob/living/basic/flock/bit(get_turf(M))
		M.gib()
		return

	if(volume < flocksplosion_threshold / 2)
		M.set_light(0, 0, COLOR_WHITE)
		if(prob(5))
			M.playsound_local(get_turf(M), pick(list('sound/goonstation/flockmind/flockbit_wisp1.ogg',
													'sound/goonstation/flockmind/flockbit_wisp2.ogg',
													'sound/goonstation/flockmind/flockbit_wisp3.ogg',
													'sound/goonstation/flockmind/flockbit_wisp4.ogg',
													'sound/goonstation/flockmind/flockbit_wisp5.ogg',
													'sound/goonstation/flockmind/flockbit_wisp6.ogg')), 40, FALSE, use_reverb = FALSE)
		if(prob(2))
			to_chat(M, SPAN_FLOCKSAY("You feel your blood running cold."))
	else
		if(prob(2) && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.take_organ_damage(5)
		if(prob(10))
			M.playsound_local(get_turf(M), pick(list('sound/goonstation/flockmind/flockbit_wisp1.ogg',
													'sound/goonstation/flockmind/flockbit_wisp2.ogg',
													'sound/goonstation/flockmind/flockbit_wisp3.ogg',
													'sound/goonstation/flockmind/flockbit_wisp4.ogg',
													'sound/goonstation/flockmind/flockbit_wisp5.ogg',
													'sound/goonstation/flockmind/flockbit_wisp6.ogg')), 40, FALSE, use_reverb = FALSE)
		if(prob(15))
			M.set_light(2, 0.2, light_color)
		if(prob(5))
			to_chat(M, SPAN_FLOCKSAY("You feel like something wants to burst out of your body!"))


	var/list/do_not_convert = list("charcoal", "calomel", "pen_acid", "gnesis_tox")
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R.id in do_not_convert)
			continue
		M.reagents.remove_reagent(R.id, 0.4)
		M.reagents.add_reagent("gnesis_tox", 0.4)
	return ..()
