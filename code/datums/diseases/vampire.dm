/datum/disease/vampire
	name = "Grave Fever"
	max_stages = 3
	stage_prob = 5
	spread_text = "Non-Contagious"
	spread_flags = SPECIAL
	cure_text = "Antibiotics"
	cures = list("spaceacillin")
	agent = "Grave Dust"
	cure_chance = 20
	viable_mobtypes = list(/mob/living/carbon/human)
	severity = DANGEROUS
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS

/datum/disease/vampire/stage_act()
	..()
	var/toxdamage = stage * 2
	var/stuntime = stage * 2

	if(prob(10))
		affected_mob.emote(pick("cough","groan", "gasp"))
		affected_mob.losebreath++

	if(prob(15))
		if(prob(33))
			to_chat(affected_mob, "<span class='danger'>You feel sickly and weak.</span>")
			affected_mob.slowed += 3
		affected_mob.adjustToxLoss(toxdamage)

	if(prob(5))
		to_chat(affected_mob, "<span class='danger'>Your joints ache horribly!</span>")
		affected_mob.Weaken(stuntime)
		affected_mob.Stun(stuntime)