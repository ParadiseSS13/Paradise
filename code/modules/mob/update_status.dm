// These are procs that cause immediate updates to features of the mob - prefixed with `update_`
// Procs that have a stacking effect depending on how many times they are called
// do not belong in this file - those go in `life.dm` instead, with the prefix `handle_`

// OVERLAY/SIGHT PROCS

// These return 0 if they are not applying an overlay, and 1 if they are

// Call this to immediately apply blindness effects, instead of
// waiting for the next `Life` tick
/mob/proc/update_blind_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_blurry_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_druggy_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_nearsighted_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_sleeping_effects()
	// No handling for this on the mob level
	return 0

/mob/proc/update_tint_effects()
	// No handling for this on the mob level
	return 0

// Procs that give information about the status of the mob

/mob/proc/can_hear()
	. = 1

/mob/proc/has_vision(information_only = FALSE)
	return 1

/mob/proc/can_speak()
	return 1

/mob/proc/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_lying = FALSE)
	return FALSE

/mob/proc/restrained(ignore_grab)
	// All are created free
	return FALSE

/mob/proc/get_restraining_item()
	return null

// Procs that update other things about the mob

// Does various animations - Jitter, Flying, Spinning
/mob/proc/update_animations()
	if(flying)
		animate(src, pixel_y = pixel_y + 5 , time = 10, loop = 1, easing = SINE_EASING)
		animate(pixel_y = pixel_y - 5, time = 10, loop = 1, easing = SINE_EASING)

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/mob/proc/update_canmove()
	return 1
