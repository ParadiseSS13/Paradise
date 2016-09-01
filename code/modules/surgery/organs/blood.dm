/****************************************************
				BLOOD SYSTEM
****************************************************/

/mob/living/carbon/human/var/datum/reagents/vessel	//Container for blood and BLOOD ONLY. Do not transfer other chems here.

//Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()

	if(vessel)
		return

	vessel = new/datum/reagents(max_blood)
	vessel.my_atom = src

	if(species && species.exotic_blood)
		vessel.add_reagent(species.exotic_blood, max_blood)
	else
		vessel.add_reagent("blood", max_blood)
		for(var/datum/reagent/blood/B in vessel.reagent_list)
			if(B.id == "blood")
				B.data = list(
				"donor" = src,
				"viruses" = null,
				"blood_DNA" = dna.unique_enzymes,
				"blood_colour" = species.blood_color,
				"blood_type" = b_type,
				"resistances" = null,
				"trace_chem" = null)
	spawn(1)
		fixblood()

//Resets blood data
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.data = list(
			"donor" = src,
			"viruses" = null,
			"blood_DNA" = dna.unique_enzymes,
			"blood_colour" = species.blood_color,
			"blood_type" = b_type,
			"resistances" = null,
			"trace_chem" = null)

// Takes care blood loss and regeneration
/mob/living/carbon/human/proc/handle_blood()
	var/blood_volume
	if(species && species.flags & NO_BLOOD)
		return
	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.
		if(species.exotic_blood)
			var/blood_reagent = species.exotic_blood // This is a string of the name of the species' blood reagent
			blood_volume = round(vessel.get_reagent_amount(blood_reagent))
			if(blood_volume < max_blood && blood_volume)
				vessel.add_reagent(blood_reagent, 0.1) // regenerate blood VERY slowly
				if(reagents.has_reagent(blood_reagent))
					vessel.add_reagent(blood_reagent, 0.4)

		else
			blood_volume = round(vessel.get_reagent_amount("blood"))
			//Blood regeneration if there is some space
			if(blood_volume < max_blood && blood_volume)
				var/datum/reagent/blood/B = locate() in vessel.reagent_list //Grab some blood
				if(B) // Make sure there's some blood at all
					if(mind) //Handles vampires "eating" blood that isn't their own.
						if(mind in ticker.mode.vampires)
							for(var/datum/reagent/blood/BL in vessel.reagent_list)
								if(nutrition >= 450)
									break //We don't want blood tranfusions making vampires fat.
								if(BL.data["donor"] != src)
									nutrition += (15 * REAGENTS_METABOLISM)
									BL.volume -= REAGENTS_METABOLISM
									if(BL.volume <= 0)
										qdel(BL)
									break //Only process one blood per tick, to maintain the same metabolism as nutriment for non-vampires.

					if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
						for(var/datum/reagent/blood/D in vessel.reagent_list)
							if(D.data["donor"] == src)
								B = D
								break

					vessel.add_reagent("blood", 0.1) // regenerate blood VERY slowly


		//Effects of bloodloss
		var/oxy_immune = species.flags & NO_BREATHE //Some species have blood, but don't breathe; they should still suffer the effects of bloodloss.

		switch(blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(5))
					to_chat(src, "<span class='warning'>You feel [pick("dizzy","woozy","faint")].</span>")
				if(oxy_immune)
					adjustToxLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.01, 1))
				else
					adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.01, 1))
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(oxy_immune)
					adjustToxLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))
				else
					adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))
				if(prob(5))
					eye_blurry = max(eye_blurry, 6)
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, "<span class='warning'>You feel very [word].</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				if(oxy_immune)
					adjustToxLoss(5)
				else
					adjustOxyLoss(5)
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, "<span class='warning'>You feel extremely [word].</span>")
			if(0 to BLOOD_VOLUME_SURVIVE)
				death()

		//Bleeding out
		var/blood_max = 0
		for(var/obj/item/organ/external/temp in organs)
			if(!(temp.status & ORGAN_BLEEDING) || temp.status & ORGAN_ROBOT)
				continue
			for(var/datum/wound/W in temp.wounds)
				if(W.bleeding())
					blood_max += W.damage / 4
			if(temp.open)
				blood_max += 2  //Yer stomach is cut open
		drip(blood_max)

//Makes a blood drop, leaking certain amount of blood from the mob
/mob/living/carbon/human/proc/drip(var/amt as num)

	if(species && species.flags & NO_BLOOD) //TODO: Make drips come from the reagents instead.
		return

	if(!amt)
		return

	var/amm = 0.1 * amt
	var/turf/T = get_turf(src)

	if(species.exotic_blood)
		vessel.remove_reagent(species.exotic_blood,amm)
		if(vessel.total_volume)
			var/fraction = amm / vessel.total_volume
			vessel.reaction(T, TOUCH, fraction)
		return

	else
		vessel.remove_reagent("blood",amm)
		blood_splatter(src, src)


/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to the container, preserving all data in it.
/mob/living/carbon/proc/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/B = get_blood(container.reagents)
	if(!istype(B, /datum/reagent/blood))	B = new /datum/reagent/blood
	B.holder = container
	B.volume += amount

	//set reagent data
	B.data["donor"] = src
	B.data["viruses"] = list()

	for(var/datum/disease/D in viruses)
		B.data["viruses"] += D.Copy()
	if(resistances && resistances.len)
		B.data["resistances"] = resistances.Copy()

	B.data["blood_DNA"] = copytext(src.dna.unique_enzymes,1,0)
	B.data["blood_type"] = copytext(src.dna.b_type,1,0)

	// Putting this here due to return shenanigans.
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		B.data["blood_colour"] = H.species.blood_color
		B.color = B.data["blood_colour"]

	var/list/temp_chem = list()
	for(var/datum/reagent/R in src.reagents.reagent_list)
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	B.data["trace_chem"] = list2params(temp_chem)
	return B

//For humans, blood does not appear from blue, it comes from vessels.
/mob/living/carbon/human/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	if(src.species.exotic_blood)
		if(vessel.get_reagent_amount(src.species.exotic_blood) < amount)
			return null
		var/datum/reagent/W = new /datum/reagent
		W.holder = container
		W.volume += amount
		var/list/temp_chem = list()
		for(var/datum/reagent/R in src.reagents.reagent_list)
			temp_chem += R.id
			temp_chem[R.id] = R.volume
		W.data["trace_chem"] = list2params(temp_chem)
		vessel.remove_reagent(src.species.exotic_blood,amount) // Removes blood if human
		return W
	if(species && species.flags & NO_BLOOD)
		return null
	else
		if(vessel.get_reagent_amount("blood") < amount)
			return null
		. = ..()
		vessel.remove_reagent("blood",amount) // Removes blood if human

//Transfers blood from container ot vessels
/mob/living/carbon/proc/inject_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/blood/injected = get_blood(container.reagents)

	if(!istype(injected))
		return

	var/list/chems = list()
	chems = params2list(injected.data["trace_chem"])
	for(var/C in chems)
		src.reagents.add_reagent(C, (text2num(chems[C]) / BLOOD_VOLUME_NORMAL) * amount)//adds trace chemicals to owner's blood
	reagents.update_total()

	container.reagents.remove_reagent("blood", amount)

//Transfers blood from container ot vessels, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(obj/item/weapon/reagent_containers/container, var/amount)

	var/datum/reagent/blood/injected = get_blood(container.reagents)

	if(species && species.flags & NO_BLOOD)
		reagents.add_reagent("blood", amount, injected.data)
		reagents.update_total()
		return

	var/datum/reagent/blood/our = get_blood(vessel)

	if(!istype(injected) || !istype(our))
		return
	if(blood_incompatible(injected.data["blood_type"],our.data["blood_type"]) )
		reagents.add_reagent("toxin",amount * 0.5)
		reagents.update_total()
	else
		vessel.add_reagent("blood", amount, injected.data)
		vessel.update_total()
	..()

//Gets human's own blood.
/mob/living/carbon/proc/get_blood(datum/reagents/container)
	var/datum/reagent/blood/res = locate() in container.reagent_list //Grab some blood
	if(res) // Make sure there's some blood at all
		if(res.data["donor"] != src) //If it's not theirs, then we look for theirs
			for(var/datum/reagent/blood/D in container.reagent_list)
				if(D.data["donor"] == src)
					return D
	return res

/mob/living/carbon/human/get_blood(datum/reagents/container)
	if(species.exotic_blood)
		return container.get_reagent_from_id(species.exotic_blood)
	else
		return ..()

/mob/living/carbon/proc/get_blood_name()
	return "blood"

/mob/living/carbon/human/get_blood_name()
	if(species.exotic_blood)
		return species.exotic_blood
	else
		return ..()

/proc/blood_incompatible(donor,receiver)

	var/donor_antigen = copytext(donor,1,lentext(donor))
	var/receiver_antigen = copytext(receiver,1,lentext(receiver))
	var/donor_rh = findtext("+",donor)
	var/receiver_rh = findtext("+",receiver)

	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0

/*
Target: Thing/tile to get bloody
Source: Human or blood reagent
Large: Whether the splat should be big or not
*/
/proc/blood_splatter(var/target,var/source,var/large = 0)

	var/obj/effect/decal/cleanable/blood/B
	var/decal_type = /obj/effect/decal/cleanable/blood/splatter
	var/turf/T = get_turf(target)
	var/datum/reagent/blood/bld
	if(istype(source,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = source
		bld = H.get_blood(H.vessel)
		if(H.species.exotic_blood)
			H.vessel.reaction(T, TOUCH)
			return
		else if(H.species.flags & NO_BLOOD)
			return
	else if(istype(source, /datum/reagent))
		bld = source
		if(!istype(bld, /datum/reagent/blood))
			var/datum/reagent/R = bld
			if(istype(R))
				R.reaction_turf(T, R.volume)
			return
	else if(source)
		log_runtime(EXCEPTION("Non-human or reagent blood source. Area: [get_area(source)], Name: [source]"), source)

	// Are we dripping or splattering?
	var/list/drips = list()
	// Only a certain number of drips (or one large splatter) can be on a given turf.
	for(var/obj/effect/decal/cleanable/blood/drip/drop in T)
		drips |= drop.drips
		qdel(drop)
	if(!large && drips.len < 3)
		decal_type = /obj/effect/decal/cleanable/blood/drip

	// Find a blood decal or create a new one.
	B = locate(decal_type) in T
	if(!B)
		B = new decal_type(T)

	var/obj/effect/decal/cleanable/blood/drip/drop = B
	if(istype(drop) && drips && drips.len && !large)
		drop.overlays |= drips
		drop.drips |= drips

	// If there's no data to copy, call it quits here.
	if(!bld)
		return B

	// Update appearance.
	if(bld.data["blood_colour"])
		B.basecolor = bld.data["blood_colour"]
		B.update_icon()

	// Update blood information.
	if(bld.data["blood_DNA"])
		B.blood_DNA = list()
		if(bld.data["blood_type"])
			B.blood_DNA[bld.data["blood_DNA"]] = bld.data["blood_type"]
		else
			B.blood_DNA[bld.data["blood_DNA"]] = "O+"

	return B
