/datum/disease/berserker
	name = "Berserker"
	max_stages = 2
	stage_prob = 5
	spread_text = "Non-Contagious"
	spread_flags = SPECIAL
	cure_text = "Anti-Psychotics"
	cures = list("haloperidol")
	agent = "Jagged Crystals"
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Swearing, shouting, attacking nearby crew members uncontrollably."
	severity = DANGEROUS
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS

/datum/disease/berserker/stage_act()
	..()
	if(affected_mob.reagents.has_reagent("thc"))
		to_chat(affected_mob, "<span class='notice'>You mellow out.</span>")
		cure()
		return
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote(pick("twitch_s", "grumble"))
			if(prob(5))
				var/speak = pick("Grr...", "Fuck...", "Fucking...", "Fuck this fucking.. fuck..")
				affected_mob.say(speak)
		if(2)
			if(prob(5))
				affected_mob.emote(pick("twitch_s", "scream"))
			if(prob(5))
				var/speak = pick("AAARRGGHHH!!!!", "GRR!!!", "FUCK!! FUUUUUUCK!!!", "FUCKING SHITCOCK!!", "WROOAAAGHHH!!")
				affected_mob.say(speak)
			if(prob(15))
				affected_mob.visible_message("<span class='danger'>[affected_mob] twitches violently!</span>")
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
			if(prob(33))
				if(affected_mob.incapacitated())
					affected_mob.visible_message("<span class='danger'>[affected_mob] spasms and twitches!</span>")
					return
				affected_mob.visible_message("<span class='danger'>[affected_mob] thrashes around violently!</span>")
				for(var/mob/living/carbon/M in range(1, affected_mob))
					if(M == affected_mob)
						continue
					var/damage = rand(1, 5)
					if(prob(80))
						playsound(affected_mob.loc, "punch", 25, 1, -1)
						affected_mob.visible_message("<span class='danger'>[affected_mob] hits [M] with [affected_mob.p_their()] thrashing!</span>")
						M.adjustBruteLoss(damage)
					else
						playsound(affected_mob.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						affected_mob.visible_message("<span class='danger'>[affected_mob] fails to hit [M] with [affected_mob.p_their()] thrashing!</span>")