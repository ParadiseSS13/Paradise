/mob/living/carbon/human/proc/update_eyes()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		eyes.update_colour()
		update_body()

/mob/living/carbon/human/var/list/bodyparts = list()
/mob/living/carbon/human/var/list/bodyparts_by_name = list() // map organ names to organs
/mob/living/carbon/human/var/obj/item/organ/external/tail/bodypart_tail = null
/mob/living/carbon/human/var/obj/item/organ/external/wing/bodypart_wing = null

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

		if(!lying && world.time - l_move_time < 15)
		//Moving around with fractured ribs won't do you any good
			if(E.is_broken() && E.internal_organs && E.internal_organs.len && prob(15))
				var/obj/item/organ/internal/I = pick(E.internal_organs)
				custom_pain("Вы чувствуете как в вашей [E.declent_ru(PREPOSITIONAL)] двигаются сломанные кости!")
				I.receive_damage(rand(3,5))

	//handle_stance()
	handle_grasp()
	handle_stance()


/mob/living/carbon/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if(!stance_damage && (lying || resting) && (life_tick % 4) == 0)
		return

	stance_damage = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	// Not standing, so no need to care about stance
	if(istype(buckled, /obj/structure/chair) || !isturf(loc))
		return

	for(var/limb_tag in list("l_leg","r_leg","l_foot","r_foot"))
		var/obj/item/organ/external/E = bodyparts_by_name[limb_tag]
		if(!E || (E.status & ORGAN_DEAD) || E.is_malfunctioning())
			stance_damage += 2 // let it fail even if just foot&leg. Also malfunctioning happens sporadically so it should impact more when it procs
		else if(E.is_broken() || !E.is_usable())
			stance_damage += 1

	// Canes and crutches help you stand (if the latter is ever added)
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs, canes aren't gonna help you.
	if(l_hand && l_hand.is_crutch())
		stance_damage -= 2
	if(r_hand && r_hand.is_crutch())
		stance_damage -= 2

	if(stance_damage < 0)
		stance_damage = 0

	// standing is poor
	if(stance_damage >= 8)
		if(!(lying || resting))
			if(!(NO_PAIN in dna.species.species_traits))
				emote("scream")
			custom_emote(1, "падает!")
		Weaken(5) //can't emote while weakened, apparently.


/mob/living/carbon/human/proc/handle_grasp()

	if(!l_hand && !r_hand)
		return

	for(var/obj/item/organ/external/E in bodyparts)
		if(!E || !E.can_grasp || (E.status & ORGAN_SPLINTED))
			continue

		if(E.is_broken())
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

			var/emote_scream = pick("крич[pluralize_ru(src.gender,"ит","ат")] от боли и ", "изда[pluralize_ru(src.gender,"ёт","ют")] резкий крик и ", "вскрикива[pluralize_ru(src.gender,"ет","ют")] и ")
			custom_emote(1, "[(NO_PAIN in dna.species.species_traits) ? "" : emote_scream ]броса[pluralize_ru(src.gender,"ет","ют")] предмет, который держал[genderize_ru(src.gender,"","а","о","и")] в [E.declent_ru(PREPOSITIONAL)]!")

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

			custom_emote(1, "броса[pluralize_ru(src.gender,"ет","ют")] предмет, который держал[genderize_ru(src.gender,"","а","о","и")] держали, [genderize_ru(src.gender,"его","её","его","их")] [E.declent_ru(NOMINATIVE)] выход[pluralize_ru(E.gender,"ит","ят")] из строя!")

			do_sparks(5, 0, src)

/mob/living/carbon/human/handle_germs()
	..()
	if(gloves && germ_level > gloves.germ_level && prob(10))
		gloves.germ_level += 1

/mob/living/carbon/human/proc/becomeSlim()
	to_chat(src, "<span class='notice'>[pluralize_ru(src.gender,"Ты","Вы")] снова чувствуе[pluralize_ru(src.gender,"шь","те")] себя в форме!</span>")
	mutations.Remove(FAT)

/mob/living/carbon/human/proc/becomeFat()
	to_chat(src, "<span class='alert'>[pluralize_ru(src.gender,"Ты","Вы")] вдруг чувствуе[pluralize_ru(src.gender,"шь","те")] себя пухлым!</span>")
	mutations.Add(FAT)

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
/mob/living/carbon/human/proc/sync_organ_dna(var/assimilate = 1, var/old_ue = null)
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
/mob/living/carbon/human/proc/named_organ_parent(var/organ_name)
	if(!get_int_organ_tag(organ_name))
		return null
	var/obj/item/organ/internal/O = get_int_organ_tag(organ_name)
	return O.parent_organ

/mob/living/carbon/human/has_organic_damage()
	var/odmg = 0
	for(var/obj/item/organ/external/O in bodyparts)
		if(O.is_robotic())
			odmg += O.brute_dam
			odmg += O.burn_dam
	return (health < (100 - odmg))

/mob/living/carbon/human/proc/handle_splints() //proc that rebuilds the list of splints on this person, for ease of processing
	splinted_limbs.Cut()
	for(var/obj/item/organ/external/limb in bodyparts)
		if(limb.status & ORGAN_SPLINTED)
			splinted_limbs += limb

/mob/living/carbon/human/proc/update_tail()
	if(bodyparts_by_name["tail"])
		bodypart_tail = bodyparts_by_name["tail"]
	else
		bodypart_tail = null
/mob/living/carbon/human/proc/update_wing()
	if(bodyparts_by_name["wing"])
		bodypart_wing = bodyparts_by_name["wing"]
	else
		bodypart_wing = null
