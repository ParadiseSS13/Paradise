/datum/objective/assassinate/mindshielded
	name = "Assassinate mindshielded"
	flags_target = MINDSHIELDED_TARGET

/datum/objective/assassinate/nomindshield
	name = "Assassinate non-mindshielded"
	flags_target = UNMINDSHIELDED_TARGET

/datum/objective/assassinate/syndicate
	name = "Assassinate syndicate agent"
	flags_target = SYNDICATE_TARGET

/datum/objective/assassinate/syndicate/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Assassinate [target.current.real_name], the Syndicate agent undercover as the [target.assigned_role]."
		if(target && length(target.antag_datums))
			for(var/datum/antagonist/traitor/A in target.antag_datums)
				A.queue_backstab()

/datum/objective/assassinateonce/arc
	name = "Assassinate once (ARC)"
	target_jobs = list("Head of Personnel", "Quartermaster", "Cargo Technician", "Bartender", "Chef", "Botanist", "Geneticist", "Virologist")
