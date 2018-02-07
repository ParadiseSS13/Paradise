// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
/proc/domutcheck(var/mob/living/M, var/connected=null, var/flags=0)
	for(var/datum/dna/gene/gene in dna_genes)
		if(!M || !M.dna)
			return
		if(!gene.block)
			continue

		domutation(gene, M, connected, flags)

// Use this to force a mut check on a single gene!
/proc/genemutcheck(var/mob/living/M, var/block, var/connected=null, var/flags=0)
	if(ishuman(M)) // Would've done this via species instead of type, but the basic mob doesn't have a species, go figure.
		var/mob/living/carbon/human/H = M
		if(NO_DNA in H.dna.species.species_traits)
			return
	if(!M)
		return
	if(block < 0)
		return

	var/datum/dna/gene/gene = assigned_gene_blocks[block]
	domutation(gene, M, connected, flags)


/proc/domutation(var/datum/dna/gene/gene, var/mob/living/M, var/connected=null, var/flags=0)
	if(!gene || !istype(gene))
		return 0

	// Current state
	var/gene_active = M.dna.GetSEState(gene.block)

	// Sanity checks, don't skip.
	if(!gene.can_activate(M,flags) && gene_active)
		//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
		return 0

	var/defaultgenes // Do not mutate inherent species abilities
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		defaultgenes = H.dna.species.default_genes

		if((gene in defaultgenes) && gene_active)
			return

	// Prior state
	var/gene_prior_status = (gene.type in M.active_genes)
	var/changed = gene_active != gene_prior_status

	// If gene state has changed:
	if(changed)
		// Gene active (or ALWAYS ACTIVATE)
		if(gene_active)
			//testing("[gene.name] activated!")
			gene.activate(M,connected,flags)
			if(M)
				M.active_genes |= gene.type
		// If Gene is NOT active:
		else
			//testing("[gene.name] deactivated!")
			gene.deactivate(M,connected,flags)
			if(M)
				M.active_genes -= gene.type
