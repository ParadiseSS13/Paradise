/datum/reagent/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	admin_only = 1

/datum/reagent/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.adjustBruteLoss(-5)
	M.adjustFireLoss(-5)
	M.adjustToxLoss(-5)
	M.setBrainLoss(0)
	M.radiation = 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/name in H.internal_organs)
			var/obj/item/organ/internal/I = H.get_int_organ(name)
			I.damage = max(0, I.damage-5)
		for(var/obj/item/organ/external/E in H.organs)
			if(E.mend_fracture())
				E.perma_injury = 0
	M.SetEyeBlind(0)
	M.CureNearsighted()
	M.CureBlind()
	M.CureMute()
	M.CureDeaf()
	M.CureEpilepsy()
	M.CureTourettes()
	M.CureCoughing()
	M.CureNervous()
	M.SetEyeBlurry(0)
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.SetSilence(0)
	M.SetHallucinate(0)
	M.SetDizzy(0)
	M.SetDrowsy(0)
	M.SetStuttering(0)
	M.SetSlur(0)
	M.SetConfused(0)
	M.SetSleeping(0)
	M.SetJitter(0)
	for(var/datum/disease/D in M.viruses)
		if(D.severity == NONTHREAT)
			continue
		D.spread_text = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	..()

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
			if(istype(check, /atom))
				var/atom/reagentCheck = check
				var/datum/reagents/reagents = reagentCheck.reagents
				var/admin = 0
				for(var/reag in reagents.reagent_list)
					var/datum/reagent/reagent = reag
					if(reagent.admin_only)
						admin = 1
						break
				if(!(admin))
					outgoing += tocheck
			else
				outgoing += tocheck
	return outgoing
