/datum/action/changeling/exfiltration
	name = "Generate Extraction Mass"
	desc = "We separate a specialized organ that will generate an extraction portal. Costs 30 chemicals."
	helptext = "Creates a fleshy mass that can be used in certain areas to create a portal to leave the station early."
	button_overlay_icon_state = "adrenaline"
	chemical_cost = 30
	req_human = TRUE
	power_type = CHANGELING_INNATE_POWER

// Create extraction mass
/datum/action/changeling/exfiltration/sting_action(mob/living/user)
	var/datum/antagonist/changeling/ling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	// No extraction for certian steals/hijack
	var/denied = FALSE
	var/objectives = user.mind.get_all_objectives()
	for(var/datum/objective/goal in objectives)
		if(istype(goal, /datum/objective/steal))
			var/datum/objective/steal/theft = goal
			if(istype(theft.steal_target, /datum/theft_objective/nukedisc) || istype(theft.steal_target, /datum/theft_objective/plutonium_core))
				denied = TRUE
				break
		if(istype(goal, /datum/objective/hijack))
			denied = TRUE
			break
	if(denied)
		to_chat(user, "<span class='warning'>The greater hivemind has deemed your objectives too delicate for an early extraction.</span>")
		ling.remove_specific_power(/datum/action/changeling/exfiltration)
		return

	if(world.time < 60 MINUTES) // 60 minutes of no exfil
		to_chat(user, "<span class='warning'>The hivemind is still amassing an exfiltration portal. Please wait another [round((36000 - world.time) / 600)] minutes before trying again.</span>")
		return
	var/mob/living/L = user
	if(!istype(L))
		return
	var/obj/item/wormhole_jaunter/extraction/changeling/extractor = new /obj/item/wormhole_jaunter/extraction/changeling()
	L.put_in_active_hand(extractor)
	ling.remove_specific_power(/datum/action/changeling/exfiltration)
	return TRUE
