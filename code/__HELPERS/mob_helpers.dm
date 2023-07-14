/proc/GetOppositeDir(dir)
	switch(dir)
		if(NORTH)     return SOUTH
		if(SOUTH)     return NORTH
		if(EAST)      return WEST
		if(WEST)      return EAST
		if(SOUTHWEST) return NORTHEAST
		if(NORTHWEST) return SOUTHEAST
		if(NORTHEAST) return SOUTHWEST
		if(SOUTHEAST) return NORTHWEST
	return 0

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

	if(!valid_picks.len) valid_picks += "Nude"

	return pick(valid_picks)

/proc/random_hair_style(gender, species = "Human", datum/robolimb/robohead)
	var/h_style = "Bald"
	var/list/valid_hairstyles = list()
	for(var/hairstyle in GLOB.hair_styles_public_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_public_list[hairstyle]

		if(hairstyle == "Bald") //Just in case.
			valid_hairstyles += hairstyle
			continue
		if((gender == MALE && S.gender == FEMALE) || (gender == FEMALE && S.gender == MALE))
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

	if(valid_hairstyles.len)
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
		if((gender == MALE && S.gender == FEMALE) || (gender == FEMALE && S.gender == MALE))
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

	if(valid_facial_hairstyles.len)
		f_style = pick(valid_facial_hairstyles)

	return f_style

/proc/random_head_accessory(species = "Human")
	var/ha_style = "None"
	var/list/valid_head_accessories = list()
	for(var/head_accessory in GLOB.head_accessory_styles_list)
		var/datum/sprite_accessory/S = GLOB.head_accessory_styles_list[head_accessory]

		if(!(species in S.species_allowed))
			continue
		valid_head_accessories += head_accessory

	if(valid_head_accessories.len)
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

	if(valid_markings.len)
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
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	else
		return current_species.get_random_name(gender)

/proc/random_skin_tone(species = "Human")
	if(species == "Human" || species == "Drask")
		switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
			if("caucasian")		. = -10
			if("afroamerican")	. = -115
			if("african")		. = -165
			if("latino")		. = -55
			if("albino")		. = 34
			else				. = rand(-185, 34)
		return min(max(. + rand(-25, 25), -185), 34)
	else if(species == "Vox")
		. = rand(1, 6)
		return .

/proc/skintone2racedescription(tone, species = "Human")
	if(species == "Human")
		switch(tone)
			if(30 to INFINITY)		return "albino"
			if(20 to 30)			return "pale"
			if(5 to 15)				return "light skinned"
			if(-10 to 5)			return "white"
			if(-25 to -10)			return "tan"
			if(-45 to -25)			return "darker skinned"
			if(-65 to -45)			return "brown"
			if(-INFINITY to -65)	return "black"
			else					return "unknown"
	else if(species == "Vox")
		switch(tone)
			if(2)					return "dark green"
			if(3)					return "brown"
			if(4)					return "gray"
			if(5)					return "emerald"
			if(6)					return "azure"
			else					return "green"
	else
		return "unknown"

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

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
	log_attack(user_str, target_str, what_done)

	var/loglevel = ATKLOG_MOST
	if(!isnull(custom_level))
		loglevel = custom_level
	var/area/A = get_area(MT)
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

/proc/do_mob(mob/user, mob/target, time = 30, progress = 1, list/extra_checks = list(), only_use_extra_checks = FALSE, requires_upright = TRUE)
	if(!user || !target)
		return 0
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, target)

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

		if(drifting && !user.inertia_dir)
			drifting = 0
			user_loc = user.loc

		if((!drifting && user.loc != user_loc) || target.loc != target_loc || user.get_active_hand() != holding || user.incapacitated() || (requires_upright && L && IS_HORIZONTAL(L)) || check_for_true_callbacks(extra_checks))
			. = 0
			break
	if(progress)
		qdel(progbar)

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
 */
/proc/do_after(mob/user, delay, needhand = 1, atom/target = null, progress = 1, allow_moving = 0, must_be_held = 0, list/extra_checks = list(), use_default_checks = TRUE)
	if(!user)
		return FALSE
	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = FALSE
	if(!allow_moving && !user.Process_Spacemove(0) && user.inertia_dir)
		drifting = TRUE

	var/holding = user.get_active_hand()

	var/holdingnull = TRUE //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = FALSE //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, delay, target)

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
			if(drifting && !user.inertia_dir)
				drifting = FALSE
				Uloc = user.loc
			if(!drifting && user.loc != Uloc)
				. = FALSE
				break

		if(!user || user.stat || check_for_true_callbacks(extra_checks))
			. = FALSE
			break

		if(Tloc && (!target || Tloc != target.loc))
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

// Upon any of the callbacks in the list returning TRUE, the proc will return TRUE.
/proc/check_for_true_callbacks(list/extra_checks)
	for(var/datum/callback/CB in extra_checks)
		if(CB.Invoke())
			return TRUE
	return FALSE

#define DOAFTERONCE_MAGIC "Magic~~"
GLOBAL_LIST_INIT(do_after_once_tracker, list())
/proc/do_after_once(mob/user, delay, needhand = 1, atom/target = null, progress = 1, allow_moving, must_be_held, attempt_cancel_message = "Attempt cancelled.")
	if(!user || !target)
		return

	var/cache_key = "[user.UID()][target.UID()]"
	if(GLOB.do_after_once_tracker[cache_key])
		GLOB.do_after_once_tracker[cache_key] = DOAFTERONCE_MAGIC
		to_chat(user, "<span class='warning'>[attempt_cancel_message]</span>")
		return FALSE
	GLOB.do_after_once_tracker[cache_key] = TRUE
	. = do_after(user, delay, needhand, target, progress, allow_moving, must_be_held, extra_checks = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(do_after_once_checks), cache_key)))
	GLOB.do_after_once_tracker[cache_key] = FALSE

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

/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE, list/extra_args)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/new_args = list(T)
	if(extra_args)
		new_args += extra_args

	for(var/j in 1 to amount)
		var/atom/X = new spawn_type(arglist(new_args))
		X.admin_spawned = admin_spawn

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
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
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

	//Gener
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
	to_chat(user, "(<a href='?src=[usr.UID()];priv_msg=[M.client?.ckey]'>PM</a>) ([ADMIN_PP(M,"PP")]) ([ADMIN_VV(M,"VV")]) ([ADMIN_TP(M,"TP")]) ([ADMIN_SM(M,"SM")]) ([ADMIN_FLW(M,"FLW")])")

// Gets the first mob contained in an atom, and warns the user if there's not exactly one
/proc/get_mob_in_atom_with_warning(atom/A, mob/user = usr)
	if(!istype(A))
		return null
	if(ismob(A))
		return A

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
/client/var/next_mouse_macro_warning
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

/proc/getviewsize(view)
	var/viewX
	var/viewY
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		viewX = totalviewrange
		viewY = totalviewrange
	else
		var/list/viewrangelist = splittext(view, "x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	return list(viewX, viewY)

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(mob_spawn_meancritters.len <= 0 || mob_spawn_nicecritters.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
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
	var/sec_positions = GLOB.security_positions - "Magistrate"
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
