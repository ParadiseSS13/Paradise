/**
 * Emotes usable by humanoid xenomorphs.
 */
/datum/emote/living/carbon/alien/humanoid
	mob_type_allowed_typecache = list(/mob/living/carbon/alien/humanoid)

/datum/emote/living/carbon/alien/humanoid/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	message_param = "roars at %t!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	sound = "sound/voice/hiss5.ogg"
	volume = 80

/datum/emote/living/carbon/alien/humanoid/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses!"
	message_param = "hisses at %t!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	sound = "sound/voice/hiss1.ogg"
	volume = 30

/datum/emote/living/carbon/alien/humanoid/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth."
	message_param = "gnarls and flashes its teeth at %t."
	sound = "sound/voice/hiss4.ogg"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	volume = 30
