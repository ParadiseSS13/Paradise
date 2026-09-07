
GLOBAL_LIST_INIT(diseases, subtypesof(/datum/disease))


/datum/disease
	//Flags
	var/visibility_flags = 0
	var/disease_flags = VIRUS_CURABLE|VIRUS_CAN_CARRY|VIRUS_CAN_RESIST
	var/spread_flags = SPREAD_AIRBORNE

	//Fluff
	/// Used for identification of viruses in the Medical Records Virus Database
	var/medical_name
	var/form = "Virus"
	var/name = "No disease"
	var/desc = ""
	var/agent = "some microbes"
	var/spread_text = ""
	var/cure_text = ""

	//Stages
	var/stage = 1
	var/max_stages = 0
	var/stage_prob = 4
	/// The fraction of stages the virus must at least be at to show up on medical HUDs. Rounded up.
	var/discovery_threshold = 0.5
	/// If TRUE, this virus will show up on medical HUDs. Automatically set when it reaches mid-stage.
	var/discovered = FALSE

	//Other
	var/list/viable_mobtypes = list() //typepaths of viable mobs
	var/mob/living/carbon/affected_mob
	var/list/cures = list() //list of cures if the disease has the VIRUS_CURABLE flag, these are reagent ids
	var/infectivity = 65
	var/cure_chance = 8
	var/carrier = FALSE //If our host is only a carrier
	var/bypasses_immunity = FALSE //Does it skip species virus immunity check? Some things may diseases and not viruses
	var/virus_heal_resistant = FALSE // Some things aren't technically viruses/traditional diseases and should be immune to edge case cure methods, like healing viruses.
	var/permeability_mod = 1
	var/severity = VIRUS_NONTHREAT
	var/list/required_organs = list()
	var/needs_all_cures = TRUE
	var/list/strain_data = list() //dna_spread special bullshit
	/// Allow the virus to infect and process while the affected_mob is dead
	var/allow_dead = FALSE
	/// How many cycles we should incubate
	var/incubation = 0

/datum/disease/Destroy()
	affected_mob = null
	GLOB.active_diseases.Remove(src)
	return ..()

/datum/disease/proc/stage_act()
	// Still incubating, do nothing
	if(incubation)
		if(is_species(affected_mob, /datum/species/monkey))
			incubation = 0
		else
			incubation--
		return FALSE
	// We have no host
	if(!affected_mob)
		return FALSE
	var/cure = has_cure()

	// This is patient 0 and we aren't curing them. Do nothing
	if(carrier && !cure)
		return FALSE

	stage = min(stage, max_stages)

	handle_stage_advance(cure)

	return handle_cure_testing(cure)

/datum/disease/proc/handle_stage_advance(has_cure = FALSE)
	if(!has_cure && prob(stage_prob))
		stage = min(stage + 1, max_stages)
		if(!discovered && stage >= CEILING(max_stages * discovery_threshold, 1)) // Once we reach a late enough stage, medical HUDs can pick us up even if we regress
			discovered = TRUE
			affected_mob.med_hud_set_status()

/datum/disease/proc/handle_cure_testing(has_cure = FALSE)
	if(has_cure && prob(cure_chance))
		stage = max(stage - 1, 1)

	if(disease_flags & VIRUS_CURABLE)
		if(has_cure && prob(cure_chance))
			cure()
			return FALSE
	return TRUE

/datum/disease/proc/has_cure()
	if(!(disease_flags & VIRUS_CURABLE))
		return 0

	var/cures_found = 0
	for(var/C_id in cures)
		if(C_id == "ethanol")
			for(var/datum/reagent/consumable/ethanol/booze in affected_mob.reagents.reagent_list)
				cures_found++
				break
		else if(affected_mob.reagents.has_reagent(C_id))
			cures_found++

	if(needs_all_cures && cures_found < length(cures))
		return FALSE

	return cures_found

/datum/disease/proc/spread(force_spread = 0)
	if(!affected_mob)
		return

	if((spread_flags & SPREAD_SPECIAL || spread_flags & SPREAD_NON_CONTAGIOUS || spread_flags & SPREAD_BLOOD) && !force_spread)
		return

	if(affected_mob.reagents.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/spread_range = 1

	if(force_spread)
		spread_range = force_spread

	if(spread_flags & SPREAD_AIRBORNE)
		spread_range++

	var/spread_method = NONE
	// If we do an airborne spread we will do that as well as other spreads
	if((spread_flags & SPREAD_AIRBORNE) || spread_range > 1)
		spread_method |= SPREAD_AIRBORNE

	var/turf/target = affected_mob.loc
	if(istype(target))
		for(var/mob/living/carbon/C in oview(spread_range, affected_mob))
			// Assume we are touching
			spread_method |= (SPREAD_CONTACT_GENERAL | SPREAD_CONTACT_FEET | SPREAD_CONTACT_HANDS)
			var/turf/current = get_turf(C)
			if(current)
				while(TRUE)
					// Found a path from target to source that isn't atmos blocked. Try to give them the disease
					if(current == target)
						// If we are further than 1 tile we aren't touching
						if(get_dist(target, C) > 1)
							spread_method &= ~(SPREAD_CONTACT_GENERAL | SPREAD_CONTACT_FEET | SPREAD_CONTACT_HANDS)
						// We also want to test our own mob's permeability so people in hardsuits with internals won't just infect others with sneezes or touch
						affected_mob.can_spread_disease(src, spread_method) && C.ContractDisease(src, spread_method)
						break
					var/direction = get_dir(current, target)
					var/turf/next = get_step(current, direction)
					if(!current.CanAtmosPass(direction) || !next.CanAtmosPass(turn(direction, 180)))
						break
					current = next

/datum/disease/proc/after_infect()
	return

/datum/disease/proc/cure()
	if(affected_mob)
		if(disease_flags & VIRUS_CAN_RESIST)
			if(!(type in affected_mob.resistances))
				affected_mob.resistances += type
		remove_virus()
		affected_mob.create_log(MISC_LOG, "has been cured from the virus \"[src]\"")
	qdel(src)

// Gives the received mob a resistance to this disease. Does not cure it if they are already infected
/datum/disease/proc/make_resistant(mob/living/target)
	if(target && disease_flags & VIRUS_CAN_RESIST && !(type in target.resistances))
		target.resistances += type

/datum/disease/proc/IsSame(datum/disease/D)
	if(ispath(D))
		return istype(src, D)
	return istype(src, D.type)

/datum/disease/proc/Copy()
	var/datum/disease/D = new type()
	D.spread_flags = spread_flags //In case an admin (or other factor) has made a virus non spreading, you should *not* get a new spreading virus from blood
	D.visibility_flags = visibility_flags // See above.
	D.strain_data = strain_data.Copy()
	return D

/datum/disease/proc/get_required_cures()
	return needs_all_cures ? length(cures) : 1

/datum/disease/proc/is_stabilized()
	return TRUE

/datum/disease/proc/get_tracker()
	return ""

/datum/disease/proc/get_stage()
	return stage

/datum/disease/proc/GetDiseaseID()
	return type

// Id for the pandemic
/datum/disease/proc/get_ui_id()
	return name

// Another Id for the pandemic. We need multiple procs so we can override them in different ways
/datum/disease/proc/get_strain_id()
	return name

// Another Id for the pandemic.
/datum/disease/proc/get_full_strain_id()
	return name

/datum/disease/proc/IsSpreadByTouch()
	if(spread_flags & SPREAD_CONTACT_FEET || spread_flags & SPREAD_CONTACT_HANDS || spread_flags & SPREAD_CONTACT_GENERAL)
		return 1
	return 0

//don't use this proc directly. this should only ever be called by cure()
/datum/disease/proc/remove_virus()
	affected_mob.viruses -= src		//remove the datum from the list
	affected_mob.med_hud_set_status()

/// Not interested in normal diseases right now
/datum/disease/proc/record_infection()
	return

/// Returns whether or not the disease is known
/datum/disease/proc/is_known(z)
	return TRUE

/// Returns an Asoc list of disease's symptoms and their properties in a format usable by the PANDEMIC
/datum/disease/proc/get_pandemic_symptoms()
	return list()

/// Returns the Disease's base stats
/datum/disease/proc/get_pandemic_base_stats()
	return list(
			"resistance" = 0,
			"stealth" = 0,
			"stageSpeed" = 0,
			"transmissibility" = 0,
			)
