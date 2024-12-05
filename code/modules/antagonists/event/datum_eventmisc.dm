RESTRICT_TYPE(/datum/antagonist/event_misc)

/datum/antagonist/event_misc
	name = "Event"
	job_rank = ROLE_EVENTMISC
	special_role = SPECIAL_ROLE_EVENTMISC
	give_objectives = FALSE
	antag_hud_name = "hudeventmisc"
	antag_hud_type = ANTAG_HUD_EVENTMISC

/datum/antagonist/event_misc/add_owner_to_gamemode()
	SSticker.mode.eventmiscs |= owner

/datum/antagonist/event_misc/remove_owner_from_gamemode()
	SSticker.mode.eventmiscs -= owner
