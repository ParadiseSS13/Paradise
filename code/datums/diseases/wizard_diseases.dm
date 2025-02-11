/datum/disease/beesease/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/berserker/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/cold9/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/brainrot/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/fluspanish/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/kingstons_advanced/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/dna_retrovirus/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/tuberculosis/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/wizarditis/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/anxiety/wizard_variant
	spread_flags = NON_CONTAGIOUS

/datum/disease/grut_gut
	name = "Grut Gut"
	max_stages = 5
	spread_text = "Non-contagious"
	spread_flags = NON_CONTAGIOUS
	cure_text = "Sleep"
	agent = "Eruca Stomachum"
	cures = list("stabilizing_agent")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A magic-infused disease that builds up dangerously high pressure within the stomach."
	severity = DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/grut_gut/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(5))

				to_chat(affected_mob, "<span class='danger'>Your stomach feels strange.</span>")
		if(2)

		if(3)

		if(4)

		if(5)
			if(prob(5))
				affected_mob.emote("burps")

/datum/disease/wand_rot
	name = "Food Poisoning"
	max_stages = 5
	spread_text = "Non-contagious"
	spread_flags = NON_CONTAGIOUS
	cure_text = "Mugwort Tea"
	agent = "nasum magicum"
	cures = list("mugwort")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A magic-infused disease that replaces one's nose hairs with tiny wands. Avoid nasal irritants."
	severity = DANGEROUS
	virus_heal_resistant = TRUE

/datum/disease/mystic_malaise
	name = "Mystic Malaise"
	max_stages = 5
	spread_text = "Non-contagious"
	spread_flags = NON_CONTAGIOUS
	cure_text = "liquid dark matter"
	agent = "Spatio Ventrem"
	cures = list("liquid_dark_matter")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "A magic-infused disease that resides in the gut, converting gastric juices into space-matter."
	severity = DANGEROUS
	virus_heal_resistant = TRUE
