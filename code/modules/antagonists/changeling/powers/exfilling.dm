/datum/action/changeling/exfiltration
	name = "Generate Extraction Mass"
	desc = "We separate a specialized organ that will generate an extraction portal. Costs 30 chemicals."
	helptext = "Creates a fleshy mass that can be used in certain areas to create a portal to leave the station early."
	button_icon = 'icons/obj/items.dmi'
	button_icon_state = "changeling-organ"
	chemical_cost = 30
	req_human = TRUE
	power_type = CHANGELING_INNATE_POWER

// Create extraction mass
/datum/action/changeling/exfiltration/sting_action(mob/living/user)
	cling.prepare_exfiltration(user, /obj/item/wormhole_jaunter/extraction/changeling)
	cling.remove_specific_power(/datum/action/changeling/exfiltration)
	return TRUE
