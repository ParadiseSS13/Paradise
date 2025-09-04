GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums) // This is protected because we dont want people making their own admin ranks, for obvious reasons

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

/proc/GenerateToken()
	. = ""
	for(var/I in 1 to 32)
		. += "[rand(10)]"

/datum/admins
	var/rank = "No Rank"
	var/ckey
	var/client/owner
	/// Bitflag containing the current rights this admin holder is assigned to
	var/rights = 0
	/// Tracks if their permissions have been reduced due to a lack of 2fa.
	var/restricted_by_2fa = FALSE
	/// Was this auto-created for someone connecting from localhost?
	var/is_localhost_autoadmin = FALSE
	var/fakekey
	var/big_brother	= FALSE
	var/current_tab = 0

	/// Unique-to-session randomly generated token given to each admin to help add detail to logs on admin interactions with hrefs
	var/href_token

	/// Our currently linked marked datum
	var/datum/marked_datum

	/// Our index into GLOB.antagonist_teams, so that admins can have pretty tabs in the Check Teams menu.
	var/team_switch_tab_index = 1

/datum/admins/New(initial_rank, initial_rights, ckey)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Admin rank creation blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to create a new admin rank via advanced proc-call")
		log_admin("[key_name(usr)] attempted to edit feedback a new admin rank via advanced proc-call")
		return
	if(!ckey)
		error("Admin datum created without a ckey argument. Datum has been deleted")
		qdel(src)
		return
	src.ckey = ckey
	if(initial_rank)
		rank = initial_rank
	if(initial_rights)
		rights = initial_rights
	href_token = GenerateToken()
	GLOB.admin_datums[ckey] = src

/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Admin rank deletion blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to delete an admin rank via advanced proc-call")
		log_admin("[key_name(usr)] attempted to delete an admin rank via advanced proc-call")
		return
	disassociate()
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/admins/proc/associate(client/C, delay_2fa_complaint = FALSE)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Rank association blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to associate an admin rank to a new client via advanced proc-call")
		log_admin("[key_name(usr)] attempted to associate an admin rank to a new client via advanced proc-call")
		return

	if(istype(C) && C.ckey != ckey)
		CRASH("Admin datum belonging to [ckey] was asked to associate to client belonging to [C.ckey].")

	owner = C

	// Check for 2fa, if required.
	if(needs_2fa() && istype(owner) && !owner.has_2fa())
		// Disable most permissions.
		rights = rights & (R_MENTOR | R_VIEWRUNTIMES)
		restricted_by_2fa = TRUE
		if(!delay_2fa_complaint)
			// And tell them about it.
			to_chat(owner,"<span class='boldannounceooc'><big>You do not have 2FA enabled. Admin verbs will be unavailable until you have enabled 2FA.\nTo setup 2FA, head to the following menu: <a href='byond://?_src_=prefs;preference=tab;tab=[TAB_GAME]'>Game Preferences</a></span>")  // Very fucking obvious

	// Regardless of client, tell BYOND if they should have profiler access.
	if(rights & (R_DEBUG | R_VIEWRUNTIMES))
		world.SetConfig("APP/admin", ckey, "role=admin")

	if(!istype(owner))
		return

	owner.holder = src
	owner.add_admin_verbs()
	if(isobserver(owner.mob))
		var/mob/dead/observer/ghost = owner.mob
		ghost.update_admin_actions()
	remove_verb(owner, /client/proc/readmin)
	owner.init_verbs() //re-initialize the verb list
	owner.update_active_keybindings()
	if(rights & (R_DEBUG | R_VIEWRUNTIMES))
		// Enable the buttons they should have.
		winset(owner, "debugmcbutton", "is-disabled=false")
		winset(owner, "profilecode", "is-disabled=false")
	GLOB.admins |= owner
	GLOB.de_admins -= ckey
	GLOB.de_mentors -= ckey

/datum/admins/proc/needs_2fa()
	if((rights & (R_MENTOR | R_VIEWRUNTIMES)) == rights)
		// No significant permissions.
		return FALSE

	if(GLOB.configuration.admin.enable_localhost_autoadmin && owner && owner.is_connecting_from_localhost())
		// Localhost connections are immune.
		return FALSE

	if(!GLOB.configuration.system.is_production)
		// 2fa isn't required for anyone.
		return FALSE

	return TRUE

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Rank disassociation blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to disassociate an admin rank from a client via advanced proc-call")
		log_admin("[key_name(usr)] attempted to disassociate an admin rank from a client via advanced proc-call")
		return

	GLOB.admin_datums -= ckey

	// Regardless of client, tell BYOND they shouldn't have access to the profiler.
	world.SetConfig("APP/admin", ckey, null)

	if(owner)
		GLOB.admins -= owner
		owner.hide_verbs()
		owner.holder = null
		owner.init_verbs()
		if(isobserver(owner.mob))
			var/mob/dead/observer/ghost = owner.mob
			ghost.update_admin_actions()
		owner.update_active_keybindings()
		// Disable buttons they should no longer have.
		winset(owner, "debugmcbutton", "is-disabled=true")
		winset(owner, "profilecode", "is-disabled=true")
		owner = null

/*
Checks if usr is an admin.
If rights_required == 0, then it simply checks if they are an admin.
If all is set, requires all the rights listed. Otherwise, any matching right is sufficient.
With show_msg, if the check fails, prints a message explaining why.

Usage:
/some/proc()
	if(!check_rights(R_ADMIN))
		return
	to_chat(world, "you have enough rights!")

NOTE: checks usr by default, not src
*/
/proc/check_rights(rights_required, show_msg = TRUE, mob/user = usr, all = FALSE)
	if(user && user.client)
		return check_rights_ckey(rights_required, show_msg, user.ckey, all)
	return FALSE

// As above, for a /client
/proc/check_rights_client(rights_required, show_msg, client/C, all = FALSE)
	if(C)
		return check_rights_ckey(rights_required, show_msg, C.ckey, all)
	return FALSE

// As above, for a ckey
/proc/check_rights_ckey(rights_required, show_msg, ckey, all)
	var/datum/admins/holder = GLOB.admin_datums[ckey]
	if(!holder)
		if(show_msg)
			to_chat(GLOB.directory[ckey], "<font color='red'>Error: You are not an admin.</font>")
		return FALSE

	if(!rights_required)
		return TRUE

	if((rights_required & holder.rights) == rights_required)
		return TRUE
	else if(!all && (rights_required & holder.rights))
		return TRUE

	if(show_msg)
		if(all)
			to_chat(GLOB.directory[ckey], "<font color='red'>Error: You do not have sufficient rights to do that. You require all of the following flags:[rights2text(rights_required," ")].</font>")
		else
			to_chat(GLOB.directory[ckey], "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>")

	return FALSE

/client/proc/deadmin()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Deadmin blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to de-admin a client via advanced proc-call")
		log_admin("[key_name(usr)] attempted to de-admin a client via advanced proc-call")
		return
	if(holder)
		if(check_rights(R_ADMIN, show_msg = FALSE))
			GLOB.de_admins += ckey
		else
			GLOB.de_mentors += ckey
		qdel(holder)
		add_verb(src, /client/proc/readmin)
	else
		to_chat(src, "<font color='red'>Error: You were already not an admin.</font>")

/client/proc/readmin()
	set name = "Re-admin self"
	set category = "Admin"
	set desc = "Regain your admin powers."

	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounceooc'>Readmin blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to re-admin a client via advanced proc-call")
		log_admin("[key_name(usr)] attempted to re-admin a client via advanced proc-call")

	if(holder)
		to_chat(usr, "<span class='notice'>You are already an admin.</span>")
	else if(ckey in (GLOB.de_admins + GLOB.de_mentors))
		GLOB.de_admins -= ckey
		GLOB.de_mentors -= ckey
		reload_one_admin(ckey, silent = TRUE)
		log_admin("[key_name(usr)] re-adminned themselves.")
		message_admins("[key_name_admin(usr)] re-adminned themselves.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Re-admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		to_chat(usr, "<span class='boldannounceooc'>Readmin blocked: You were not an admin or mentor.</span>")
		message_admins("[key_name(usr)] attempted to re-admin without being an admin or mentor")
		log_admin("[key_name(usr)] attempted to re-admin without being an admin or mentor")

/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE // no admin abuse

/datum/admins/can_vv_delete()
	return FALSE // don't break shit either
