/datum/emote/living/simple_animal
	mob_type_allowed_typecache = list(/mob/living/simple_animal)

/datum/emote/living/simple_animal/diona_chirp
	key = "chirp"
	key_third_person = "chirps"
	message = "chirps!"
	sound = "sound/creatures/nymphchirp.ogg"
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/basic/diona_nymph)

// Dog emotes

/datum/emote/living/simple_animal/pet/dog
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/dog)

/datum/emote/living/simple_animal/pet/dog/bark
	key = "bark"
	key_third_person = "barks"
	message = "barks."
	message_param = "barks at %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/pet/dog/bark/get_sound(mob/living/user)
	. = ..()

	var/mob/living/simple_animal/pet/dog/D = user
	message = pick(D.speak_emote)
	return pick(D.bark_sound)

/datum/emote/living/simple_animal/pet/dog/yelp
	key = "yelp"
	key_third_person = "yelps"
	message = "yelps!"
	message_param = "yelps at %t!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/pet/dog/yelp/get_sound(mob/living/user)
	var/mob/living/simple_animal/pet/dog/D = user
	return D.yelp_sound

/datum/emote/living/simple_animal/pet/dog/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls!"
	message_param = "growls at %t!"
	emote_type = EMOTE_AUDIBLE
	sound = "growl"

// Mouse

/datum/emote/living/simple_animal/mouse
	mob_type_allowed_typecache = list(/mob/living/basic/mouse)

/datum/emote/living/simple_animal/mouse/squeak
	key = "squeak"
	key_third_person = "squeaks"
	message = "squeaks!"
	message_param = "squeaks at %t!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/mouse/squeak/get_sound(mob/living/user)
	var/mob/living/basic/mouse/M = user
	return M.squeak_sound

// cat

/datum/emote/living/simple_animal/pet/cat
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/cat)

/datum/emote/living/simple_animal/pet/cat/meow
	key = "meow"
	key_third_person = "meows"
	message = "meows."
	message_param = "meows at %t."
	sound = "sound/creatures/cat_meow.ogg"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/pet/cat/meow/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/simple_animal/pet/cat/C = user
	message = pick(C.emote_hear)
	. = ..()

/datum/emote/living/simple_animal/pet/cat/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses!"
	message_param = "hisses at %t!"

/datum/emote/living/simple_animal/pet/cat/purr
	key = "purr"
	key_third_person = "purrs"
	message = "purrs."

/datum/emote/living/sit/cat
	message = null
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/cat)

/datum/emote/living/sit/cat/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/simple_animal/pet/cat/C = user
	C.sit()
	return TRUE
