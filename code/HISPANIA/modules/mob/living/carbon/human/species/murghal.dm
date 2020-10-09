/datum/species/murghal
	name = "Murghal"
	name_plural = "Murghal"
	language = "Yakar"
	icobase = 'icons/hispania/mob/human_races/r_murghal.dmi'
	deform = 'icons/hispania/mob/human_races/r_def_murghal.dmi'
	unarmed_type = /datum/unarmed_attack/claws

	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG

	blood_color = "#213d99"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/murghal,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
		"gland" = /obj/item/organ/internal/adrenal/murghal
	)
	allowed_consumed_mobs = list(/mob/living/simple_animal/hostile/poison/terror_spider)
