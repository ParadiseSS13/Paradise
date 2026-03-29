/datum/component/viral_contamination
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Asoc list of virus Ids to virus refs.
	var/list/viruses = list()

/datum/component/viral_contamination/Initialize(_viruses)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	for(var/datum/disease/virus in _viruses)
		// If we don't have a copy of this virus, put one it
		if(virus.spread_flags >= SPREAD_BLOOD && !(virus.GetDiseaseID() in viruses))
			viruses += list("[virus.GetDiseaseID()]" = virus.Copy())
	RegisterSignal(parent, COMSIG_MOB_REAGENT_EXCHANGE, PROC_REF(infect_target))
	RegisterSignal(parent, COMSIG_ATOM_DISINFECTED, PROC_REF(disinfect))

/datum/component/viral_contamination/InheritComponent(datum/component/viral_contamination/C, i_am_original, _viruses)
	if(!i_am_original)
		return
	var/list/virus_list = list()
	if(C)
		virus_list = C.viruses
		// Add a copy of each virus to our list if we don't already have one
		for(var/disease_id in virus_list)
			if(!(disease_id in viruses))
				var/datum/disease/virus = C.viruses["[disease_id]"]
				viruses += list("[disease_id]" = virus.Copy())
	else
		virus_list = _viruses
		// Add a copy of each virus to our list if we don't already have on
		for(var/datum/disease/virus in virus_list)
			if(virus.spread_flags >= SPREAD_BLOOD && !(virus.GetDiseaseID() in viruses))
				viruses += list(list("[virus.GetDiseaseID()]" = virus.Copy()))

/datum/component/viral_contamination/proc/infect_target(atom/source, mob/target)
	SIGNAL_HANDLER // COMSIG_MOB_REAGENT_EXCHANGE
	if(!istype(target))
		return
	for(var/disease_id in viruses)
		var/datum/disease/virus = viruses[disease_id]
		if(istype(virus))
			target.ForceContractDisease(virus, FALSE)

/datum/component/viral_contamination/proc/disinfect(atom/source)
	SIGNAL_HANDLER // COMSIG_ATOM_DISINFECTED
	qdel(src)
