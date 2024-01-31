/datum/objective/debrain/command
	name = "Debrain command"
	target_jobs = list("Captain", "Head of Personnel", "Head of Security", "Research Director", "Chief Engineer", "Chief Medical Officer", "Quartermaster")

/datum/objective/debrain/science
	name = "Debrain science"
	target_jobs = list("Research Director", "Scientist", "Roboticist", "Geneticist")

/datum/objective/assassinate/mindshielded
	name = "Assassinate mindshielded"
	mindshielded_target = TRUE

/datum/objective/assassinate/nomindshield
	name = "Assassinate non-mindshielded"
	not_mindshielded_target = TRUE

/datum/objective/assassinate/syndicate
	name = "Assassinate syndicate agent"
	syndicate_target = TRUE

/datum/objective/assassinate/medical
	name = "Assassinate medical"
	target_jobs = list("Chief Medical Officer", "Medical Doctor", "Paramedic", "Chemist", "Virologist", "Psychologist", "Coroner")

/datum/objective/assassinate/engineering
	name = "Assassinate engineering"
	target_jobs = list("Chief Engineer", "Station Engineer", "Atmospherics Technician")

/datum/objective/assassinateonce/animal_abuser
	name = "Assassinate animal abuser once"
	target_jobs = list("Cargo Technician", "Bartender", "Chef", "Botanist", "Geneticist", "Scientist", "Virologist")

/datum/objective/assassinateonce/animal_abuser/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Teach [target.current.real_name], the animal abuser and alleged [target.assigned_role], a lesson they will not forget. The target only needs to die once for success."

/datum/objective/assassinateonce/command
	name = "Assassinate command once"
	target_jobs = list("Captain", "Head of Personnel", "Head of Security", "Research Director", "Chief Engineer", "Chief Medical Officer", "Quartermaster")

/datum/objective/assassinateonce/medical
	name = "Assassinate medical once"
	target_jobs = list("Chief Medical Officer", "Medical Doctor", "Paramedic", "Chemist", "Virologist", "Psychologist", "Coroner")

/datum/objective/assassinateonce/science
	name = "Assassinate science once"
	target_jobs = list("Research Director", "Scientist", "Roboticist", "Geneticist")

/datum/objective/assassinateonce/engineering
	name = "Assassinate engineering once"
	target_jobs = list("Chief Engineer", "Station Engineer", "Atmospherics Technician")

