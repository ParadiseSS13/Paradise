/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	can_synth = FALSE
	taste_message = "admin abuse"

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.adjustBruteLoss(-5)
	M.adjustFireLoss(-5)
	M.adjustToxLoss(-5)
	M.setBrainLoss(0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/thing in H.internal_organs)
			var/obj/item/organ/internal/I = thing
			I.receive_damage(-5)
		for(var/obj/item/organ/external/E in H.bodyparts)
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
	for(var/thing in M.viruses)
		var/datum/disease/D = thing
		if(D.severity == NONTHREAT)
			continue
		D.cure(0)
	..()

/datum/reagent/medicine/adminordrazine/nanites
	name = "Nanites"
	id = "nanites"
	description = "Nanomachines that aid in rapid cellular regeneration."
	taste_message = "nanomachines, son"

/datum/reagent/virushcure //Puesto aqui dado que para poder sintetizarlo ic se va a tardar para evitar que pueda producirse en masa en virologia.
	name = "Mother cell stabilizer"
	id = "virushcure"
	description = "Heals the mother cells"
	reagent_state = LIQUID
	color = "#61337c"
	overdose_threshold = 1

/datum/reagent/virushcure/on_mob_life(mob/living/M)
	M.Druggy(15)
	M.AdjustHallucinate(10)
	..()

/datum/reagent/virushcure/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks tired!</span>")
			M.Stun(6)
			M.emote("drool")
			M.adjustBruteLoss(10)
		else if(effect <= 4)
			M.emote("shiver")
			M.bodytemperature -= 40
			M.adjustBruteLoss(10)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your skin is cracking and bleeding!</span>")
			M.adjustBruteLoss(30)
			M.adjustToxLoss(5)
			M.adjustBrainLoss(3)
			M.emote("cry")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M]</b> sways and falls over!</span>")
			M.adjustToxLoss(7)
			M.adjustBrainLoss(6)
			M.adjustBruteLoss(25)
			M.Weaken(8)
			M.emote("faint")
		else if(effect <= 4)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.visible_message("<span class='warning'>[M]'s skin is rotting away!</span>")
				H.adjustBruteLoss(40)
				H.emote("scream")
				H.ChangeToHusk()
				H.emote("faint")
		else if(effect <= 7)
			M.emote("shiver")
			M.bodytemperature -= 70
			M.adjustBruteLoss(15)