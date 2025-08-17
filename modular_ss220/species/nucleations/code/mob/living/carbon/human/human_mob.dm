/mob/living/carbon/human/vox/Initialize(mapload)
	. = ..(mapload, /datum/species/vox)
	faction |= list("Vox")

/mob/living/carbon/human/nucleation/Initialize(mapload)
	. = ..(mapload, /datum/species/nucleation)

// Питание от радиации
/mob/living/carbon/human/nucleation/rad_act(amount)
	. = ..()
	if(amount)
		nutrition = min(NUTRITION_LEVEL_FAT, nutrition + round(amount / 10))

/mob/living/carbon/human/serpentid/Initialize(mapload)
	. = ..(mapload, /datum/species/serpentid)

/mob/living/carbon/human/human_doll
	icon = 'icons/mob/human_races/r_human.dmi'
	icon_state = "preview"

/mob/living/carbon/human/human_doll/Initialize(mapload)
	. = ..(mapload, /datum/species/human_doll)
