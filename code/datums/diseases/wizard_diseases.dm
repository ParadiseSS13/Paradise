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
	cure_text = "Pyrotech stabilizing agents"
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
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your stomach feels strange.</span>")
		if(2)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>You feel bloated.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your feel an uncomfortable pressure in your abdomen</span>")
		if(3)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your feel an uncomfortable pressure in your abdomen</span>")
			if(prob(1))
				affected_mob.custom_emote("burps")
		if(4)
			if(prob(1))
				affected_mob.fakevomit(no_text = 1)
				affected_mob.adjust_nutrition(-rand(3,5))
			if(prob(1))
				affected_mob.custom_emote("burps")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your feel horribly bloated.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>A deep bubbling resounds through your chest</span>")
		if(5)
			if(prob(2))
				affected_mob.custom_emote("belches loudly")
			if(prob(1))
				affected_mob.custom_emote("burps")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your stomach is killing you!</span>")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Your abdoment gurgles with a firce intensity!</span>")
			if(prob(30) && affected_mob.nutrition >= 100)
				affected_mob.vomit(6,0,TRUE,5,0)
				affected_mob.fakevomit
				affected_mob.visible_message("[affected_mob] vomits with such force that [p_theyre(FALSE)] sent flying backwards!", "You vomit a torrent of magic bile so forcefully, that you are sent flying!", "You hear someone vomit profusely.")
				var/mob_facing = get_step(affected_mob, affected_mob.dir)
				var/mob_direction = get_dir(mob_facing, affected_mob)
				var/fling_dir = get_opposite_direction(mob_direction)
				var/turf/general_direction = get_edge_target_turf(affected_mob, fling_dir)
				affected_mob.throw_at(general_direction, 100, 3) // YEET them!


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

/datum/disease/wand_rot/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)

		if(2)

		if(3)

		if(4)

		if(5)
			return

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

/datum/disease/mystic_malaise/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)

		if(2)

		if(3)

		if(4)

		if(5)
			return
