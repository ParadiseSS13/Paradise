/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(
		/mob/living/brain,	// nice try
		/mob/living/silicon,
		/mob/living/simple_animal/bot
	)
	message_postfix = "на %t."

/datum/emote/living/should_play_sound(mob/user, intentional)
	. = ..()
	if(user.mind?.miming)
		return FALSE  // shh

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "краснеет."

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "кланяется."
	message_param = "кланяется %t."
	message_postfix = "%t."

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "отрыгивает."
	message_mime = "довольно противно открывает рот."
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("странный")

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "подавился!"
	message_mime = "отчаянно хватается за горло!"
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("рвотный", "громкий")

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "падает!"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.KnockDown(10 SECONDS)

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "радостно танцует."

/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "прыгает!"

/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE  // make sure deathgasp gets runechatted regardless
	age_based = TRUE
	cooldown = 10 SECONDS
	volume = 40
	unintentional_stat_allowed = DEAD
	muzzle_ignore = TRUE // makes sure that sound is played upon death
	bypass_unintentional_cooldown = TRUE  // again, this absolutely MUST play when a user dies, if it can.
	message = "цепенеет и расслабляется, взгляд становится пустым и безжизненным..."
	message_alien = "издает затихающий гортанный визг, из его пасти пузырится зеленая кровь..."
	message_robot = "издаёт короткую серию пронзительных звуковых сигналов, вздрагивает и падает, не функционируя."
	message_AI = "скрипит, мерцая экраном, пока системы медленно выключаются."
	message_larva = "с тошнотворным шипением выдыхает воздух и падает на пол..."
	message_monkey = "издаёт слабый визг, падает и перестаёт двигаться..."
	message_simple = "перестаёт двигаться..."

	mob_type_blacklist_typecache = list(
		/mob/living/brain,
	)

/datum/emote/living/deathgasp/should_play_sound(mob/user, intentional)
	. = ..()
	if(user.is_muzzled() && intentional)
		return FALSE

/datum/emote/living/deathgasp/get_sound(mob/living/user)
	. = ..()

	if(isanimal(user))
		var/mob/living/simple_animal/S = user
		if(S.deathmessage)
			message_simple = S.deathmessage
		return S.death_sound

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species)
			message = H.dna.species.death_message
			return pick(H.dna.species.death_sounds)

	if(isalien(user))
		var/mob/living/carbon/alien/A = user
		message_alien = A.death_message
		return A.death_sound

	if(issilicon(user))
		var/mob/living/silicon/SI = user
		return SI.death_sound

/datum/emote/living/deathgasp/play_sound_effect(mob/user, intentional, sound_path, sound_volume)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return ..()
	// special handling here: we don't want monkeys' gasps to sound through walls so you can actually walk past xenobio
	playsound(user.loc, sound_path, sound_volume, TRUE, -8, frequency = H.get_age_pitch(H.dna.species.max_age) * alter_emote_pitch(user), ignore_walls = !isnull(user.mind))

/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "пускает слюни."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/quiver
	key = "quiver"
	key_third_person = "quivers"
	message = "трепещет."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "смотрит в недоумении."
	message_param = "смотрит в недоумении на %t."

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "выворачивает содержимое желудка."
	message_mime = "будто бы выворачивает содержимое желудка."
	message_param = "выворачивает содержимое желудка на %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "смотрит с ненавистью."
	message_param = "смотрит с ненавистью на %t."

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "скалится в улыбке."

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "корчит рожицу."

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "смотрит."
	message_param = "сморит на %t."

/datum/emote/living/bshake
	key = "bshake"
	key_third_person = "bshakes"
	message = "трясётся."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/shudder
	key = "shudder"
	key_third_person = "shudders"
	message = "содрогается."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "показывает пальцем."
	message_param = "показывает пальцем на %t."
	hands_use_check = TRUE
	target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	emote_target_type = EMOTE_TARGET_ANY

/datum/emote/living/point/act_on_target(mob/user, target)
	if(!target)
		return

	user.pointed(target)

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	// again, /tg/ has some flavor when pointing (like if you only have one leg) that applies debuffs
	// but it's so common that seems unnecessary for here
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.has_left_hand() && !H.has_right_hand())
			if(H.get_num_legs() != 0)
				message_param = "пытается указать ногой на %t."
			else
				// nugget
				message_param = "<span class='userdanger'>ударяется головой о землю</span>, пытаясь двигаться в направлении %t."

	return ..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "надувает губы."

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "кричит!"
	message_mime = "как будто кричит!"
	message_simple = "скулит."
	message_alien = "рычит!"
	emote_type = EMOTE_MOUTH | EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(
		// Humans and silicons get specialized scream.
		/mob/living/carbon/human,
		/mob/living/silicon
	)
	volume = 80

/datum/emote/living/scream/get_sound(mob/living/user)
	. = ..()
	if(isalien(user))
		return "sound/voice/hiss5.ogg"

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "мотает головой."

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "дрожит."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "вздыхает."
	message_mime = "беззвучно вздыхает."
	muzzled_noises = list("слабый")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/sigh/happy
	key = "hsigh"
	key_third_person = "hsighs"
	message = "удовлетворённо вздыхает."
	message_mime = "кажется, удовлетворённо вздыхает"
	muzzled_noises = list("расслабленный", "довольный")

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "садится."

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "улыбается."
	message_param = "улыбается, смотря на %t."

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "самодовольно ухмыляется."
	message_param = "самодовольно ухмыляется, смотря на %t."

/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "шмыгает носом."
	emote_type = EMOTE_AUDIBLE
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "храпит."
	message_mime = "будто храпит."
	message_simple = "шевелится во сне."
	message_robot = "мечтает об электроовцах..."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	// lock it so these emotes can only be used while unconscious
	stat_allowed = UNCONSCIOUS
	max_stat_allowed = UNCONSCIOUS
	unintentional_stat_allowed = UNCONSCIOUS
	max_unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/nightmare
	key = "nightmare"
	message = "ворочается во сне."
	emote_type = EMOTE_VISIBLE
	stat_allowed = UNCONSCIOUS
	max_stat_allowed = UNCONSCIOUS
	unintentional_stat_allowed = UNCONSCIOUS
	max_unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/nightmare/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	user.dir = pick(GLOB.cardinal)

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "пялится."
	message_param = "пялится на %t."

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "разминает руки."
	message_robot = "тестирует приводы."

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "печально опускает голову."

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "раскачивается на месте."

/datum/emote/living/swear
	key = "swear"
	key_third_person = "swears"
	message = "ругается!"
	message_param = "говорит нелестное слово %t!"
	message_mime = "показывает оскорбительный жест!"
	message_simple = "издает недовольный звук!"
	message_robot = "издает особенно оскорбительную серию звуковых сигналов!"
	message_postfix = ", обращаясь к %t!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

	mob_type_blacklist_typecache = list(
		/mob/living/brain,
	)

/datum/emote/living/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "наклоняет голову в сторону."

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "дрожит от страха!"

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "сильно дёргается."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "дёргается."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "хнычет."
	message_mime = "кажется, задет."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	muzzled_noises = list("слабый", "жалкий")

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "сдержанно улыбается."

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null
	mob_type_blacklist_typecache = list(
		/mob/living/brain,	// nice try
	)

	// Custom emotes should be able to be forced out regardless of context.
	// It falls on the caller to determine whether or not it should actually be called.
	unintentional_stat_allowed = DEAD

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	var/static/regex/stop_bad_mime = regex(@"говорит|кричит|шепчет|спрашивает")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, "<span class='danger'>Некорректная эмоция.</span>")
		return TRUE
	return FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	var/custom_emote
	var/custom_emote_type

	if(QDELETED(user))
		return FALSE
	else if(check_mute(user?.client?.ckey, MUTE_IC))
		to_chat(user, "<span class='boldwarning'>Отправка IC сообщение недоступна (muted).</span>")
		return FALSE
	else if(!params)
		custom_emote = tgui_input_text(user, "Выберите эмоцию для отображения.", "Custom Emote")
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = tgui_alert(user, "Эта эмоция видима или слышима?", "Custom Emote", list("Видима", "Слышима"))
			switch(type)
				if("Видима")
					custom_emote_type = EMOTE_VISIBLE
				if("Слышима")
					custom_emote_type = EMOTE_AUDIBLE
				else
					to_chat(user,"<span class='warning'>Использовать эмоцию невозможно, она должна быть слышима или видима.</span>")
					return
	else
		custom_emote = params
		if(type_override)
			custom_emote_type = type_override

	message = custom_emote
	emote_type = custom_emote_type
	. = ..()
	message = initial(message)
	emote_type = initial(emote_type)

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	// Trust the user said what they mean
	return message

