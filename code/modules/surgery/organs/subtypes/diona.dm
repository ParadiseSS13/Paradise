/obj/item/organ/external/chest/diona
	species_type = /datum/species/diona
	name = "core trunk"
	max_damage = 200
	min_broken_damage = 50
	amputation_point = "trunk"
	encased = null
	gendered_icon = 0

/obj/item/organ/external/groin/diona
	species_type = /datum/species/diona
	name = "fork"
	min_broken_damage = 50
	amputation_point = "lower trunk"
	gendered_icon = 0

/obj/item/organ/external/arm/diona
	species_type = /datum/species/diona
	name = "left upper tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "upper left trunk"

/obj/item/organ/external/arm/right/diona
	species_type = /datum/species/diona
	name = "right upper tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "upper right trunk"

/obj/item/organ/external/leg/diona
	species_type = /datum/species/diona
	name = "left lower tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "lower left fork"

/obj/item/organ/external/leg/right/diona
	species_type = /datum/species/diona
	name = "right lower tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "lower right fork"

/obj/item/organ/external/foot/diona
	species_type = /datum/species/diona
	name = "left foot"
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "branch"

/obj/item/organ/external/foot/right/diona
	species_type = /datum/species/diona
	name = "right foot"
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "branch"

/obj/item/organ/external/hand/diona
	species_type = /datum/species/diona
	name = "left grasper"
	amputation_point = "branch"

/obj/item/organ/external/hand/right/diona
	species_type = /datum/species/diona
	name = "right grasper"
	amputation_point = "branch"

/obj/item/organ/external/head/diona
	species_type = /datum/species/diona
	max_damage = 50
	min_broken_damage = 25
	encased = null
	amputation_point = "upper trunk"
	gendered_icon = 0

/obj/item/organ/diona/process()
	return

/obj/item/organ/internal/heart/diona // Turns into a nymph instantly, no transplanting possible.
	species_type = /datum/species/diona
	name = "neural strata"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/lungs/diona
	species_type = /datum/species/diona
	name = "respiratory vacuoles"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/brain/diona // Turns into a nymph instantly, no transplanting possible.
	species_type = /datum/species/diona
	name = "gas bladder"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/kidneys/diona // Turns into a nymph instantly, no transplanting possible.
	species_type = /datum/species/diona
	name = "polyp segment"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/appendix/diona // Turns into a nymph instantly, no transplanting possible.
	species_type = /datum/species/diona
	name = "anchoring ligament"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/eyes/diona // Turns into a nymph instantly, no transplanting possible.
	species_type = /datum/species/diona
	name = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

//TODO:Make absorb rads on insert

/obj/item/organ/internal/liver/diona // Turns into a nymph instantly, no transplanting possible.
	species_type = /datum/species/diona
	name = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	alcohol_intensity = 0.5
