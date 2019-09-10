/datum/species/shadow
	name = "Shadow"
	name_plural = "Shadows"

	icobase = 'icons/mob/human_races/r_shadow.dmi'
	deform = 'icons/mob/human_races/r_shadow.dmi'
	dangerous_existence = TRUE

	unarmed_type = /datum/unarmed_attack/claws

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain,
		"eyes" = /obj/item/organ/internal/eyes/shadow //8 darksight.
		)

	species_traits = list(NO_BREATHE, NO_BLOOD, RADIMMUNE, VIRUSIMMUNE)
	dies_at_threshold = TRUE

	dietflags = DIET_OMNI		//the mutation process allowed you to now digest all foods regardless of initial race
	reagent_tag = PROCESS_ORG
	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is staring into the closest light source!")

	var/grant_vision_toggle = TRUE
	var/datum/action/innate/shadow/darkvision/vision_toggle

/datum/action/innate/shadow/darkvision //Darkvision toggle so shadowpeople can actually see where darkness is
	name = "Toggle Darkvision"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_default"
	button_icon_state = "blind"

/datum/action/innate/shadow/darkvision/Activate()
	var/mob/living/carbon/human/H = owner
	if(!H.vision_type)
		H.vision_type = new /datum/vision_override/nightvision
		to_chat(H, "<span class='notice'>You adjust your vision to pierce the darkness.</span>")
	else
		H.vision_type = null
		to_chat(H, "<span class='notice'>You adjust your vision to recognize the shadows.</span>")

/datum/species/shadow/on_species_gain(mob/living/carbon/human/H)
	..()
	if(grant_vision_toggle)
		vision_toggle = new
		vision_toggle.Grant(H)
	H.faction |= "faithless"

/datum/species/shadow/on_species_loss(mob/living/carbon/human/H)
	..()
	if(grant_vision_toggle && vision_toggle)
		H.vision_type = null
		vision_toggle.Remove(H)
	H.faction -= "faithless"

/datum/species/shadow/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10

		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
			H.throw_alert("lightexposure", /obj/screen/alert/lightexposure)
		else if(light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)
			H.clear_alert("lightexposure")
	..()