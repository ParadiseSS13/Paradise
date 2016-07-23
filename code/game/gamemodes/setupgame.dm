/proc/getAssignedBlock(var/name,var/list/blocksLeft, var/activity_bounds=DNA_DEFAULT_BOUNDS, var/good=0)
	if(blocksLeft.len==0)
		warning("[name]: No more blocks left to assign!")
		return 0
	var/assigned = pick(blocksLeft)
	blocksLeft.Remove(assigned)
	if(good)
		good_blocks += assigned
	else
		bad_blocks += assigned
	assigned_blocks[assigned]=name
	dna_activity_bounds[assigned]=activity_bounds
	//Debug message_admins("[name] assigned to block #[assigned].")
//	testing("[name] assigned to block #[assigned].")
	return assigned

/proc/setupgenetics()

	if(prob(50))
		BLOCKADD = rand(-300,300)
	if(prob(75))
		DIFFMUT = rand(0,20)


//Thanks to nexis for the fancy code
// BITCH I AIN'T DONE YET

	// SE blocks to assign.
	var/list/numsToAssign=new()
	for(var/i=1;i<DNA_SE_LENGTH;i++)
		numsToAssign += i

//	testing("Assigning DNA blocks:")
	//message_admins("Assigning DNA blocks:")

	// Standard muts
	BLINDBLOCK         = getAssignedBlock("BLIND",         numsToAssign)
	DEAFBLOCK          = getAssignedBlock("DEAF",          numsToAssign)
	HULKBLOCK          = getAssignedBlock("HULK",          numsToAssign, DNA_HARD_BOUNDS, good=1)
	TELEBLOCK          = getAssignedBlock("TELE",          numsToAssign, DNA_HARD_BOUNDS, good=1)
	FIREBLOCK          = getAssignedBlock("FIRE",          numsToAssign, DNA_HARDER_BOUNDS, good=1)
	XRAYBLOCK          = getAssignedBlock("XRAY",          numsToAssign, DNA_HARDER_BOUNDS, good=1)
	CLUMSYBLOCK        = getAssignedBlock("CLUMSY",        numsToAssign)
	FAKEBLOCK          = getAssignedBlock("FAKE",          numsToAssign)
	COUGHBLOCK         = getAssignedBlock("COUGH",         numsToAssign)
	GLASSESBLOCK       = getAssignedBlock("GLASSES",       numsToAssign)
	EPILEPSYBLOCK      = getAssignedBlock("EPILEPSY",      numsToAssign)
	TWITCHBLOCK        = getAssignedBlock("TWITCH",        numsToAssign)
	NERVOUSBLOCK       = getAssignedBlock("NERVOUS",       numsToAssign)

	// Bay muts
	NOBREATHBLOCK      = getAssignedBlock("NOBREATH",      numsToAssign, DNA_HARD_BOUNDS, good=1)
	REMOTEVIEWBLOCK    = getAssignedBlock("REMOTEVIEW",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	REGENERATEBLOCK    = getAssignedBlock("REGENERATE",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	INCREASERUNBLOCK   = getAssignedBlock("INCREASERUN",   numsToAssign, DNA_HARDER_BOUNDS, good=1)
	REMOTETALKBLOCK    = getAssignedBlock("REMOTETALK",    numsToAssign, DNA_HARDER_BOUNDS, good=1)
	MORPHBLOCK         = getAssignedBlock("MORPH",         numsToAssign, DNA_HARDER_BOUNDS, good=1)
	COLDBLOCK          = getAssignedBlock("COLD",          numsToAssign, good=1)
	HALLUCINATIONBLOCK = getAssignedBlock("HALLUCINATION", numsToAssign)
	NOPRINTSBLOCK      = getAssignedBlock("NOPRINTS",      numsToAssign, DNA_HARD_BOUNDS, good=1)
	SHOCKIMMUNITYBLOCK = getAssignedBlock("SHOCKIMMUNITY", numsToAssign, good=1)
	SMALLSIZEBLOCK     = getAssignedBlock("SMALLSIZE",     numsToAssign, DNA_HARD_BOUNDS, good=1)

	//
	// Goon muts
	/////////////////////////////////////////////

	// Disabilities
	LISPBLOCK      = getAssignedBlock("LISP",       numsToAssign)
	MUTEBLOCK      = getAssignedBlock("MUTE",       numsToAssign)
	RADBLOCK       = getAssignedBlock("RAD",        numsToAssign)
	FATBLOCK       = getAssignedBlock("FAT",        numsToAssign)
	CHAVBLOCK      = getAssignedBlock("CHAV",       numsToAssign)
	SWEDEBLOCK     = getAssignedBlock("SWEDE",      numsToAssign)
	SCRAMBLEBLOCK  = getAssignedBlock("SCRAMBLE",   numsToAssign)
	TOXICFARTBLOCK = getAssignedBlock("TOXICFART",  numsToAssign, good=1)
	STRONGBLOCK    = getAssignedBlock("STRONG",     numsToAssign, good=1)
	HORNSBLOCK     = getAssignedBlock("HORNS",      numsToAssign)
	COMICBLOCK     = getAssignedBlock("COMIC",      numsToAssign)

	// Powers
	SOBERBLOCK     = getAssignedBlock("SOBER",      numsToAssign, good=1)
	PSYRESISTBLOCK = getAssignedBlock("PSYRESIST",  numsToAssign, DNA_HARD_BOUNDS, good=1)
	SHADOWBLOCK    = getAssignedBlock("SHADOW",     numsToAssign, DNA_HARDER_BOUNDS, good=1)
	CHAMELEONBLOCK = getAssignedBlock("CHAMELEON",  numsToAssign, DNA_HARDER_BOUNDS, good=1)
	CRYOBLOCK      = getAssignedBlock("CRYO",       numsToAssign, DNA_HARD_BOUNDS, good=1)
	EATBLOCK       = getAssignedBlock("EAT",        numsToAssign, DNA_HARD_BOUNDS, good=1)
	JUMPBLOCK      = getAssignedBlock("JUMP",       numsToAssign, DNA_HARD_BOUNDS, good=1)
	IMMOLATEBLOCK  = getAssignedBlock("IMMOLATE",   numsToAssign)
	EMPATHBLOCK    = getAssignedBlock("EMPATH",     numsToAssign, DNA_HARD_BOUNDS, good=1)
	SUPERFARTBLOCK = getAssignedBlock("SUPERFART",  numsToAssign, DNA_HARDER_BOUNDS, good=1)
	POLYMORPHBLOCK = getAssignedBlock("POLYMORPH",  numsToAssign, DNA_HARDER_BOUNDS, good=1)

	//
	// /vg/ Blocks
	/////////////////////////////////////////////

	// Disabilities
	LOUDBLOCK      = getAssignedBlock("LOUD",       numsToAssign)
	DIZZYBLOCK     = getAssignedBlock("DIZZY",      numsToAssign)


	//
	// Static Blocks
	/////////////////////////////////////////////.

	// Monkeyblock is always last.
	MONKEYBLOCK = DNA_SE_LENGTH

	// And the genes that actually do the work. (domutcheck improvements)
	var/list/blocks_assigned[DNA_SE_LENGTH]
	for(var/gene_type in typesof(/datum/dna/gene))
		var/datum/dna/gene/G = new gene_type
		if(G.block)
			if(G.block in blocks_assigned)
				warning("DNA2: Gene [G.name] trying to use already-assigned block [G.block] (used by [english_list(blocks_assigned[G.block])])")
			dna_genes.Add(G)
			var/list/assignedToBlock[0]
			if(blocks_assigned[G.block])
				assignedToBlock=blocks_assigned[G.block]
			assignedToBlock.Add(G.name)
			blocks_assigned[G.block]=assignedToBlock
			//testing("DNA2: Gene [G.name] assigned to block [G.block].")

	// I WILL HAVE A LIST OF GENES THAT MATCHES THE RANDOMIZED BLOCKS GODDAMNIT!
	for(var/block=1;block<=DNA_SE_LENGTH;block++)
		var/name = assigned_blocks[block]
		for(var/datum/dna/gene/gene in dna_genes)
			if(gene.name == name || gene.block == block)
				if(gene.block in assigned_gene_blocks)
					warning("DNA2: Gene [gene.name] trying to add to already assigned gene block list (used by [english_list(assigned_gene_blocks[block])])")
				assigned_gene_blocks[block] = gene

	//testing("DNA2: [numsToAssign.len] blocks are unused: [english_list(numsToAssign)]")

/proc/setupfactions()

	// Populate the factions list:
	for(var/x in typesof(/datum/faction))
		var/datum/faction/F = new x
		if(!F.name)
			qdel(F)
			continue
		else
			ticker.factions.Add(F)
			ticker.availablefactions.Add(F)

	// Populate the syndicate coalition:
	for(var/datum/faction/syndicate/S in ticker.factions)
		ticker.syndicate_coalition.Add(S)


/* This was used for something before, I think, but is not worth the effort to process now.
/proc/setupcorpses()
	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Corpse")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			qdel(A)
			continue
		if(A.name == "Corpse-Engineer")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(M), slot_shoes)
		//	M.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_r_store)
			//M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(M), slot_head)
			else
				if(prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/welding(M), slot_head)
			del(A)
			continue
		if(A.name == "Corpse-Engineer-Space")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space(M), slot_wear_suit)
		//	M.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(M), slot_head)
			else
				if(prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/welding(M), slot_head)
				else
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space(M), slot_head)
			del(A)
			continue
		if(A.name == "Corpse-Engineer-Chief")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/utilitybelt(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(M), slot_shoes)
		//	M.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(M), slot_head)
			else
				if(prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/welding(M), slot_head)
			del(A)
			continue
		if(A.name == "Corpse-Syndicate")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			//M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/jetpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/syndicate(M), slot_wear_suit)
				if(prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
				else
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/syndicate(M), slot_head)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
			qdel(A)
			continue
*/
