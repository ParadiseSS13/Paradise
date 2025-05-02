RESTRICT_TYPE(/datum/job_candidate)

/// A datum representing all the information needed to perform roundstart job
/// selection, without actually needing clients. This allows for the creation
/// of fake candidates, allowing testing of the role selection system independent
/// of the number of actual players.
/datum/job_candidate
	/// The character being considered for assignment. Is a default character
	/// save but can have player characters loaded into it via
	/// [/datum/job_candidate/proc/load_from_player].
	VAR_PRIVATE/datum/character_save/active_character
	/// The jobbans of the current player or simulated candidate.
	VAR_PRIVATE/datum/job_ban_holder/jbh
	/// The list of special roles the candidate has enabled.
	VAR_PRIVATE/list/be_special = list()
	/// The jobs that the candidate cannot play, usually populated as a result
	/// of the candidate being assigned a special/antag role.
	VAR_PRIVATE/list/restricted_roles = list()
	/// The account age in days.
	VAR_PRIVATE/account_age_in_days
	/// The bitfield of admin rights the candidate has. Used to allow bypasses
	/// of playtime requirements for admins if
	/// [/datum/configuration_section/job_configuration/var/enable_exp_admin_bypass]
	/// is set.
	VAR_PRIVATE/admin_rights = 0
	/// The name of the assigned job, once one has been assigned.
	VAR_PRIVATE/assigned_job_title = null
	/// A query parameterized list of jobs to hours played.
	VAR_PRIVATE/exp
	/// Whether or not the player represented by the candidate is an admin.
	VAR_PRIVATE/is_admin = FALSE
	/// Whether or not the player represented by the candidate is logged in on a
	/// guest account.
	VAR_PRIVATE/is_guest_key = FALSE
	/// Whether or not the candidate is a late join candidate, as opposed to a
	/// roundstart one.
	VAR_PRIVATE/latejoin = FALSE
	/// The player's ckey, if the candidate is representing a real player.
	VAR_PRIVATE/real_ckey
	/// Whether or not the player is being returned to the lobby due to a failed
	/// job selection.
	VAR_PRIVATE/return_to_lobby = FALSE
	/// What, if any, special/antag role has been assigned to the candidate
	/// ahead of job selection.
	VAR_PRIVATE/special_role
	/// Whether this candidate failed a head roll as an antag.
	VAR_PRIVATE/failed_head_antag_roll_

/datum/job_candidate/New()
	active_character = new()
	jbh = new()

/datum/job_candidate/Destroy(force, ...)
	active_character = null
	jbh = null
	return ..()

/datum/job_candidate/proc/get_ckey()
	return real_ckey ? real_ckey : "(simulated) CKEY"

/datum/job_candidate/proc/is_assigned()
	return assigned_job_title != null

/datum/job_candidate/proc/assign_title(title)
	assigned_job_title = title

/datum/job_candidate/proc/return_to_lobby()
	return_to_lobby = TRUE

/datum/job_candidate/proc/restricted_from(datum/job/job)
	return job.title in restricted_roles

/datum/job_candidate/proc/has_special_role()
	return special_role

/datum/job_candidate/proc/alternate_spawn_option()
	return active_character.alternate_option

/datum/job_candidate/proc/has_restricted_roles()
	return length(restricted_roles)

/datum/job_candidate/proc/is_jobbanned(datum/job/job)
	if(GLOB.configuration.jobs.guest_job_ban && is_guest_key)
		return "Guest Job-ban"

	if(job.title in jbh.job_bans)
		var/datum/job_ban/ban = jbh.job_bans[job.title]
		return ban.reason

/datum/job_candidate/proc/wants_job(datum/job/job, level)
	return active_character.GetJobDepartment(job, level) & job.flag

/datum/job_candidate/proc/is_account_old_enough(datum/job/job)
	if(GLOB.configuration.jobs.restrict_jobs_on_account_age && isnum(account_age_in_days) && isnum(job.minimal_player_age))
		return max(0, job.minimal_player_age - account_age_in_days) == 0

	return TRUE

/datum/job_candidate/proc/has_special(flag)
	return flag in be_special

/datum/job_candidate/proc/failed_head_antag_roll()
	return failed_head_antag_roll_

/datum/job_candidate/proc/fail_head_antag_roll()
	failed_head_antag_roll_ = TRUE

/datum/job_candidate/proc/load_from_player(mob/new_player/player)
	if(!istype(player))
		log_debug("asked to load job candidate from null player")
		return
	if(!istype(player.client))
		log_debug("asked to load job candidate from player [player] with no attached client")
		return
	active_character = player.client.prefs.active_character
	jbh.reload_jobbans(player.client)
	account_age_in_days = player.client.player_age
	be_special = player.client.prefs.be_special
	restricted_roles = player.mind.restricted_roles
	special_role = player.mind.special_role
	exp = player.client.prefs.exp
	if(player.client.holder)
		is_admin = TRUE
		admin_rights = player.client.holder.rights
	real_ckey = player.ckey

/datum/job_candidate/proc/apply_to_player(mob/new_player/player)
	if(return_to_lobby)
		player.ready = FALSE
		return

	var/datum/job/job = SSjobs.GetJob(assigned_job_title)
	if(job)
		player.mind.assigned_role = assigned_job_title
		player.mind.role_alt_title = active_character.GetPlayerAltTitle(job)
		player.mind.job_objectives.Cut()

		for(var/objective_type in job.required_objectives)
			new objective_type(player.mind)

/datum/job_candidate/proc/get_job_eligibility(datum/job/job)
	if(!job)
		return FALSE
	if(job.job_banned_gamemode)
		return FALSE
	if(is_jobbanned(job))
		return FALSE
	if(!is_account_old_enough(job))
		return FALSE
	if(get_job_exp_restrictions(job))
		return FALSE
	if(is_barred_by_disability(job))
		return FALSE
	if(is_barred_by_missing_limbs(job))
		return FALSE

	return TRUE

/datum/job_candidate/proc/is_barred_by_missing_limbs(datum/job/job)
	if(!job.missing_limbs_allowed)
		return FALSE

	var/organ_status
	var/list/active_character_organs = active_character.organ_data

	for(var/organ_name in active_character_organs)
		organ_status = active_character_organs[organ_name]
		if(organ_status == "amputated")
			return TRUE
	return FALSE

/datum/job_candidate/proc/is_barred_by_disability(datum/job/job)
	if(!length(job.blacklisted_disabilities))
		return FALSE
	for(var/disability in job.blacklisted_disabilities)
		if(active_character.disabilities & disability)
			return TRUE
	return FALSE

/datum/job_candidate/proc/get_job_exp_restrictions(datum/job/job)
	if(is_job_playable(job))
		return null

	var/list/play_records = params2list(exp)
	var/list/innertext = list()

	for(var/exp_type in job.exp_map)
		if(!(exp_type in play_records))
			innertext += "[get_exp_format(job.exp_map[exp_type])] as [exp_type]"
			continue
		// You may be saying "Jeez why so many text2num()"
		// The DB loads these as strings for some reason, and I also dont trust coders to use ints in the job lists properly
		if(text2num(job.exp_map[exp_type]) > text2num(play_records[exp_type]))
			var/diff = text2num(job.exp_map[exp_type]) - text2num(play_records[exp_type])
			innertext += "[get_exp_format(diff)] as [exp_type]"

	if(length(innertext))
		return innertext.Join(", ")

	return null

/datum/job_candidate/proc/check_admin_rights(rights_required)
	if(rights_required)
		if(rights_required & admin_rights)
			return TRUE
	else if(is_admin)
		return TRUE

	return FALSE

/datum/job_candidate/proc/is_job_playable(datum/job/job)
	if(!length(job.exp_map))
		return TRUE // No EXP map, playable
	if(!GLOB.configuration.jobs.enable_exp_restrictions)
		return TRUE // No restrictions, playable
	if(GLOB.configuration.jobs.enable_exp_admin_bypass && check_admin_rights(R_ADMIN))
		return TRUE // Admin user, playable

	// Now look through their EXP
	var/list/play_records = params2list(exp)
	var/success = TRUE

	// Check their requirements
	for(var/exp_type in job.exp_map)
		if(!(exp_type in play_records))
			success = FALSE
			continue
		if(text2num(job.exp_map[exp_type]) > text2num(play_records[exp_type]))
			success = FALSE

	return success
