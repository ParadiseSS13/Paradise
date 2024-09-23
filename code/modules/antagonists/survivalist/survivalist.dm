/datum/antagonist/survivalist
	name = "Survivalist"
	special_role = "Survivalist"
	var/greet_message = ""

/datum/antagonist/survivalist/give_objectives()
	add_antag_objective(/datum/objective/survive)

/datum/antagonist/survivalist/greet()
	. = ..()
	. += "<span class='notice'>[greet_message]</span>"

/datum/antagonist/survivalist/guns
	greet_message = "Your own safety matters above all else, and the only way to ensure your safety is to stockpile weapons! Grab as many guns as possible, by any means necessary. Kill anyone who gets in your way."

/datum/antagonist/survivalist/guns/give_objectives()
	add_antag_objective(/datum/objective/steal_five_of_type/summon_guns)
	..()

/datum/antagonist/survivalist/magic
	name = "Amateur Magician"
	greet_message = "Grow your newfound talent! Grab as many magical artefacts as possible, by any means necessary. Kill anyone who gets in your way. As a wonderful magician, you should remember that spellbooks don't mean anything if they are used up."

/datum/antagonist/survivalist/magic/give_objectives()
	add_antag_objective(/datum/objective/steal_five_of_type/summon_magic)
	..()
