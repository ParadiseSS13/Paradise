/// Sentinel value; passing this as mood sets mood to null.
#define MOOD_RESET "reset"

/datum/emote/living/simple_animal/slime
	mob_type_allowed_typecache = list(/mob/living/simple_animal/slime)
	/// Apply mood of the emote. Set this to MOOD_RESET to cause the emote to reset the mood back to default.
	var/mood

/datum/emote/living/simple_animal/slime/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE

	if(mood)
		var/mob/living/simple_animal/slime/S = user
		if(mood == MOOD_RESET)
			S.mood = null
		else
			S.mood = mood

/datum/emote/living/simple_animal/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "подпрыгивает на месте."

/datum/emote/living/simple_animal/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "трясётся!"

/datum/emote/living/simple_animal/slime/light
	key = "light"
	key_third_person = "lights"
	message = "заливается светом ненадолго и потом гаснет."

/datum/emote/living/simple_animal/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "вибрирует!"

/datum/emote/living/simple_animal/slime/noface
	// mfw no face
	key = "noface"
	mood = MOOD_RESET

/datum/emote/living/simple_animal/slime/smile
	key = "smile"
	mood = "mischievous"

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

#undef MOOD_RESET
