/datum/mood_event/drunk
	mood_change = 3
	description = "Everything just feels better after a drink or two."

/datum/mood_event/drunk/add_effects(param)
	if(!ishuman(owner))
		return
	if(is_species(owner, /datum/species/vox))
		mood_change = -(mood_change)
		description = "Uh-h.. Oh-h.. I really feeling bad after this drink."

/datum/mood_event/quality_revolting
	description = "That drink was the worst thing I've ever consumed."
	mood_change = -4
	timeout = 7 MINUTES

/datum/mood_event/quality_nice
	description = "That drink wasn't bad at all."
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "That drink was pretty good."
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "That drink was great!"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "That drink was amazing!"
	mood_change = 8
	timeout = 7 MINUTES

/datum/mood_event/tajaran_love_milk
	description = "M-m-M-m-Milk"
	mood_change = 4
	timeout = 4 MINUTES

/datum/mood_event/love_coffee
	description = "I LOVE COFFEE!!!"
	mood_change = 4
	timeout = 4 MINUTES

/datum/mood_event/viva
	description = "It's the beginning of a new day"
	mood_change = 8
	timeout = 7 MINUTES
