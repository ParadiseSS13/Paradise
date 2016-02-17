/datum/reagent/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	adminOnly=1

/datum/reagent/adminordrazine/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom ///This can even heal dead people.
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,5)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_organ_damage(5,5)
	M.adjustToxLoss(-5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
		if(istype(E))
			E.damage = max(E.damage-5 , 0)
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.confused = 0
	M.sleeping = 0
	M.jitteriness = 0
	if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
		var/mob/living/carbon/C = M
		if(C.virus2.len)
			for (var/ID in C.virus2)
				var/datum/disease2/disease/V = C.virus2[ID]
				C.antibodies |= V.antigen
	..()
	return


/datum/reagent/adminordrazine/nanites
	name = "Nanites"
	id = "nanites"
	description = "Nanomachines that aid in rapid cellular regeneration."


// For random item spawning. Takes a list of paths, and returns the same list without anything that contains admin only reagents

/proc/adminReagentCheck(var/list/incoming)
	var/list/outgoing[0]
	for(var/tocheck in incoming)
		if(ispath(tocheck))
			var/check = new tocheck
			if (istype(check, /atom))
				var/atom/reagentCheck = check
				var/datum/reagents/reagents = reagentCheck.reagents
				var/admin = 0
				for(var/datum/reagent/reagent in reagents.reagent_list)
					if(reagent.adminOnly)
						admin = 1
						break
				if(!(admin))
					outgoing += tocheck
	return outgoing