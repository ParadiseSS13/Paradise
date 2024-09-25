/datum/emote/living/simple_animal
	mob_type_allowed_typecache = list(/mob/living/simple_animal)

/datum/emote/living/simple_animal/diona_chirp
	key = "chirp"
	key_third_person = "chirps"
	message = "chirps!"
	sound = "sound/creatures/nymphchirp.ogg"
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/simple_animal/diona)

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
	mob_type_allowed_typecache = list(/mob/living/simple_animal/mouse)

/datum/emote/living/simple_animal/mouse/squeak
	key = "squeak"
	key_third_person = "squeaks"
	message = "squeaks!"
	message_param = "squeaks at %t!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/mouse/squeak/get_sound(mob/living/user)
	var/mob/living/simple_animal/mouse/M = user
	return M.squeak_sound

/datum/emote/living/simple_animal/mouse/idle
	key = "msniff"
	key_third_person = "msniffs"
	message = "sniffs!"
	emote_type = EMOTE_VISIBLE
	cooldown = 20 SECONDS
	audio_cooldown = 20 SECONDS
	emote_type = EMOTE_VISIBLE|EMOTE_FORCE_NO_RUNECHAT
	var/anim_type = "idle1"
	var/duration = 2 SECONDS

/datum/emote/living/simple_animal/mouse/idle/try_run_emote(mob/user, emote_arg, type_override, intentional)
	if(istype(user, /mob/living/simple_animal/mouse/admin))
		var/mob/living/simple_animal/mouse/admin/admin_mouse = user
		if(admin_mouse.jetpack)
			to_chat(user, "<span class='warning'>You can't emote, while you use jetpack.</span>")
			return FALSE
	. = ..()

/datum/emote/living/simple_animal/mouse/idle/run_emote(mob/living/simple_animal/mouse/user, params, type_override, intentional)
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/simple_animal/mouse, do_idle_animation), anim_type, duration)
	. = ..()

/datum/emote/living/simple_animal/mouse/idle/get_sound(mob/living/simple_animal/mouse/user)
	return user.squeak_sound

/datum/emote/living/simple_animal/mouse/idle/shake
	key = "mshake"
	key_third_person = "mshakes"
	message = "shakes!"
	anim_type = "idle2"

/datum/emote/living/simple_animal/mouse/idle/scratch
	key = "mscratch"
	key_third_person = "mscratches"
	message = "scratches itseld!"
	anim_type = "idle3"

/datum/emote/living/simple_animal/mouse/idle/washup
	key = "mwashup"
	key_third_person = "mwashesup"
	message = "washes up itself!"
	anim_type = "idle4"

/datum/emote/living/simple_animal/mouse/idle/flower
	key = "mshowflower"
	key_third_person = "mshowsflower"
	message = "shows a flower!"
	anim_type = "flower"
	duration = 4 SECONDS

/datum/emote/living/simple_animal/mouse/idle/smoke
	key = "msmoke"
	key_third_person = "msmokes"
	message = "smokes!"
	anim_type = "smoke"
	duration = 7 SECONDS

/datum/emote/living/simple_animal/mouse/idle/thumb_up
	key = "mthumbup"
	key_third_person = "mthumbup"
	message = "gives a thumbs-up!"
	anim_type = "thumb_up"
	duration = 4 SECONDS

/datum/emote/living/simple_animal/mouse/idle/dance
	key = "mdance"
	key_third_person = "mdances"
	message = "dances!"
	anim_type = "dance"
	duration = 7 SECONDS

/datum/emote/living/simple_animal/mouse/idle/shakeass
	key = "mshakeass"
	key_third_person = "mshakesass"
	message = "shakes ass!"
	anim_type = "ass"

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
