#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

/datum/emote
	var/key = "" //What calls the emote
	var/key_third_person = "" //This will also call the emote
	var/message = "" //Message displayed when emote is used
	var/message_param = "" //Message to display if a param was given
	var/emote_type = EMOTE_VISIBLE //Whether the emote is visible or audible
	var/restraint_check = FALSE //Checks if the mob is restrained before performing the emote
	var/muzzle_ignore = FALSE //Will only work if the emote is EMOTE_AUDIBLE
	var/list/mob_type_blacklist_typecache //Types that are NOT allowed to use that emote
	var/punct = "."
	var/list/mob_type_ignore_stat_typecache
	var/stat_allowed = CONSCIOUS
	var/static/list/emote_list = list()
	var/cooldown = 0
	var/sound
	var/sound_vary = FALSE
	var/sound_volume = 50

/datum/emote/New()
	if(key_third_person)
		emote_list[key_third_person] = src
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

/datum/emote/proc/run_emote(mob/user, params, type_override)
	. = TRUE
	if(!can_run_emote(user))
		return FALSE
	var/msg = select_message_type(user)
	if(params)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(!msg)
		return

	msg = "<b>[user]</b> " + msg + punct

	if(!findtext(msg, " snores."))
		for(var/mob/M in player_list)
			if(!M.client || isnewplayer(M))
				continue
			var/T = get_turf(user)
			if(M.stat == DEAD && M.client && M.get_preference(CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
				M.show_message(msg)

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg)
		if(can_play_sound(user))
			play_sound(user)
	else
		user.visible_message(msg)
	log_emote(msg, user)
	emote_cooldown()

/datum/emote/proc/emote_cooldown(mob/user)
	if(!cooldown || user.emote_on_cd)
		return
	user.emote_on_cd = TRUE
	addtimer(CALLBACK(src, .proc/emote_warmup, user), cooldown)

/datum/emote/proc/emote_warmup(mob/user)
	if(user.emote_on_cd > TRUE)
		return
	user.emote_on_cd = FALSE

/datum/emote/proc/replace_pronoun(mob/user, message)
	if(findtext(message, "their"))
		message = replacetext(message, "their", user.p_their())
	if(findtext(message, "them"))
		message = replacetext(message, "them", user.p_them())
	if(findtext(message, "%s"))
		message = replacetext(message, "%s", user.p_s())
	return message

/datum/emote/proc/select_message_type(mob/user)
	. = message
	if(!can_play_sound(user))
		return "makes a [pick("strong ", "weak ", "")]noise"

/datum/emote/proc/select_param(mob/user, params)
	if(!can_play_sound(user))
		return "makes a [pick("strong ", "weak ", "")]noise at [params]"
	if(!message_param)
		return "[message] at [params]"
	return replacetext(message_param, "%t", params)

/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE)
	. = TRUE
	if(cooldown && user.emote_on_cd)
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE
	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if(user.stat > stat_allowed)
			to_chat(user, "<span class='notice'>You cannot [key] while unconscious.</span>")
			return FALSE
		if(restraint_check && (user.restrained() || user.buckled))
			to_chat(user, "<span class='notice'>You cannot [key] while restrained.</span>")
			return FALSE

/datum/emote/proc/play_sound(mob/user)
	if(!sound)
		return
	playsound(user.loc, sound, sound_volume, sound_vary)

/datum/emote/proc/can_play_sound(mob/user)
	return (!muzzle_ignore && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)

// Override this to change the param handling. By default they have to be visible to you, but not next to you.
/datum/emote/proc/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	return handle_emote_param_helper(user, target, not_self, vicinity, return_mob)

/datum/emote/proc/handle_emote_param_helper(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	//Only returns not null if the target param is valid.
	//not_self means we'll only return if target is valid and not us
	//vicinity is the distance passed to the view proc.
	var/view_vicinity = vicinity ? vicinity : null 
	if(!target)
		return
		//if set, return_mob will cause this proc to return the mob instead of just its name if the target is valid.
	for(var/mob/A in view(view_vicinity, null))
		if(target == A.name && (!not_self || (not_self && target != user.name)))
			if(return_mob)
				return A
			return target
