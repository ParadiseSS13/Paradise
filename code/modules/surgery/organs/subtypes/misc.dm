//CORTICAL BORER ORGANS.
/obj/item/organ/internal/borer
	name = "cortical borer"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borer"
	parent_organ = "head"
	organ_tag = "brain"
	slot = "borer"
	vital = 1

/obj/item/organ/internal/borer/process()

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

/obj/item/organ/internal/borer/remove(var/mob/living/user)

	..()

	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	if(B)
		B.leave_host()
		B.ckey = owner.ckey

	spawn(0)
		qdel(src)
	return null

//VOX ORGANS.
/obj/item/organ/internal/stack
	name = "cortical stack"
	icon_state = "brain-prosthetic"
	parent_organ = "head"
	organ_tag = "stack"
	slot = "vox_stack"
	robotic = 2
	vital = 1
	var/backup_time = 0
	var/datum/mind/backup

/obj/item/organ/internal/stack/process()
	if(owner && owner.stat != 2 && !is_broken())
		backup_time = world.time
		if(owner.mind) backup = owner.mind

/obj/item/organ/internal/stack/vox
	name = "vox cortical stack"

/obj/item/organ/internal/stack/vox/stack
