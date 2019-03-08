/datum/disease/transformation/virush
	name = "VirusH"
	disease_flags = CURABLE|CAN_CARRY|CAN_RESIST|HIDDEN_PANDEMIC
	cure_text = "Mother cell stabilizer"
	cures = list("virushcure")
	permeability_mod = 1
	cure_chance = 1
	spread_text = "Segregations from other infected"
	spread_flags = SPECIAL
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "An unknown virus that will turn one human into a zombie"
	severity = BIOHAZARD
	stage_prob = 4
	max_stages = 4
	visibility_flags = 0
	agent = "Zombie H-2018"
	stage1	= list("<span class='warning'>You feel strange.</span>")
	stage2	= list("<span class='warning'>You can't breathe easily.</span>")
	stage3	= list("<span class='warning'>Your body hurts.</span>")
	stage4	= list("<span class='warning'>All living things look delicious.</span>")
	new_form = /datum/species/zombie

/datum/disease/transformation/virush/stage_act()
	..()
	var/mob/living/carbon/human/human = affected_mob
	var/mob/living/M = affected_mob
		
	switch(stage)
		if(1)
			if(prob(6) && !iszombie(affected_mob))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your mind started to dissipate.</span>")
				if(M.health <= -30 && prob(20))
					playsound(affected_mob, 'sound/goonstation/voice/zombie.ogg', 40, 1, 1)
					to_chat(affected_mob, "<span class='danger'>You are a zombie, a new biological weapon. Your brain is dead and You can only think about infect and eat living people and can't remember anything. Silicon are not living people, but you must destroy them if they try to hurt you.</span>")
					human.rejuvenate()
					human.set_species(/datum/species/zombie)

		if(2)
			if(prob(8) && !iszombie(affected_mob))
				affected_mob.adjustToxLoss(10)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your mind started to dissipate.</span>")
				if(M.health <= -30 && prob(45))
					playsound(affected_mob, 'sound/goonstation/voice/zombie.ogg', 40, 1, 1)
					to_chat(affected_mob, "<span class='danger'>You are a zombie, a new biological weapon. Your brain is dead and You can only think about infect and eat living people and can't remember anything. Silicon are not living people, but you must destroy them if they try to hurt you.</span>")
					human.rejuvenate()
					human.set_species(/datum/species/zombie)

		if(3)
			if(prob(12) && !iszombie(affected_mob))
				affected_mob.adjustToxLoss(10)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your mind started to dissipate.</span>")
				if(M.health <= -20 && prob(45))
					playsound(affected_mob, 'sound/goonstation/voice/zombie.ogg', 40, 1, 1)
					to_chat(affected_mob, "<span class='danger'>You are a zombie, a new biological weapon. Your brain is dead and You can only think about infect and eat living people and can't remember anything. Silicon are not living people, but you must destroy them if they try to hurt you.</span>")
					human.rejuvenate()
					human.set_species(/datum/species/zombie)
					
		if(4)
			if(prob(12) && !iszombie(affected_mob))
				affected_mob.adjustToxLoss(10)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your feel like your energy is being drained.</span>")
				if(M.health <= -20 && prob(45))
					playsound(affected_mob, 'sound/goonstation/voice/zombie.ogg', 40, 1, 1)
					to_chat(affected_mob, "<span class='danger'>You are a zombie, a new biological weapon. Your brain is dead and You can only think about infect and eat living people and can't remember anything. Silicon are not living people, but you must destroy them if they try to hurt you.</span>")
					human.rejuvenate()
					human.set_species(/datum/species/zombie)