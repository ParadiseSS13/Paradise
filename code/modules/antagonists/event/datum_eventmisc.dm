RESTRICT_TYPE(/datum/antagonist/eventmisc)

/datum/antagonist/eventmisc
	name = "Event"
	job_rank = ROLE_EVENTMISC
	special_role = SPECIAL_ROLE_EVENTMISC
	give_objectives = FALSE
	antag_hud_name = "hudevent"
	antag_hud_type = ANTAG_HUD_EVENTMISC

/datum/antagonist/eventmisc/add_owner_to_gamemode()
	SSticker.mode.eventmiscs |= owner

/datum/antagonist/eventmisc/remove_owner_from_gamemode()
	SSticker.mode.eventmiscs -= owner
