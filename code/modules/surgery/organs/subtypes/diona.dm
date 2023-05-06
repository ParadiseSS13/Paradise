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
	convertable_children = list(/obj/item/organ/external/hand/diona)

/obj/item/organ/external/arm/right/diona
	species_type = /datum/species/diona
	name = "right upper tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "upper right trunk"
	convertable_children = list(/obj/item/organ/external/hand/right/diona)

/obj/item/organ/external/leg/diona
	species_type = /datum/species/diona
	name = "left lower tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "lower left fork"
	convertable_children = list(/obj/item/organ/external/foot/diona)

/obj/item/organ/external/leg/right/diona
	species_type = /datum/species/diona
	name = "right lower tendril"
	max_damage = 35
	min_broken_damage = 20
	amputation_point = "lower right fork"
	convertable_children = list(/obj/item/organ/external/foot/right/diona)

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

/obj/item/organ/internal/brain/diona
	species_type = /datum/species/diona
	name = "neural strata"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	dead_icon = null
	parent_organ = "chest"
	actions_types = list(/datum/action/item_action/organ_action/diona_brain_evacuation)

/datum/action/item_action/organ_action/diona_brain_evacuation
	name = "Evacuation"
	check_flags = 0
	desc = "Leave body as a nymph."

/datum/action/item_action/organ_action/diona_brain_evacuation/IsAvailable()
	. = ..()
	if((!owner.mind) || owner.mind.suicided)
		return FALSE


/datum/action/item_action/organ_action/diona_brain_evacuation/Trigger()
	. = ..()
	var/confirm = alert("Вы уверены, что хотите покинуть свое тело как нимфа? (!Если использовать, пока живы, то лишитесь роли антагониста!)","Confirm evacuation","Yes","No")
	if(confirm == "No")
		return

	if(. && istype(target, /obj/item/organ/internal/brain/diona))
		var/is_dead = owner.is_dead()
		if(is_dead || do_after(owner, 1 MINUTES, target = owner))
			var/obj/item/organ/internal/brain/diona/brain = target
			var/loc = owner.loc
			var/datum/mind/mind = owner.mind
			if(!is_dead)
				mind.remove_all_antag_roles(FALSE)
				log_and_message_admins("diona-evacuated into nymph and lost all possible antag roles.")
			brain.remove(owner)

			for(var/mob/living/simple_animal/diona/nymph in get_turf(loc))
				var/throw_dir = pick(GLOB.alldirs)
				var/throwtarget = get_edge_target_turf(nymph, throw_dir)
				nymph.throw_at(throwtarget, 3, 1, owner)

/obj/item/organ/internal/kidneys/diona
	species_type = /datum/species/diona
	name = "filtrating vacuoles"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/lungs/diona
	species_type = /datum/species/diona
	name = "gas bladder"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/appendix/diona
	species_type = /datum/species/diona
	name = "polyp segment"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"

/obj/item/organ/internal/heart/diona
	species_type = /datum/species/diona
	name = "anchoring ligament"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	parent_organ = "groin"

/obj/item/organ/internal/heart/diona/update_icon()
	return

/obj/item/organ/internal/eyes/diona
	species_type = /datum/species/diona
	name = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	parent_organ = "chest"

/obj/item/organ/internal/liver/diona
	species_type = /datum/species/diona
	name = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	alcohol_intensity = 0.5

/obj/item/organ/internal/ears/diona
	species_type = /datum/species/diona
	name = "oscillatory catcher"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	desc = "A strange organic object used by a Gestalt for orientation in a three-dimensional projection."
	parent_organ = "groin"

/datum/component/diona_internals

/datum/component/diona_internals/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(istype(parent, /obj/item/organ/internal))
		RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(transform_organ))

/datum/component/diona_internals/proc/transform_organ()
	if(is_int_organ(parent))
		var/obj/item/organ/internal/organ = parent
		var/mob/living/simple_animal/diona/nymph = new /mob/living/simple_animal/diona(get_turf(organ.owner))
		nymph.health = round(clamp(1 - organ.damage / organ.min_broken_damage, 0, 1) * nymph.maxHealth)

		if(istype(organ, /obj/item/organ/internal/brain))
			var/obj/item/organ/internal/brain/brain = organ
			if(brain.brainmob)
				nymph.random_name = FALSE
				nymph.real_name = brain.brainmob.real_name
				nymph.name = brain.brainmob.real_name
				var/datum/mind/mind = brain.brainmob.mind
				mind.transfer_to(nymph)

		qdel(organ)


