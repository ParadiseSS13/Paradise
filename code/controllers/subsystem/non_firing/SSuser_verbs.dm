GENERAL_PROTECT_DATUM(/datum/controller/subsystem/user_verbs)

SUBSYSTEM_DEF(user_verbs)
	name = "User Verbs"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_USER_VERBS
	/// A list of all user verbs indexed by their type.
	var/list/user_verbs_by_type = list()
	/// A list of all user verbs indexed by their visibility flag.
	var/list/user_verbs_by_visibility_flag = list()
	/// A map of all associated admins and their visibility flags.
	var/list/admin_visibility_flags = list()
	/// A list of all admins that are pending initialization of this SS.
	var/list/admins_pending_subsytem_init = list()

/datum/controller/subsystem/user_verbs/Initialize()
	setup_verb_list()
	process_pending_admins()

/datum/controller/subsystem/user_verbs/Recover()
	user_verbs_by_type = SSuser_verbs.user_verbs_by_type

/datum/controller/subsystem/user_verbs/stat_entry(msg)
	msg = "V:[length(user_verbs_by_type)]"
	return ..()

/datum/controller/subsystem/user_verbs/proc/process_pending_admins()
	var/list/pending_admins = admins_pending_subsytem_init
	admins_pending_subsytem_init = null
	for(var/admin_ckey in pending_admins)
		associate(GLOB.directory[admin_ckey])

/datum/controller/subsystem/user_verbs/proc/setup_verb_list()
	if(length(user_verbs_by_type))
		CRASH("Attempting to set up user verbs twice!")
	for(var/datum/user_verb/verb_type as anything in subtypesof(/datum/user_verb))
		var/datum/user_verb/verb_singleton = new verb_type
		if(!verb_singleton.__avd_check_should_exist())
			qdel(verb_singleton, force = TRUE)
			continue

		user_verbs_by_type[verb_type] = verb_singleton
		if(verb_singleton.visibility_flag)
			if(!(verb_singleton.visibility_flag in user_verbs_by_visibility_flag))
				user_verbs_by_visibility_flag[verb_singleton.visibility_flag] = list()
			user_verbs_by_visibility_flag[verb_singleton.visibility_flag] |= list(verb_singleton)

/datum/controller/subsystem/user_verbs/proc/get_valid_verbs_for(client/admin)
	if(isnull(admin.holder))
		CRASH("Tried to get valid verbs for client without permissions")

	var/list/has_permission = list()
	for(var/permission_flag in GLOB.more_bitflags)
		if(check_rights_client(permission_flag, FALSE, admin))
			has_permission["[permission_flag]"] = TRUE

	var/list/valid_verbs = list()
	for(var/datum/user_verb/verb_type as anything in user_verbs_by_type)
		var/datum/user_verb/verb_singleton = user_verbs_by_type[verb_type]
		if(!verify_visibility(admin, verb_singleton))
			continue

		var/verb_permissions = verb_singleton.permissions
		if(verb_permissions == R_NONE)
			valid_verbs |= list(verb_singleton)
		else for(var/permission_flag in bitfield2list(verb_permissions))
			if(!has_permission["[permission_flag]"])
				continue
			valid_verbs |= list(verb_singleton)

	return valid_verbs

/datum/controller/subsystem/user_verbs/proc/verify_visibility(client/admin, datum/user_verb/verb_singleton)
	var/needed_flag = verb_singleton.visibility_flag
	return !needed_flag || (needed_flag in admin_visibility_flags[admin.ckey])

/datum/controller/subsystem/user_verbs/proc/update_visibility_flag(client/admin, flag, state)
	if(state)
		admin_visibility_flags[admin.ckey] |= list(flag)
		associate(admin)
		return

	admin_visibility_flags[admin.ckey] -= list(flag)
	// they lost the flag, iterate over verbs with that flag and yoink em
	for(var/datum/user_verb/verb_singleton as anything in user_verbs_by_visibility_flag[flag])
		verb_singleton.unassign_from_client(admin)
	admin.init_verbs()

/datum/controller/subsystem/user_verbs/proc/invoke_verb(client/admin, datum/user_verb/verb_type, ...)
	if(IsAdminAdvancedProcCall())
		message_admins("PERMISSION ELEVATION: [key_name_admin(admin)] attempted to dynamically invoke user verb '[verb_type]'.")
		return

	if(ismob(admin))
		var/mob/mob = admin
		admin = mob.client

	if(!ispath(verb_type, /datum/user_verb) || verb_type == /datum/user_verb)
		CRASH("Attempted to dynamically invoke user verb with invalid typepath '[verb_type]'.")
	if(isnull(admin.holder))
		CRASH("Attempted to dynamically invoke user verb '[verb_type]' with a non-admin.")

	var/list/verb_args = args.Copy()
	verb_args.Cut(2, 3)
	var/datum/user_verb/verb_singleton = user_verbs_by_type[verb_type] // this cannot be typed because we need to use `:`
	if(isnull(verb_singleton))
		CRASH("Attempted to dynamically invoke user verb '[verb_type]' that doesn't exist.")

	if(!check_rights_client(verb_singleton.permissions, FALSE, admin))
		to_chat(admin, SPAN_ADMINNOTICE("You lack the permissions to do this."))
		return

	var/old_usr = usr
	usr = admin.mob
	// THE MACRO ENSURES THIS EXISTS. IF IT EVER DOESNT EXIST SOMEONE DIDNT USE THE DAMN MACRO!
	verb_singleton.__avd_do_verb(arglist(verb_args))
	usr = old_usr
	SSblackbox.record_feedback("tally", "dynamic_user_verb_invocation", 1, "[verb_type]")

/**
 * Assosciates and/or resyncs an admin with their accessible user verbs.
 */
/datum/controller/subsystem/user_verbs/proc/associate(client/user)
	if(IsAdminAdvancedProcCall())
		return

	if(!isnull(admins_pending_subsytem_init)) // if the list exists we are still initializing
		if(!(user.ckey in admins_pending_subsytem_init))
			to_chat(user, "<span class='big green'>User Verbs are still initializing. Please wait and you will be automatically assigned your verbs when it is complete.</span>")
			admins_pending_subsytem_init |= list(user.ckey)
		return

	// refresh their verbs
	admin_visibility_flags[user.ckey] ||= list()
	if(user.holder.is_localhost_autoadmin)
		admin_visibility_flags[user.ckey] |= list(VERB_VISIBILITY_FLAG_LOCALHOST)
	for(var/datum/user_verb/verb_singleton as anything in get_valid_verbs_for(user))
		verb_singleton.assign_to_client(user)
	user.init_verbs()

/**
 * Unassociates an admin from their user verbs.
 * Goes over all user verbs because we don't know which ones are assigned to the admin's mob without a bunch of extra bookkeeping.
 * This might be a performance issue in the future if we have a lot of user verbs.
 */
/datum/controller/subsystem/user_verbs/proc/deassociate(client/user)
	if(IsAdminAdvancedProcCall())
		return

	UnregisterSignal(user, COMSIG_MOB_CLIENT_LOGIN)
	for(var/verb_type in user_verbs_by_type)
		var/datum/user_verb/user_verb = user_verbs_by_type[verb_type]
		user_verb.unassign_from_client(user)
	admin_visibility_flags -= list(user.ckey)
