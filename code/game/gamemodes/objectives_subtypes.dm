/datum/objective/debrain/science
	name = "Debrain science"
	target_department = DEPARTMENT_SCIENCE

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

/datum/objective/assassinate/medical
	name = "Assassinate medical"
	target_department = DEPARTMENT_MEDICAL

/datum/objective/assassinate/engineering
	name = "Assassinate engineering"
	target_department = DEPARTMENT_ENGINEERING

/datum/objective/assassinateonce/animal_user
	name = "Assassinate animal user"
	target_jobs = list("Head of Personnel", "Quartermaster", "Cargo Technician", "Bartender", "Chef", "Botanist", "Geneticist", "Virologist")

/datum/objective/assassinateonce/command
	name = "Assassinate command once"
	target_department = DEPARTMENT_COMMAND

/datum/objective/assassinateonce/medical
	name = "Assassinate medical once"
	target_department = DEPARTMENT_MEDICAL

/datum/objective/assassinateonce/science
	name = "Assassinate science once"
	target_department = DEPARTMENT_SCIENCE

/datum/objective/assassinateonce/engineering
	name = "Assassinate engineering once"
	target_department = DEPARTMENT_ENGINEERING

/datum/objective/steal/cybersun
	name = "Steal Item (Cybersun)"
	steal_list = list(/datum/theft_objective/antique_laser_gun, /datum/theft_objective/nukedisc, /datum/theft_objective/hoslaser)

/datum/objective/steal/interdyne
	name = "Steal Item (Interdyne)"
	steal_list = list(/datum/theft_objective/hypospray, /datum/theft_objective/defib, /datum/theft_objective/krav)

/datum/objective/steal/self
	name = "Steal Item (SELF)"
	steal_list = list(/datum/theft_objective/reactive, /datum/theft_objective/steal/documents, /datum/theft_objective/hand_tele)

/datum/objective/steal/electra
	name = "Steal Item (Electra Dynamics)"
	steal_list = list(/datum/theft_objective/supermatter_sliver, /datum/theft_objective/plutonium_core, /datum/theft_objective/captains_modsuit)

/datum/objective/steal/faid
	name = "Steal Item (FAID)"
	steal_list = list(/datum/theft_objective/blueprints, /datum/theft_objective/steal/documents)
