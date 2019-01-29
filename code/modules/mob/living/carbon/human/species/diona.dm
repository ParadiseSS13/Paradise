/datum/species/diona
	name = "Diona"
	name_plural = "Dionaea"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	speech_sounds = list('sound/voice/dionatalk1.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/diona
	//primitive_form = "Nymph"
	slowdown = 5
	remains_type = /obj/effect/decal/cleanable/ash


	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 300
	heat_level_2 = 340
	heat_level_3 = 400

	blurb = "Commonly referred to (erroneously) as 'plant people', the Dionaea are a strange space-dwelling collective \
	species hailing from Epsilon Ursae Minoris. Each 'diona' is a cluster of numerous cat-sized organisms called nymphs; \
	there is no effective upper limit to the number that can fuse in gestalt, and reports exist	of the Epsilon Ursae \
	Minoris primary being ringed with a cloud of singing space-station-sized entities.<br/><br/>The Dionaea coexist peacefully with \
	all known species, especially the Skrell. Their communal mind makes them slow to react, and they have difficulty understanding \
	even the simplest concepts of other minds. Their alien physiology allows them survive happily off a diet of nothing but light, \
	water and other radiation."

	species_traits = list(NO_BREATHE, RADIMMUNE, IS_PLANT, NO_BLOOD, NO_PAIN)
	clothing_flags = HAS_SOCKS
	default_hair_colour = "#000000"
	has_gender = FALSE
	dietflags = 0		//Diona regenerate nutrition in light and water, no diet necessary
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	skinned_type = /obj/item/stack/sheet/wood

	oxy_mod = 0

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not
	blood_color = "#004400"
	flesh_color = "#907E4A"
	butt_sprite = "diona"

	reagent_tag = PROCESS_ORG

	has_organ = list(
		"nutrient channel" =   /obj/item/organ/internal/liver/diona,
		"neural strata" =      /obj/item/organ/internal/heart/diona,
		"receptor node" =      /obj/item/organ/internal/eyes/diona, //Default darksight of 2.
		"gas bladder" =        /obj/item/organ/internal/brain/diona,
		"polyp segment" =      /obj/item/organ/internal/kidneys/diona,
		"anchoring ligament" = /obj/item/organ/internal/appendix/diona
		)

	vision_organ = /obj/item/organ/internal/eyes/diona
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

/datum/species/diona/handle_life(mob/living/carbon/human/H)
	H.radiation = Clamp(H.radiation, 0, 100) //We have to clamp this first, then decrease it, or there's a few edge cases of massive heals if we clamp and decrease at the same time.
	var/rads = H.radiation / 25
	H.radiation = max(H.radiation-rads, 0)
	H.nutrition = min(H.nutrition+rads, NUTRITION_LEVEL_WELL_FED+10)
	H.adjustBruteLoss(-(rads))
	H.adjustToxLoss(-(rads))

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(T.get_lumcount() * 10, 5)  //hardcapped so it's not abused by having a ton of flashlights
	H.nutrition = min(H.nutrition+light_amount, NUTRITION_LEVEL_WELL_FED+10)

	if(light_amount > 0)
		H.clear_alert("nolight")
	else
		H.throw_alert("nolight", /obj/screen/alert/nolight)

	if((light_amount >= 5) && !H.suiciding) //if there's enough light, heal

		H.adjustBruteLoss(-(light_amount/2))
		H.adjustFireLoss(-(light_amount/4))
	if(H.nutrition < NUTRITION_LEVEL_STARVING+50)
		H.take_overall_damage(10,0)
	..()
