/datum/emote/living/simple_animal/friendly
	mob_type_allowed_typecache = list(/mob/living/simple_animal/friendly)

/datum/emote/living/simple_animal/friendly/diona_chirp
	key = "chirp"
	key_third_person = "chirps"
	message = "chirps!"
	sound = "sound/creatures/nymphchirp.ogg"
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/simple_animal/friendly/diona)

// Dog emotes

/datum/emote/living/simple_animal/pet/dog
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/dog)

/datum/emote/living/simple_animal/pet/dog/bark
	key = "bark"
	key_third_person = "barks"

/datum/emote/living/simple_animal/pet/dog/bark/get_sound(mob/living/user)
	. = ..()

	var/mob/living/simple_animal/pet/dog/D = user

	message = pick(D.speak_emote)
	return pick(D.bark_sound)

/datum/emote/living/simple_animal/pet/dog/yelp
	key = "yelp"
	key_third_person = "yelps"
	message = "yelps!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/pet/dog/yelp/get_sound(mob/living/user)
	var/mob/living/simple_animal/pet/dog/D = user
	return D.yelp_sound

/datum/emote/living/simple_animal/pet/dog/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls!"
	emote_type = EMOTE_AUDIBLE
	sound = "growl"

// Mouse

/datum/emote/living/simple_animal/mouse
	mob_type_allowed_typecache = list(/mob/living/simple_animal/mouse)

/datum/emote/living/simple_animal/mouse/squeak
	key = "squeak"
	key_third_person = "squeaks"
	message = "squeaks!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/mouse/squeak/get_sound(mob/living/user)
	var/mob/living/simple_animal/mouse/M = user
	return M.squeak_sound

// cat

/datum/emote/living/simple_animal/pet/cat
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/cat)

/datum/emote/living/simple_animal/pet/cat/meow
	key = "meow"
	key_third_person = "meows"
	sound = "sound/creatures/cat_meow.ogg"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/pet/cat/meow/run_emote(mob/user, params, type_override, intentional)

	if(can_run_emote(user, intentional))
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
