
// The datum in use is defined in code/datums/emotes.dm

/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE, force_silence = FALSE)
	act = lowertext(act)
	var/param = message
	// TODO /tg/ used spaces instead of dashes. this might be okay?
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
			SEND_SIGNAL(src, COMSIG_MOB_EMOTE, P, act, m_type, message, intentional)
			SEND_SIGNAL(src, COMSIG_MOB_EMOTED(P.key))
			return TRUE
	if(intentional && !silenced && !force_silence)
		log_world("<span class='notice'>Unusable emote '[act]'. Say *help for a list. </span>")
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list. </span>")
	return FALSE

// All mobs should have custom emote, really..
/mob/proc/custom_emote(m_type=EMOTE_VISIBLE, message=null)
	var/input = ""
	if(!message)
		input = sanitize(copytext(input(src,"Choose an emote to display.") as text|null,1,MAX_MESSAGE_LEN))
	else
		input = message

	emote("me", m_type, input, TRUE)

/mob/proc/emote_dead(message)
	CRASH("emote_dead is oldcode but was called")

// Stub these out since they're still referenced everywhere
/mob/proc/handle_emote_CD(cooldown)
	CRASH("handle_emote_CD is oldcode but was called.")

/mob/proc/handle_emote_param(param)
	CRASH("handle_emote_param is oldcode but was called")

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
				if(istype(H) && P.species_whitelist && (H?.dna?.species.name in species_whitelist))
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
	hands_use_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)  // okay but what if we allowed ghosts to flip as well
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/camera)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/living/silicon/ai)

/datum/emote/flip/run_emote(mob/user, params, type_override, intentional)

	if(!can_run_emote(user, TRUE, intentional))
		return FALSE

	message = "does a flip!"

	if(user.lying || user.IsWeakened())
		message = "flops and flails around on the floor."
	else if(params)
		message_param = "flips in %t's general direction."
	else if(istype(user.get_active_hand(), /obj/item/grab))
		var/obj/item/grab/G = user.get_active_hand()
		if(G && G.affecting)
			if(user.buckled || G.affecting.buckled)
				return
			var/turf/oldloc = user.loc
			var/turf/newloc = G.affecting.loc
			if(isturf(oldloc) && isturf(newloc))
				user.SpinAnimation(5,1)
				user.glide_for(0.6 SECONDS) // This and the glide_for below are purely arbitrary. Pick something that looks aesthetically pleasing.
				user.forceMove(newloc)
				G.glide_for(0.6 SECONDS)
				G.affecting.forceMove(oldloc)
				message = "flips over [G.affecting]!"

	else if(prob(5))
		message = "attempts a flip and crashes to the floor!"
		user.SpinAnimation(5,1)
		sleep(0.3 SECONDS)
		user.Weaken(2)
	else
		message = "does a flip!"
		user.SpinAnimation(5,1)

	. = ..()
	message = initial(message)
	message_param = initial(message_param)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	hands_use_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/camera)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/spin/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(prob(5))
		user.spin(32, 1)
		to_chat(user, "<span class='warning'>You spin too much!</span>")
		user.Dizzy(12)
		user.Confused(12)
	else
		user.spin(20, 1)
