/datum/emote/living/simple_animal/slime
	mob_type_allowed_typecache = list(/mob/living/simple_animal/slime)
	/// Apply mood of the emote
	var/mood

/datum/emote/living/simple_animal/slime/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE

	if(mood)
		var/mob/living/simple_animal/slime/S = user
		S.mood = mood

/datum/emote/living/simple_animal/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "bounces in place."

/datum/emote/living/simple_animal/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "jiggles!"

/datum/emote/living/simple_animal/slime/light
	key = "light"
	key_third_person = "lights"
	message = "lights up for a bit, then stops."

/datum/emote/living/simple_animal/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "vibrates!"

/datum/emote/living/simple_animal/slime/noface
	key = "noface"
	mood = null

/datum/emote/living/simple_animal/slime/smile
	key = "smile"
	mood = "mischevous"

/datum/emote/living/simple_animal/slime/colon_three
	key = ":3"
	mood = ":33"

/datum/emote/living/simple_animal/slime/pout
	key = "pout"
	mood = "pout"

/datum/emote/living/simple_animal/slime/sad
	key = "frown"
	mood = "sad"

/datum/emote/living/simple_animal/slime/scowl
	key = "scowl"
	mood = "angry"
