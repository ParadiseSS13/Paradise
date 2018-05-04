/datum/emote/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "bounces in place"

/datum/emote/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "jiggles in place"
	punct = "!"

/datum/emote/slime/light
	key = "light"
	key_third_person = "lights"
	message = "lights up for a bit, then stops"

/datum/emote/slime/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans"
	emote_type = EMOTE_AUDIBLE

/datum/emote/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "vibrates"
	punct = "!"

/datum/emote/slime/mood
	var/mood = ""

/datum/emote/slime/mood/run_emote(mob/living/carbon/slime/user, params, type_override)
	user.mood = mood
	user.regenerate_icons()

/datum/emote/slime/mood/noface
	key = "noface"
	key_third_person = "nofaces"
	mood = null

/datum/emote/slime/mood/smile
	key = "smile"
	key_third_person = "smiles"
	mood = "mischievous"

/datum/emote/slime/mood/colon_three
	key = ":3"
	key_third_person = ":33"
	mood = ":33"

/datum/emote/slime/mood/pout
	key = "pout"
	key_third_person = "pouts"
	mood = "pout"

/datum/emote/slime/mood/frown
	key = "frown"
	key_third_person = "frowns"
	mood = "sad"

/datum/emote/slime/mood/scowl
	key = "scowl"
	key_third_person = "scowls"
	mood = "angry"
