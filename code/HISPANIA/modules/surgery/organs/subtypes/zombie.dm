/obj/item/organ/internal/brain/zombie
	name = "brain"

/obj/item/organ/internal/brain/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/internal/eyes/zombie
	name = "strange eyeballs"
	colourmatrix = MATRIX_GREYSCALE
	replace_colours = LIST_GREYSCALE_REPLACE

/obj/item/organ/internal/eyes/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/internal/heart/zombie
	name = "heart"
	status = ORGAN_DEAD

/obj/item/organ/internal/heart/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/internal/lungs/zombie
	name = "lungs"
	status = ORGAN_DEAD

/obj/item/organ/internal/lungs/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/internal/liver/zombie
	name = "liver"
	status = ORGAN_DEAD

/obj/item/organ/internal/liver/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/internal/kidneys/zombie
	name = "kidneys"
	status = ORGAN_DEAD

/obj/item/organ/internal/kidneys/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/internal/appendix/zombie
	name = "appendix"
	status = ORGAN_DEAD

/obj/item/organ/internal/appendix/zombie/insert(mob/living/carbon/M, special = 0)
	..()
	M.reagents.add_reagent("virush", 5)

/obj/item/organ/external/chest/zombie
	cannot_break = 1

/obj/item/organ/external/groin/zombie
	cannot_break = 1

/obj/item/organ/external/arm/zombie
	cannot_break = 1

/obj/item/organ/external/arm/right/zombie
	cannot_break = 1

/obj/item/organ/external/leg/zombie
	cannot_break = 1

/obj/item/organ/external/leg/right/zombie
	cannot_break = 1

/obj/item/organ/external/foot/zombie
	cannot_break = 1

/obj/item/organ/external/foot/right/zombie
	cannot_break = 1

/obj/item/organ/external/hand/zombie
	cannot_break = 1
	status = ORGAN_BROKEN

/obj/item/organ/external/hand/right/zombie
	cannot_break = 1
	status = ORGAN_BROKEN

/obj/item/organ/external/head/zombie
	cannot_break = 1
