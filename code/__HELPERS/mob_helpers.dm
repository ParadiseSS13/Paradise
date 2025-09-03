/proc/random_underwear(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = GLOB.underwear_m
		if(FEMALE)	pick_list = GLOB.underwear_f
		else		pick_list = GLOB.underwear_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/random_undershirt(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = GLOB.undershirt_m
		if(FEMALE)	pick_list = GLOB.undershirt_f
		else		pick_list = GLOB.undershirt_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/random_socks(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = GLOB.socks_m
		if(FEMALE)	pick_list = GLOB.socks_f
		else		pick_list = GLOB.socks_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/pick_species_allowed_underwear(list/all_picks, species)
	var/list/valid_picks = list()
	for(var/test in all_picks)
		var/datum/sprite_accessory/S = all_picks[test]
		if(!(species in S.species_allowed))
			continue
		valid_picks += test

	if(!length(valid_picks)) valid_picks += "Nude"

	return pick(valid_picks)

/proc/random_hair_style(gender, species = "Human", datum/robolimb/robohead)
	var/h_style = "Bald"
	var/list/valid_hairstyles = list()
	for(var/hairstyle in GLOB.hair_styles_public_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_public_list[hairstyle]

		if(hairstyle == "Bald") //Just in case.
			valid_hairstyles += hairstyle
			continue
		if(species == "Machine") //If the user is a species who can have a robotic head...
			if(!robohead)
				robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"]
			if((species in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_hairstyles += hairstyle //Give them their hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
					valid_hairstyles += hairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(species in S.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
				valid_hairstyles += hairstyle

	if(length(valid_hairstyles))
		h_style = pick(valid_hairstyles)

	return h_style

/proc/random_facial_hair_style(gender, species = "Human", datum/robolimb/robohead)
	var/f_style = "Shaved"
	var/list/valid_facial_hairstyles = list()
	for(var/facialhairstyle in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]

		if(facialhairstyle == "Shaved") //Just in case.
			valid_facial_hairstyles += facialhairstyle
			continue
		if(species == "Machine") //If the user is a species who can have a robotic head...
			if(!robohead)
				robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"]
			if((species in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
					valid_facial_hairstyles += facialhairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(species in S.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
				valid_facial_hairstyles += facialhairstyle

	if(length(valid_facial_hairstyles))
		f_style = pick(valid_facial_hairstyles)

	return f_style

// it might be made species related, but it is pretty okay now
/proc/random_hair_color(tint = TRUE, range)
	if(prob(1))
		return rand_hex_color() // sPaCe PuNk
	var/list/color_options = list(
		// gray, black, blue - 5 total
		COLOR_GRAY15,
		COLOR_GRAY40,
		COLOR_SILVER,
		COLOR_DARK_BLUE_GRAY,
		COLOR_WALL_GUNMETAL,
		// yellow, red, orange - 5 total
		COLOR_YELLOW_GRAY,
		COLOR_WARM_YELLOW,
		COLOR_DARK_ORANGE,
		COLOR_PALE_ORANGE,
		COLOR_SUN,
		// brownish. there is not much of them so they are repeated - 5 total
		COLOR_CHESTNUT,
		COLOR_CHESTNUT,
		COLOR_BEASTY_BROWN,
		COLOR_BEASTY_BROWN,
		COLOR_BROWN_ORANGE,
	)
	if(tint) // returns a tint of selected color
		return tint_color(pick(color_options), range)
	return pick(color_options)

/// Returns a purely random tint for specific color
/proc/tint_color(color, range = 25)
	if(!is_color_text(color)) // if it's not a hex color
		return color // just leave it as it is

	var/R = clamp(color2R(color) + rand(-range, range), 0, 255)
	var/G = clamp(color2G(color) + rand(-range, range), 0, 255)
	var/B = clamp(color2B(color) + rand(-range, range), 0, 255)

	return rgb(R, G, B)

/proc/random_head_accessory(species = "Human")
	var/ha_style = "None"
	var/list/valid_head_accessories = list()
	for(var/head_accessory in GLOB.head_accessory_styles_list)
		var/datum/sprite_accessory/S = GLOB.head_accessory_styles_list[head_accessory]

		if(!(species in S.species_allowed))
			continue
		valid_head_accessories += head_accessory

	if(length(valid_head_accessories))
		ha_style = pick(valid_head_accessories)

	return ha_style

/proc/random_marking_style(location = "body", species = "Human", datum/robolimb/robohead, body_accessory, alt_head)
	var/m_style = "None"
	var/list/valid_markings = list()
	for(var/marking in GLOB.marking_styles_list)
		var/datum/sprite_accessory/body_markings/S = GLOB.marking_styles_list[marking]
		if(S.name == "None")
			valid_markings += marking
			continue
		if(S.marking_location != location) //If the marking isn't for the location we desire, skip.
			continue
		if(!(species in S.species_allowed)) //If the user's head is not of a species the marking style allows, skip it. Otherwise, add it to the list.
			continue
		if(location == "tail")
			if(!body_accessory)
				if(S.tails_allowed)
					continue
			else
				if(!S.tails_allowed || !(body_accessory in S.tails_allowed))
					continue
		if(location == "head")
			var/datum/sprite_accessory/body_markings/head/M = GLOB.marking_styles_list[S.name]
			if(species == "Machine")//If the user is a species that can have a robotic head...
				if(!robohead)
					robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"]
				if(!(S.models_allowed && (robohead.company in S.models_allowed))) //Make sure they don't get markings incompatible with their head.
					continue
			else if(alt_head && alt_head != "None") //If the user's got an alt head, validate markings for that head.
				if(!("All" in M.heads_allowed) && !(alt_head in M.heads_allowed))
					continue
			else
				if(M.heads_allowed && !("All" in M.heads_allowed))
					continue
		valid_markings += marking

	if(length(valid_markings))
		m_style = pick(valid_markings)

	return m_style

/**
  * Returns a random body accessory for a given species name. Can be null based on is_optional argument.
  *
  * Arguments:
  * * species - The name of the species to filter valid body accessories.
  * * is_optional - Whether *no* body accessory (null) is an option.
 */
/proc/random_body_accessory(species = "Vulpkanin", is_optional = TRUE)
	var/list/valid_body_accessories = list()
	if(is_optional)
		valid_body_accessories += null

	if(GLOB.body_accessory_by_species[species])
		for(var/name in GLOB.body_accessory_by_species[species])
			valid_body_accessories += name

	return length(valid_body_accessories) ? pick(valid_body_accessories) : null

/proc/random_name(gender, species = "Human")

	var/datum/species/current_species
	if(species)
		current_species = GLOB.all_species[species]

	if(!current_species || current_species.name == "Human")
		switch(gender)
			if(FEMALE)
				return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
			if(MALE)
				return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
			else
				return capitalize(pick(GLOB.first_names_male + GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	else
		return current_species.get_random_name(gender)

/// Randomises skin tone, specifically for each species that has a skin tone. Otherwise keeps a default of 1
/proc/random_skin_tone(species = "Human")
	var/datum/species/species_selected = GLOB.all_species[species]
	if(species_selected?.bodyflags & HAS_SKIN_TONE)
		return rand(1, 220)
	else if(species_selected?.bodyflags & HAS_ICON_SKIN_TONE)
		return rand(1, length(species_selected.icon_skin_tones))
	return 1

/proc/set_criminal_status(mob/living/user, datum/data/record/target_records , criminal_status, comment, user_rank, list/authcard_access = list(), user_name)
	var/status = criminal_status
	var/their_name = target_records.fields["name"]
	var/their_rank = target_records.fields["rank"]
	switch(criminal_status)
		if("arrest", SEC_RECORD_STATUS_ARREST)
			status = SEC_RECORD_STATUS_ARREST
		if("none", SEC_RECORD_STATUS_NONE)
			status = SEC_RECORD_STATUS_NONE
		if("execute", SEC_RECORD_STATUS_EXECUTE)
			if((ACCESS_MAGISTRATE in authcard_access) || (ACCESS_ARMORY in authcard_access))
				status = SEC_RECORD_STATUS_EXECUTE
				message_admins("[ADMIN_FULLMONTY(usr)] authorized <span class='warning'>EXECUTION</span> for [their_rank] [their_name], with comment: [comment]")
			else
				return 0
		if("search", SEC_RECORD_STATUS_SEARCH)
			status = SEC_RECORD_STATUS_SEARCH
		if("monitor", SEC_RECORD_STATUS_MONITOR)
			status = SEC_RECORD_STATUS_MONITOR
		if("demote", SEC_RECORD_STATUS_DEMOTE)
			message_admins("[ADMIN_FULLMONTY(usr)] set criminal status to <span class='warning'>DEMOTE</span> for [their_rank] [their_name], with comment: [comment]")
			status = SEC_RECORD_STATUS_DEMOTE
		if("incarcerated", SEC_RECORD_STATUS_INCARCERATED)
			status = SEC_RECORD_STATUS_INCARCERATED
		if("parolled", SEC_RECORD_STATUS_PAROLLED)
			status = SEC_RECORD_STATUS_PAROLLED
		if("released", SEC_RECORD_STATUS_RELEASED)
			status = SEC_RECORD_STATUS_RELEASED
	target_records.fields["criminal"] = status
	log_admin("[key_name_admin(user)] set secstatus of [their_rank] [their_name] to [status], comment: [comment]")
	target_records.fields["comments"] += "Set to [status] by [user_name || user.name] ([user_rank]) on [GLOB.current_date_string] [station_time_timestamp()], comment: [comment]"
	update_all_mob_security_hud()
	return 1

/**
 * Creates attack (old and new) logs for the user and defense logs for the target.
 * Will message admins depending on the custom_level, user and target.
 *
 * custom_level will determine the log level set. Unless the target is SSD and there is a user doing it
 * If custom_level is not set then the log level will be determined using the user and the target.
 *
 * * Arguments:
 * * user - The thing doing it. Can be null
 * * target - The target of the attack
 * * what_done - What has happened
 * * custom_level - The log level override
 */
/proc/add_attack_logs(atom/user, target, what_done, custom_level)
	if(islist(target)) // Multi-victim adding
		var/list/targets = target
		for(var/t in targets)
			add_attack_logs(user, t, what_done, custom_level)
		return

	var/user_str = key_name_log(user) + (istype(user) ? COORD(user) : "")
	var/target_str
	var/target_info
	if(isatom(target))
		var/atom/AT = target
		target_str = key_name_log(AT) + COORD(AT)
		target_info = key_name_admin(target)
	else
		target_str = target
		target_info = target
	var/mob/MU = user
	var/mob/MT = target
	if(istype(MU))
		MU.create_log(ATTACK_LOG, what_done, target, get_turf(user))
		MU.create_attack_log("<font color='red'>Attacked [target_str]: [what_done]</font>")
	if(istype(MT))
		MT.create_log(DEFENSE_LOG, what_done, user, get_turf(MT))
		MT.create_attack_log("<font color='orange'>Attacked by [user_str]: [what_done]</font>")
	log_attack(user, target_str, what_done)

	var/loglevel = ATKLOG_MOST
	if(!isnull(custom_level))
		loglevel = custom_level
	var/area/A
	if(isatom(MT) && !QDELETED(MT))
		A = get_area(MT)
	else
		A = get_area(user)
	if(A && A.hide_attacklogs)
		loglevel = ATKLOG_ALL
	else if(istype(MT))
		if(istype(MU))
			if(!MU.ckey && !MT.ckey) // Attacks between NPCs are only shown to admins with ATKLOG_ALL
				loglevel = ATKLOG_ALL
			else if(!MU.ckey || !MT.ckey || (MU.ckey == MT.ckey)) // Player v NPC combat is de-prioritized. Also no self-harm, nobody cares
				loglevel = ATKLOG_ALMOSTALL
	else
		loglevel = ATKLOG_ALL // Hitting an object. Not a mob
	if(user && isLivingSSD(target))  // Attacks on SSDs are shown to admins with any log level except ATKLOG_NONE. Overrides custom level
		loglevel = ATKLOG_FEW


	msg_admin_attack("[key_name_admin(user)] vs [target_info]: [what_done]", loglevel)

/proc/do_mob(mob/user, mob/target, time = 30, progress = 1, list/extra_checks = list(), only_use_extra_checks = FALSE, requires_upright = TRUE, hidden = FALSE)
	if(!user || !target)
		return 0
	var/user_loc = user.loc

	var/drifting = 0
	if(GLOB.move_manager.processing_on(user, SSspacedrift))
		drifting = 1

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	var/datum/cogbar/cog
	if(progress)
		progbar = new(user, time, target)

		if(!hidden && time >= 1 SECONDS)
			cog = new(user)

	var/endtime = world.time+time
	var/starttime = world.time
	. = 1

	var/mob/living/L
	if(isliving(user))
		L = user

	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)
		if(!user || !target)
			. = 0
			break
		if(only_use_extra_checks)
			if(check_for_true_callbacks(extra_checks))
				. = 0
				break
			continue

		if(drifting && !GLOB.move_manager.processing_on(user, SSspacedrift))
			drifting = 0
			user_loc = user.loc

		if((!drifting && user.loc != user_loc) || target.loc != target_loc || user.get_active_hand() != holding || user.incapacitated() || (requires_upright && L && IS_HORIZONTAL(L)) || check_for_true_callbacks(extra_checks))
			. = 0
			break
	if(progress)
		qdel(progbar)
		cog?.remove()

/*	Use this proc when you want to have code under it execute after a delay, and ensure certain conditions are met during that delay...
 *	Such as the user not being interrupted via getting stunned or by moving off the tile they're currently on.
 *
 *	Example usage:
 *
 *	if(do_after(user, 50, target = sometarget, extra_checks = list(callback_check1, callback_check2)))
 *		do_stuff()
 *
 *	This will create progress bar that lasts for 5 seconds. If the user doesn't move or otherwise do something that would cause the checks to fail in those 5 seconds, do_stuff() would execute.
 *	The Proc returns TRUE upon success (the progress bar reached the end), or FALSE upon failure (the user moved or some other check failed)
 *	param {boolean} hidden - By default, any action 1 second or longer shows a cog over the user while it is in progress. If hidden is set to TRUE, the cog will not be shown.
 *	If allow_sleeping_or_dead is true, dead and sleeping mobs will continue. Good if you want to show a progress bar to the user but it doesn't need them to do anything, like modsuits.
 */
/proc/do_after(mob/user, delay, needhand = 1, atom/target = null, progress = 1, allow_moving = 0, must_be_held = 0, list/extra_checks = list(), interaction_key = null, use_default_checks = TRUE, allow_moving_target = FALSE, hidden = FALSE, allow_sleeping_or_dead = FALSE)
	if(!user)
		return FALSE

	if(interaction_key)
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)
	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = FALSE
	if(!allow_moving && GLOB.move_manager.processing_on(user, SSspacedrift))
		drifting = TRUE

	var/holding = user.get_active_hand()

	var/holdingnull = TRUE //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = FALSE //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	var/datum/cogbar/cog
	if(progress)
		progbar = new(user, delay, target)

		if(!hidden && delay >= 1 SECONDS)
			cog = new(user)

	SEND_SIGNAL(user, COMSIG_DO_AFTER_BEGAN)
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE

	// By default, checks for weakness and stunned get added to the extra_checks list.
	// Setting `use_default_checks` to FALSE means that you don't want the do_after to check for these statuses, or that you will be supplying your own checks.
	if(use_default_checks)
		extra_checks += CALLBACK(user, TYPE_PROC_REF(/mob/living, IsWeakened))
		extra_checks += CALLBACK(user, TYPE_PROC_REF(/mob/living, IsStunned))

	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)
		if(!allow_moving)
			if(drifting && !GLOB.move_manager.processing_on(user, SSspacedrift))
				drifting = FALSE
				Uloc = user.loc
			if(!drifting && user.loc != Uloc)
				. = FALSE
				break

		if(!user || (user.stat && !allow_sleeping_or_dead) || check_for_true_callbacks(extra_checks))
			. = FALSE
			break

		if(!allow_moving_target && Tloc && (!target || Tloc != target.loc))
			. = FALSE
			break

		if(must_be_held && target.loc != user)
			. = FALSE
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = FALSE
					break
			if(user.get_active_hand() != holding)
				. = FALSE
				break
	if(progress)
		qdel(progbar)
		cog?.remove()
		if(interaction_key)
			var/reduced_interaction_count = (LAZYACCESS(user.do_afters, interaction_key) || 0) - 1
			if(reduced_interaction_count > 0) // Not done yet!
				LAZYSET(user.do_afters, interaction_key, reduced_interaction_count)
				return
			// all out, let's clear er out fully
			LAZYREMOVE(user.do_afters, interaction_key)
		SEND_SIGNAL(user, COMSIG_DO_AFTER_ENDED)

// Upon any of the callbacks in the list returning TRUE, the proc will return TRUE.
/proc/check_for_true_callbacks(list/extra_checks)
	for(var/datum/callback/CB in extra_checks)
		if(CB.Invoke())
			return TRUE
	return FALSE

#define DOAFTERONCE_MAGIC "Magic~~"
GLOBAL_LIST_EMPTY(do_after_once_tracker)
/proc/do_after_once(mob/user, delay, needhand = 1, atom/target = null, progress = 1, allow_moving, must_be_held, attempt_cancel_message = "Attempt cancelled.", special_identifier, hidden = FALSE, interaction_key = null)
	if(!user || !target)
		return

	var/cache_key = "[user.UID()][target.UID()][special_identifier]"
	if(GLOB.do_after_once_tracker[cache_key])
		GLOB.do_after_once_tracker[cache_key] = DOAFTERONCE_MAGIC
		to_chat(user, "<span class='warning'>[attempt_cancel_message]</span>")
		return FALSE
	GLOB.do_after_once_tracker[cache_key] = TRUE
	. = do_after(user, delay, needhand, target, progress, allow_moving, must_be_held, extra_checks = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(do_after_once_checks), cache_key, hidden)), interaction_key = interaction_key)
	GLOB.do_after_once_tracker[cache_key] = FALSE

// Please don't use this unless you absolutely need to. Just have a direct call to do_after_once whenever possible.
/proc/interrupt_do_after_once(mob/user, atom/target, special_identifier)
	var/cache_key = "[user.UID()][target.UID()][special_identifier]"
	if(GLOB.do_after_once_tracker[cache_key])
		GLOB.do_after_once_tracker[cache_key] = DOAFTERONCE_MAGIC
		return TRUE
	return FALSE

/proc/do_after_once_checks(cache_key)
	if(GLOB.do_after_once_tracker[cache_key] && GLOB.do_after_once_tracker[cache_key] == DOAFTERONCE_MAGIC)
		GLOB.do_after_once_tracker[cache_key] = FALSE
		return TRUE
	return FALSE

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/proc/admin_mob_info(mob/M, mob/user = usr)
	if(!ismob(M))
		to_chat(user, "This can only be used on instances of type /mob")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/T = get_turf(M)

	//Location
	if(isturf(T))
		if(isarea(T.loc))
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
		else
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

	//Job + antagonist
	if(M.mind)
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev) ? "Yes" : "No"]"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

	//Health
	if(isliving(M))
		var/mob/living/L = M
		var/status
		switch(M.stat)
			if(CONSCIOUS)
				status = "Alive"
			if(UNCONSCIOUS)
				status = "<font color='orange'><b>Unconscious</b></font>"
			if(DEAD)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status = [status]"
		health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gender
	switch(M.gender)
		if(MALE, FEMALE)
			gender_description = "[M.gender]"
		else
			gender_description = "<font color='red'><b>[M.gender]</b></font>"

	to_chat(user, "<b>Info about [M.name]:</b> ")
	to_chat(user, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
	to_chat(user, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
	to_chat(user, "Location = [location_description];")
	to_chat(user, "[special_role_description]")
	to_chat(user, "(<a href='byond://?src=[usr.UID()];priv_msg=[M.client?.ckey]'>PM</a>) ([ADMIN_PP(M,"PP")]) ([ADMIN_VV(M,"VV")]) ([ADMIN_TP(M,"TP")]) ([ADMIN_SM(M,"SM")]) ([ADMIN_FLW(M,"FLW")]) ([ADMIN_OBS(M, "OBS")])")

// Gets the first mob contained in an atom, and warns the user if there's not exactly one
/proc/get_mob_in_atom_with_warning(atom/A, mob/user = usr)
	if(!istype(A))
		return null
	if(ismob(A))
		return A
	if(istype(A, /obj/structure/blob/core))
		var/obj/structure/blob/core/blob = A
		if(blob.overmind)
			return blob.overmind

	. = null
	for(var/mob/M in A)
		if(!.)
			. = M
		else
			to_chat(user, "<span class='warning'>Multiple mobs in [A], using first mob found...</span>")
			break
	if(!.)
		to_chat(user, "<span class='warning'>No mob located in [A].</span>")

// Suppress the mouse macros
/mob/proc/LogMouseMacro(verbused, params)
	if(!client)
		return
	if(!client.next_mouse_macro_warning) // Log once
		log_admin("[key_name(usr)] attempted to use a mouse macro: [verbused] [params]")
		message_admins("[key_name_admin(usr)] attempted to use a mouse macro: [verbused] [html_encode(params)]")
	if(client.next_mouse_macro_warning < world.time) // Warn occasionally
		SEND_SOUND(usr, sound('sound/misc/sadtrombone.ogg'))
		client.next_mouse_macro_warning = world.time + 600

/mob/verb/ClickSubstitute(params as command_text)
	set hidden = 1
	set name = ".click"
	LogMouseMacro(".click", params)

/mob/verb/DblClickSubstitute(params as command_text)
	set hidden = 1
	set name = ".dblclick"
	LogMouseMacro(".dblclick", params)

/mob/verb/MouseSubstitute(params as command_text)
	set hidden = 1
	set name = ".mouse"
	LogMouseMacro(".mouse", params)

/proc/update_all_mob_security_hud()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		H.sec_hud_set_security_status()

/proc/update_all_mob_malf_hud()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		H.malf_hud_set_status()

/proc/getviewsize(view)
	var/viewX
	var/viewY
	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		viewX = totalviewrange
		viewY = totalviewrange
	else if(istext(view))
		var/list/viewrangelist = splittext(view, "x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	else if(islist(view) && length(view) == 2 && isnum(view[1]) && isnum(view[2]))
		// better be a list of nums!
		viewX = view[1]
		viewY = view[2]
	else
		CRASH("Invalid view type parameter passed to getviewsize: [view]")

	return list(viewX, viewY)

/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	return ISINRANGE(target.x, source.x - view_range[1], source.x + view_range[1]) && ISINRANGE(target.y, source.y - view_range[2], source.y + view_range[2])

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(length(mob_spawn_meancritters) <= 0 || length(mob_spawn_nicecritters) <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T

		for(var/T in typesof(/mob/living/basic))
			var/mob/living/basic/BA = T
			switch(initial(BA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/simple_animal/C = new chosen(spawn_location)
	return C

//determines the job of a mob, taking into account job transfers
/proc/determine_role(mob/living/P)
	var/datum/mind/M = P.mind
	if(!M)
		return
	return M.playtime_role ? M.playtime_role : M.assigned_role	//returns current role

/**	checks the security force on station and returns a list of numbers, of the form:
 * 	total, active, dead, antag
 * 	where active is defined as conscious (STAT = 0) and not an antag
*/
/proc/check_active_security_force()
	var/sec_positions = GLOB.active_security_positions
	var/total = 0
	var/active = 0
	var/dead = 0
	var/antag = 0
	for(var/p in GLOB.human_list)	//contains only human mobs, so no type check needed
		var/mob/living/carbon/human/player = p	//need to tell it what type it is or we can't access stat without the dreaded :
		if(determine_role(player) in sec_positions)
			total++
			if(player.stat == DEAD)
				dead++
				continue
			if(isAntag(player))
				antag++
				continue
			if(player.stat == CONSCIOUS)
				active++
	return list(total, active, dead, antag)

/**
  * Safe ckey getter
  *
  * Should be used whenever broadcasting public information about a mob,
  * as this proc will make a best effort to hide the users ckey if they request it.
  * It will first check the mob for a client, then use the mobs last ckey as a directory lookup.
  * If a client cant be found to check preferences on, it will just show as DC'd.
  * This proc should only be used for public facing stuff, not administration related things.
  *
  * Arguments:
  * * M - Mob to get a safe ckey of
  */
/proc/safe_get_ckey(mob/M)
	var/client/C = null
	if(M.client)
		C = M.client
	else if(M.last_known_ckey in GLOB.directory)
		C = GLOB.directory[M.last_known_ckey]

	// Now we see if we need to respect their privacy
	var/out_ckey
	if(C)
		if(C.prefs.toggles2 & PREFTOGGLE_2_ANON)
			out_ckey = "(Anon)"
		else
			out_ckey = C.ckey
	else
		// No client. Just mark as DC'd.
		out_ckey = "(Disconnected)"

	return out_ckey

/// rounds value to limited symbols after the period for organ damage and other values
/proc/round_health(health)
	return round(health, 0.01)

/// Takes in an associated list (key `/datum/action` typepaths, value is the AI
/// blackboard key) and handles granting the action and adding it to the mob's
/// AI controller blackboard. This is only useful in instances where you don't
/// want to store the reference to the action on a variable on the mob. You can
/// set the value to null if you don't want to add it to the blackboard (like in
/// player controlled instances). Is also safe with null AI controllers. Assumes
/// that the action will be initialized and held in the mob itself, which is
/// typically standard.
/mob/proc/grant_actions_by_list(list/input)
	if(length(input) <= 0)
		return

	for(var/action in input)
		var/datum/action/ability = new action(src)
		ability.Grant(src)

		var/blackboard_key = input[action]
		if(isnull(blackboard_key))
			continue

		ai_controller?.set_blackboard_key(blackboard_key, ability)

/**
 * [/proc/ran_zone] but only returns bodyzones that the mob actually has.
 *
 * * `blacklisted_parts` allows you to specify zones that will not be chosen.
 *   e.g.: list(`BODY_ZONE_CHEST`, `BODY_ZONE_R_LEG`). **Blacklisting
 *   `BODY_ZONE_CHEST` is really risky since it's the only bodypart guaranteed
 *   to always exist. Only do that if you're certain they have limbs, otherwise
 *   we'll crash!**
 *
 * * [/proc/ran_zone] has a base `prob(80)` to return the `base_zone` (or if null,
 *   `BODY_ZONE_CHEST`) vs something in our generated list of limbs. This
 *   probability is overriden when either blacklisted_parts contains
 *   BODY_ZONE_CHEST and we aren't passed a base_zone (since the default
 *   fallback for ran_zone would be the chest in that scenario), or if
 *   even_weights is enabled. You can also manually adjust this probability by
 *   altering `base_probability`.
 *
 * * even_weights - ran_zone has a 40% chance (after the prob(80) mentioned
 *   above) of picking a limb, vs the torso & head which have an additional 10%
 *   chance. Setting even_weights to TRUE will make it just a straight up pick()
 *   between all possible bodyparts.
 */
/mob/proc/get_random_valid_zone(base_zone, base_probability = 80, list/blacklisted_parts, even_weights, bypass_warning)
	return BODY_ZONE_CHEST // Pass the default of check_zone to be safe.

/mob/living/carbon/human/get_random_valid_zone(base_zone, base_probability = 80, list/blacklisted_parts, even_weights, bypass_warning)
	var/list/limbs = list()
	for(var/obj/item/organ/limb as anything in bodyparts)
		var/limb_zone = limb.parent_organ // cache the parent organ since we're gonna check it a ton.
		if(limb_zone in blacklisted_parts)
			continue
		if(even_weights)
			limbs[limb_zone] = 1
			continue
		if(limb_zone == BODY_ZONE_CHEST || limb_zone == BODY_ZONE_HEAD)
			limbs[limb_zone] = 1
		else
			limbs[limb_zone] = 4

	if(base_zone && !(check_zone(base_zone) in limbs))
		base_zone = null // check if the passed zone is infact valid

	var/chest_blacklisted
	if(BODY_ZONE_CHEST in blacklisted_parts)
		chest_blacklisted = TRUE
		if(bypass_warning && length(limbs))
			CRASH("limbs is empty and the chest is blacklisted. this may not be intended!")
	return (((chest_blacklisted && !base_zone) || even_weights) ? pickweight(limbs) : ran_zone(base_zone, base_probability, limbs))
