/datum/emote
	cooldown = 1.5 SECONDS
	audio_cooldown = 3 SECONDS

/datum/emote/living/carbon/human/gasp
	message = "задыхается!"
	message_mime = "кажется, задыхается!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	unintentional_stat_allowed = UNCONSCIOUS

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

/datum/emote/living/carbon/human/scream
	message = "кричит!"
	message_mime = "как будто кричит!"
	message_simple = "скулит."
	message_alien = "рычит!"
	message_postfix = "на %t!"
	muzzled_noises = list("очень громко")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH

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
	else
		return pick(human.dna.species.male_scream_sound)

/datum/emote/living/carbon/human/salute
	message = "салютует."
	message_param = "салютует %t."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/salute/get_sound(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(!is_type_in_list(H.shoes, funny_shoes))
		return 'sound/effects/salute.ogg'
	if(is_type_in_list(H.shoes, funny_shoes))
		return 'sound/items/toysqueak1.ogg'

/datum/emote/living/carbon/human/cry
	message = "плачет."
	muzzled_noises = list("слабо", "жалко", "грустно")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_VISIBLE

/datum/emote/living/carbon/human/cry/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_cry_sound)
	else
		return pick(H.dna.species.male_cry_sound)

/datum/emote/living/carbon/giggle
	message = "хихикает."
	message_mime = "бесшумно хихикает!"
	muzzled_noises = list("булькающе")

/datum/emote/living/carbon/giggle/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_giggle_sound)
	else
		return pick(H.dna.species.male_giggle_sound)

/datum/emote/living/carbon/moan
	message = "стонет!"
	message_mime = "как будто стонет!"
	muzzled_noises = list("болезненно")
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/moan/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_moan_sound)
	else
		return pick(H.dna.species.male_moan_sound)

/datum/emote/living/carbon/laugh
	message = "смеется."
	message_mime = "бесшумно смеется!"
	message_param = "смеется над %t."
	muzzled_noises = list("счастливо", "весело")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_VISIBLE

/datum/emote/living/carbon/laugh/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_laugh_sound)
	else
		return pick(H.dna.species.male_laugh_sound)

/datum/emote/living/carbon/yawn
	message = "зевает."
	muzzled_noises = list("устало", "медленно", "сонно")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_SOUND

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

/datum/emote/living/carbon/human/sneeze
	message = "чихает."
	muzzled_noises = list("странно", "остро")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/sneeze/get_sound(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_sneeze_sound)
	else
		return pick(H.dna.species.male_sneeze_sound)

/datum/emote/living/sigh
	message = "вздыхает."
	message_mime = "беззвучно вздыхает."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/sigh/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(H.gender == FEMALE)
		return pick(H.dna.species.female_sigh_sound)
	else
		return pick(H.dna.species.male_sigh_sound)

/datum/emote/living/choke
	message = "подавился!"
	message_mime = "отчаянно хватается за горло!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

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

/datum/emote/living/carbon/human/sniff
	message = "нюхает."
	message_mime = "бесшумно нюхнул."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/sniff/get_sound(mob/living/user)
	. = ..()
	if(user.gender == FEMALE)
		return "modular_ss220/emotes/audio/female/sniff_female.ogg"
	else
		return "modular_ss220/emotes/audio/male/sniff_male.ogg"

/datum/emote/living/sniff
	message = "нюхает."
	message_mime = "бесшумно нюхнул."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/sniff/get_sound(mob/living/user)
	. = ..()
	if(user.gender == FEMALE)
		return "modular_ss220/emotes/audio/female/sniff_female.ogg"
	else
		return "modular_ss220/emotes/audio/male/sniff_male.ogg"

/datum/emote/living/snore
	message = "храпит."
	message_mime = "крепко спит."
	message_simple = "ворочается во сне."
	message_robot = "мечтает об электроовцах"
	emote_type = EMOTE_AUDIBLE | EMOTE_SOUND
	stat_allowed = CONSCIOUS
	max_stat_allowed = CONSCIOUS
	unintentional_stat_allowed = UNCONSCIOUS
	max_unintentional_stat_allowed = UNCONSCIOUS

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

/datum/emote/living/dance
	message = "радостно танцует."
	cooldown = 5 SECONDS
	var/dance_time = 3 SECONDS

/datum/emote/living/dance/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	user.spin(dance_time, pick(0.1 SECONDS, 0.2 SECONDS))
	user.do_jitter_animation(rand(8 SECONDS, 16 SECONDS), dance_time / 4)

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

/datum/emote/living/carbon/human/fart
	message = "пердит."
	message_param = "пердит в направлении %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	muzzle_ignore = TRUE
	only_forced_audio = TRUE
	bypass_unintentional_cooldown = TRUE
	sound = 'modular_ss220/emotes/audio/fart.ogg'

////////////////////
/// Keybindings ///
//////////////////
/datum/keybinding/emote/carbon/human/hem
	linked_emote = /datum/emote/living/carbon/human/hem
	name = "Хныкать"

/datum/keybinding/emote/carbon/human/scratch
	linked_emote = /datum/emote/living/carbon/human/scratch
	name = "Чесаться"

/datum/keybinding/emote/carbon/human/whistle
	linked_emote = /datum/emote/living/carbon/human/whistle
	name = "Свистеть"

/datum/keybinding/emote/carbon/human/snuffle
	linked_emote = /datum/emote/living/carbon/human/snuffle
	name = "Шмыгать носом"

/datum/keybinding/emote/carbon/human/roar
	linked_emote = /datum/emote/living/carbon/human/roar
	name = "Рычать"

/datum/keybinding/emote/carbon/human/rumble
	linked_emote = /datum/emote/living/carbon/human/rumble
	name = "Урчать"

/datum/keybinding/emote/carbon/human/threat
	linked_emote = /datum/emote/living/carbon/human/threat
	name = "Угрожающе рычать"

/datum/keybinding/emote/carbon/human/purr
	linked_emote = /datum/emote/living/carbon/human/purr
	name = "Мурчать"

/datum/keybinding/emote/carbon/human/purrl
	linked_emote = /datum/emote/living/carbon/human/purrl
	name = "Мурчать подольше"

/datum/keybinding/emote/carbon/human/waves
	linked_emote = /datum/emote/living/carbon/human/waves_k
	name = "Взмахнуть усиками"

/datum/keybinding/emote/carbon/human/wiggles
	linked_emote = /datum/emote/living/carbon/human/wiggles
	name = "Шевелить усиками"
