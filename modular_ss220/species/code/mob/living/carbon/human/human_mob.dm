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
