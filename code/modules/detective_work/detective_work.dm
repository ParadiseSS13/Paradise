//CONTAINS: Suit fibers and Detective's Scanning Computer

/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && isclothing(M.gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(easy_to_spill_blood && G.blood_DNA)
			add_blood(G.blood_DNA, G.blood_color)
		else if(G.transfer_blood > 1 && add_blood(G.blood_DNA, G.blood_color))
			G.transfer_blood--

		if(blood_DNA && should_spread_blood)
			var/old_transfer_blood = G.transfer_blood
			G.add_blood(blood_DNA, blood_color)
			G.transfer_blood = max(1, old_transfer_blood)
			M.update_inv_gloves()

	else
		if(easy_to_spill_blood && M.blood_DNA)
			add_blood(M.blood_DNA, M.hand_blood_color)
		else if(M.bloody_hands > 1 && add_blood(M.blood_DNA, M.hand_blood_color))
			M.bloody_hands--

		if(blood_DNA && should_spread_blood)
			var/old_bloody_hands = M.bloody_hands
			M.make_bloody_hands(blood_DNA, blood_color)
			M.bloody_hands = max(1, old_bloody_hands)

	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = isitem(src)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in suit_fibers) && M.wear_suit.can_leave_fibers)
			//log_world("Added fibertext: [fibertext]")
			suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & UPPER_TORSO))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !(fibertext in suit_fibers) && M.w_uniform.can_leave_fibers) //Wearing a suit means less of the uniform exposed.
					//log_world("Added fibertext: [fibertext]")
					suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !(fibertext in suit_fibers) && M.gloves.can_leave_fibers)
					//log_world("Added fibertext: [fibertext]")
					suit_fibers += fibertext
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in suit_fibers) && M.w_uniform.can_leave_fibers)
			// "Added fibertext: [fibertext]"
			suit_fibers += fibertext
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !(fibertext in suit_fibers) && M.gloves.can_leave_fibers)
				//log_world("Added fibertext: [fibertext]")
				suit_fibers += "Material from a pair of [M.gloves.name]."
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in suit_fibers) && M.gloves.can_leave_fibers)
			//log_world("Added fibertext: [fibertext]")
			suit_fibers += "Material from a pair of [M.gloves.name]."
