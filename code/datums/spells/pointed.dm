// Parent type for easy setup
/datum/spell/pointed
	var/cast_range = 7

/datum/spell/pointed/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/C = new()
	C.range = cast_range
	C.try_auto_target = FALSE
	return C
