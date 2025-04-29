/*
MARK: Contraction





MARK: Helpers
*/

/mob/proc/check_contraction_mob(datum/disease/D, spread_method = CONTACT_GENERAL)
	if(stat == DEAD && !D.allow_dead)
		return FALSE

	if(D.GetDiseaseID() in resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(istype(D, /datum/disease/advance))
		var/datum/disease/advance/advanced = D
		for(var/datum/disease/advance/exists in viruses)
			if(exists.event == advanced.event)
				return FALSE

	if(!(type in D.viable_mobtypes))
		return -1 //for stupid fucking monkies

	return TRUE

/mob/living/carbon/proc/check_contraction_carbon(datum/disease/D, spread_method = CONTACT_GENERAL)
	// positive satiety makes it harder to contract the disease.
	return (spread_method & BLOOD) || !((satiety > 0 && prob(satiety/10))|| (prob(15/D.permeability_mod)))

/mob/living/carbon/human/proc/check_contraction_human(datum/disease/D, spread_method = CONTACT_GENERAL)
	if(HAS_TRAIT(src, TRAIT_VIRUSIMMUNE) && !D.bypasses_immunity)
		return FALSE

	for(var/organ in D.required_organs)
		if(istext(organ) && get_int_organ_datum(organ))
			continue
		if(locate(organ) in internal_organs)
			continue
		if(locate(organ) in bodyparts)
			continue
		return FALSE

	// We transfer to the blood directly
	if(spread_method == BLOOD)
		return TRUE

	var/passed = FALSE

	if(spread_method & (CONTACT_FEET | CONTACT_HANDS | CONTACT_GENERAL))
		passed = TRUE
		var/obj/item/clothing/Cl = null

		var/head_ch = 100
		var/body_ch = 100
		var/hands_ch = 25
		var/feet_ch = 25

		if(D.spread_flags & CONTACT_HANDS)
			head_ch = 0
			body_ch = 0
			hands_ch = 100
			feet_ch = 0
		if(D.spread_flags & CONTACT_FEET)
			head_ch = 0
			body_ch = 0
			hands_ch = 0
			feet_ch = 100

		var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)

		switch(target_zone)
			if(1)
				if(isobj(head) && !istype(head, /obj/item/paper))
					Cl = head
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(wear_mask))
					Cl = wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(2)
				if(isobj(wear_suit))
					Cl = wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(w_uniform))
					Cl = w_uniform
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(3)
				if(isobj(wear_suit) && wear_suit.body_parts_covered&HANDS)
					Cl = wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(gloves))
					Cl = gloves
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(4)
				if(isobj(wear_suit) && wear_suit.body_parts_covered&FEET)
					Cl = wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(shoes))
					Cl = shoes
					passed = prob((Cl.permeability_coefficient*100) - 1)

	// If spreading by air we need to get through the mask and helmet.
	if(!passed && (spread_method & AIRBORNE))
		// Check for eye protection
		var/eye_check = !((wear_mask?.flags_cover & MASKCOVERSEYES) || (head?.flags_cover & HEADCOVERSEYES) || (glasses?.flags_cover & GLASSESCOVERSEYES))
		// Masks and hoods protect our mouth from sneezes, but not truely airborn viruses
		var/mouth_check = ((prob((wear_mask?.permeability_coefficient*100) - 1) || !(wear_mask?.flags_cover & MASKCOVERSMOUTH)) && (prob((head?.permeability_coefficient*100) - 1) || !(head?.flags_cover & HEADCOVERSMOUTH)))
		// A further check on the mask against airborne diseases
		var/breath_check = !internal && (D.spread_flags & AIRBORNE) && prob(100 * D.permeability_mod) && !((wear_mask?.flags_cover & MASKCOVERSMOUTH && HAS_TRAIT(wear_mask, TRAIT_ANTI_VIRAL)) || (head?.flags_cover & MASKCOVERSMOUTH && HAS_TRAIT(head, TRAIT_ANTI_VIRAL)))
		// If anything gets penetrated we contract the disease.
		passed = eye_check || mouth_check || breath_check

	return passed

// MARK: Mob

/// Grinds a mob in the turbine
/mob/compressor_grind()
	gib()

/// Returns whether or not the mob has the disease
/mob/proc/HasDisease(datum/disease/D)
	for(var/thing in viruses)
		var/datum/disease/DD = thing
		if(DD.IsSame(D))
			return TRUE
	return FALSE

/// Checks if a mob can contract the disease
/mob/proc/can_contract_disease(datum/disease/D, spread_method = CONTACT_GENERAL)
	return check_contraction_mob(D, spread_method)

/mob/proc/can_spread_disease(D, spread_method = CONTACT_GENERAL)
	return TRUE

// Attempt contracting a diseas
/mob/proc/ContractDisease(datum/disease/D, spread_method = CONTACT_GENERAL)
	if(!can_contract_disease(D, spread_method))
		return 0
	AddDisease(D)
	return TRUE

/**
 * Forces the mob to contract a virus. If the mob can have viruses. Ignores clothing and other protection
 * Returns TRUE if it succeeds. False if it doesn't
 *
 * Arguments:
 * * D - the disease the mob will try to contract
 * * respect_carrier - if set to TRUE will not ignore the disease carrier flag
 * * notify_ghosts - will notify ghosts of infection if set to TRUE
 */
//Same as ContractDisease, except it ignores the clothes check
/mob/proc/ForceContractDisease(datum/disease/D, respect_carrier, notify_ghosts = FALSE)
	if(!can_contract_disease(D, BLOOD))
		return FALSE
	if(notify_ghosts)
		for(var/mob/ghost as anything in GLOB.dead_mob_list) //Announce outbreak to dchat
			to_chat(ghost, "<span class='deadsay'><b>Disease outbreak: </b>[src] ([ghost_follow_link(src, ghost)]) [D.carrier ? "is now a carrier of" : "has contracted"] [D]!</span>")
	AddDisease(D, respect_carrier)
	return TRUE

/// Directly adds a disease to a mob.
/mob/proc/AddDisease(datum/disease/D, respect_carrier = FALSE, start_stage = 1)
	if(src.client)
		D.record_infection()
	var/datum/disease/DD = new D.type(1, D, 0)
	DD.stage = start_stage
	viruses += DD
	DD.affected_mob = src
	GLOB.active_diseases += DD //Add it to the active diseases list, now that it's actually in a mob and being processed.

	//Copy properties over. This is so edited diseases persist.
	var/list/skipped = list("affected_mob","holder","carrier","stage","type","parent_type","vars","transformed")
	if(respect_carrier)
		skipped -= "carrier"
	for(var/V in DD.vars)
		if(V in skipped)
			continue
		if(istype(DD.vars[V],/list))
			var/list/L = D.vars[V]
			DD.vars[V] = L.Copy()
		else
			DD.vars[V] = D.vars[V]

	create_log(MISC_LOG, "has contacted the virus \"[DD]\"")
	DD.affected_mob.med_hud_set_status()

// MARK: Carbon
/mob/living/carbon/can_spread_disease(D, spread_method = CONTACT_GENERAL)
	return check_contraction_carbon(D, spread_method)

/mob/living/carbon/can_contract_disease(datum/disease/D, spread_method = CONTACT_GENERAL)
	return ..() && check_contraction_carbon(D)

/mob/living/carbon/ContractDisease(datum/disease/D, spread_method = CONTACT_GENERAL)
	if(!can_contract_disease(D, spread_method))
		return 0
	AddDisease(D)
	return TRUE

//MARK: Human
/mob/living/carbon/human/can_spread_disease(D, spread_method = CONTACT_GENERAL)
	return check_contraction_human(D, spread_method)

/mob/living/carbon/human/can_contract_disease(datum/disease/D, spread_method = CONTACT_GENERAL)
	return check_contraction_human(D, spread_method) && ..()

/mob/living/carbon/human/monkey/can_contract_disease(datum/disease/D, spread_method = CONTACT_GENERAL)
	. = ..()
	if(. == -1)
		if(D.viable_mobtypes.Find(/mob/living/carbon/human))
			return 1 //this is stupid as fuck but because monkeys are only half the time actually subtypes of humans they need this
