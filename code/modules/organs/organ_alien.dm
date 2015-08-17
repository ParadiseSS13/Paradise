/*
/proc/spawn_diona_nymph_from_organ(var/obj/item/organ/organ)
	if(!istype(organ))
		return

	//This is a terrible hack and I should be ashamed.
	var/datum/seed/diona = plant_controller.seeds["diona"]
	if(!diona)
		del(src)

	spawn(1) // So it has time to be thrown about by the gib() proc.
		var/mob/living/simple_animal/diona/D = new(get_turf(organ))
		diona.request_player(D)
		del(organ)
*/

/obj/item/organ/external/diona
	name = "tendril"
	cannot_break = 1
	amputation_point = "branch"

/obj/item/organ/external/diona/chest
	name = "core trunk"
	limb_name = "chest"
	icon_name = "torso"
	health = 200
	min_broken_damage = 50
	body_part = UPPER_TORSO
	vital = 1
	cannot_amputate = 1
	parent_organ = null

/obj/item/organ/external/diona/groin
	name = "fork"
	limb_name = "groin"
	icon_name = "groin"
	health = 100
	min_broken_damage = 50
	body_part = LOWER_TORSO
	vital = 1
	parent_organ = "chest"

/obj/item/organ/external/diona/arm
	name = "left upper tendril"
	limb_name = "l_arm"
	icon_name = "l_arm"
	health = 35
	min_broken_damage = 20
	body_part = ARM_LEFT
	parent_organ = "chest"
	can_grasp = 1

/obj/item/organ/external/diona/arm/right
	name = "right upper tendril"
	limb_name = "r_arm"
	icon_name = "r_arm"
	body_part = ARM_RIGHT

/obj/item/organ/external/diona/leg
	name = "left lower tendril"
	limb_name = "l_leg"
	icon_name = "l_leg"
	health = 35
	min_broken_damage = 20
	body_part = LEG_LEFT
	icon_position = LEFT
	parent_organ = "groin"
	can_stand = 1

/obj/item/organ/external/diona/leg/right
	name = "right lower tendril"
	limb_name = "r_leg"
	icon_name = "r_leg"
	body_part = LEG_RIGHT
	icon_position = RIGHT

/obj/item/organ/external/diona/foot
	name = "left foot"
	limb_name = "l_foot"
	icon_name = "l_foot"
	health = 20
	min_broken_damage = 10
	body_part = FOOT_LEFT
	icon_position = LEFT
	parent_organ = "l_leg"
	can_stand = 1

/obj/item/organ/external/diona/foot/right
	name = "right foot"
	limb_name = "r_foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ = "r_leg"
	amputation_point = "right ankle"

/obj/item/organ/external/diona/hand
	name = "left grasper"
	limb_name = "l_hand"
	icon_name = "l_hand"
	health = 30
	min_broken_damage = 15
	body_part = HAND_LEFT
	parent_organ = "l_arm"
	can_grasp = 1

/obj/item/organ/external/diona/hand/right
	name = "right grasper"
	limb_name = "r_hand"
	icon_name = "r_hand"
	body_part = HAND_RIGHT
	parent_organ = "r_arm"

/obj/item/organ/external/diona/head
	limb_name = "head"
	icon_name = "head"
	name = "head"
	health = 50
	min_broken_damage = 25
	body_part = HEAD
	vital = 1
	parent_organ = "chest"

/obj/item/organ/external/diona/head/removed()
	if(owner)
		owner.unEquip(owner.head)
		owner.unEquip(owner.l_ear)
	..()

/*
//DIONA ORGANS.
/obj/item/organ/external/diona/removed()
	..()
	if(!istype(owner))
		del(src)

	if(!owner.organs.len)
		owner.death()

	if(prob(50))
		spawn_diona_nymph_from_organ(src)
*/
/obj/item/organ/diona/process()
	return

/obj/item/organ/diona/strata
	name = "neural strata"
	parent_organ = "chest"

/obj/item/organ/diona/bladder
	name = "gas bladder"
	parent_organ = "head"

/obj/item/organ/diona/polyp
	name = "polyp segment"
	parent_organ = "groin"

/obj/item/organ/diona/ligament
	name = "anchoring ligament"
	parent_organ = "groin"

/obj/item/organ/diona/node
	name = "receptor node"
	parent_organ = "head"

/obj/item/organ/diona/nutrients
	name = "nutrient vessel"
	parent_organ = "chest"

/obj/item/organ/diona
	name = "diona nymph"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "special" // Turns into a nymph instantly, no transplanting possible.
/*
/obj/item/organ/diona/removed(var/mob/living/user)

	..()
	if(!istype(owner))
		del(src)

	if(!owner.internal_organs.len)
		owner.death()

	spawn_diona_nymph_from_organ(src)
*/
// These are different to the standard diona organs as they have a purpose in other
// species (absorbing radiation and light respectively)
/obj/item/organ/diona/nutrients
	name = "nutrient vessel"
	organ_tag = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/diona/nutrients/removed()
	return

/obj/item/organ/diona/node
	name = "receptor node"
	organ_tag = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/diona/node/removed()
	return

//CORTICAL BORER ORGANS.
/obj/item/organ/borer
	name = "cortical borer"
	parent_organ = "head"
	vital = 1

/obj/item/organ/borer/process()

	// Borer husks regenerate health, feel no pain, and are resistant to stuns and brainloss.
	for(var/chem in list("saline", "sailcylic", "meth", "mannitol"))
		if(owner.reagents.get_reagent_amount(chem) < 3)
			owner.reagents.add_reagent(chem, 5)

	// They're also super gross and ooze ichor.
	if(prob(5))
		var/mob/living/carbon/human/H = owner
		if(!istype(H))
			return

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in H.vessel.reagent_list
		blood_splatter(H,B,1)
		var/obj/effect/decal/cleanable/blood/splatter/goo = locate() in get_turf(owner)
		if(goo)
			goo.name = "husk ichor"
			goo.desc = "It's thick and stinks of decay."
			goo.basecolor = "#412464"
			goo.update_icon()

/obj/item/organ/borer
	name = "cortical borer"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borer"
	organ_tag = "brain"
	desc = "A disgusting space slug."

/obj/item/organ/borer/removed(var/mob/living/user)

	..()

	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	if(B)
		B.leave_host()
		B.ckey = owner.ckey

	spawn(0)
		qdel(src)

//XENOMORPH ORGANS
/obj/item/organ/xenos/eggsac
	name = "egg sac"
	parent_organ = "groin"

/obj/item/organ/xenos/plasmavessel
	name = "plasma vessel"
	parent_organ = "chest"
	var/stored_plasma = 0
	var/max_plasma = 500

/obj/item/organ/xenos/plasmavessel/queen
	name = "bloated plasma vessel"
	stored_plasma = 200
	max_plasma = 500

/obj/item/organ/xenos/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/obj/item/organ/xenos/plasmavessel/hunter
	name = "tiny plasma vessel"
	stored_plasma = 100
	max_plasma = 150

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	parent_organ = "head"

/obj/item/organ/xenos/hivenode
	name = "hive node"
	parent_organ = "chest"

/obj/item/organ/xenos/resinspinner
	name = "resin spinner"
	parent_organ = "head"

/obj/item/organ/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."

/obj/item/organ/xenos/eggsac
	name = "egg sac"
	icon_state = "xgibmid1"
	organ_tag = "egg sac"

/obj/item/organ/xenos/plasmavessel
	name = "plasma vessel"
	icon_state = "xgibdown1"
	organ_tag = "plasma vessel"

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	icon_state = "xgibtorso"
	organ_tag = "acid gland"

/obj/item/organ/xenos/hivenode
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "hive node"

/obj/item/organ/xenos/resinspinner
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "resin spinner"

//VOX ORGANS.
/obj/item/organ/stack
	name = "cortical stack"
	icon_state = "brain-prosthetic"
	parent_organ = "head"
	organ_tag = "stack"
	robotic = 2
	vital = 1
	var/backup_time = 0
	var/datum/mind/backup

/obj/item/organ/stack/process()
	if(owner && owner.stat != 2 && !is_broken())
		backup_time = world.time
		if(owner.mind) backup = owner.mind

/obj/item/organ/stack/vox
	name = "vox cortical stack"

/obj/item/organ/stack/vox/stack


//WRYN ORGAN

/obj/item/organ/wryn/hivenode
	name = "antennae"
	parent_organ = "head"

/obj/item/organ/wryn/hivenode
	name = "antennae"
	organ_tag = "antennae"
	icon = 'icons/mob/human_races/r_wryn.dmi'
	icon_state = "antennae"


//NUCLEATION ORGAN

/obj/item/organ/nucleation
	name = "nucleation organ"
	icon = 'icons/obj/surgery.dmi'
	desc = "A crystalized human organ. /red It has a strangely iridescent glow."

/obj/item/organ/nucleation/resonant_crystal
	name = "resonant crystal"
	icon_state = "resonant-crystal"
	organ_tag = "resonant crystal"
	parent_organ = "head"

/obj/item/organ/nucleation/strange_crystal
	name = "strange crystal"
	icon_state = "strange-crystal"
	organ_tag = "strange crystal"
	parent_organ = "chest"

/obj/item/organ/eyes/luminescent_crystal
	name = "luminescent eyes"
	icon_state = "crystal-eyes"
	organ_tag = "luminescent eyes"
	light_color = "#1C1C00"
	parent_organ = "head"

	New()
		set_light(2)

/obj/item/organ/brain/crystal
	name = "crystalized brain"
	icon_state = "crystal-brain"
	organ_tag = "crystalized brain"