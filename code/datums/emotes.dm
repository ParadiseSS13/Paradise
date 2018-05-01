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
	var/muzzled_noise = "" // For snowflaking the muzzled noise
	var/list/mob_type_blacklist_typecache //Types that are NOT allowed to use that emote
	var/punct = "."
	var/list/mob_type_ignore_stat_typecache
	var/stat_allowed = CONSCIOUS
	var/cooldown = 0
	var/sound
	var/sound_volume = 50
	var/sound_vary = 0
	var/static/list/emote_lists = list(
		mob=init_subtypes(/datum/emote/mob),
		living=init_subtypes(/datum/emote/living),
		human=init_subtypes(/datum/emote/human),
		synth=init_subtypes(/datum/emote/synth),
	)

/datum/emote/New()
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

/datum/emote/proc/run_emote(mob/user, params, type_override)
	. = TRUE
	if(!can_run_emote(user))
		return FALSE

	var/msg = create_emote_message(user, params)
	if(!msg)
		return
	show_to_ghosts(user, msg)

	var/ET = type_override ? type_override : emote_type

	if(ET == EMOTE_AUDIBLE)
		user.audible_message(msg)
		if(can_play_sound(user))
			play_sound(user)
	else
		user.visible_message(msg)
		play_sound(user)
	log_emote(msg, user)
	emote_cooldown(user)

// Override this to use custom message behavior, or do something before the emote is printed to the screen
/datum/emote/proc/create_emote_message(mob/user, params)
	var/msg = select_message_type(user)
	if(params)
		msg = select_param(user, params, msg)

	msg = replace_pronoun(user, msg)

	if(!msg)
		return

	msg = "<b>[user]</b> " + msg + punct
	return msg

/datum/emote/proc/show_to_ghosts(mob/user, msg)
	if(findtext(msg, " snores."))
		return

	for(var/mob/M in player_list)
		if(!M.client || isnewplayer(M))
			continue
		var/T = get_turf(user)
		if(M.stat == DEAD && M.client && M.get_preference(CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
			M.show_message(msg)

/datum/emote/proc/emote_cooldown(mob/user)
	if(!cooldown || user.emote_on_cd)
		return
	user.emote_on_cd = TRUE
	addtimer(CALLBACK(src, .proc/emote_warmup, user), cooldown)

/datum/emote/proc/emote_warmup(mob/user)
	if(user.emote_on_cd > TRUE)
		return
	user.emote_on_cd = FALSE

/datum/emote/proc/replace_pronoun(mob/user, msg)
	if(findtext(msg, "their"))
		msg = replacetext(msg, "their", user.p_their())
	if(findtext(msg, "them"))
		msg = replacetext(msg, "them", user.p_them())
	if(findtext(msg, "%s"))
		msg = replacetext(msg, "%s", user.p_s())
	return msg

/datum/emote/proc/select_message_type(mob/user)
	. = message
	if(!can_play_sound(user))
		return "makes a [muzzled_noise ? muzzled_noise : pick("strong ", "weak ", "")]noise"

/datum/emote/proc/select_param(mob/user, params, msg)
	var/M = handle_emote_param(user, params)
	if(!M)
		return msg
	if(!message_param)
		return "[msg] at [params]"
	return replacetext(message_param, "%t", params)

/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE)
	. = TRUE
	if(cooldown && user.emote_on_cd)
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		unusable_message(user, status_check)
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
	return !(!muzzle_ignore && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)

// Override this to change the param handling. By default they have to be visible to you, but not next to you.
/datum/emote/proc/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	//Only returns not null if the target param is valid.
	//not_self means we'll only return if target is valid and not us
	//vicinity is the distance passed to the view proc.
	var/view_vicinity = vicinity ? vicinity : null
	if(!target)
		return
		//if set, return_mob will cause this proc to return the mob instead of just its name if the target is valid.
	for(var/mob/A in view(view_vicinity, null))
		if(cmptext(target, A.name) && (!not_self || (not_self && cmptext(target, user.name))))
			if(return_mob)
				return A
			return target

/datum/emote/proc/unusable_message(mob/user, status_check)
	if(status_check)
		to_chat(user, "<span class='notice'>Unusable emote '[key]'. Say *help for a list.</span>")
