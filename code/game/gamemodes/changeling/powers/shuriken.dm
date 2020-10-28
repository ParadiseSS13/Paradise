/datum/action/changeling/shuriken
	name = "Bone Shuriken"
	desc = "We evolve the ability to break off shards of our bone, and shape them into 2 shurikens. Costs 15 chemicals per shuriken."
	helptext = "This will damage our arms, and be noticable to nearbye people. Shurikens will be dulled after hitting someone. 30 chemicals are required to use this ability, but you'll only be charged 15 per shuriken you make, and refunded 15 for those you do not."
	button_icon_state = "shuriken"
	chemical_cost = 30 // covered in making the stars
	dna_cost = 2
	req_human = 1
	max_genetic_damage = 20

/obj/item/throwing_star/bone
	name = "bone shuriken"
	desc = "A gross shard of bone and flesh, sharpened to deadly proportions."
	icon_state = "bone_star"
	throwforce = 15
	embedded_fall_chance = 5
	embedded_impact_pain_multiplier = 3
	embedded_unsafe_removal_pain_multiplier = 6
	embedded_pain_chance = 10
	embedded_pain_multiplier = 3 //If you can make a lot of these, they will not be as good.

/obj/item/throwing_star/bone/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(isliving(hit_atom))
		name = "dull bone shuriken"
		desc = "A gross shard of bone and flesh, now much duller than it used to be."
		throwforce = 7
		embed_chance = FALSE //No using these over and over, for the crew, or the clings.
	else
		..()
/datum/action/changeling/shuriken/sting_action(var/mob/living/carbon/human/user)
	if(iscarbon(user))
		var/obj/item/organ/external/L = user.get_organ("l_hand")
		var/obj/item/organ/external/LA = user.get_organ("l_arm")
		var/obj/item/organ/external/R = user.get_organ("r_hand")
		var/obj/item/organ/external/RA = user.get_organ("r_arm")

		var/left_hand_good_c = FALSE
		var/left_arm_good_c = FALSE
		var/right_hand_good_c = FALSE
		var/right_arm_good_c = FALSE
		var/made_stuff = FALSE

		if(L && (!(L.status & ORGAN_SPLINTED)) && (!(L.status & ORGAN_BROKEN)))
			left_hand_good_c = TRUE
		if(LA && (!(LA.status & ORGAN_SPLINTED)) && (!(LA.status & ORGAN_BROKEN)))
			left_arm_good_c = TRUE
		if(R && (!(R.status & ORGAN_SPLINTED)) && (!(R.status & ORGAN_BROKEN)))
			right_hand_good_c = TRUE
		if(RA && (!(RA.status & ORGAN_SPLINTED)) && (!(RA.status & ORGAN_BROKEN)))
			right_arm_good_c = TRUE


		if(left_hand_good_c && left_arm_good_c)
			if(user.put_in_l_hand(new /obj/item/throwing_star/bone(user)))
				user.apply_damage(7.5, BRUTE, "l_arm")
				user.mind.changeling.geneticdamage += 10
				made_stuff = TRUE
			else
				user.mind.changeling.chem_charges += 15 //if you dont make a star, you do not pay
		else
			to_chat(user, "<span class='warning'>Our left arm is too damaged to make our weapons.</span>")

		if(right_hand_good_c && right_arm_good_c)
			if(user.put_in_r_hand(new /obj/item/throwing_star/bone(user)))
				user.apply_damage(7.5, BRUTE, "r_arm")
				user.mind.changeling.geneticdamage += 10
				made_stuff = TRUE
			else
				user.mind.changeling.chem_charges += 15
		else
			to_chat(user, "<span class='warning'>Our right arm is too damaged to make our weapons.</span>")

		if(made_stuff)
			user.visible_message("<span class='warning'>Shards of bones grow from [user.name]\'s arms, pierce their skin, and fall into their hands!</span>", "<span class='warning'>We sharpen our new bone growths, and expell them from our body.</span>", "<span class='hear'>You hear organic matter ripping and tearing!</span>")
			made_stuff = FALSE
		else
			to_chat(user, "<span class='notice'>We are unable to make shuriken at this time.</span>")
	else
		to_chat(user, "<span class='notice'>We are unable to make shuriken at this time.</span>")

	feedback_add_details("changeling_powers","STAR")
	return 1
