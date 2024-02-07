/datum/mood_event/high
	mood_change = 6
	description = "Woooow duudeeeeee... I'm tripping baaalls..."

/datum/mood_event/smoked
	description = "I have had a smoke recently."
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = "I think I took a bit too much of that [drug_name]!"
