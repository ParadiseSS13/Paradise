/mob/living/carbon/human/proc/update_eyes()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		eyes.update_colour()
		update_body()

/mob/living/carbon/human/var/list/bodyparts = list()
/mob/living/carbon/human/var/list/bodyparts_by_name = list() // map organ names to organs

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/handle_organs()
	..()
	//processing internal organs is pretty cheap, do that first.
	for(var/X in internal_organs)
		var/obj/item/organ/internal/I = X
		I.process()

	for(var/Y in bodyparts)
		var/obj/item/organ/external/E = Y
		E.process()

		if(!IS_HORIZONTAL(src) && world.time - l_move_time < 15)
		//Moving around with fractured ribs won't do you any good
			if(E.is_broken() && E.internal_organs && E.internal_organs.len && prob(15))
				var/obj/item/organ/internal/I = pick(E.internal_organs)
				E.custom_pain("You feel broken bones moving in your [E.name]!")
				I.receive_damage(rand(3, 5))
			if((E.status & ORGAN_BURNT) && !(E.status & ORGAN_SALVED))
				E.custom_pain("You feel the skin sloughing off the burn on your [E.name]!")
				E.germ_level++


	//handle_stance()
	handle_grasp()
	handle_stance()


/mob/living/carbon/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if(!stance_damage && IS_HORIZONTAL(src) && (life_tick % 4) == 0)
		return

	stance_damage = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	// Not standing, so no need to care about stance
	if(istype(buckled, /obj/structure/chair) || !isturf(loc))
		return

	for(var/limb_tag in list("l_leg","r_leg","l_foot","r_foot"))
		var/obj/item/organ/external/E = bodyparts_by_name[limb_tag]
		if(!E || (E.status & ORGAN_DEAD) || E.is_malfunctioning() || !E.properly_attached)
			if(E && !E.properly_attached && life_tick % 24 == 0)
				to_chat(src, "<span class='danger'>Your [E] is hanging on by a thread! You need someone to surgically attach it for you!</span>")
			// let it fail even if just foot&leg. Also malfunctioning happens sporadically so it should impact more when it procs.
			// Also, if you haven't gotten your leg properly attached surgically, you're not gonna have a good time trying to walk.
			stance_damage += 2
		else if(E.is_broken() || !E.is_usable())
			stance_damage += 1

	// Canes and crutches help you stand
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs, canes aren't gonna help you. Get some crutches instead.
	if(l_hand)
		stance_damage -= l_hand.get_crutch_efficiency()
	if(r_hand)
		stance_damage -= r_hand.get_crutch_efficiency()

	if(stance_damage < 0)
		stance_damage = 0

	// standing is poor
	if(stance_damage >= 8)
		if(!IS_HORIZONTAL(src))
			if(!HAS_TRAIT(src, TRAIT_NOPAIN))
				emote("scream")
			emote("collapses")
		KnockDown(10 SECONDS)


/mob/living/carbon/human/proc/handle_grasp()

	if(!l_hand && !r_hand)
		return

	for(var/obj/item/organ/external/E in bodyparts)
		if(!E || !E.can_grasp || (E.status & ORGAN_SPLINTED))
			continue


		if(E.is_broken() || !E.properly_attached)
			if((E.body_part == HAND_LEFT) || (E.body_part == ARM_LEFT))
				if(!l_hand)
					continue
				if(!unEquip(l_hand))
					continue
			else
				if(!r_hand)
					continue
				if(!unEquip(r_hand))
					continue

			if(!E.properly_attached)
				visible_message(
					"<span class='warning'>[src]'s [E.name] seems to be hanging loosely from [p_their()] wrist, completely fumbling what [p_they()] [p_were()] holding!</span>",
					"<span class='userdanger'>You feel pain shoot through your [E.name] as it dangles limply from your [E.amputation_point], you need to get it surgically attached before you can hold anything with it!</span>"
				)

				return

			var/emote_scream = pick("screams in pain and ", "lets out a sharp cry and ", "cries out and ")
			custom_emote(EMOTE_VISIBLE, "[HAS_TRAIT(src, TRAIT_NOPAIN) ? "" : emote_scream ]drops what [p_they()] [p_were()] holding in [p_their()] [E.name]!")

		else if(E.is_malfunctioning())

			if((E.body_part == HAND_LEFT) || (E.body_part == ARM_LEFT))
				if(!l_hand)
					continue
				if(!unEquip(l_hand))
					continue
			else
				if(!r_hand)
					continue
				if(!unEquip(r_hand))
					continue

			custom_emote(EMOTE_VISIBLE, "drops what [p_they()] [p_were()] holding, [p_their()] [E.name] malfunctioning!")

			do_sparks(5, 0, src)

/mob/living/carbon/human/handle_germs()
	..()
	if(gloves && germ_level > gloves.germ_level && prob(10))
		gloves.germ_level += 1

/mob/living/carbon/human/proc/becomeSlim()
	to_chat(src, "<span class='notice'>You feel fit again!</span>")
	REMOVE_TRAIT(src, TRAIT_FAT, OBESITY)

/mob/living/carbon/human/proc/becomeFat()
	to_chat(src, "<span class='alert'>You suddenly feel blubbery!</span>")
	ADD_TRAIT(src, TRAIT_FAT, OBESITY)

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/obj/item/organ/internal/O = pick(bodyparts)
		O.trace_chemicals[A.name] = 100

/*
When assimilate is 1, organs that have a different UE will still have their DNA overriden by that of the host
Otherwise, this restricts itself to organs that share the UE of the host.

old_ue: Set this to a UE string, and this proc will overwrite the dna of organs that have that UE, instead of the host's present UE
*/
/mob/living/carbon/human/proc/sync_organ_dna(assimilate = 1, old_ue = null)
	var/ue_to_compare = (old_ue) ? old_ue : dna.unique_enzymes
	var/list/all_bits = internal_organs|bodyparts
	for(var/obj/item/organ/O in all_bits)
		if(assimilate || O.dna.unique_enzymes == ue_to_compare)
			O.set_dna(dna)

/*
Given the name of an organ, returns the external organ it's contained in
I use this to standardize shadowling dethrall code
-- Crazylemon
*/
/mob/living/carbon/human/proc/named_organ_parent(organ_name)
	if(!get_int_organ_tag(organ_name))
		return null
	var/obj/item/organ/internal/O = get_int_organ_tag(organ_name)
	return O.parent_organ

/mob/living/carbon/human/has_organic_damage()
	var/robo_damage = 0
	var/perma_injury_damage = 0
	for(var/obj/item/organ/external/E in bodyparts)
		if(E.is_robotic())
			robo_damage += E.brute_dam
			robo_damage += E.burn_dam
		if(E.perma_injury > (E.brute_dam + E.burn_dam))
			perma_injury_damage += E.perma_injury - (E.brute_dam + E.burn_dam)
	return health < maxHealth - robo_damage - perma_injury_damage

/mob/living/carbon/human/proc/handle_splints() //proc that rebuilds the list of splints on this person, for ease of processing
	splinted_limbs.Cut()
	for(var/obj/item/organ/external/limb in bodyparts)
		if(limb.status & ORGAN_SPLINTED)
			splinted_limbs += limb
