/datum/objective/flock_relay
	name = "Broadcast"
	objective_name = "Directive"
	explanation_text = "Broadcast the Signal"

/datum/objective/flock_relay/check_completion()
	var/mob/camera/flock/ghostbird = owner.current
	return ghostbird.flock.flock_game_status == FLOCK_ENDGAME_VICTORY
