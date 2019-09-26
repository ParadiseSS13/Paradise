/datum/species/diona
	name = "Diona"
	name_plural = "Dionaea"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	speech_sounds = list('sound/voice/dionatalk1.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/diona
	remains_type = /obj/effect/decal/cleanable/ash

	burn_mod = 1.25
	heatmod = 1.5
	var/pod = FALSE //did they come from a pod? If so, they're stronger than normal Diona.
	var/reproduce = FALSE // Can be toggled by an ability. If true, the diona will plant a diona nymph pod when clicking with an empty hand on an empty hydroponics tray and take brute damage.
	var/datum/action/innate/reproduction/repro

	blurb = "Commonly referred to (erroneously) as 'plant people', the Dionaea are a strange collective species hailing from Epsilon Ursae \
	Minoris. Each 'diona' is a cluster of numerous cat-sized organisms called nymphs; there is no effective upper limit to the \
	number that can fuse in gestalt, and reports exist	of the Epsilon Ursae Minoris primary being ringed with a cloud of singing \
	space-station-sized entities.<br/><br/> The Dionaea coexist peacefully with all known species, especially the Skrell. Due to their communal mind they have difficulty \
	understanding even the simplest concepts of other minds. Their alien physiology allows them to survive happily off a diet of \
	nothing but light after their initial growth cycles have passed. They are capable of reproducing themselves under the correct \
	growing conditions, provided water and nutrients are available."

	species_traits = list(IS_PLANT, NO_GERMS, NO_DECAY)
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

// Only roundstart and arriving dionaea should have had time to prepare a seed pod. 
// Terrarium and Pod dionaea will likely have access to botany and won't need this ability. 
/datum/species/diona/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	repro = new
	repro.Grant(H)

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	..()
	H.gender = NEUTER

/datum/species/diona/on_species_loss(mob/living/carbon/human/H)
	..()
	if(repro)
		repro.Remove(H)

/datum/species/diona/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "glyphosate" || R.id == "atrazine")
		H.adjustToxLoss(3) //Deal aditional damage
		return TRUE
	return ..()

/datum/action/innate/reproduction
	name = "Reproduce"
	desc = "Produce a Diona Nymph seed pod within your gestalt, ready to plant in an available growing spot. Producing these pods is very slow; you only have one available."
	icon_icon = 'icons/obj/hydroponics/harvest.dmi'
	button_icon_state = "mushy"

/datum/action/innate/reproduction/Activate()
	var/mob/living/carbon/human/user = owner
	var/datum/species/diona/D = user.dna.species
	if (D.reproduce)
		to_chat(user, "<span class='notice'>You absorb the prepared seeds back into your gestalt.</span>")
		D.reproduce = FALSE
	else
		to_chat(user, "<span class='notice'>You prepare a small part of your gestalt for reproduction. Now to find somewhere to plant it.</span>")
		D.reproduce = TRUE

/datum/species/diona/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /obj/screen/alert/nolight)
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

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/diona/pod //Same name and everything; we want the same limitations on them; we just want their regeneration to kick in at all times and them to have special factions
	pod = TRUE

/datum/species/diona/pod/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "plants"
	C.faction |= "vines"

/datum/species/diona/pod/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "plants"
	C.faction -= "vines"