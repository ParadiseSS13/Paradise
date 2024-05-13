/datum/action/changeling/miasmic_mist
	name = "Miasmic Mist"
	desc = "We exhale a blinding mist, obscuring the vision of our victims and poisoning their air. Costs 15 chemicals."
	helptext = "The smoke will also obscure our own vision, unless we adapt means to overcome it."
	button_icon_state = "miasma"
	chemical_cost = 15
	dna_cost = 2
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/defence

/datum/action/changeling/miasmic_mist/can_sting(mob/living/carbon/user)
	if(!..())
		return FALSE
	var/datum/effect_system/smoke_spread/changeling/smoke = new
	smoke.set_up(10, FALSE, get_turf(user))
	smoke.start()
	sleep(10)
	smoke.start()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
