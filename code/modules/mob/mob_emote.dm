
// The datum in use is defined in code/datums/emotes.dm

/**
 * Send an emote.
 *
 * * emote_key: Key of the emote being triggered
 * * m_type: Type of the emote, like EMOTE_AUDIBLE. If this is not null, the default type of the emote will be overridden.
 * * message: Custom parameter for the emote. This should be used if you want to pass something like a target programmatically.
 * * intentional: Whether or not the emote was deliberately triggered by the mob. If true, it's forced, which skips some checks when calling the emote.
 * * force_silence: If true, unusable/nonexistent emotes will not notify the user.
 */
/mob/proc/emote(emote_key, type_override = null, message = null, intentional = FALSE, force_silence = FALSE)
	emote_key = lowertext(emote_key)
	var/param = message
	var/custom_param_offset = findtext(emote_key, EMOTE_PARAM_SEPARATOR, 1, null)
	if(custom_param_offset)
		param = copytext(emote_key, custom_param_offset + length(emote_key[custom_param_offset]))
		emote_key = copytext(emote_key, 1, custom_param_offset)

	var/list/key_emotes = GLOB.emote_list[emote_key]

	if(!length(key_emotes))
		if(intentional && !force_silence)
			to_chat(src, "<span class='notice'>'[emote_key]' emote does not exist. Say *help for a list.</span>")
		else if(!intentional)
			CRASH("Emote with key [emote_key] was attempted to be called, though doesn't exist!")
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/P in key_emotes)
		// can this mob run the emote at all?
		if(!P.can_run_emote(src, intentional = intentional))
			continue
		if(!P.check_cooldown(src, intentional))
			// if an emote's on cooldown, don't spam them with messages of not being able to use it
			silenced = TRUE
			continue
		if(P.try_run_emote(src, param, type_override, intentional))
			return TRUE
	if(intentional && !silenced && !force_silence)
		to_chat(src, "<span class='notice'>Unusable emote '[emote_key]'. Say *help for a list.</span>")
	return FALSE

/**
 * Perform a custom emote.
 *
 * * m_type: Type of message to send.
 * * message: Content of the message. If none is provided, the user will be prompted to choose the input.
 * * intentional: Whether or not the user intendeded to perform the emote.
 */
/mob/proc/custom_emote(m_type = EMOTE_VISIBLE, message = null, intentional = FALSE)
	var/input = ""
	if(!message && !client)
		CRASH("An empty custom emote was called from a client-less mob.")
	else if(!message)
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
			if(P.key in all_keys)
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
			if(P.key in all_keys)
				continue
			if(P.can_run_emote(user, status_check = FALSE, intentional = TRUE))
				if(P.message_param && P.param_desc)
					// Add our parameter description, like flap-user
					full_key = P.key + "\[[EMOTE_PARAM_SEPARATOR][P.param_desc]\]"
				if(istype(H) && P.species_type_whitelist_typecache && H.dna && is_type_in_typecache(H.dna.species, P.species_type_whitelist_typecache))
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

	if(isobserver(user))
		user.SpinAnimation(5, 1)
		return TRUE

	var/mob/living/L = user

	if(IS_HORIZONTAL(L))
		message = "flops and flails around on the floor."
		return ..()
	else if(params)
		message_param = "flips in %t's general direction."
	else if(ishuman(user))
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
					var/old_pass = user.pass_flags
					user.pass_flags |= (PASSMOB | PASSTABLE)
					step(user, get_dir(oldloc, newloc))
					user.pass_flags = old_pass
					G.glide_for(0.6 SECONDS)
					message = "flips over [G.affecting]!"
					return ..()

	user.SpinAnimation(5, 1)

	if(prob(5) && ishuman(user))
		message = "attempts a flip and crashes to the floor!"
		sleep(0.3 SECONDS)
		if(istype(L))
			L.Weaken(4 SECONDS)
		return ..()

	. = ..()

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_FORCE_NO_RUNECHAT
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/camera, /mob/living/silicon/ai)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	cooldown = 2 SECONDS // how long the spin takes, any faster and mobs can spin

/datum/emote/spin/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE

	if(prob(95) || isobserver(user) || !ishuman(user))
		user.spin(20, 1)
		return TRUE

	user.spin(32, 1)
	to_chat(user, "<span class='warning'>You spin too much!</span>")
	var/mob/living/L = user
	if(istype(L))
		L.Dizzy(24 SECONDS)
		L.Confused(24 SECONDS)
