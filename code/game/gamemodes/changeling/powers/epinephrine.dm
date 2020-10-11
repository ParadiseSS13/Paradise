/datum/action/changeling/epinephrine
	name = "Epinephrine Overdose"
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 30 chemicals."
	helptext = "Removes all stuns instantly and adds a short term prevention in further stuns. Can be used while unconscious. Slightly poisions the body on use."
	button_icon_state = "adrenaline"
	genetic_damage = 30
	chemical_cost = 30
	dna_cost = 2
	req_human = 1
	req_stat = UNCONSCIOUS
	max_genetic_damage = 30 //One shot if you have used anything else that does genetic damage of late. Make it count.

//Recover from stuns.
/datum/action/changeling/epinephrine/sting_action(var/mob/living/user)

	if(user.lying)
		to_chat(user, "<span class='notice'>We arise.</span>")
	else
		to_chat(user, "<span class='notice'>Adrenaline rushes through us.</span>")
	user.apply_status_effect(STATUS_EFFECT_EPI_OVERDOSE)
	feedback_add_details("changeling_powers","UNS")
	return 1
