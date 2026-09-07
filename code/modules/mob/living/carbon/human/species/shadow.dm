/datum/species/shadow
	name = "Shadow"
	name_plural = "Shadows"

	icobase = 'icons/mob/human_races/r_shadow.dmi'
	dangerous_existence = TRUE
	inherent_factions = list("faithless")

	unarmed_type = /datum/unarmed_attack/claws

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"
	meat_type = /obj/item/food/meat/human
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain,
		"eyes" = /obj/item/organ/internal/eyes/night_vision/nightmare //8 darksight.
		)

	species_traits = list(NO_BLOOD, NOT_SELECTABLE)
	inherent_traits = list(TRAIT_VIRUSIMMUNE, TRAIT_NOBREATH, TRAIT_RADIMMUNE)
	dies_at_threshold = TRUE

	dietflags = DIET_OMNI		//the mutation process allowed you to now digest all foods regardless of initial race
	reagent_tag = PROCESS_ORG
	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is staring into the closest light source!")

/datum/species/shadow/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10

		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1, 1)
			H.throw_alert("lightexposure", /atom/movable/screen/alert/lightexposure)
		else if(light_amount < 2) //heal in the dark
			H.heal_overall_damage(1, 1)
			H.clear_alert("lightexposure")
	else	//we're inside an object, so darkness
		H.clear_alert("lightexposure")
		H.heal_overall_damage(1, 1)
	..()
