/datum/disease/fluspanish
	name = "Spanish Inquisition Flu"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 10
	agent = "1nqu1s1t10n flu virion"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will burn to death for being a heretic."
	severity = VIRUS_HARMFUL

/datum/disease/fluspanish/stage_act()
	if(!..())
		return FALSE
	if(stage < 2)
		return

	var/stage_factor = stage - 1
	affected_mob.bodytemperature += 10 * stage_factor // Enough to consistently cook certain species alive at stage 3
	if(prob(3 * stage_factor))
		affected_mob.emote("sneeze")
	if(prob(3 * stage_factor))
		affected_mob.emote("cough")
	if(prob(2.5 * stage_factor))
		to_chat(affected_mob, "<span class='danger'>You're burning in your own skin!</span>")
		affected_mob.adjustFireLoss(5)
