/proc/getAssignedBlock(name, list/blocksLeft, activity_bounds=DNA_DEFAULT_BOUNDS, good=0)
	if(blocksLeft.len==0)
		warning("[name]: No more blocks left to assign!")
		return 0
	var/assigned = pick(blocksLeft)
	blocksLeft.Remove(assigned)
	if(good)
		GLOB.good_blocks += assigned
	else
		GLOB.bad_blocks += assigned
	GLOB.assigned_blocks[assigned]=name
	GLOB.dna_activity_bounds[assigned]=activity_bounds
	//Debug message_admins("[name] assigned to block #[assigned].")
//	testing("[name] assigned to block #[assigned].")
	return assigned

/proc/setupgenetics()

	if(prob(50))
		GLOB.blockadd = rand(-300,300)
	if(prob(75))
		GLOB.diffmut = rand(0,20)


//Thanks to nexis for the fancy code
// BITCH I AIN'T DONE YET

	// SE blocks to assign.
	var/list/numsToAssign=new()
	for(var/i=1;i<DNA_SE_LENGTH;i++)
		numsToAssign += i

//	testing("Assigning DNA blocks:")
	//message_admins("Assigning DNA blocks:")

	// Standard muts
	GLOB.blindblock         = getAssignedBlock("BLINDNESS",     numsToAssign)
	GLOB.colourblindblock   = getAssignedBlock("COLOURBLIND",   numsToAssign)
	GLOB.deafblock          = getAssignedBlock("DEAF",          numsToAssign)
	GLOB.hulkblock          = getAssignedBlock("HULK",          numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.teleblock          = getAssignedBlock("TELE",          numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.fireblock          = getAssignedBlock("FIRE",          numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.xrayblock          = getAssignedBlock("XRAY",          numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.clumsyblock        = getAssignedBlock("CLUMSY",        numsToAssign)
	GLOB.fakeblock          = getAssignedBlock("FAKE",          numsToAssign)
	GLOB.coughblock         = getAssignedBlock("COUGH",         numsToAssign)
	GLOB.glassesblock       = getAssignedBlock("GLASSES",       numsToAssign)
	GLOB.epilepsyblock      = getAssignedBlock("EPILEPSY",      numsToAssign)
	GLOB.twitchblock        = getAssignedBlock("TWITCH",        numsToAssign)
	GLOB.nervousblock       = getAssignedBlock("NERVOUS",       numsToAssign)
	GLOB.wingdingsblock     = getAssignedBlock("WINGDINGS",     numsToAssign)

	// Bay muts
	GLOB.breathlessblock    = getAssignedBlock("BREATHLESS",    numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.remoteviewblock    = getAssignedBlock("REMOTEVIEW",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.regenerateblock    = getAssignedBlock("REGENERATE",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.increaserunblock   = getAssignedBlock("INCREASERUN",   numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.remotetalkblock    = getAssignedBlock("REMOTETALK",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.morphblock         = getAssignedBlock("MORPH",         numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.coldblock          = getAssignedBlock("COLD",          numsToAssign, good=1)
	GLOB.hallucinationblock = getAssignedBlock("HALLUCINATION", numsToAssign)
	GLOB.noprintsblock      = getAssignedBlock("NOPRINTS",      numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.shockimmunityblock = getAssignedBlock("SHOCKIMMUNITY", numsToAssign, good=1)
	GLOB.smallsizeblock     = getAssignedBlock("SMALLSIZE",     numsToAssign, DNA_HARD_BOUNDS, good=1)

	//
	// Goon muts
	/////////////////////////////////////////////

	// Disabilities
	GLOB.lispblock      = getAssignedBlock("LISP",       numsToAssign)
	GLOB.muteblock      = getAssignedBlock("MUTE",       numsToAssign)
	GLOB.radblock       = getAssignedBlock("RAD",        numsToAssign)
	GLOB.fatblock       = getAssignedBlock("FAT",        numsToAssign)
	GLOB.chavblock      = getAssignedBlock("CHAV",       numsToAssign)
	GLOB.swedeblock     = getAssignedBlock("SWEDE",      numsToAssign)
	GLOB.scrambleblock  = getAssignedBlock("SCRAMBLE",   numsToAssign)
	GLOB.strongblock    = getAssignedBlock("STRONG",     numsToAssign, good=1)
	GLOB.hornsblock     = getAssignedBlock("HORNS",      numsToAssign)
	GLOB.comicblock     = getAssignedBlock("COMIC",      numsToAssign)

	// Powers
	GLOB.soberblock     = getAssignedBlock("SOBER",      numsToAssign, good=1)
	GLOB.psyresistblock = getAssignedBlock("PSYRESIST",  numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.shadowblock    = getAssignedBlock("SHADOW",     numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.chameleonblock = getAssignedBlock("CHAMELEON",  numsToAssign, DNA_HARDER_BOUNDS, good=1)
	GLOB.cryoblock      = getAssignedBlock("CRYO",       numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.eatblock       = getAssignedBlock("EAT",        numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.jumpblock      = getAssignedBlock("JUMP",       numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.immolateblock  = getAssignedBlock("IMMOLATE",   numsToAssign)
	GLOB.empathblock    = getAssignedBlock("EMPATH",     numsToAssign, DNA_HARD_BOUNDS, good=1)
	GLOB.polymorphblock = getAssignedBlock("POLYMORPH",  numsToAssign, DNA_HARDER_BOUNDS, good=1)

	//
	// /vg/ Blocks
	/////////////////////////////////////////////

	// Disabilities
	GLOB.loudblock      = getAssignedBlock("LOUD",       numsToAssign)
	GLOB.dizzyblock     = getAssignedBlock("DIZZY",      numsToAssign)


	//
	// Static Blocks
	/////////////////////////////////////////////.

	// Monkeyblock is always last.
	GLOB.monkeyblock = DNA_SE_LENGTH

	// And the mutations that actually do the work. (domutcheck improvements)
	var/list/blocks_assigned[DNA_SE_LENGTH]
	for(var/mutation_type in typesof(/datum/mutation))
		var/datum/mutation/G = new mutation_type
		if(G.block)
			if(G.block in blocks_assigned)
				warning("DNA2: Gene [G.name] trying to use already-assigned block [G.block] (used by [english_list(blocks_assigned[G.block])])")
			GLOB.dna_mutations[mutation_type] = G
			var/list/assignedToBlock[0]
			if(blocks_assigned[G.block])
				assignedToBlock = blocks_assigned[G.block]
			assignedToBlock.Add(G.name)
			blocks_assigned[G.block] = assignedToBlock
			//testing("DNA2: Gene [G.name] assigned to block [G.block].")
		else
			qdel(G)

	// I WILL HAVE A LIST OF MUTATIONS THAT MATCHES THE RANDOMIZED BLOCKS GODDAMNIT!
	for(var/block in 1 to DNA_SE_LENGTH)
		var/name = GLOB.assigned_blocks[block]
		for(var/mutation_type in GLOB.dna_mutations)
			var/datum/mutation/mutation = GLOB.dna_mutations[mutation_type]
			if(mutation.name == name || mutation.block == block)
				if(mutation.block in GLOB.assigned_mutation_blocks)
					warning("DNA2: Mutation [mutation.name] trying to add to already assigned gene block list (used by [english_list(GLOB.assigned_mutation_blocks[block])])")
				GLOB.assigned_mutation_blocks[block] = mutation

	//testing("DNA2: [numsToAssign.len] blocks are unused: [english_list(numsToAssign)]")

/proc/setupcult()
	var/static/datum/cult_info/picked_cult // Only needs to get picked once

	if(picked_cult)
		return picked_cult

	var/random_cult = pick(typesof(/datum/cult_info))
	picked_cult = new random_cult()

	if(!picked_cult)
		log_runtime(EXCEPTION("Cult datum creation failed"))
	//todo:add adminonly datum var, check for said var here...
	return picked_cult
