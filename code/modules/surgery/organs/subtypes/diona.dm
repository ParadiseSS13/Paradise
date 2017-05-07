/obj/item/organ/external/chest/diona
	name = "core trunk"
	max_damage = 200
	min_broken_damage = 50
	cannot_break = 1
	amputation_point = "trunk"
	encased = null
	gendered_icon = 0
	species = "Diona"

/obj/item/organ/external/groin/diona
	name = "fork"
	min_broken_damage = 50
	cannot_break = 1
	amputation_point = "lower trunk"
	gendered_icon = 0
	species = "Diona"

/obj/item/organ/external/arm/diona
	name = "left upper tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "upper left trunk"
	species = "Diona"

/obj/item/organ/external/arm/right/diona
	name = "right upper tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "upper right trunk"
	species = "Diona"

/obj/item/organ/external/leg/diona
	name = "left lower tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "lower left fork"
	species = "Diona"

/obj/item/organ/external/leg/right/diona
	name = "right lower tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "lower right fork"
	species = "Diona"

/obj/item/organ/external/foot/diona
	name = "left foot"
	max_damage = 20
	min_broken_damage = 10
	cannot_break = 1
	amputation_point = "branch"
	species = "Diona"

/obj/item/organ/external/foot/right/diona
	name = "right foot"
	max_damage = 20
	min_broken_damage = 10
	cannot_break = 1
	amputation_point = "branch"
	species = "Diona"

/obj/item/organ/external/hand/diona
	name = "left grasper"
	cannot_break = 1
	amputation_point = "branch"
	species = "Diona"

/obj/item/organ/external/hand/right/diona
	name = "right grasper"
	cannot_break = 1
	amputation_point = "branch"
	species = "Diona"

/obj/item/organ/external/head/diona
	max_damage = 50
	min_broken_damage = 25
	cannot_break = 1
	encased = null
	amputation_point = "upper trunk"
	gendered_icon = 0
	species = "Diona"

//DIONA ORGANS.
/* /obj/item/organ/external/diona/removed()
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.bodyparts || !H.bodyparts.len)
		H.death()
	if(prob(50) && spawn_diona_nymph_from_organ(src))
		qdel(src) */

/obj/item/organ/diona/process()
	return

/obj/item/organ/internal/heart/diona // Turns into a nymph instantly, no transplanting possible.
	name = "neural strata"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	species = "Diona"

/obj/item/organ/internal/brain/diona // Turns into a nymph instantly, no transplanting possible.
	name = "gas bladder"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	species = "Diona"

/obj/item/organ/internal/kidneys/diona // Turns into a nymph instantly, no transplanting possible.
	name = "polyp segment"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	species = "Diona"

/obj/item/organ/internal/appendix/diona // Turns into a nymph instantly, no transplanting possible.
	name = "anchoring ligament"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	species = "Diona"

/obj/item/organ/internal/eyes/diona // Turns into a nymph instantly, no transplanting possible.
	name = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	species = "Diona"

//TODO:Make absorb rads on insert

/obj/item/organ/internal/liver/diona // Turns into a nymph instantly, no transplanting possible.
	name = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	alcohol_intensity = 0.5
	species = "Diona"

//TODO:Make absorb light on insert.

/*/obj/item/organ/diona/removed(var/mob/living/user)
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.bodyparts || !H.bodyparts.len)
		H.death()
	if(prob(50) && spawn_diona_nymph_from_organ(src))
		qdel(src) */
