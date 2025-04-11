
// Defines are in code\__DEFINES\emotes.dm

/// Sentinel for emote stats.
/// If this is set for max stat, then its value will be ignored.
#define DEFAULT_MAX_STAT_ALLOWED "defaultstat"

/**
 * # Emote
 *
 * Most of the text that's not someone talking is based off of this.
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
	/// Message to display if the user is a spooky observer ghost.
	var/message_observer = ""
	/// Sounds emitted when the user is muzzled. Generally used like "[user] makes a pick(muzzled_noises) noise!"
	var/muzzled_noises = list("strong", "weak")
	/// Message with %t at the end to allow adding params to the message, like for mobs doing an emote relatively to something else.
	/// Set this to EMOTE_PARAM_USE_POSTFIX to just use the postfix.
	var/message_param = ""
	/// Message postfix with %t used when we don't want to use message_param for our targeting. Used for things like message_monkey or message_mime.
	/// Punctuation from the message will be stripped when this is applied, so make sure it's punctuated as well.
	var/message_postfix = ""
	/// Description appended to the emote name describing what the target should be, like for help commands.
	var/param_desc = "target"
	/// Whether the emote is visible or audible.
	var/emote_type = EMOTE_VISIBLE
	/// Checks if the mob can use its hands before performing the emote.
	var/hands_use_check = FALSE
	/// If the emote type is EMOTE_MOUTH but should still bypass a muzzle.
	var/muzzle_ignore = FALSE
	/// Types that are allowed to use that emote.
	var/list/mob_type_allowed_typecache = /mob
	/// Types that are NOT allowed to use that emote.
	var/list/mob_type_blacklist_typecache
	/// Types that can use this emote regardless of their state.
	var/list/mob_type_ignore_stat_typecache
	/// Species types which the emote will be exclusively available to. Should be subclasses of /datum/species
	var/list/species_type_whitelist_typecache
	/// Species types which the emote will be exclusively not available to. Should be subclasses of /datum/species
	var/list/species_type_blacklist_typecache
	/// If we get a target, how do we want to treat it?
	var/target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	/// If our target behavior isn't to ignore, what should we look for with targets?
	var/emote_target_type = EMOTE_TARGET_ANY

	// Stat_allowed is the "lower threshold" for stat, and basically represents how alive you have to be to use it.
	// on the other hand, max_stat_allowed is the "upper threshold" representing how 'dead' you can be while still using the emote.
	// see stat.dm for the stats that you can actually use here.

	// Typical use case might be setting unintentional_stat_allowed to UNCONSCIOUS to allow a mob to gasp whether or not they're conscious.
	// A use case for max_stat alone would be in case you'd want someone to be able to do something while unconscious or dead. Unlikely, but the option will still be there.
	// A use case for both at once would be fixing it somewhere in the middle, like only allowing mobs to snore while they're unconscious.

	// (worth noting: this is flexible on purpose in case we ever increase the amount of life stats).

	/// How conscious do you need to be to use this emote intentionally?
	var/stat_allowed = CONSCIOUS
	/// How unconscious/dead can you be while still being able to use this emote intentionally?
	/// If this is set to DEFAULT_STAT_ALLOWED, it'll behave as if it isn't set.
	var/max_stat_allowed = DEFAULT_MAX_STAT_ALLOWED
	/// How conscious do you need to be to have this emote forced out of you?
	var/unintentional_stat_allowed = CONSCIOUS
	/// Same as above, how unconscious/dead do you need to be to have this emote forced out of you?
	/// If this is set to DEFAULT_STAT_ALLOWED, it'll behave as if it isn't set.
	var/max_unintentional_stat_allowed = DEFAULT_MAX_STAT_ALLOWED
	/// Sound to play when emote is called. If you want to adjust this dynamically, see get_sound().
	var/sound
	/// Whether or not to vary the sound of the emote.
	var/vary = FALSE
	/// Whether or not to adjust the frequency of the emote sound based on age.
	var/age_based = FALSE
	/// If true, this emote will only make a sound effect when called unintentionally.
	var/only_forced_audio = FALSE
	/// Whether or not the emote can even be called at all if it's not intentional
	var/only_unintentional = FALSE
	/// The cooldown between the uses of the emote.
	var/cooldown = DEFAULT_EMOTE_COOLDOWN
	/// How long is the cooldown on the audio of the emote, if it has one?
	var/audio_cooldown = AUDIO_EMOTE_COOLDOWN
	/// If the emote is triggered unintentionally, how long would that cooldown be?
	var/unintentional_audio_cooldown = AUDIO_EMOTE_UNINTENTIONAL_COOLDOWN
	/// If true, an emote will completely bypass any cooldown when called unintentionally. Necessary for things like deathgasp.
	var/bypass_unintentional_cooldown = FALSE
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
	species_type_blacklist_typecache = typecacheof(species_type_blacklist_typecache)

/datum/emote/Destroy(force)
	if(force)
		return ..()
	else
		// if you're deleting an emote something has gone wrong
		return QDEL_HINT_LETMELIVE

/**
 * Handles the modifications and execution of emotes.
 *
 * In general, what this does:
 * - Checks if the user can run the emote at all
 * - Checks and applies the message parameter, if it exists
 * - Replaces pronouns with a mob's specific pronouns
 * - Checks for and plays sound if the emote supports it
 * - Sends the emote to users
 * - Runechats the emote
 *
 * You most likely want to use try_run_emote() anywhere you would otherwise call this directly,
 * 	as that will incorporate can_run_emote() checking as well.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * emote_arg - String parameter added after the emote.
 * * type_override - Override to the current emote_type.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns TRUE if it was able to run the emote, FALSE otherwise.
 */
/datum/emote/proc/run_emote(mob/user, emote_arg, type_override, intentional = FALSE)
	. = TRUE
	var/msg = select_message_type(user, message, intentional)
	if(emote_arg && message_param)
		// In this case, we did make some changes to the message that will be used, and we want to add the postfix on with the new parameters.
		// This is applicable to things like mimes, who this lets have a target on their canned emote responses.
		// Note that we only do this if we would otherwise have a message param, meaning there should be some target by default.
		// If we're using EMOTE_PARAM_USE_POSTFIX, we don't want to bother specifying a message_param and just want to use the postfix for everything.
		if(message_param == EMOTE_PARAM_USE_POSTFIX || (msg != message && message_postfix))
			if(!message_postfix)
				CRASH("Emote was specified to use postfix but message_postfix is empty.")
			msg = select_param(user, emote_arg, "[remove_ending_punctuation(msg)] [message_postfix]", msg)
		else if(msg == message)
			// In this case, we're not making any substitutions in select_message_type, but we do have some params we want to sub in.
			msg = select_param(user, emote_arg, message_param, message)

		// If this got propogated up, jump out.
		if(msg == EMOTE_ACT_STOP_EXECUTION)
			return TRUE

		if(isnull(msg))
			to_chat(user, "<span class='warning'>'[emote_arg]' isn't a valid parameter for [key].</span>")
			return TRUE

	msg = replace_pronoun(user, msg)

	var/suppressed = FALSE

	// Keep em quiet if they can't speak
	if(!can_vocalize_emotes(user) && (emote_type & (EMOTE_MOUTH | EMOTE_AUDIBLE)))
		var/noise_emitted = pick(muzzled_noises)
		suppressed = TRUE
		msg = "makes \a [noise_emitted] noise."

	var/tmp_sound = get_sound(user)
	var/sound_volume = get_volume(user)
	// If our sound emote is forced by code, don't worry about cooldowns at all.
	if(tmp_sound && should_play_sound(user, intentional) && sound_volume > 0)
		if(bypass_unintentional_cooldown || user.start_audio_emote_cooldown(intentional, intentional ? audio_cooldown : unintentional_audio_cooldown))
			play_sound_effect(user, intentional, tmp_sound, sound_volume)

	if(msg)
		user.create_log(EMOTE_LOG, msg)
		if(isobserver(user))
			log_ghostemote(msg, user)
		else
			log_emote(msg, user)

		var/displayed_msg = "<b>[user]</b> [msg]"

		var/user_turf = get_turf(user)
		if(user.client && !isobserver(user))
			for(var/mob/ghost as anything in GLOB.dead_mob_list)
				if(!ghost.client)
					continue
				if((ghost.client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTSIGHT) && !(ghost in viewers(user_turf, null)))
					ghost.show_message("<span class='emote'>[user] ([ghost_follow_link(user, ghost)]) [msg]</span>", chat_message_type = MESSAGE_TYPE_LOCALCHAT)

		if(isobserver(user))
			for(var/mob/dead/observer/ghost in viewers(user))
				ghost.show_message("<span class='deadsay'>[displayed_msg]</span>", EMOTE_VISIBLE, chat_message_type = MESSAGE_TYPE_LOCALCHAT)

		else if((emote_type & EMOTE_AUDIBLE) && !user.mind?.miming)
			user.audible_message(displayed_msg, deaf_message = "<span class='emote'>You see how <b>[user]</b> [msg]</span>")
		else
			user.visible_message(displayed_msg, blind_message = "<span class='emote'>You hear how someone [msg]</span>")

		if(!((emote_type & EMOTE_FORCE_NO_RUNECHAT) || suppressed) && !isobserver(user))
			runechat_emote(user, msg)

	SEND_SIGNAL(user, COMSIG_MOB_EMOTED(key), src, key, emote_type, message, intentional)
	SEND_SIGNAL(user, COMSIG_MOB_EMOTE, key, intentional)

/**
 * Try to run an emote, checking can_run_emote once before executing the emote itself.
 *
 * * user - User of the emote
 * * params - An optional extra argument included after the emote key.
 * * type_override - emote type to override the existing one with, if given.
 * * intentional - Whether or not the emote was triggered intentionally (if false, the emote was forced by code).
 *
 * Returns TRUE if the emote was able to be run (or failed successfully), or FALSE if the emote is unusable.
 */
/datum/emote/proc/try_run_emote(mob/user, emote_arg, type_override, intentional = FALSE)
	// You can use this signal to block execution of emotes from components/other sources.
	var/sig_res = SEND_SIGNAL(user, COMSIG_MOB_PREEMOTE, key, intentional)
	switch(sig_res)
		if(COMPONENT_BLOCK_EMOTE_UNUSABLE)
			return FALSE
		if(COMPONENT_BLOCK_EMOTE_SILENT)
			return TRUE

	. = run_emote(user, emote_arg, type_override, intentional)

	// safeguard in case these get modified
	reset_emote()

/**
 * Reset the emote back to its original state.
 * Necessary if you've made modifications to the emote itself over the course of its
 * execution, as emotes are singletons, and changes would be reflected on every usage of the emote.
 */
/datum/emote/proc/reset_emote()
	SHOULD_CALL_PARENT(TRUE)
	message = initial(message)
	message_param = initial(message_param)

/**
 * Play the sound effect in an emote.
 * If you want to change the way the playsound call works, override this.
 * Note! If you want age_based to work, you need to force vary to TRUE.
 * * user - The user of the emote.
 * * intentional - Whether or not the emote was triggered intentionally.
 * * sound_path - Filesystem path to the audio clip to play.
 * * sound_volume - Volume at which to play the audio clip.
 */
/datum/emote/proc/play_sound_effect(mob/user, intentional, sound_path, sound_volume)
	if(age_based && ishuman(user))
		var/mob/living/carbon/human/H = user
		// Vary needs to be true as otherwise frequency changes get ignored deep within playsound_local :(
		playsound(user.loc, sound_path, sound_volume, TRUE, frequency = H.get_age_pitch(H.dna.species.max_age) * alter_emote_pitch(user))
	else
		playsound(user.loc, sound_path, sound_volume, TRUE, frequency = alter_emote_pitch(user, FALSE))

/datum/emote/proc/alter_emote_pitch(mob/user, multiplicative = TRUE)
	if(HAS_TRAIT(user, TRAIT_I_WANT_BRAINS))
		return 0.7
	return multiplicative

/**
 * Send an emote to runechat for all (listening) users in the vicinity.
 *
 * * user - The user of the emote.
 * * text - The text of the emote.
 */
/proc/runechat_emote(atom/user, text)
	var/runechat_text = text
	if(length(text) > 100)
		runechat_text = "[copytext(text, 1, 101)]..."
	var/list/can_see = get_mobs_in_view(1, user, ai_eyes=AI_EYE_INCLUDE)  //Allows silicon & mmi mobs carried around to see the emotes of the person carrying them around.
	can_see |= viewers(user, null)
	for(var/mob/O as anything in can_see)
		if(O.status_flags & PASSEMOTES)
			for(var/obj/item/holder/H in O.contents)
				H.show_message(text, EMOTE_VISIBLE, chat_message_type = MESSAGE_TYPE_LOCALCHAT)

			for(var/mob/living/M in O.contents)
				M.show_message(text, EMOTE_VISIBLE, chat_message_type = MESSAGE_TYPE_LOCALCHAT)

		if(O.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
			O.create_chat_message(user, runechat_text, symbol = RUNECHAT_SYMBOL_EMOTE)
		if(is_ai_eye(O))
			var/mob/camera/eye/ai/eye = O
			if(!(eye.ai in can_see) && eye.ai?.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
				eye.ai.create_chat_message(user, runechat_text, symbol = RUNECHAT_SYMBOL_EMOTE)

/**
 * Check whether or not an emote can be used due to a cooldown.
 * This applies to per-emote cooldowns, preventing individual emotes from being used (intentionally) too frequently.
 * This also checks audio cooldowns, so that intentional uses of audio emotes across the mob are time-constrained.
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
	// if our emote would play sound but another audio emote is on cooldown, prevent this emote from being used.
	// Note that this only applies to intentional emotes
	if(get_sound(user) && should_play_sound(user, intentional) && !user.can_use_audio_emote(intentional))
		return FALSE
	var/cooldown_in_use
	if(!isnull(user.emote_cooldown_override))
		// if the user has a a cooldown override in place, apply that instead.
		cooldown_in_use = user.emote_cooldown_override
	else
		cooldown_in_use = cooldown
	// Check cooldown on a per-emote basis.
	if(user.emotes_used && user.emotes_used[src] + cooldown_in_use > world.time)
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
 * Get the volume of the audio emote to play.
 *
 * Override this if you want to dynamically change the volume of an emote.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 *
 * Returns the volume level for an emote's audio component.
 */
/datum/emote/proc/get_volume(mob/living/user)
	return volume

/**
 * Replace pronouns in the inputed string with the user's proper pronouns.
 *
 * Specifically replaces they/them/their pronouns with the user's pronouns, as well as %s (like theirs)
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
	if(findtext(msg, "themselves"))
		msg = replacetext(msg, "themselves", user.p_themselves())
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
	. = msg
	if(user.mind && user.mind.miming && message_mime)
		. = message_mime
	if(isalienadult(user) && message_alien)
		. = message_alien
	else if(islarva(user) && message_larva)
		. = message_larva
	else if(issilicon(user) && message_robot)
		. = message_robot
	else if(is_ai(user) && message_AI)
		. = message_AI
	else if(ismonkeybasic(user) && message_monkey)
		. = message_monkey
	else if(isanimal_or_basicmob(user) && message_simple)
		. = message_simple
	else if(isobserver(user) && message_observer)
		. = message_observer

/**
 * Replaces the %t in the message in message_param by params.
 *
 * The behavior of this proc is particularly dependent on `target_behavior` and `emote_target_type`.
 * If target_behavior is EMOTE_TARGET_BHVR_RAW, we ignore any sort of target searching.
 * Otherwise, we try to find a target in view to call this emote on based on emote_target_type.
 *
 *
 * If you want to call something on the target object itself while it's still in scope, override act_on_target().
 *
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 * * substitution_str - String to substitute the target into.
 * * base_message - If passed, the original message before any sort of modification occurred. Useful when dealing with non-standard message types.
 *
 * Returns the modified string, or null if the given parameter is invalid. May also return EMOTE_ACT_STOP_EXECUTION if acting on the target should stop emote execution.
 */
/datum/emote/proc/select_param(mob/user, params, substitution, base_message)

	if(target_behavior == EMOTE_TARGET_BHVR_IGNORE)
		return base_message

	if(target_behavior == EMOTE_TARGET_BHVR_RAW)
		return replacetext(substitution, "%t", params)

	if(target_behavior == EMOTE_TARGET_BHVR_NUM)
		if(!isnum(text2num(params)))
			return null
		act_on_target(user, text2num(params))
		return replacetext(substitution, "%t", params)

	var/full_target = find_target(user, params, emote_target_type)
	if(full_target)
		// If we find an actual target obj/item/whatever, see if we'd want to perform some action on it and jump out
		// Fire off a signal first to see if our interaction should be stopped for some reason
		if(!(SEND_SIGNAL(user, COMSIG_MOB_EMOTE_AT, full_target, key) & COMPONENT_BLOCK_EMOTE_ACTION))
			if(act_on_target(user, full_target) == EMOTE_ACT_STOP_EXECUTION)
				return EMOTE_ACT_STOP_EXECUTION
		return replacetext(substitution, "%t", full_target)

	// no target found, contingency plans
	switch(target_behavior)
		if(EMOTE_TARGET_BHVR_MUST_MATCH)
			return null
		if(EMOTE_TARGET_BHVR_DEFAULT_TO_BASE)
			return base_message
		if(EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY)
			return replacetext(substitution, "%t", params)

	CRASH("Emote tried to select_param with invalid target behavior.")

/**
 * Perform an action on the target of an emote, if one was found.
 *
 * This gets called in select_param if a valid object target was found, and should let you interact with the
 * object being targeted while it's still in scope.
 *
 * * user - Person who is triggering the emote.
 * * Target - The target of the emote itself.
 */
/datum/emote/proc/act_on_target(mob/user, target)
	return

/**
 * Check to see if the user is allowed to run the emote.
 *
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

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna)
			// Since the typecaches might be null as a valid option, it looks like we do need to check that these exist first.
			if(species_type_whitelist_typecache && !is_type_in_typecache(H.dna.species, species_type_whitelist_typecache))
				return FALSE

			if(species_type_blacklist_typecache && is_type_in_typecache(H.dna.species, species_type_blacklist_typecache))
				return FALSE

	if(intentional && only_unintentional)
		return FALSE

	if(check_mute(user.client?.ckey, MUTE_EMOTE))
		to_chat(user, "<span class='warning'>You cannot send emotes (muted).</span>")
		return FALSE

	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		var/intentional_stat_check = (intentional && (user.stat <= stat_allowed && (max_stat_allowed == DEFAULT_MAX_STAT_ALLOWED || user.stat >= max_stat_allowed)))
		var/unintentional_stat_check = (!intentional && (user.stat <= unintentional_stat_allowed && (max_unintentional_stat_allowed == DEFAULT_MAX_STAT_ALLOWED || user.stat >= max_unintentional_stat_allowed)))
		if(!intentional_stat_check && !unintentional_stat_check)
			var/stat = stat_to_text(user.stat)
			if(!intentional)
				return FALSE

			if(stat)
				to_chat(user, "<span class='warning'>You cannot [key] while [stat]!</span>")
			return FALSE
		if(HAS_TRAIT(user, TRAIT_FAKEDEATH))
			// Don't let people blow their cover by mistake
			return FALSE
		if(hands_use_check && !user.can_use_hands() && (iscarbon(user)))
			if(!intentional)
				return FALSE
			to_chat(user, "<span class='warning'>You cannot use your hands to [key] right now!</span>")
			return FALSE

	if(isliving(user))
		var/mob/living/sender = user
		if(HAS_TRAIT(sender, TRAIT_EMOTE_MUTE) && intentional)
			return FALSE
		if(isbrain(sender))
			var/mob/living/brain/B = user
			if(istype(B.container, /obj/item/mmi/robotic_brain)) //Robobrains can't be silenced and still emote
				var/obj/item/mmi/robotic_brain/robobrain = B.container
				return !robobrain.silenced
	else
		// deadchat handling
		if(check_mute(user.client?.ckey, MUTE_DEADCHAT))
			to_chat(user, "<span class='warning'>You cannot send deadchat emotes (muted).</span>")
			return FALSE
		if(!(user.client?.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
			to_chat(user, "<span class='warning'>You have deadchat muted.</span>")
			return FALSE
		if(!check_rights(R_ADMIN, FALSE, user))
			if(!GLOB.dsay_enabled)
				to_chat(user, "<span class='warning'>Deadchat is globally muted.</span>")
				return FALSE

/**
 * Find a target for the emote based on the message parameter fragment passed in.
 *
 * * user - The user looking for a target.
 * * fragment - The mesage parameter or fragment of text they're using to try to find a target.
 * * emote_target_type - Define denoting the type of target to use when searching.
 *
 * Returns a matched target, or null if a specific match couldn't be made.
 */
/datum/emote/proc/find_target(mob/user, fragment, emote_target_type)
	var/target = null

	fragment = lowertext(fragment)

	if(emote_target_type & EMOTE_TARGET_MOB)
		for(var/mob/living/M in view(user.client))
			if(findtext(lowertext(M.name), fragment))
				target = M
				break

	if(!target && emote_target_type & EMOTE_TARGET_OBJ)
		for(var/obj/thing in view(user.client))
			if(findtext(lowertext(thing.name), fragment))
				target = thing
				break

	return target

/**
 * Return whether a user should be able to vocalize emotes or not, due to a mask or inability to speak.
 * If this returns false, any mouth emotes will be replaced with muzzled noises.
 */
/datum/emote/proc/can_vocalize_emotes(mob/user)
	if(user.mind?.miming)
		// mimes get special treatment; though they can't really "vocalize" we don't want to replace their message.
		return TRUE
	if(!muzzle_ignore && !user.can_speak())
		return FALSE

	return TRUE


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
	if((emote_type & EMOTE_MOUTH) && !can_vocalize_emotes(user))
		return FALSE
	if(isliving(user))
		var/mob/living/liveuser = user
		if(liveuser.has_status_effect(STATUS_EFFECT_ABSSILENCED))
			return FALSE
	return TRUE

/datum/emote/proc/remove_ending_punctuation(msg)
	var/static/list/end_punctuation = list(".", "?", "!")
	if(copytext(msg, -1) in end_punctuation)
		msg = copytext(msg, 1, -1)
	return msg

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
	create_log(EMOTE_LOG, text)

	var/ghost_text = "<b>[src]</b> [text]"

	var/origin_turf = get_turf(src)
	if(client)
		for(var/mob/ghost as anything in GLOB.dead_mob_list)
			if(!ghost.client)
				continue
			if(ghost.client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTSIGHT && !(ghost in viewers(origin_turf, null)))
				ghost.show_message("[ghost_follow_link(src, ghost)] [ghost_text]", chat_message_type = MESSAGE_TYPE_LOCALCHAT)

	visible_message(text)


#undef DEFAULT_MAX_STAT_ALLOWED
