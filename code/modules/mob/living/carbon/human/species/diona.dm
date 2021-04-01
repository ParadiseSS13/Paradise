/datum/species/diona
	name = "Diona"
	name_plural = "Dionaea"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	language = "Rootspeak"
	speech_sounds = list('sound/voice/dionatalk1.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/diona
	remains_type = /obj/effect/decal/cleanable/ash
	total_health = 120
	speed_mod = 4
	punchdamagelow = 12
	punchdamagehigh = 14

	brute_mod = 0.75
	stamina_mod = 0.75
	burn_mod = 1.4
	heatmod = 1.6
	var/pod = FALSE //did they come from a pod? If so, they're stronger than normal Diona.

	blurb = "Commonly referred to (erroneously) as 'plant people', the Dionaea are a strange space-dwelling collective \
	species hailing from Epsilon Ursae Minoris. Each 'diona' is a cluster of numerous cat-sized organisms called nymphs; \
	there is no effective upper limit to the number that can fuse in gestalt, and reports exist	of the Epsilon Ursae \
	Minoris primary being ringed with a cloud of singing space-station-sized entities.<br/><br/>The Dionaea coexist peacefully with \
	all known species, especially the Skrell. Their communal mind makes them slow to react, and they have difficulty understanding \
	even the simplest concepts of other minds. Their alien physiology allows them survive happily off a diet of nothing but light, \
	water and other radiation."

	species_traits = list(NO_HAIR)
	inherent_traits = list(TRAIT_NOGERMS, TRAIT_NODECAY, TRAIT_NOPAIN)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	clothing_flags = HAS_SOCKS
	default_hair_colour = "#000000"
	has_gender = FALSE
	dietflags = DIET_HERB		//Diona regenerate nutrition in light and water, no diet necessary, but if they must, they eat other plants *scream
	taste_sensitivity = TASTE_SENSITIVITY_DULL
	skinned_type = /obj/item/stack/sheet/wood

	blood_color = "#004400"
	flesh_color = "#907E4A"
	butt_sprite = "diona"

	reagent_tag = PROCESS_ORG

	has_organ = list(
		"nutrient channel" =   /obj/item/organ/internal/liver/diona,
		"respiratory vacuoles" =   /obj/item/organ/internal/lungs/diona,
		"neural strata" =      /obj/item/organ/internal/heart/diona,
		"eyes"			 =      /obj/item/organ/internal/eyes/diona, //Default darksight of 2.
		"gas bladder" =        /obj/item/organ/internal/brain/diona,
		"polyp segment" =      /obj/item/organ/internal/kidneys/diona,
		"anchoring ligament" = /obj/item/organ/internal/appendix/diona
		)
	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/diona),
		"groin" =  list("path" = /obj/item/organ/external/groin/diona),
		"head" =   list("path" = /obj/item/organ/external/head/diona),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/diona),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/diona),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/diona),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/diona),
		"l_hand" = list("path" = /obj/item/organ/external/hand/diona),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/diona),
		"l_foot" = list("path" = /obj/item/organ/external/foot/diona),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/diona)
		)

	suicide_messages = list(
		"is losing branches!",
		"pulls out a secret stash of herbicide and takes a hearty swig!",
		"is pulling themselves apart!")

/datum/species/diona/can_understand(mob/other)
	if(istype(other, /mob/living/simple_animal/diona))
		return 1
	return 0

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	..()
	H.gender = NEUTER

/datum/species/diona/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.clear_alert("nolight")

/datum/species/diona/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "glyphosate" || R.id == "atrazine")
		H.adjustToxLoss(3) //Deal aditional damage
		return TRUE
	return ..()

/datum/species/diona/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	var/is_vamp = H.mind?.vampire != null
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /obj/screen/alert/nolight)

		if(!is_vamp)
			H.adjust_nutrition(light_amount * 10)
			if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
				H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)

		if(light_amount > 0.2 && !H.suiciding) //if there's enough light, heal
			if(!pod && H.health <= 0)
				return
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(!is_vamp && H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/diona/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	switch(P.type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.rad_act(rand(30, 80))
				H.Weaken(5)
				H.visible_message("<span class='warning'>[H] writhes in pain as [H.p_their()] vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(H)
					domutcheck(H)
				else
					randmutg(H)
					domutcheck(H)
			else
				H.adjustFireLoss(rand(5, 15))
				H.show_message("<span class='warning'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.set_nutrition(min(H.nutrition + 30, NUTRITION_LEVEL_FULL))
	return TRUE

/datum/species/diona/pod //Same name and everything; we want the same limitations on them; we just want their regeneration to kick in at all times and them to have special factions
	pod = TRUE

	inherent_factions = list("plants", "vines")

/datum/species/diona/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, mob/living/carbon/human/H, sharp = 0, obj/used_weapon = null)
	var/old_brute_mob = brute_mod
	if(sharp)
		brute_mod = 1
	..()
	brain_mod += old_brute_mob - 1
