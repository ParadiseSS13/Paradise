// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// flags: See below, bitfield.
/proc/domutcheck(mob/living/M, flags = 0)
	for(var/mutation_type in GLOB.dna_mutations)
		var/datum/mutation/mutation = GLOB.dna_mutations[mutation_type]
		if(!M || !M.dna)
			return
		if(!mutation.block)
			continue

		domutation(mutation, M, flags)

// Use this to force a mut check on a single mutation!
/proc/singlemutcheck(mob/living/M, block, flags = 0)
	if(!M)
		return
	if(HAS_TRAIT(M, TRAIT_GENELESS))
		return
	if(block < 0)
		return

	var/datum/mutation/mutation = GLOB.assigned_mutation_blocks[block]
	domutation(mutation, M, flags)


/proc/domutation(datum/mutation/mutation, mob/living/M, flags = 0)
	if(!mutation || !istype(mutation))
		return FALSE

	// Current state
	var/mutation_active = M.dna.GetSEState(mutation.block)

	// Sanity checks, don't skip.
	if(mutation_active && !mutation.can_activate(M, flags))
		//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
		return FALSE

	// Prior state
	var/mutation_prior_status = (mutation.type in M.active_mutations)
	var/changed = mutation_active != mutation_prior_status

	// If gene state has changed:
	if(changed)
		// Gene active (or ALWAYS ACTIVATE)
		if(mutation_active)
			//testing("[gene.name] activated!")
			mutation.activate(M)
		// If Gene is NOT active:
		else
			//testing("[gene.name] deactivated!")
			mutation.deactivate(M)
