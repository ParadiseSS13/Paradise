/datum/disease/cold9
	name = "The Cold"
	medical_name = "ICE9 Cold"
	max_stages = 3
	spread_text = "On contact"
	spread_flags = SPREAD_CONTACT_GENERAL
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	agent = "ICE9-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated the subject will slow, as if partly frozen."
	severity = VIRUS_HARMFUL

/datum/disease/cold9/stage_act()
	if(!..())
		return FALSE
	if(stage < 2)
		return

	var/stage_factor = stage - 1
	affected_mob.bodytemperature -= 7.5 * stage_factor // Enough to consistently frostburn certain species alive at stage 3
	if(prob(2 * stage_factor))
		affected_mob.emote("sneeze")
	if(prob(2 * stage_factor))
		affected_mob.emote("cough")
	if(prob(3 * stage_factor))
		to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
	if(prob(5 * stage_factor))
		to_chat(affected_mob, "<span class='danger'>You feel stiff.</span>")
		affected_mob.adjustFireLoss(1)
