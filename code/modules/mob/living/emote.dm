/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain)  // nice try

/datum/emote/living/should_play_sound(mob/user, intentional)
	. = ..()
	if(user.mind?.miming)
		return FALSE  // shh
	return .

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes."

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."
	hands_use_check = TRUE

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps."
	message_mime = "opens their mouth rather obnoxiously."
	// TODO EMOTE_AUDIBLE can probably have a default override
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("peculiar")

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	message_mime = "appears to choke!"
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("choking")

/datum/emote/living/cross
	key = "cross"
	key_third_person = "crosses"
	message = "crosses their arms."
	hands_use_check = TRUE

/datum/emote/living/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles."
	message_mime = "appears to chuckle."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Paralyse(2 SECONDS)

/datum/emote/living/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"
	message_mime = "appears to cough!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily."
	hands_use_check = TRUE

/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps!"
	hands_use_check = TRUE

/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	age_based = TRUE
	cooldown = 15 SECONDS
	unintentional_stat_allowed = DEAD
	message = "seizes up and falls limp, their eyes dead and lifeless..."
	message_alien = "seizes up and falls limp, their eyes dead and lifeless..."
	message_robot = "shudders violently for a moment before falling still, its eyes slowly darkening."
	message_AI = "screeches, its screen flickering as its systems slowly halt."
	message_alien = "lets out a waning guttural screech, green blood bubbling from its maw..."
	message_larva = "lets out a sickly hiss of air and falls limply to the floor..."
	message_monkey = "lets out a faint chimper as it collapses and stops moving..."
	message_simple = "stops moving..."

/datum/emote/living/deathgasp/get_sound(mob/living/user)
	. = ..()
	var/death_sound = null
	var/mob/living/simple_animal/S = user
	if(istype(S) && S.deathmessage)
		message_simple = S.deathmessage
	var/mob/living/carbon/human/H = user
	if(istype(H) && H.dna.species)
		message = H.dna.species.death_message
		death_sound = pick(H.dna.species.death_sounds)
	var/mob/living/carbon/alien/A = user
	if(istype(A))
		message_alien = A.death_message
		death_sound = A.death_sound

	return death_sound
/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools."

/datum/emote/living/quiver
	key = "quiver"
	key_third_person = "quivers"
	message = "quivers."

/datum/emote/living/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."

/datum/emote/living/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.SetSleeping(2 SECONDS)

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns."

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags."
	message_mime = "appears to gag."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	message_mime = "giggles silently!"
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

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans!"
	message_mime = "appears to groan!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces."

/datum/emote/living/gurgle
	key = "gurgle"
	key_third_person = "gurgles"
	message = "makes an uncomfortable gurgle."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/inhale/sharp
	key = "inhale_s"
	key_third_person = "inhales sharply!"
	message = "takes a deep breath!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps!"
	hands_use_check = TRUE

/datum/emote/living/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss."
	message_param = "blows a kiss at %t!"

/datum/emote/living/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently!"
	message_param = "laughs at %t."

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "looks."
	message_param = "looks at %t."

/datum/emote/living/bshake
	key = "bshake"
	key_third_person = "bshakes"
	message = "shakes."

/datum/emote/living/shudder
	key = "shudder"
	key_third_person = "shudders"
	message = "shudders."

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points."
	message_param = "points at %t."
	hands_use_check = TRUE

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	// again, /tg/ has some flavor when pointing (like if you only have one leg) that applies debuffs
	// but it's so common that seems unnecessary for here
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.has_left_hand() && !H.has_right_hand())
			if(H.get_num_legs() != 0)
				message_param = "tries to point at %t with a leg."
			else
				// nugget
				message_param = "<span class='userdanger>bumps [user.p_their()] head on the ground</span> trying to motion towards %t."
	// TODO THIS SHOULD PROBABLY ACTUALLY POINT
	return ..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts."

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams."
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human) // Humans get specialized scream.

/datum/emote/living/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(!intentional && isanimal(user))
		return "makes a loud and pained whimper."

/datum/emote/living/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls."

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head."

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."

/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	message_mime = "appears to sigh."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down."

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles."

/datum/emote/living/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly."

/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	message_mime = "sleeps soundly."
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares."
	message_param = "stares at %t."

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms."

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
	message_mime = "makes a rude gesture!"
	emote_type = EMOTE_AUDIBLE

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

/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "twitches."

/datum/emote/living/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers."
	message_mime = "appears hurt."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "smiles weakly."

/datum/emote/living/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null

/datum/emote/living/custom/can_run_emote(mob/user, status_check, intentional)
	. = ..()
	return . && intentional

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return TRUE
	return FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	var/custom_emote
	var/custom_emote_type
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	else if(QDELETED(user))
		return FALSE
	else if(check_mute(user?.client?.ckey, MUTE_IC))
		to_chat(user, "<span class='boldwarning'>You cannot send IC messages (muted).</span>")
		return FALSE
	else if(!params)
		custom_emote = copytext(sanitize(input("Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
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
	message = null
	emote_type = EMOTE_VISIBLE

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	// Trust the user said what they mean
	return message

