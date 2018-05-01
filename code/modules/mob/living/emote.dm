// Emotes shared by all living beings

// These are used by both silicons and carbons so that's why they're kinda snowflaked
/datum/emote/synth
	emote_type = EMOTE_AUDIBLE

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

/datum/emote/living/flip
	key = "flip"
	message = "does a flip"
	punct = "!"
	cooldown = 20

/datum/emote/living/flip/run_emote(mob/user, params, type_override)
	. = ..()
	if(.)
		user.SpinAnimation(5,1)
