/datum/preferences/New(client/C, datum/db_query/Q)
	. = ..()
	volume_mixer |= (list("[CHANNEL_CINEMATIC]" = 50,))
