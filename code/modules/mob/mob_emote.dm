
// The datum in use is defined in code/datums/emotes.dm

/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE, force_silence = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findtext(act, EMOTE_PARAM_SEPARATOR, 1, null)
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)

	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes))
		if(intentional && !force_silence)
			log_world("<span class='notice'> '[act]' emote does not exist. Say *help for a list.</span>")
			to_chat(src, "<span class='notice'> '[act]' emote does not exist. Say *help for a list.</span>")
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/P in key_emotes)
		if(!P.check_cooldown(src, intentional))
			silenced = TRUE
			continue
		if(P.run_emote(src, param, m_type, intentional))
			return TRUE
	if(intentional && !silenced && !force_silence)
		log_world("<span class='notice'>Unusable emote '[act]'. Say *help for a list. </span>")
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list. </span>")
	return FALSE

/**
 * Perform a custom emote.
 *
 * * m_type: Type of message to send.
 * * message: Content of the message. If none is provided, the user will be prompted to choose the input.
 */
/mob/proc/custom_emote(m_type = EMOTE_VISIBLE, message = null, intentional = TRUE)
	var/input = ""
	if(!message && !client)
		CRASH("An empty custom emote was called from a client-less mob.")
	else if (!message)
		input = sanitize(copytext(input(src,"Choose an emote to display.") as text|null, 1, MAX_MESSAGE_LEN))
	else
		input = message

	emote("me", m_type, input, intentional)

/**
 * Get a list of all emote keys usable by the current mob.
 *
 * * intentional_use: Whether or not to check based on if the action was intentional.
 */
/mob/proc/usable_emote_keys(intentional_use = TRUE)
	var/list/all_keys = list()
	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			if((P.key in all_keys))
				continue
			if(P.can_run_emote(src, status_check = FALSE, intentional = null))
				all_keys += P.key
				if(P.key_third_person)
					all_keys += P.key_third_person

	return all_keys

/datum/emote/help
	key = "help"
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/living/silicon/ai)

/datum/emote/help/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/list/base_keys = list()
	var/list/all_keys = list()
	var/list/species_emotes = list()
	var/list/message = list("Available emotes, you can use them with say \"*emote\": ")

	var/mob/living/carbon/human/H = user
	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			var/full_key = P.key
			if((P.key in all_keys))
				continue
			if(P.can_run_emote(user, status_check = FALSE, intentional = TRUE))
				if(P.message_param && P.param_desc)
					// Add our parameter description, like flap-user
					full_key = P.key + "\[[EMOTE_PARAM_SEPARATOR][P.param_desc]\]"
				if(istype(H) && species_type_whitelist_typecache && H.dna && is_type_in_typecache(H.dna.species, species_type_whitelist_typecache))
					species_emotes += full_key
				else
					base_keys += full_key
				all_keys += P.key

	base_keys = sortList(base_keys)

	message += base_keys.Join(", ")
	message += "."
	message = message.Join("")
	if(length(species_emotes) > 0)
		species_emotes = sortList(species_emotes)
		message += "\n<u>[user?.dna?.species.name] specific emotes</u> :- "
		message += species_emotes.Join(", ")
		message += "."
	to_chat(user, message)

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	message = "does a flip!"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_FORCE_NO_RUNECHAT  // don't need an emote to see that
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)  // okay but what if we allowed ghosts to flip as well
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/camera, /mob/living/silicon/ai)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/flip/run_emote(mob/user, params, type_override, intentional)

	if(!can_run_emote(user, TRUE, intentional))
		return FALSE

	if(user.lying || user.IsWeakened())
		message = "flops and flails around on the floor."
	else if(params)
		message_param = "flips in %t's general direction."
	else if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(istype(H.get_active_hand(), /obj/item/grab))
			var/obj/item/grab/G = H.get_active_hand()
			if(G && G.affecting)
				if(H.buckled || G.affecting.buckled)
					to_chat(user, "<span class='warning'>[G.affecting] is buckled, you can't flip around [G.affecting.p_them()]!</span>")
					return TRUE
				var/turf/oldloc = user.loc
				var/turf/newloc = G.affecting.loc
				if(isturf(oldloc) && isturf(newloc))
					user.SpinAnimation(5, 1)
					user.glide_for(0.6 SECONDS) // This and the glide_for below are purely arbitrary. Pick something that looks aesthetically pleasing.
					user.forceMove(newloc)
					G.glide_for(0.6 SECONDS)
					G.affecting.forceMove(oldloc)
					message = "flips over [G.affecting]!"
					return TRUE

	if(prob(5))
		message = "attempts a flip and crashes to the floor!"
		user.SpinAnimation(5, 1)
		sleep(0.3 SECONDS)
		user.Weaken(2)
		return TRUE
	user.SpinAnimation(5, 1)

	. = ..()
	message = initial(message)
	message_param = initial(message_param)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_FORCE_NO_RUNECHAT
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/camera)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/spin/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return TRUE
	if(prob(5))
		user.spin(32, 1)
		to_chat(user, "<span class='warning'>You spin too much!</span>")
		user.Dizzy(12)
		user.Confused(12)
	else
		user.spin(20, 1)


