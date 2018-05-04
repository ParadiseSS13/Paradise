// Emotes shared by all living beings

// These are used by both silicons and carbons so that's why they're kinda snowflaked
/datum/emote/synth
	emote_type = EMOTE_AUDIBLE
	cooldown = 20

/datum/emote/synth/can_run_emote(mob/user, status_check = TRUE)
	if(!..())
		return FALSE
	if (ishuman(user) && user.get_species() != "Machine")
		unusable_message(user, status_check)
		return FALSE
	return TRUE

/datum/emote/synth/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings"
	sound = 'sound/machines/ping.ogg'

/datum/emote/synth/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes"
	sound = 'sound/machines/buzz-sigh.ogg'

/datum/emote/synth/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps"
	sound = 'sound/machines/twobeep.ogg'

/datum/emote/synth/yes
	key = "yes"
	message = "emits an affirmative blip"
	sound = 'sound/machines/synth_yes.ogg'

/datum/emote/synth/no
	key = "no"
	message = "emits a negative blip"
	sound = 'sound/machines/synth_no.ogg'

/datum/emote/synth/buzz_two
	key = "buzz2"
	message = "emits an irritated buzzing sound"
	sound = 'sound/machines/buzz-two.ogg'

/datum/emote/synth/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams"
	sound = 'sound/goonstation/voice/robot_scream.ogg'

/datum/emote/living
	mob_type_blacklist_typecache = list(/mob/living/captive_brain, /mob/living/carbon/brain)

/datum/emote/living/flip
	key = "flip"
	message = "does a flip"
	punct = "!"
	restraint_check = TRUE
	cooldown = 20

/datum/emote/living/flip/run_emote(mob/user, params, type_override)
	. = ..()
	if(.)
		user.SpinAnimation(5,1)

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares"

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares"

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "looks"

/datum/emote/living/twitch
	key = "twitch"
	message = "twitches violently"

/datum/emote/living/twitch_s
	key = "twitch_s"
	key_third_person = "twitches"
	message = "twitches"

/datum/emote/living/bow
	key = "bows"
	key_third_person = "bows"
	message = "bows"
	message_param = "bows to %t"
	restraint_check = TRUE

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily"
	restraint_check = TRUE

/datum/emote/living/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings"
	restraint_check = TRUE
	mob_type_blacklist_typecache = list(/mob/living/captive_brain, /mob/living/carbon/brain, /mob/living/carbon/alien/larva, /mob/living/carbon/slime)

/datum/emote/living/aflap
	key = "aflap"
	key_third_person = "aflaps"
	message = "flaps their wings ANGRILY"
	restraint_check = TRUE
	mob_type_blacklist_typecache = list(/mob/living/captive_brain, /mob/living/carbon/brain, /mob/living/carbon/alien/larva, /mob/living/carbon/slime)

/datum/emote/living/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls"
	restraint_check = TRUE

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily"

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shivers"
	message = "shivers"

/datum/emote/living/quiver
	key = "quiver"
	key_third_person = "quivers"
	message = "quivers"

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles"
