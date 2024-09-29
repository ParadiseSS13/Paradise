/datum/emote
	cooldown = 1.5 SECONDS
	audio_cooldown = 3 SECONDS

//////////////////////
/// Living Emotes ///
////////////////////

/datum/emote/living/dance
	cooldown = 5 SECONDS
	var/dance_time = 3 SECONDS

/datum/emote/living/dance/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	user.spin(dance_time, pick(0.1 SECONDS, 0.2 SECONDS))
	user.do_jitter_animation(rand(8 SECONDS, 16 SECONDS), dance_time / 4)
	var/obj/structure/table/danced_on = locate() in user.loc
	if(danced_on)
		SEND_SIGNAL(danced_on, COMSIG_DANCED_ON, user)


/datum/emote/living/choke/get_sound(mob/living/user)
	. = ..()
	if(user.gender == FEMALE)
		return pick(
			"modular_ss220/emotes/audio/female/choke_female_1.ogg",
			"modular_ss220/emotes/audio/female/choke_female_2.ogg",
			"modular_ss220/emotes/audio/female/choke_female_3.ogg")
	else
		return pick(
			"modular_ss220/emotes/audio/male/choke_male_1.ogg",
			"modular_ss220/emotes/audio/male/choke_male_2.ogg",
			"modular_ss220/emotes/audio/male/choke_male_3.ogg")

/datum/emote/living/sigh/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_sigh_sound)
	else
		return pick(H.dna.species.male_sigh_sound)

/datum/emote/living/sniff/get_sound(mob/living/user)
	. = ..()
	if(user.gender == FEMALE)
		return "modular_ss220/emotes/audio/female/sniff_female.ogg"
	else
		return "modular_ss220/emotes/audio/male/sniff_male.ogg"

/datum/emote/living/snore/get_sound(mob/living/user)
	. = ..()
	if(iscarbon(user))
		return pick(
			'modular_ss220/emotes/audio/snore_1.ogg',
			'modular_ss220/emotes/audio/snore_2.ogg',
			'modular_ss220/emotes/audio/snore_3.ogg',
			'modular_ss220/emotes/audio/snore_4.ogg',
			'modular_ss220/emotes/audio/snore_5.ogg',
			'modular_ss220/emotes/audio/snore_6.ogg',
			'modular_ss220/emotes/audio/snore_7.ogg')

//////////////////////
/// Carbon Emotes ///
////////////////////

/datum/emote/living/carbon/moan/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_moan_sound)
	else
		return pick(H.dna.species.male_moan_sound)

/datum/emote/living/carbon/giggle/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_giggle_sound)
	else
		return pick(H.dna.species.male_giggle_sound)

/datum/emote/living/carbon/yawn/get_sound(mob/living/user)
	. = ..()
	if(user.gender == FEMALE)
		return pick(
			"modular_ss220/emotes/audio/female/yawn_female_1.ogg",
			"modular_ss220/emotes/audio/female/yawn_female_2.ogg",
			"modular_ss220/emotes/audio/female/yawn_female_3.ogg")
	else
		return pick(
			"modular_ss220/emotes/audio/male/yawn_male_1.ogg",
			"modular_ss220/emotes/audio/male/yawn_male_2.ogg")

/datum/emote/living/carbon/laugh/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_laugh_sound)
	else
		return pick(H.dna.species.male_laugh_sound)

/////////////////////
/// Human Emotes ///
///////////////////

/datum/emote/living/carbon/human/scream/select_message_type(mob/user, msg, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(H.dna.species?.scream_verb)
		if(H.mind?.miming)
			return "как будто [H.dna.species?.scream_verb]!"
		else
			return "[H.dna.species?.scream_verb]!"

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	var/mob/living/carbon/human/human = user
	if(human.mind?.miming || !istype(human))
		return
	if(human.gender == FEMALE)
		return pick(human.dna.species.female_scream_sound)
	return pick(human.dna.species.male_scream_sound)

/datum/emote/living/carbon/human/gasp/get_sound(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.is_muzzled())
		// If you're muzzled you're not making noise
		return

	if(H.health > 0)
		if(H.gender == FEMALE)
			return pick(H.dna.species.female_gasp_sound)
		else
			return pick(H.dna.species.gasp_sound)

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_dying_gasp_sounds)
	else
		return pick(H.dna.species.male_dying_gasp_sounds)

/datum/emote/living/carbon/human/salute/get_sound(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(!is_type_in_list(H.shoes, funny_shoes))
		return 'sound/effects/salute.ogg'
	if(is_type_in_list(H.shoes, funny_shoes))
		return 'sound/items/toysqueak1.ogg'

/datum/emote/living/carbon/human/cry/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_cry_sound)
	else
		return pick(H.dna.species.male_cry_sound)

/datum/emote/living/carbon/human/sniff/get_sound(mob/living/user)
	. = ..()
	if(user.gender == FEMALE)
		return "modular_ss220/emotes/audio/female/sniff_female.ogg"
	else
		return "modular_ss220/emotes/audio/male/sniff_male.ogg"

/datum/emote/living/carbon/human/sneeze/get_sound(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_sneeze_sound)
	else
		return pick(H.dna.species.male_sneeze_sound)

/datum/emote/living/carbon/human/fart
	vary = TRUE
	muzzle_ignore = TRUE
	only_forced_audio = TRUE
	bypass_unintentional_cooldown = TRUE
	sound = 'modular_ss220/emotes/audio/fart.ogg'

/////////////////////
/// New Emotes ///
///////////////////

/datum/emote/living/carbon/human/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "свистит."
	message_param = "свистит на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_VISIBLE
	sound = "modular_ss220/emotes/audio/whistle.ogg"

/datum/emote/living/carbon/human/snuffle
	key = "snuffle"
	key_third_person = "snuffles"
	message = "нюхает."
	message_param = "нюхает %t."

/datum/emote/living/carbon/human/hem
	key = "hem"
	key_third_person = "hems"
	message = "хмыкает."
	message_param = "хмыкает %t."

/datum/emote/living/carbon/human/scratch
	key = "scratch"
	key_third_person = "scratch"
	message = "чешется."
	message_param = "чешет %t."

/datum/emote/living/carbon/human/roar
	key = "roar"
	key_third_person = "roar"
	message = "рычит."
	message_mime = "бесшумно рычит."
	message_param = "рычит на %t."
	species_type_whitelist_typecache = list(/datum/species/unathi)
	volume = 50
	muzzled_noises = list("раздражённый")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE
	age_based = TRUE

/datum/emote/living/carbon/human/roar/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/unathi/roar_unathi_1.ogg',
		'modular_ss220/emotes/audio/unathi/roar_unathi_2.ogg',
		'modular_ss220/emotes/audio/unathi/roar_unathi_3.ogg')

/datum/emote/living/carbon/human/rumble
	key = "rumble"
	key_third_person = "rumble"
	message = "урчит."
	message_param = "урчит на %t."
	species_type_whitelist_typecache = list(/datum/species/unathi)
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE
	age_based = TRUE
	volume = 50
	muzzled_noises = list("слабо урчащий")

/datum/emote/living/carbon/human/rumble/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/unathi/rumble_unathi_1.ogg',
		'modular_ss220/emotes/audio/unathi/rumble_unathi_2.ogg')

/datum/emote/living/carbon/human/threat
	key = "threat"
	key_third_person = "threat"
	message = "угрожающе рычит."
	message_param = "угрожающе рычит на %t."
	species_type_whitelist_typecache = list(/datum/species/unathi)
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE
	age_based = TRUE
	volume = 80
	muzzled_noises = list("очень раздражённый")

/datum/emote/living/carbon/human/threat/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/unathi/threat_unathi_1.ogg',
		'modular_ss220/emotes/audio/unathi/threat_unathi_2.ogg')

/datum/emote/living/carbon/human/purr
	key = "purr"
	key_third_person = "purr"
	message = "мурчит."
	message_param = "мурчит из-за %t."
	species_type_whitelist_typecache = list(/datum/species/tajaran)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = 'modular_ss220/emotes/audio/tajaran/purr_tajaran.ogg'
	volume = 80
	muzzled_noises = list("слабо")

/datum/emote/living/carbon/human/purrl
	key = "purrl"
	key_third_person = "purrl"
	message = "мурчит."
	message_param = "мурчит из-за %t."
	cooldown = 5 SECONDS
	species_type_whitelist_typecache = list(/datum/species/tajaran)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = 'modular_ss220/emotes/audio/tajaran/purr_tajaran_long.ogg'
	volume = 80
	muzzled_noises = list("слабо")

/datum/emote/living/carbon/human/waves_k
	key = "waves_k"
	key_third_person = "waves_k"
	message = "взмахивает усиками."
	message_param = "взмахивает усиками из-за %t."
	species_type_whitelist_typecache = list(/datum/species/kidan)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_MOUTH
	age_based = TRUE
	volume = 80
	muzzled_noises = list("слабо")

/datum/emote/living/carbon/human/waves_k/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/kidan/waves_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/waves_kidan_2.ogg')

/datum/emote/living/carbon/human/wiggles
	key = "wiggles"
	key_third_person = "wiggles"
	message = "шевелит усиками."
	message_param = "шевелит усиками из-за %t."
	cooldown = 5 SECONDS
	species_type_whitelist_typecache = list(/datum/species/kidan)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_MOUTH
	age_based = TRUE
	volume = 80
	muzzled_noises = list("слабо")

/datum/emote/living/carbon/human/wiggles/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/kidan/wiggles_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/wiggles_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/wiggles_kidan_3.ogg')

/datum/emote/living/carbon/human/whip
	key = "whip"
	key_third_person = "whip"
	message = "ударяет хвостом."
	message_mime = "взмахивает хвостом и бесшумно опускает его на пол."
	message_postfix = ", грозно смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	species_type_whitelist_typecache = list(/datum/species/unathi)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	volume = 75
	audio_cooldown = 3 SECONDS
	sound = 'modular_ss220/emotes/audio/unathi/whip_short_unathi.ogg'

/datum/emote/living/carbon/human/whip/whip_l
	key = "whips"
	key_third_person = "whips"
	message = "хлестает хвостом."
	species_type_whitelist_typecache = list(/datum/species/unathi)
	audio_cooldown = 6 SECONDS
	sound = 'modular_ss220/emotes/audio/unathi/whip_unathi.ogg'

/datum/emote/living/carbon/human/whip/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE

	if(!can_wag(user))
		return FALSE

	return TRUE

/datum/emote/living/carbon/human/warble/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/skrell/warble_1.ogg',
		'modular_ss220/emotes/audio/skrell/warble_2.ogg')

/datum/emote/living/carbon/human/croak
	key = "croak"
	key_third_person = "croak"
	message = "квакает."
	message_param = "квакает на %t."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/croak/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/skrell/croak_1.ogg',
		'modular_ss220/emotes/audio/skrell/croak_2.ogg',
		'modular_ss220/emotes/audio/skrell/croak_3.ogg')

/datum/emote/living/carbon/human/croak/anger
	key = "croak_anger"
	key_third_person = "croak_anger"
	message = "гневно квакает!"
	message_param = "гневно квакает на %t."
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	volume = 80
	species_type_whitelist_typecache = list(/datum/species/skrell)

/datum/emote/living/carbon/human/croak/anger/get_sound(mob/living/user)
	return pick(
		'modular_ss220/emotes/audio/skrell/anger_1.ogg',
		'modular_ss220/emotes/audio/skrell/anger_2.ogg')

/datum/emote/living/carbon/human/bark
	key = "bark"
	key_third_person = "bark"
	message = "гавкает."
	message_param = "гавкает на %t."
	sound = 'modular_ss220/emotes/audio/bark.ogg'
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	vary = TRUE
	cooldown = 10 SECONDS
	volume = 30

/datum/emote/living/carbon/human/wbark
	key = "wbark"
	key_third_person = "wbark"
	message = "дважды гавкает."
	message_param = "дважды гавкает на %t."
	sound = 'modular_ss220/emotes/audio/wbark.ogg'
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)
	emote_type = EMOTE_AUDIBLE
	age_based = TRUE
	vary = TRUE
	cooldown = 10 SECONDS
	volume = 30

/datum/emote/living/carbon/human/ururu
	key = "ururu"
	key_third_person = "ururu"
	message = "урчит."
	message_param = "урчит на %t."
	sound = 'modular_ss220/emotes/audio/vulpkanin/purr.ogg'
	species_type_whitelist_typecache = list(/datum/species/vulpkanin)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	cooldown = 10 SECONDS
	volume = 50
	muzzled_noises = list("слабо")

/datum/emote/living/carbon/human/meow
	key = "meow"
	key_third_person = "meow"
	message = "мяукает."
	message_param = "мяукает на %t."
	sound = 'modular_ss220/emotes/audio/tajaran/meow_tajaran.ogg'
	species_type_whitelist_typecache = list(/datum/species/tajaran)
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE
	vary = TRUE
	cooldown = 10 SECONDS
	volume = 50
	muzzled_noises = list("слабо")

/datum/emote/living/carbon/human/mrow
	key = "mrow"
	key_third_person = "mrow"
	message = "раздражённо мяукает."
	message_param = "раздражённо мяукает на %t."
	sound = 'modular_ss220/emotes/audio/tajaran/annoyed_meow_tajaran.ogg'
	species_type_whitelist_typecache = list(/datum/species/tajaran)
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE
	vary = TRUE
	cooldown = 10 SECONDS
	volume = 70
	muzzled_noises = list("слабо")
