/****************************************************
				MARK: BLOOD SYSTEM
****************************************************/

#define EXOTIC_BLEED_MULTIPLIER 4 //Multiplies the actually bled amount by this number for the purposes of turf reaction calculations.

/mob/living/carbon/human/proc/suppress_bloodloss(amount)
	if(bleedsuppress)
		return
	else
		bleedsuppress = TRUE
		addtimer(CALLBACK(src, PROC_REF(resume_bleeding)), amount)

/mob/living/carbon/human/proc/resume_bleeding()
	if(stat != DEAD && bleed_rate && bleedsuppress)
		to_chat(src, "<span class='warning'>The blood soaks through your bandage.</span>")
	bleedsuppress = FALSE

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()
	if(NO_BLOOD in dna.species.species_traits)
		bleed_rate = 0
		return

	if(bodytemperature >= TCRYO && !HAS_TRAIT(src, TRAIT_BADDNA)) //cryosleep or husked people do not pump the blood.
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly
			if(nutrition >= NUTRITION_LEVEL_WELL_FED)
				blood_volume += 0.1 // double it if you are well fed

		//Effects of bloodloss
		var/word = pick("dizzy","woozy","faint")
		switch(blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(5))
					to_chat(src, "<span class='warning'>You feel [word].</span>")
				apply_damage_type(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.01, 1), dna.species.blood_damage_type)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				apply_damage_type(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1), dna.species.blood_damage_type)
				if(prob(5))
					EyeBlurry(12 SECONDS)
					to_chat(src, "<span class='warning'>You feel very [word].</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				apply_damage_type(5, dna.species.blood_damage_type)
				if(prob(15))
					Paralyse(rand(2 SECONDS, 6 SECONDS))
					to_chat(src, "<span class='warning'>You feel extremely [word].</span>")
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				death()

		var/temp_bleed = 0
		var/internal_bleeding_rate = 0
		//Bleeding out
		for(var/X in bodyparts)
			var/obj/item/organ/external/BP = X
			var/brutedamage = BP.brute_dam

			if(BP.is_robotic())
				continue

			//We want an accurate reading of length()
			listclearnulls(BP.embedded_objects)
			temp_bleed += 0.5 * length(BP.embedded_objects)

			if(brutedamage >= 20)
				temp_bleed += (brutedamage * 0.013)

			if(BP.open)
				temp_bleed += 0.5

			if(BP.status & ORGAN_INT_BLEEDING)
				internal_bleeding_rate += 0.5

		bleed_rate = max(bleed_rate - 0.5, temp_bleed)//if no wounds, other bleed effects naturally decreases

		var/additional_bleed = round(clamp((reagents.get_reagent_amount("heparin") / 10), 0, 2), 1) //Heparin worsens existing bleeding

		if(internal_bleeding_rate && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
			bleed_internal(internal_bleeding_rate + additional_bleed)

		if(bleed_rate && !bleedsuppress && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
			bleed(bleed_rate + additional_bleed)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt)
	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(isturf(loc)) //Blood loss still happens in locker, floor stays clean
			if(amt >= 10)
				add_splatter_floor(loc)
			else
				add_splatter_floor(loc, 1)

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!(NO_BLOOD in dna.species.species_traits))
		..()
		if(dna.species.exotic_blood)
			var/datum/reagent/R = GLOB.chemical_reagents_list[get_blood_id()]
			if(istype(R) && isturf(loc))
				if(EXOTIC_COLOR in dna.species.species_traits)
					R.reaction_turf(get_turf(src), amt * EXOTIC_BLEED_MULTIPLIER, dna.species.blood_color)
				else
					R.reaction_turf(get_turf(src), amt * EXOTIC_BLEED_MULTIPLIER)

/mob/living/carbon/proc/bleed_internal(amt) // Return 1 if we've coughed blood up, 2 if we're vomited it.
	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(prob(10 * amt)) // +5% chance per internal bleeding site that we'll cough up blood on a given tick.
			custom_emote(EMOTE_VISIBLE, "coughs up blood!")
			add_splatter_floor(loc, 1)
			return 1
		else if(amt >= 1 && prob(5 * amt)) // +2.5% chance per internal bleeding site that we'll cough up blood on a given tick. Must be bleeding internally in more than one place to have a chance at this.
			vomit(0, 1)
			return 2
	return 0

/mob/living/carbon/human/bleed_internal(amt)
	if(!(NO_BLOOD in dna.species.species_traits))
		.=..()
		if(dna.species.exotic_blood && .) // Do we have exotic blood, and have we left any on the ground?
			var/datum/reagent/R = GLOB.chemical_reagents_list[get_blood_id()]
			if(istype(R) && isturf(loc))
				if(EXOTIC_COLOR in dna.species.species_traits)
					R.reaction_turf(get_turf(src), amt * EXOTIC_BLEED_MULTIPLIER, dna.species.blood_color)
				else
					R.reaction_turf(get_turf(src), amt * EXOTIC_BLEED_MULTIPLIER)

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/human/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	bleed_rate = 0

/****************************************************
				MARK: BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return FALSE
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return FALSE

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return FALSE

	blood_volume -= amount

	SEND_SIGNAL(AM, COMSIG_MOB_REAGENT_EXCHANGE, src)

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == "blood") //normal blood
				if(blood_data["viruses"])
					for(var/thing in blood_data["viruses"])
						var/datum/disease/D = thing
						if((D.spread_flags & SPREAD_SPECIAL) || (D.spread_flags & SPREAD_NON_CONTAGIOUS))
							continue
						C.ForceContractDisease(D)
				if(!(blood_data?["blood_type"] in get_safe_blood(C.dna.blood_type)) || C.dna.species.name != blood_data["species"] && (blood_data["species_only"] || C.dna.species.own_species_blood))
					C.reagents.add_reagent("toxin", amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_NORMAL)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/human/get_blood_data(blood_id)
	if(blood_id == "blood") //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["donor"] = src
		blood_data["viruses"] = list()

		for(var/thing in viruses)
			var/datum/disease/D = thing
			blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = copytext(dna.unique_enzymes,1,0)
		if(resistances && length(resistances))
			blood_data["resistances"] = resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.id] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		if(ckey)
			blood_data["ckey"] = ckey
		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = copytext(src.dna.blood_type,1,0)
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["blood_color"] = dna.species.blood_color
		blood_data["factions"] = faction
		blood_data["dna"] = dna.Clone()
		blood_data["species"] = dna.species.name
		blood_data["species_only"] = dna.species.own_species_blood
		return blood_data
	if(blood_id == "slimejelly")
		var/blood_data = list()
		blood_data["blood_color"] = dna.species.blood_color
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return "blood"

/mob/living/carbon/human/get_blood_id()
	if(dna.species.exotic_blood)//some races may bleed water..or kethcup..
		return dna.species.exotic_blood
	else if((NO_BLOOD in dna.species.species_traits) || HAS_TRAIT(src, TRAIT_HUSK))
		return
	return "blood"

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list(BLOOD_TYPE_FAKE_BLOOD)
	if(!bloodtype)
		return
	switch(bloodtype)
		if("A-")
			. += list("A-", "O-")
		if("A+")
			. += list("A-", "A+", "O-", "O+")
		if("B-")
			. += list("B-", "O-")
		if("B+")
			. += list("B-", "B+", "O-", "O+")
		if("AB-")
			. += list("A-", "B-", "O-", "AB-")
		if("AB+")
			. += list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+")
		if("O-")
			. += list("O-")
		if("O+")
			. += list("O-", "O+")

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip, shift_x, shift_y)
	if((get_blood_id() != "blood") && (get_blood_id() != "slimejelly") && (get_blood_id() != "tomatojuice"))//is it blood or welding fuel?
		return
	if(!T)
		T = get_turf(src)

	var/list/temp_blood_DNA
	var/list/b_data = get_blood_data(get_blood_id())
	var/datum/move_loop/move/move_loop = GLOB.move_manager.processing_on(src, SSspacedrift)

	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(move_loop)
				drop.newtonian_move(move_loop.direction, instant = TRUE)
			if(drop.drips < 5)
				drop.drips++
				var/image/I = image(drop.icon, drop.random_icon_states)
				I.icon += drop.basecolor
				drop.overlays |= I

				drop.transfer_mob_blood_dna(src)
				if(b_data && !isnull(b_data["blood_color"]))
					drop.basecolor = b_data["blood_color"]
				else
					drop.basecolor = "#A10808"
				drop.update_icon()
			else
				temp_blood_DNA = list()
				temp_blood_DNA |= drop.blood_DNA.Copy() //we transfer the dna from the drip to the splatter
				qdel(drop)
		else
			drop = new(T)
			drop.transfer_mob_blood_dna(src)
			if(b_data && !isnull(b_data["blood_color"]))
				drop.basecolor = b_data["blood_color"]
			else
				drop.basecolor = "#A10808"
			drop.update_icon()
			if(move_loop)
				drop.newtonian_move(move_loop.direction, instant = TRUE)
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in T
	var/list/bloods = get_atoms_of_type(T, B, TRUE, 0, 0) //Get all the non-projectile-splattered blood on this turf (not pixel-shifted).
	if(shift_x || shift_y)
		bloods = get_atoms_of_type(T, B, TRUE, shift_x, shift_y) //Get all the projectile-splattered blood at these pixels on this turf (pixel-shifted).
		B = locate() in bloods
	if(!B)
		B = new(T)
	if(B.bloodiness < MAX_SHOE_BLOODINESS) //add more blood, up to a limit
		B.bloodiness += BLOOD_AMOUNT_PER_DECAL
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.blood_DNA |= temp_blood_DNA
	B.pixel_x = (shift_x)
	B.pixel_y = (shift_y)
	B.update_icon()
	if(shift_x || shift_y)
		B.off_floor = TRUE
		B.layer = BELOW_MOB_LAYER //So the blood lands ontop of things like posters, windows, etc.
	if(move_loop)
		B.newtonian_move(move_loop.direction, instant = TRUE)

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip, shift_x, shift_y, emittor_intertia)
	if(!(NO_BLOOD in dna.species.species_traits))
		..()

/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip, shift_x, shift_y, emittor_intertia)
	if(!T)
		T = get_turf(src)

	var/obj/effect/decal/cleanable/blood/xeno/splatter/B = locate() in T
	var/list/bloods = get_atoms_of_type(T, B, TRUE, 0, 0) //The more the better.
	if(shift_x || shift_y)
		bloods = get_atoms_of_type(T, B, TRUE, shift_x, shift_y)
		B = locate() in bloods
	if(!B)
		B = new(T)

	B.blood_DNA["UNKNOWN DNA"] = "X*"
	B.pixel_x = (shift_x)
	B.pixel_y = (shift_y)
	if(shift_x || shift_y)
		B.off_floor = TRUE
		B.layer = BELOW_MOB_LAYER

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip, shift_x, shift_y)
	if(!T)
		T = get_turf(src)

	var/obj/effect/decal/cleanable/blood/oil/streak/O = locate() in T
	var/list/oils = get_atoms_of_type(T, O, TRUE, 0, 0) //Don't let OSHA catch wind of this.
	if(shift_x || shift_y)
		oils = get_atoms_of_type(T, O, TRUE, shift_x, shift_y)
		O = locate() in oils
	if(!O)
		O = new(T)

	O.pixel_x = (shift_x)
	O.pixel_y = (shift_y)
	if(shift_x || shift_y)
		O.off_floor = TRUE
		O.layer = BELOW_MOB_LAYER

/mob/living/proc/absorb_blood()
	// This merely deletes the blood reagent inside of the mob to look nice on health scans.
	// The update to .blood_volume happens in `/datum/reagent/proc/reaction_mob`
	var/id = get_blood_id()
	if(id)
		reagents.del_reagent(get_blood_id())

#undef EXOTIC_BLEED_MULTIPLIER
