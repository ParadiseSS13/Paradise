/*/proc/spawn_diona_nymph_from_organ(var/obj/item/organ/organ)
	if(!istype(organ))
		return 0

	//This is a terrible hack and I should be ashamed.
	var/datum/seed/diona = plant_controller.seeds["diona"]
	if(!diona)
		return 0

	spawn(1) // So it has time to be thrown about by the gib() proc.
		var/mob/living/simple_animal/diona/D = new(get_turf(organ))
		var/datum/ghosttrap/plant/P = get_ghost_trap("living plant")
		P.request_player(D, "A diona nymph has split off from its gestalt. ")
		spawn(60)
			if(D)
				if(!D.ckey || !D.client)
					D.death()
		return 1 */

/obj/item/organ/external/chest/diona
	name = "core trunk"
	max_damage = 200
	min_broken_damage = 50
	cannot_break = 1
	amputation_point = "trunk"
	encased = null
	gendered_icon = 0

/obj/item/organ/external/groin/diona
	name = "fork"
	min_broken_damage = 50
	cannot_break = 1
	amputation_point = "lower trunk"
	gendered_icon = 0

/obj/item/organ/external/arm/diona
	name = "left upper tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "upper left trunk"

/obj/item/organ/external/arm/right/diona
	name = "right upper tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "upper right trunk"

/obj/item/organ/external/leg/diona
	name = "left lower tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "lower left fork"

/obj/item/organ/external/leg/right/diona
	name = "right lower tendril"
	max_damage = 35
	min_broken_damage = 20
	cannot_break = 1
	amputation_point = "lower right fork"

/obj/item/organ/external/foot/diona
	name = "left foot"
	max_damage = 20
	min_broken_damage = 10
	cannot_break = 1
	amputation_point = "branch"

/obj/item/organ/external/foot/right/diona
	name = "right foot"
	max_damage = 20
	min_broken_damage = 10
	cannot_break = 1
	amputation_point = "branch"

/obj/item/organ/external/hand/diona
	name = "left grasper"
	cannot_break = 1
	amputation_point = "branch"

/obj/item/organ/external/hand/right/diona
	name = "right grasper"
	cannot_break = 1
	amputation_point = "branch"

/obj/item/organ/external/head/diona
	max_damage = 50
	min_broken_damage = 25
	cannot_break = 1
	encased = null
	amputation_point = "upper trunk"
	gendered_icon = 0

//DIONA ORGANS.
/* /obj/item/organ/external/diona/removed()
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.organs || !H.organs.len)
		H.death()
	if(prob(50) && spawn_diona_nymph_from_organ(src))
		qdel(src) */

/obj/item/organ/diona/process()
	return

/obj/item/organ/internal/heart/diona
	name = "neural strata"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "heart" // Turns into a nymph instantly, no transplanting possible.
	origin_tech = "biotech=3"
	parent_organ = "chest"
	slot = "heart"

/obj/item/organ/internal/brain/diona
	name = "gas bladder"
	parent_organ = "head"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "brain" // Turns into a nymph instantly, no transplanting possible.
	origin_tech = "biotech=3"
	slot = "brain"

/obj/item/organ/internal/kidneys/diona
	name = "polyp segment"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "kidneys" // Turns into a nymph instantly, no transplanting possible.
	origin_tech = "biotech=3"
	parent_organ = "groin"
	slot = "kidneys"

/obj/item/organ/internal/appendix/diona
	name = "anchoring ligament"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "appendix" // Turns into a nymph instantly, no transplanting possible.
	origin_tech = "biotech=3"
	parent_organ = "groin"
	slot = "appendix"

/obj/item/organ/internal/diona_receptor
	name = "receptor node"
	organ_tag = "eyes"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	origin_tech = "biotech=3"
	parent_organ = "head"
	slot = "eyes"


/obj/item/organ/internal/diona_receptor/surgeryize()
	if(!owner)
		return
	owner.disabilities &= ~NEARSIGHTED
	owner.sdisabilities &= ~BLIND
	owner.eye_blurry = 0
	owner.eye_blind = 0


//TODO:Make absorb rads on insert

/obj/item/organ/internal/liver/diona
	name = "nutrient vessel"
	parent_organ = "chest"
	organ_tag = "liver"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	slot = "liver"
	alcohol_intensity = 0.5

//TODO:Make absorb light on insert.

/*/obj/item/organ/diona/removed(var/mob/living/user)
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.organs || !H.organs.len)
		H.death()
	if(prob(50) && spawn_diona_nymph_from_organ(src))
		qdel(src) */
