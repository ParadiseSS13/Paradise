/obj/structure/musician/piano
	name = "space piano"
	desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
	icon = 'icons/obj/musician.dmi'
	icon_state = "piano"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = list("piano", "r3grand", "crgrand1", "crbright1")

	var/possible_dirs = 4

/obj/structure/musician/piano/proc/rotate()
	setDir(turn(dir, (360 / possible_dirs)))

/obj/structure/musician/piano/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || is_ventcrawling(user))
		return

	if(anchored || move_resist == INFINITY)
		to_chat(user, SPAN_WARNING("[src] appears to be anchored to the ground!"))
		return

	rotate()

/obj/structure/musician/piano/unanchored
	anchored = FALSE

/obj/structure/musician/piano/minimoog
	name = "space minimoog"
	desc = "This is a minimoog, like a space piano, but more spacey!"
	icon_state = "minimoog"

/obj/structure/musician/piano/minimoog/unanchored
	anchored = FALSE

/obj/effect/spawner/random/instrument/piano
	name = "piano/minimoog spawner"
	icon_state = "piano"
	// we're setting this so the piano/minimoog makes sense in the current maps
	dir = EAST
	loot = list(
		/obj/structure/musician/piano,
		/obj/structure/musician/piano/minimoog,
	)
