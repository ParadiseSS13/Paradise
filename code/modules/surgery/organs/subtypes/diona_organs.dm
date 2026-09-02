/obj/item/organ/external/chest/diona
	name = "core trunk"
	max_damage = 200
	min_broken_damage = 50
	amputation_point = "trunk"
	encased = null
	gendered_icon = FALSE
	convertable_children = list(/obj/item/organ/external/groin/diona)

/obj/item/organ/external/groin/diona
	name = "fork"
	min_broken_damage = 50
	amputation_point = "lower trunk"
	gendered_icon = FALSE

/obj/item/organ/external/arm/diona
	name = "left upper tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "upper left trunk"
	convertable_children = list(/obj/item/organ/external/hand/diona)

/obj/item/organ/external/arm/right/diona
	name = "right upper tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "upper right trunk"
	convertable_children = list(/obj/item/organ/external/hand/right/diona)

/obj/item/organ/external/leg/diona
	name = "left lower tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "lower left fork"
	convertable_children = list(/obj/item/organ/external/foot/diona)

/obj/item/organ/external/leg/right/diona
	name = "right lower tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "lower right fork"
	convertable_children = list(/obj/item/organ/external/foot/right/diona)

/obj/item/organ/external/foot/diona
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "branch"

/obj/item/organ/external/foot/right/diona
	max_damage = 20
	min_broken_damage = 10
	amputation_point = "branch"

/obj/item/organ/external/hand/diona
	name = "left grasper"
	amputation_point = "branch"

/obj/item/organ/external/hand/right/diona
	name = "right grasper"
	amputation_point = "branch"

/obj/item/organ/external/head/diona
	max_damage = 50
	min_broken_damage = 25
	encased = null
	amputation_point = "upper trunk"
	gendered_icon = FALSE

/obj/item/organ/diona/process()
	return

/// Turns into a nymph instantly, no transplanting possible.
/obj/item/organ/internal/heart/diona
	name = "circulatory siphonostele"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/lungs/diona
	name = "respiratory nodules"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/// Turns into a nymph instantly, no transplanting possible.
/obj/item/organ/internal/brain/diona
	name = "neural strata"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/// Turns into a nymph instantly, no transplanting possible.
/obj/item/organ/internal/kidneys/diona
	name = "sieve-tube bundles"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/// Turns into a nymph instantly, no transplanting possible.
/obj/item/organ/internal/appendix/diona
	name = "auxiliary bud"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/// Turns into a nymph instantly, no transplanting possible.
/obj/item/organ/internal/eyes/diona
	name = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

//TODO:Make absorb rads on insert

/// Turns into a nymph instantly, no transplanting possible.
/obj/item/organ/internal/liver/diona
	name = "nutrient sac"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	alcohol_intensity = 0.5
