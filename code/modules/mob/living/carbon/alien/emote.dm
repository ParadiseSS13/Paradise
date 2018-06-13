/datum/emote/alien/scretch
	key = "scretch"
	key_third_person = "scretches"
	message = "scretches"
	emote_type = EMOTE_AUDIBLE

/datum/emote/alien/tail
	key = "tail"
	key_third_person = "tails"
	message = "waves their tail"

/datum/emote/alien/sign
	key = "sign"
	key_third_person = "signs"
	message = "signs"
	message_param = "signs %t"

/datum/emote/alien/sign/select_param(mob/user, params, msg)
	if(text2num(params))
		return "[msg] the number [params]"
	return msg

/datum/emote/alien/sound
	emote_type = EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(/mob/living/carbon/alien/larva)
	cooldown = 20
	sound_frequency = 1

/datum/emote/alien/sound/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	message = "lets out a waning guttural screech, green blood bubbling from its maw..."
	sound = 'sound/voice/hiss6.ogg'
	sound_volume = 80
	sound_vary = 1

/datum/emote/alien/sound/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars"
	sound = 'sound/voice/hiss5.ogg'
	sound_vary = 1

/datum/emote/alien/sound/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses"
	sound = 'sound/voice/hiss1.ogg'
	sound_volume = 30
	sound_vary = 1

/datum/emote/alien/sound/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows their teeth"
	sound = 'sound/voice/hiss4.ogg'
	sound_volume = 30
	sound_vary = 1
