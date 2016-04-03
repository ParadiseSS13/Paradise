/datum/disease/rhumba_beat
	name = "The Rhumba Beat"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Chick Chicky Boom!"
	cures = list("plasma")
	agent = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	severity = BIOHAZARD

/datum/disease/rhumba_beat/stage_act()
	..()
	switch(stage)
		if(1)
			if(affected_mob.ckey == "rosham")
				src.cure()
		if(2)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(45))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "<span class='danger'>You feel strange...</span>"
		if(3)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(5))
				affected_mob << "<span class='danger'>You feel the urge to dance...</span>"
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				affected_mob << "<span class='danger'>You feel the need to chick chicky boom...</span>"
		if(4)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(10))
				affected_mob.emote("gasp")
				affected_mob << "<span class='danger'>You feel a burning beat inside...</span>"
			if(prob(20))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
		if(5)
			if(affected_mob.ckey == "rosham")
				src.cure()
			affected_mob << "<span class='danger'>Your body is unable to contain the Rhumba Beat...</span>"
			if(prob(50))
				affected_mob.gib()
		else
			return