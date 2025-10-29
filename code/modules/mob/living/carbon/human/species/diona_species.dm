/datum/species/diona
	name = "Diona"
	name_plural = "Dionaea"
	max_age = 300
	icobase = 'icons/mob/human_races/r_diona.dmi'
	language = "Rootspeak"
	speech_sounds = list('sound/voice/dionatalk1.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/diona
	remains_type = /obj/effect/decal/cleanable/ash

	heatmod = 3
	var/pod = FALSE //did they come from a pod? If so, they're stronger than normal Diona.

	blurb = "The Diona are plant-like creatures made up of a gestalt of smaller Nymphs. \
	Dionae lack any form of centralized government or homeworld, with most avoiding the affairs of the wider galaxy, preferring instead to focus on the spread of their species.<br/><br/> \
	As a gestalt entity, each nymph possesses an individual personality, yet they communicate collectively. \
	Consequently, Diona often speak in a unique blend of first and third person, using 'We' and 'I' to reflect their unified yet multifaceted nature."

	eyes = "blank_eyes"
	species_traits = list(NO_HAIR)
	inherent_traits = list(TRAIT_NOGERMS, TRAIT_NODECAY)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	clothing_flags = HAS_SOCKS
	default_hair_colour = "#000000"
	bodyflags = SHAVED
	dietflags = DIET_HERB		//Diona regenerate nutrition in light and water, no diet necessary, but if they must, they eat other plants *scream
	taste_sensitivity = TASTE_SENSITIVITY_DULL

	blood_color = "#004400"
	flesh_color = "#907E4A"
	butt_sprite = "diona"

	reagent_tag = PROCESS_ORG

	skinned_type = /obj/item/stack/sheet/wood
	meat_type = /obj/item/food/meat/human
	has_organ = list(
		"liver" =   /obj/item/organ/internal/liver/diona,
		"lungs" =   /obj/item/organ/internal/lungs/diona,
		"heart" =      /obj/item/organ/internal/heart/diona,
		"eyes"			 =      /obj/item/organ/internal/eyes/diona, //Default darksight of 2.
		"brain" =        /obj/item/organ/internal/brain/diona,
		"kidneys" =      /obj/item/organ/internal/kidneys/diona,
		"appendix" = /obj/item/organ/internal/appendix/diona
		)
	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/diona, "descriptor" = "core trunk"),
		"groin" =  list("path" = /obj/item/organ/external/groin/diona, "descriptor" = "fork"),
		"head" =   list("path" = /obj/item/organ/external/head/diona, "descriptor" = "head"),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/diona, "descriptor" = "left upper tendril"),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/diona, "descriptor" = "right upper tendril"),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/diona, "descriptor" = "left lower tendril"),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/diona, "descriptor" = "right lower tendril"),
		"l_hand" = list("path" = /obj/item/organ/external/hand/diona, "descriptor" = "left grasper"),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/diona, "descriptor" = "right grasper"),
		"l_foot" = list("path" = /obj/item/organ/external/foot/diona, "descriptor" = "left foot"),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/diona, "descriptor" = "right foot")
		)

	suicide_messages = list(
		"is losing branches!",
		"pulls out a secret stash of herbicide and takes a hearty swig!",
		"is pulling themselves apart!")

	plushie_type = /obj/item/toy/plushie/dionaplushie

/datum/species/diona/can_understand(mob/other)
	if(isnymph(other))
		return TRUE
	return FALSE

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	..()
	H.gender = NEUTER

/datum/species/diona/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.clear_alert("nolight")

	for(var/mob/living/basic/diona_nymph/N in H.contents) // Let nymphs wiggle out
		N.split()

/datum/species/diona/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "glyphosate" || R.id == "atrazine")
		H.adjustToxLoss(3) //Deal aditional damage
		return TRUE
	return ..()

/datum/species/diona/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	var/is_vamp = H.mind && H.mind.has_antag_datum(/datum/antagonist/vampire)
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /atom/movable/screen/alert/nolight)

		if(!is_vamp)
			H.adjust_nutrition(light_amount * 10)
			if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
				H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)

		if(light_amount > 0.2 && !H.suiciding) //if there's enough light, heal
			if(!pod && H.health <= 0)
				return
			H.adjustBruteLoss(-1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(!is_vamp && H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/diona/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H, def_zone)
	if(istype(P, /obj/item/projectile/energy/floramut))
		P.nodamage = TRUE
		H.Weaken(1 SECONDS)
		if(prob(80))
			randmutb(H)
		else
			randmutg(H)
		H.visible_message("[H] writhes for a moment as [H.p_their()] nymphs squirm and mutate.", "All of you squirm uncomfortably for a moment as you feel your genes changing.")
	else if(istype(P, /obj/item/projectile/energy/florayield))
		P.nodamage = TRUE
		var/obj/item/organ/external/organ = H.get_organ(check_zone(def_zone))
		if(!organ)
			organ = H.get_organ("chest")
		organ.heal_damage(5, 5)
		H.visible_message("[H] seems invogorated as [P] hits [H.p_their()] [organ.name].", "Your [organ.name] greedily absorbs [P].")
	return TRUE

/// Same name and everything; we want the same limitations on them; we just want their regeneration to kick in at all times and them to have special factions
/datum/species/diona/pod
	name = "Diomorph" //Seperate name needed else can't select diona period
	species_traits = list(NO_HAIR, NOT_SELECTABLE)
	pod = TRUE
	inherent_factions = list("plants", "vines")

/datum/species/diona/do_compressor_grind(mob/living/carbon/human/H)
	new /obj/item/food/salad(H.loc)
