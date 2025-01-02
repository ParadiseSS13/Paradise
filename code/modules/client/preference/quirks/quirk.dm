GLOBAL_LIST_EMPTY(quirk_datums)
/datum/quirk
	var/name
	var/desc = "Uh oh sisters! No description!"
	var/quirk_type = QUIRK_NEUTRAL
	var/cost = 0
	var/mob/living/carbon/human/owner
	/// If only organic characters can have it
	var/organic_only = FALSE
	/// If having this bars you from rolling sec/command
	var/blacklisted = FALSE


