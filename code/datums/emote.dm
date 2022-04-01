// Emote datums.
// Check under mob directories for where these get implemented.

// Emote types.
// These determine how the emote is treated when not directly visible (or audible).

/// Emote is visible. These emotes will be runechatted.
#define EMOTE_VISIBLE (1<<0)
/// Emote is audible (in character).
#define EMOTE_AUDIBLE (1<<1)
/// Emote makes a sound. These emotes will specifically not be runechatted.
#define EMOTE_SOUND (1<<2)
/// Regardless of its existing flags, this emote will not be sent to runechat.
#define EMOTE_FORCE_NO_RUNECHAT (1<<3)
/// This emote uses the mouth, and so should be blocked if the user is muzzled or can't breathe (for humans).
#define EMOTE_MOUTH (1<<4)

// User audio cooldown system.
// This is a value stored on the user and represents their ability to perform emotes.
/// The user is not on emote cooldown, and is ready to emote whenever.
#define EMOTE_READY (1<<0)
/// The user can spam emotes to their heart's content.
#define EMOTE_INFINITE (1<<1)
/// The user cannot emote as they have been blocked by an admin.
#define EMOTE_ADMIN_BLOCKED (1<<2)
/// The user cannot emote until their cooldown expires.
#define EMOTE_ON_COOLDOWN (1<<3)

/// Marker to separate an emote key from its parameters in user input.
#define EMOTE_PARAM_SEPARATOR "-"

/// Default cooldown for emotes
#define DEFAULT_EMOTE_COOLDOWN 2 SECONDS
/// Default cooldown for emotes that make audio.
#define AUDIO_EMOTE_COOLDOWN 10 SECONDS

// Cooldown stuff for emotes

/**
 * # Emote
 *
 * Most of the text that's not someone talking is based off of this.
 *
 * Yes, the displayed message is stored on the datum, it would cause problems
 * for emotes with a message that can vary, but that's handled differently in
 * run_emote(), so be sure to use can_message_change if you plan to have
 * different displayed messages from player to player.
 *
 */
/datum/emote
	/// What calls the emote.
	var/key = ""
	/// This will also call the emote.
	var/key_third_person = ""
	/// Message displayed when emote is used.
	var/message = ""
	/// Message displayed if the user is a mime.
	var/message_mime = ""
	/// Message displayed if the user is a grown alien.
	var/message_alien = ""
	/// Message displayed if the user is an alien larva.
	var/message_larva = ""
	/// Message displayed if the user is a robot.
	var/message_robot = ""
	/// Message displayed if the user is an AI.
	var/message_AI = ""
	/// Message displayed if the user is a monkey.
	var/message_monkey = ""
	/// Message to display if the user is a simple_animal.
	var/message_simple = ""
	/// Sounds emitted when the user is muzzled. Generally used like "[user] makes a pick(muzzled_noises) noise!"
	var/muzzled_noises = list("strong ", "weak ", "")
	/// Message with %t at the end to allow adding params to the message, like for mobs doing an emote relatively to something else.
	var/message_param = ""
	/// Description appended to the emote name describing what the target should be, like for help commands.
	var/param_desc = "target"
	/// Whether the emote is visible or audible.
	var/emote_type = EMOTE_VISIBLE
	/// Checks if the mob can use its hands before performing the emote.
	var/hands_use_check = FALSE
	/// Will only work if the emote is EMOTE_AUDIBLE.
	var/muzzle_ignore = FALSE
	/// Types that are allowed to use that emote.
	var/list/mob_type_allowed_typecache = /mob
	/// Types that are NOT allowed to use that emote.
	var/list/mob_type_blacklist_typecache
	/// Types that can use this emote regardless of their state.
	var/list/mob_type_ignore_stat_typecache
	/// Species types which the emote will be exclusively available to.
	var/species_type_whitelist_typecache
	/// In which state can you use this emote? (Check stat.dm for a full list of them)
	var/stat_allowed = CONSCIOUS
	/// In which state can this emote be forced out of you?
	var/unintentional_stat_allowed = CONSCIOUS
	/// Sound to play when emote is called.
	var/sound
	/// Whether or not to vary the sound of the emote.
	var/vary = FALSE
	/// Whether or not to adjust the frequency of the emote sound based on age.
	var/age_based = FALSE
	/// Can only code call this event instead of the player.
	var/only_forced_audio = FALSE
	/// The cooldown between the uses of the emote.
	var/cooldown = DEFAULT_EMOTE_COOLDOWN
	/// Does this message have a message that can be modified by the user?
	var/can_message_change = FALSE
	/// How long is the cooldown on the audio of the emote, if it has one?
	var/audio_cooldown = AUDIO_EMOTE_COOLDOWN
	/// How loud is the audio emote?
	var/volume = 50

/datum/emote/New()
	if(message_param && !param_desc)
		CRASH("emote [src] was given a message parameter without a description.")
	if(ispath(mob_type_allowed_typecache))
		switch(mob_type_allowed_typecache)
			if(/mob)
				mob_type_allowed_typecache = GLOB.typecache_mob
			if(/mob/living)
				mob_type_allowed_typecache = GLOB.typecache_living
			else
				mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	else
		mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)
	species_type_whitelist_typecache = typecacheof(species_type_whitelist_typecache)

/**
 * Handles the modifications and execution of emotes.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 * * type_override - Override to the current emote_type.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns TRUE if it was able to run the emote, FALSE otherwise.
 */
/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = TRUE
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	var/msg = select_message_type(user, message, intentional)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(!msg)
		return

	if(isobserver(user))
		log_ghostemote(msg, user)
	else
		log_emote(msg, user)

	var/dchatmsg = "<b>[user]</b> [msg]"

	var/tmp_sound = get_sound(user)
	// If our sound emote is forced by code, don't worry about cooldowns at all.
	if(tmp_sound && should_play_sound(user, intentional) && (!intentional || !user.start_audio_emote_cooldown(type, audio_cooldown)))
		if(age_based && istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user

			playsound(user, tmp_sound, volume, vary, frequency = H.get_age_pitch())
		else
			playsound(user, tmp_sound, volume, vary)

	var/user_turf = get_turf(user)
	if (user.client)
		for(var/mob/ghost as anything in GLOB.dead_mob_list)
			if(!ghost.client || isnewplayer(ghost))
				continue
			if(ghost.client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTSIGHT && !(ghost in viewers(user_turf, null)))
				ghost.show_message("<span class='emote'>[ghost_follow_link(user, ghost)] [dchatmsg]</span>")

	if(emote_type & EMOTE_VISIBLE)
		user.audible_message(dchatmsg, deaf_message = "<span class='emote'>You see how <b>[user]</b> [msg]</span>")
	else if(!user.mind?.miming)
		user.visible_message(dchatmsg, blind_message = "<span class='emote'>You hear how <b>[user]</b> [msg]</span>")

	if(!(emote_type & (EMOTE_FORCE_NO_RUNECHAT | EMOTE_SOUND)))
		var/runechat_text = msg
		if(length(msg) > 100)
			runechat_text = "[copytext(msg, 1, 101)]..."
		var/list/can_see = get_mobs_in_view(1, user)  //Allows silicon & mmi mobs carried around to see the emotes of the person carrying them around.
		can_see |= viewers(user,null)
		for(var/mob/O in can_see)
			if(O.status_flags & PASSEMOTES)
				for(var/obj/item/holder/H in O.contents)
					H.show_message(message, EMOTE_VISIBLE)

				for(var/mob/living/M in O.contents)
					M.show_message(message, EMOTE_VISIBLE)

			if(O.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
				O.create_chat_message(user, runechat_text, symbol = RUNECHAT_SYMBOL_EMOTE)


	SEND_SIGNAL(user, COMSIG_MOB_EMOTED(key), src, key, emote_type, message, intentional)
	SEND_SIGNAL(user, COMSIG_MOB_EMOTE, key, intentional)

/**
 * For handling emote cooldown, return true to allow the emote to happen.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns FALSE if the cooldown is not over, TRUE if the cooldown is over.
 */
/datum/emote/proc/check_cooldown(mob/user, intentional)
	if(!intentional)
		return TRUE
	if(user.emotes_used && user.emotes_used[src] + cooldown > world.time)
		return FALSE
	if(!user.emotes_used)
		user.emotes_used = list()
	user.emotes_used[src] = world.time
	return TRUE

/**
 * To get the sound that the emote plays, for special sound interactions depending on the mob.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 *
 * Returns the sound that will be made while sending the emote.
 */
/datum/emote/proc/get_sound(mob/living/user)
	return sound //by default just return this var.

/**
 * To replace pronouns in the inputed string with the user's proper pronouns.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * msg - The string to modify.
 *
 * Returns the modified msg string.
 */
/datum/emote/proc/replace_pronoun(mob/user, msg)
	if(findtext(msg, "their"))
		msg = replacetext(msg, "their", user.p_their())
	if(findtext(msg, "them"))
		msg = replacetext(msg, "them", user.p_them())
	if(findtext(msg, "they"))
		msg = replacetext(msg, "they", user.p_they())
	if(findtext(msg, "%s"))
		msg = replacetext(msg, "%s", user.p_s())
	return msg

/**
 * Selects the message type to override the message with.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * msg - The string to modify.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns the new message, or msg directly, if no change was needed.
 */
/datum/emote/proc/select_message_type(mob/user, msg, intentional)
	// Basically, we don't care that the others can use datum variables, because they're never going to change.
	. = msg
	if(!muzzle_ignore && user.is_muzzled() && emote_type & (EMOTE_MOUTH))
		return "makes a [pick(muzzled_noises)]noise."
	if(user.mind && user.mind.miming && message_mime)
		. = message_mime
	if(isalienadult(user) && message_alien)
		. = message_alien
	else if(islarva(user) && message_larva)
		. = message_larva
	else if(issilicon(user) && message_robot)
		. = message_robot
	else if(isAI(user) && message_AI)
		. = message_AI
	else if(ismonkeybasic(user) && message_monkey)
		. = message_monkey
	else if(isanimal(user) && message_simple)
		. = message_simple

/**
 * Replaces the %t in the message in message_param by params.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 *
 * Returns the modified string.
 */
/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)

/**
 * Check to see if the user is allowed to run the emote.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * status_check - Bool that says whether we should check their stat or not.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns a bool about whether or not the user can run the emote.
 */
/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	. = TRUE
	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(species_type_whitelist_typecache && H.dna && !is_type_in_typecache(H.dna.species, species_type_whitelist_typecache))
			return FALSE

	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if((intentional && user.stat > stat_allowed) || (!intentional && (user.stat > unintentional_stat_allowed)))
			if(!intentional)
				return FALSE
			switch(user.stat)
				if(UNCONSCIOUS)
					to_chat(user, "<span class='warning'>You cannot [key] while unconscious!</span>")
				if(DEAD)
					to_chat(user, "<span class='warning'>You cannot [key] while dead!</span>")
			return FALSE
		if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
			// Don't let people blow their cover by mistake
			return FALSE
		if(hands_use_check && !user.can_use_hands())
			if(!intentional)
				return FALSE
			to_chat(user, "<span class='warning'>You cannot use your hands to [key] right now!</span>")
			return FALSE

	if(isliving(user))
		var/mob/living/sender = user
		if(HAS_TRAIT(sender, TRAIT_EMOTE_MUTE))
			return FALSE
	else
		// deadchat handling
		if(check_mute(user.client?.ckey, MUTE_DEADCHAT))
			to_chat(src, "<span class='warning'>You cannot send deadchat emotes (muted).</span>")
			return FALSE
		if(!(user.client?.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
			to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
			return FALSE
		if(!user.client?.holder)
			if(!GLOB.dsay_enabled)
				to_chat(src, "<span class='warning'>Deadchat is globally muted</span>")
				return FALSE
/**
 * Check to see if the user should play a sound when performing the emote.
 *
 * Arguments:
 * * user - Person that is doing the emote.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns a bool about whether or not the user should play a sound when performing the emote.
 */
/datum/emote/proc/should_play_sound(mob/user, intentional = FALSE)
	if(only_forced_audio && intentional)
		return FALSE
	return TRUE

/**
* Allows the intrepid coder to send a basic emote
* Takes text as input, sends it out to those who need to know after some light parsing
* If you need something more complex, make it into a datum emote
* Arguments:
* * text - The text to send out
*
* Returns TRUE if it was able to run the emote, FALSE otherwise.
*/
/mob/proc/manual_emote(text) //Just override the song and dance
	. = TRUE
	if(stat != CONSCIOUS)
		return FALSE

	if(!text)
		CRASH("Someone passed nothing to manual_emote(), fix it")


	log_emote(text, src)

	var/ghost_text = "<b>[src]</b> [text]"

	var/origin_turf = get_turf(src)
	if(client)
		for(var/mob/ghost as anything in GLOB.dead_mob_list)
			if(!ghost.client || isnewplayer(ghost))
				continue
			if(ghost.client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTSIGHT && !(ghost in viewers(origin_turf, null)))
				ghost.show_message("[ghost_follow_link(src, ghost)] [ghost_text]")

	visible_message(text)
