
#define VIRUS_SYMPTOM_LIMIT	6

//Visibility Flags
#define HIDDEN_SCANNER	(1<<0)
#define HIDDEN_PANDEMIC	(1<<1)

//Disease Flags
#define CURABLE		(1<<0)
#define CAN_CARRY	(1<<1)
#define CAN_RESIST	(1<<2)

//Spread Flags
#define SPECIAL			(1<<0)
#define NON_CONTAGIOUS	(1<<1)
#define BLOOD			(1<<2)
#define CONTACT_FEET	(1<<3)
#define CONTACT_HANDS	(1<<4)
#define CONTACT_GENERAL	(1<<5)
#define AIRBORNE		(1<<6)


//Severity Defines
#define NONTHREAT	"No threat"
#define MINOR		"Minor"
#define MEDIUM		"Medium"
#define HARMFUL		"Harmful"
#define DANGEROUS 	"Dangerous!"
#define BIOHAZARD	"BIOHAZARD THREAT!"


GLOBAL_LIST_INIT(diseases, subtypesof(/datum/disease))


/datum/disease
	//Flags
	var/visibility_flags = 0
	var/disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	var/spread_flags = AIRBORNE

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
	var/list/cures = list() //list of cures if the disease has the CURABLE flag, these are reagent ids
	var/infectivity = 65
	var/cure_chance = 8
	var/carrier = FALSE //If our host is only a carrier
	var/bypasses_immunity = FALSE //Does it skip species virus immunity check? Some things may diseases and not viruses
	var/virus_heal_resistant = FALSE // Some things aren't technically viruses/traditional diseases and should be immune to edge case cure methods, like healing viruses.
	var/permeability_mod = 1
	var/severity = NONTHREAT
	var/list/required_organs = list()
	var/needs_all_cures = TRUE
	var/list/strain_data = list() //dna_spread special bullshit

/datum/disease/Destroy()
	affected_mob = null
	GLOB.active_diseases.Remove(src)
	return ..()

/datum/disease/proc/stage_act()
	if(!affected_mob)
		return FALSE
	var/cure = has_cure()

	if(carrier && !cure)
		return FALSE

	stage = min(stage, max_stages)

	if(!cure)
		if(prob(stage_prob))
			stage = min(stage + 1,max_stages)
			if(!discovered && stage >= CEILING(max_stages * discovery_threshold, 1)) // Once we reach a late enough stage, medical HUDs can pick us up even if we regress
				discovered = TRUE
				affected_mob.med_hud_set_status()
	else
		if(prob(cure_chance))
			stage = max(stage - 1, 1)

	if(disease_flags & CURABLE)
		if(cure && prob(cure_chance))
			cure()
			return FALSE
	return TRUE


/datum/disease/proc/has_cure()
	if(!(disease_flags & CURABLE))
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

	if((spread_flags & SPECIAL || spread_flags & NON_CONTAGIOUS || spread_flags & BLOOD) && !force_spread)
		return

	if(affected_mob.reagents.has_reagent("spaceacillin") || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)))
		return

	var/spread_range = 1

	if(force_spread)
		spread_range = force_spread

	if(spread_flags & AIRBORNE)
		spread_range++

	var/turf/T = affected_mob.loc
	if(istype(T))
		for(var/mob/living/carbon/C in oview(spread_range, affected_mob))
			var/turf/V = get_turf(C)
			if(V)
				while(TRUE)
					if(V == T)
						C.ContractDisease(src)
						break
					var/turf/Temp = get_step_towards(V, T)
					if(!V.CanAtmosPass(Temp))
						break
					V = Temp


/datum/disease/proc/cure()
	if(affected_mob)
		if(disease_flags & CAN_RESIST)
			if(!(type in affected_mob.resistances))
				affected_mob.resistances += type
		remove_virus()
		affected_mob.create_log(MISC_LOG, "has been cured from the virus \"[src]\"")
	qdel(src)

/datum/disease/proc/IsSame(datum/disease/D)
	if(ispath(D))
		return istype(src, D)
	return istype(src, D.type)

/datum/disease/proc/Copy()
	var/datum/disease/D = new type()
	D.strain_data = strain_data.Copy()
	return D


/datum/disease/proc/GetDiseaseID()
	return type

/datum/disease/proc/IsSpreadByTouch()
	if(spread_flags & CONTACT_FEET || spread_flags & CONTACT_HANDS || spread_flags & CONTACT_GENERAL)
		return 1
	return 0

//don't use this proc directly. this should only ever be called by cure()
/datum/disease/proc/remove_virus()
	affected_mob.viruses -= src		//remove the datum from the list
	affected_mob.med_hud_set_status()
