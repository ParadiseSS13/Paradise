/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(
		/mob/living/brain,	// nice try
		/mob/living/silicon,
		/mob/living/simple_animal/bot
	)
	message_postfix = "at %t."

/datum/emote/living/should_play_sound(mob/user, intentional)
	. = ..()
	if(user.mind?.miming)
		return FALSE  // shh

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes."

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."
	message_postfix = "to %t."

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps."
	message_mime = "opens their mouth rather obnoxiously."
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("peculiar")

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	message_mime = "clutches their throat desperately!"
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("gagging", "strong")

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses!"

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.KnockDown(10 SECONDS)

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily."

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
	message = "seizes up and falls limp, their eyes dead and lifeless..."
	message_alien = "lets out a waning guttural screech, green blood bubbling from its maw..."
	message_robot = "shudders violently for a moment before falling still, its eyes slowly darkening."
	message_AI = "screeches, its screen flickering as its systems slowly halt."
	message_larva = "lets out a sickly hiss of air and falls limply to the floor..."
	message_monkey = "lets out a faint chimper as it collapses and stops moving..."
	message_simple = "stops moving..."

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
	message = "drools."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/quiver
	key = "quiver"
	key_third_person = "quivers"
	message = "quivers."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns."
	message_param = "frowns at %t."

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags."
	message_mime = "appears to gag."
	message_param = "gags at %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins."

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces."

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "looks."
	message_param = "looks at %t."

/datum/emote/living/bshake
	key = "bshake"
	key_third_person = "bshakes"
	message = "shakes."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/shudder
	key = "shudder"
	key_third_person = "shudders"
	message = "shudders."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points."
	message_param = "points at %t."
	hands_use_check = TRUE

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
			if(H.get_num_legs() != 0 && !HAS_TRAIT(H, TRAIT_PARAPLEGIC))
				message_param = "tries to point at %t with a leg."
			else
				// nugget
				message_param = "<span class='userdanger'>bumps [user.p_their()] head on the ground</span> trying to motion towards %t."

	return ..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts."

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	message_simple = "whimpers."
	message_alien = "roars!"
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
	message = "shakes their head."

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	message_mime = "appears to sigh."
	muzzled_noises = list("weak")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/sigh/happy
	key = "hsigh"
	key_third_person = "hsighs"
	message = "sighs contentedly."
	message_mime = "appears to sigh contentedly"
	muzzled_noises = list("chill", "relaxed")

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down."

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles."
	message_param = "smiles at %t."

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly."
	message_param = "grins smugly at %t."

/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	message_mime = "sleeps soundly."
	message_simple = "stirs in their sleep."
	message_robot = "dreams of electric sheep..."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	// lock it so these emotes can only be used while unconscious
	stat_allowed = UNCONSCIOUS
	max_stat_allowed = UNCONSCIOUS
	unintentional_stat_allowed = UNCONSCIOUS
	max_unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/nightmare
	key = "nightmare"
	message = "writhes in their sleep."
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
	message = "stares."
	message_param = "stares at %t."

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms."
	message_robot = "tests their actuators."

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks down sadly."

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily."

/datum/emote/living/swear
	key = "swear"
	key_third_person = "swears"
	message = "says a swear word!"
	message_param = "says a swear word at %t!"
	message_mime = "makes a rude gesture!"
	message_simple = "makes an angry noise!"
	message_robot = "makes a particularly offensive series of beeps!"
	message_postfix = "at %t!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

	mob_type_blacklist_typecache = list(
		/mob/living/brain,
	)

/datum/emote/living/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "tilts their head to the side."

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles in fear!"

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "twitches."
	unintentional_stat_allowed = UNCONSCIOUS

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers."
	message_mime = "appears hurt."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	muzzled_noises = list("weak", "pathetic")

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "smiles weakly."

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
	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return TRUE
	return FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	var/custom_emote
	var/custom_emote_type

	if(QDELETED(user))
		return FALSE
	else if(check_mute(user?.client?.ckey, MUTE_IC))
		to_chat(user, "<span class='boldwarning'>You cannot send IC messages (muted).</span>")
		return FALSE
	else if(!params)
		custom_emote = tgui_input_text(user, "Choose an emote to display.", "Custom Emote")
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = tgui_alert(user, "Is this a visible or hearable emote?", "Custom Emote", list("Visible", "Hearable"))
			switch(type)
				if("Visible")
					custom_emote_type = EMOTE_VISIBLE
				if("Hearable")
					custom_emote_type = EMOTE_AUDIBLE
				else
					to_chat(user,"<span class='warning'>Unable to use this emote, must be either hearable or visible.</span>")
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

