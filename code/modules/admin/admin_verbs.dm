//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
GLOBAL_LIST_INIT(admin_verbs_default, list(
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/cmd_mentor_check_new_players,
	/client/proc/cmd_mentor_check_player_exp /* shows players by playtime */
	))
GLOBAL_LIST_INIT(admin_verbs_admin, list(
	/client/proc/check_antagonists,		/*shows all antags*/
	/client/proc/check_antagonists2,		/*shows all antags*/
	/datum/admins/proc/show_player_panel,
	/client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/admin_observe,			/*allows us to freely observe mobs */
	/client/proc/admin_observe_target,			/*and gives it to us on right click*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/cmd_admin_open_logging_view,
	/client/proc/getserverlogs,			/*allows us to fetch server logs (diary) for other days*/
	/client/proc/get_server_logs_by_round_id,
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
	/client/proc/jump_to,				/*Opens a menu for jumping to an Area, Mob, Key or Coordinate*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcomm*/
	/client/proc/admin_deny_shuttle,	/*toggles availability of shuttle calling*/
	/client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/manage_silicon_laws,	/* Allows viewing and editing silicon laws. */
	/client/proc/admin_memo,			/*admin memo system. show/delete/write. +SERVER needed to delete admin memos of others*/
	/client/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/togglelooc,		/*toggles looc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggledsay,		/*toggles dsay on/off for everyone*/
	/datum/admins/proc/toggleemoji,     /*toggles using emoji in ooc for everyone*/
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/cmd_admin_say,			/*admin-only ooc chat*/
	/client/proc/cmd_staff_say,
	/datum/admins/proc/PlayerNotes,
	/client/proc/cmd_mentor_say,
	/client/proc/cmd_dev_say,
	/datum/admins/proc/show_player_notes,
	/client/proc/free_slot,			/*frees slot for chosen job*/
	/client/proc/update_mob_sprite,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/library_manager,
	/client/proc/view_asays,
	/client/proc/view_msays,
	/client/proc/view_devsays,
	/client/proc/view_staffsays,
	/client/proc/empty_ai_core_toggle_latejoin,
	/client/proc/aooc,
	/client/proc/freeze,
	/client/proc/secrets,
	/client/proc/debug_variables,
	/client/proc/reset_all_tcs,			/*resets all telecomms scripts*/
	/client/proc/toggle_mentor_chat,
	/client/proc/toggle_advanced_interaction, /*toggle admin ability to interact with not only machines, but also atoms such as buttons and doors*/
	/client/proc/list_ssds_afks,
	/client/proc/ccbdb_lookup_ckey,
	/client/proc/view_instances,
	/client/proc/start_vote,
	/client/proc/ping_all_admins,
	/client/proc/show_watchlist,
	/client/proc/debugstatpanel,
	/client/proc/create_rnd_restore_disk,
	/client/proc/open_admin_zlevel_manager,
))
GLOBAL_LIST_INIT(admin_verbs_ban, list(
	/client/proc/ban_panel,
	/datum/admins/proc/vpn_whitelist
	))
GLOBAL_LIST_INIT(admin_verbs_sounds, list(
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/play_server_sound,
	/client/proc/play_intercomm_sound,
	/client/proc/stop_global_admin_sounds,
	/client/proc/stop_sounds_global,
	/client/proc/play_sound_tgchat
	))
GLOBAL_LIST_INIT(admin_verbs_event, list(
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/disease_outbreak,
	/client/proc/one_click_antag,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/economy_manager,
	/client/proc/everyone_random,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/toggle_random_events,
	/client/proc/toggle_ert_calling,
	/client/proc/set_holiday,
	/client/proc/show_tip,
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/response_team, // Response Teams admin verb
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/fax_panel,
	/client/proc/event_manager_panel,
	/client/proc/modify_goals,
	/client/proc/outfit_manager,
	/client/proc/cmd_admin_headset_message,
	/client/proc/change_human_appearance_admin,	/* Allows an admin to change the basic appearance of human-based mobs */
	/client/proc/change_human_appearance_self,	/* Allows the human-based mob itself to change its basic appearance */
	/datum/admins/proc/station_traits_panel,
	/datum/admins/proc/toggle_ai,
	))

GLOBAL_LIST_INIT(admin_verbs_spawn, list(
	/datum/admins/proc/spawn_atom,		/*allows us to spawn instances*/
	/client/proc/respawn_character,
	/client/proc/admin_deserialize,
	/client/proc/create_crate,
	/client/proc/json_spawn_menu
	))
GLOBAL_LIST_INIT(admin_verbs_server, list(
	/client/proc/reload_admins,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/client/proc/toggle_log_hrefs,
	/client/proc/toggle_antagHUD_use,
	/client/proc/toggle_antagHUD_restrictions,
	/client/proc/set_next_map,
	/client/proc/manage_queue,
	/client/proc/add_queue_server_bypass
	))
GLOBAL_LIST_INIT(admin_verbs_debug, list(
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/debug_controller,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_sing,
	/client/proc/restart_controller,
	/client/proc/enable_debug_verbs,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_del_log_simple,
	/client/proc/check_bomb_impacts,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/proc/machine_upgrade,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/map_template_load_lazy,
	/client/proc/view_runtimes,
	/client/proc/admin_serialize,
	/client/proc/uid_log,
	/client/proc/reestablish_db_connection,
	/client/proc/ss_breakdown,
	#ifdef REFERENCE_TRACKING
	/datum/proc/find_refs,
	/datum/proc/qdel_then_find_references,
	/datum/proc/qdel_then_if_fail_find_references,
	#endif
	/client/proc/dmapi_debug,
	/client/proc/dmapi_log,
	/client/proc/timer_log,
	/client/proc/debug_timers,
	/client/proc/force_verb_bypass,
	/client/proc/show_gc_queues,
	/client/proc/debug_global_variables,
	/client/proc/raw_gas_scan,
	/client/proc/teleport_interesting_turf,
	/client/proc/visualize_interesting_turfs,
	/client/proc/profile_code,
	/client/proc/debug_atom_init,
	/client/proc/debug_bloom,
	/client/proc/cmd_mass_screenshot,
	/client/proc/allow_browser_inspect,
	/client/proc/view_bug_reports,
	))
GLOBAL_LIST_INIT(admin_verbs_possess, list(
	/proc/possess,
	/proc/release
	))
GLOBAL_LIST_INIT(admin_verbs_permissions, list(
	/client/proc/edit_admin_permissions,
	/client/proc/big_brother
	))
GLOBAL_LIST_INIT(admin_verbs_rejuv, list(
	/client/proc/respawn_character,
	/client/proc/cmd_admin_rejuvenate
	))
GLOBAL_LIST_INIT(admin_verbs_mod, list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/datum/admins/proc/PlayerNotes,
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/cmd_mentor_say,
	/datum/admins/proc/show_player_notes,
	/client/proc/player_panel_new,
	/client/proc/dsay,
	/datum/admins/proc/show_player_panel,
	/client/proc/ban_panel,
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/admin_observe,
	/client/proc/admin_observe_target,
))
GLOBAL_LIST_INIT(admin_verbs_mentor, list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/openMentorTicketUI,
	/client/proc/admin_observe,  /* Allow mentors to observe as well, though they face some limitations */
	/client/proc/admin_observe_target,
	/client/proc/cmd_mentor_say,	/* mentor say*/
	/client/proc/view_msays,
	/client/proc/cmd_staff_say,
	// cmd_mentor_say is added/removed by the toggle_mentor_chat verb
))
GLOBAL_LIST_INIT(admin_verbs_dev, list(
	/client/proc/cmd_dev_say,
	/client/proc/view_devsays,
	/client/proc/cmd_staff_say,
	/client/proc/view_staffsays
))
GLOBAL_LIST_INIT(admin_verbs_proccall, list(
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query,
	/client/proc/load_sdql2_query,
))
GLOBAL_LIST_INIT(admin_verbs_ticket, list(
	/client/proc/openAdminTicketUI,
	/client/proc/openMentorTicketUI,
	/client/proc/resolveAllAdminTickets,
	/client/proc/resolveAllMentorTickets
))
// In this list are verbs that should ONLY be executed by maintainers, aka people who know how badly this will break the server
// If you are adding something here, you MUST justify it
GLOBAL_LIST_INIT(admin_verbs_maintainer, list(
	/client/proc/ticklag, // This adjusts the server tick rate and is VERY easy to hard lockup the server with
	/client/proc/debugNatureMapGenerator, // This lags like hell, and is very easy to nuke half the server with
	/client/proc/vv_by_ref, // This allows you to lookup **ANYTHING** in the server memory by spamming refs. Locked for security.
	/client/proc/cinematic, // This will break everyone's screens in the round. Dont use this for adminbus.
	/client/proc/throw_runtime, // Do I even need to explain why this is locked?
))
GLOBAL_LIST_INIT(view_runtimes_verbs, list(
	/client/proc/view_runtimes,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_del_log_simple,
	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/ss_breakdown,
	/client/proc/show_gc_queues,
	/client/proc/debug_global_variables,
	/client/proc/debug_timers,
	/client/proc/timer_log,
	/client/proc/raw_gas_scan,
	/client/proc/teleport_interesting_turf,
	/client/proc/visualize_interesting_turfs,
	/client/proc/profile_code,
	/client/proc/view_bug_reports,
))
GLOBAL_LIST_INIT(view_logs_verbs, list(
	/client/proc/getserverlogs,
	/client/proc/get_server_logs_by_round_id,
))

/client/proc/add_admin_verbs()
	if(holder)
		// If they have ANYTHING OTHER THAN ONLY VIEW RUNTIMES AND/OR DEV, then give them the default admin verbs
		if(holder.rights & ~(R_VIEWRUNTIMES|R_DEV_TEAM))
			add_verb(src, GLOB.admin_verbs_default)
		if(holder.rights & R_BUILDMODE)
			add_verb(src, /client/proc/togglebuildmodeself)
		if(holder.rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_admin)
			add_verb(src, GLOB.admin_verbs_ticket)
			spawn(1)
				control_freak = 0
		if(holder.rights & R_BAN)
			add_verb(src, GLOB.admin_verbs_ban)
		if(holder.rights & R_EVENT)
			add_verb(src, GLOB.admin_verbs_event)
		if(holder.rights & R_SERVER)
			add_verb(src, GLOB.admin_verbs_server)
		if(holder.rights & R_DEBUG)
			add_verb(src, GLOB.admin_verbs_debug)
			spawn(1)
				control_freak = 0 // Setting control_freak to 0 allows you to use the Profiler and other client-side tools
		if(holder.rights & R_POSSESS)
			add_verb(src, GLOB.admin_verbs_possess)
		if(holder.rights & R_PERMISSIONS)
			add_verb(src, GLOB.admin_verbs_permissions)
		if(holder.rights & R_STEALTH)
			add_verb(src, /client/proc/stealth)
		if(holder.rights & R_REJUVINATE)
			add_verb(src, GLOB.admin_verbs_rejuv)
		if(holder.rights & R_SOUNDS)
			add_verb(src, GLOB.admin_verbs_sounds)
		if(holder.rights & R_SPAWN)
			add_verb(src, GLOB.admin_verbs_spawn)
		if(holder.rights & R_MOD)
			add_verb(src, GLOB.admin_verbs_mod)
		if(holder.rights & R_MENTOR)
			add_verb(src, GLOB.admin_verbs_mentor)
		if(holder.rights & R_PROCCALL)
			add_verb(src, GLOB.admin_verbs_proccall)
		if(holder.rights & R_MAINTAINER)
			add_verb(src, GLOB.admin_verbs_maintainer)
		if(holder.rights & R_VIEWRUNTIMES)
			add_verb(src, GLOB.view_runtimes_verbs)
			spawn(1) // This setting exposes the profiler for people with R_VIEWRUNTIMES. They must still have it set in cfg/admin.txt
				control_freak = 0
		if(holder.rights & R_DEV_TEAM)
			add_verb(src, GLOB.admin_verbs_dev)
		if(holder.rights & R_VIEWLOGS)
			add_verb(src, GLOB.view_logs_verbs)
		if(is_connecting_from_localhost())
			add_verb(src, /client/proc/export_current_character)

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	if(!holder)
		return

	remove_verb(src, list(
		/client/proc/togglebuildmodeself,
		/client/proc/stealth,
		/client/proc/readmin,
		/client/proc/cmd_dev_say,
		/client/proc/export_current_character,
		GLOB.admin_verbs_default,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_event,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		GLOB.admin_verbs_rejuv,
		GLOB.admin_verbs_sounds,
		GLOB.admin_verbs_spawn,
		GLOB.admin_verbs_mod,
		GLOB.admin_verbs_mentor,
		GLOB.admin_verbs_proccall,
		GLOB.admin_verbs_show_debug_verbs,
		GLOB.admin_verbs_ticket,
		GLOB.admin_verbs_maintainer,
		GLOB.admin_verbs_dev
	))
	add_verb(src, /client/proc/show_verbs)

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	if(!holder)
		return

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mentor_ghost()
	var/is_mentor = check_rights(R_MENTOR, FALSE)
	var/is_full_admin = check_rights(R_ADMIN|R_MOD, FALSE)

	if(!is_mentor && !is_full_admin)
		to_chat(src, "<span class='warning'>You aren't allowed to use this!</span>")
		return

	// mentors are allowed only if they have the observe trait, which is given on observe.
	// they should also not be given this proc.
	if(!is_full_admin && (is_mentor && !HAS_MIND_TRAIT(mob, TRAIT_MENTOR_OBSERVING) || !is_mentor))
		return

	do_aghost()

/client/proc/do_aghost()
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		var/old_turf = get_turf(ghost)
		ghost.ghost_flags |= GHOST_CAN_REENTER // just in-case.
		ghost.reenter_corpse()
		log_admin("[key_name(usr)] re-entered their body")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.regenerate_icons() // workaround for #13269
		if(is_ai(mob)) // client.mob, built in byond client var
			var/mob/living/silicon/ai/ai = mob
			ai.eyeobj.set_loc(old_turf)
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or observe first.</font>")
	else
		//ghostize
		var/mob/body = mob
		body.ghostize()
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		log_admin("[key_name(usr)] has admin-ghosted")
		// TODO: SStgui.on_transfer() to move windows from old and new
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	do_aghost()

/// Allow an admin to observe someone.
/// mentors are allowed to use this verb while living, but with some stipulations:
/// if they attempt to do anything that would stop their orbit, they will immediately be returned to their body.
/client/proc/admin_observe()
	set name = "Aobserve"
	set category = "Admin"
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return

	if(isnewplayer(mob))
		to_chat(src, "<span class='warning'>You cannot aobserve while in the lobby. Please join or observe first.</span>")
		return

	var/mob/target

	target = tgui_input_list(mob, "Select a mob to observe", "Aobserve", GLOB.player_list)
	if(isnull(target))
		return
	if(target == src)
		to_chat(src, "<span class='warning'>You can't observe yourself!</span>")
		return

	if(isobserver(target))
		to_chat(src, "<span class='warning'>[target] is a ghost, and cannot be observed.</span>")
		return

	if(isnewplayer(target))
		to_chat(src, "<span class='warning'>[target] is in the lobby, and cannot be observed.</span>")
		return

	admin_observe_target(target)

/client/proc/cleanup_admin_observe(mob/dead/observer/ghost)
	if(!istype(ghost) || !ghost.mob_observed)
		return FALSE

	// un-follow them
	ghost.cleanup_observe()
	// if it's a mentor, make sure they go back to their body.
	if(HAS_TRAIT(mob.mind, TRAIT_MENTOR_OBSERVING))
		// handler will handle removing the trait
		mob.stop_orbit()
	log_admin("[key_name(src)] has de-activated Aobserve")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Aobserve")
	return TRUE

/// targeted form of admin_observe: this should only appear in the right-click menu.
/client/proc/admin_observe_target(mob/target as mob in GLOB.mob_list)
	set name = "\[Admin\] Aobserve"
	set category = null

	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR, mob))
		return

	var/full_admin = check_rights(R_ADMIN|R_MOD, FALSE, mob)

	if(isnewplayer(mob))
		to_chat(src, "<span class='warning'>You cannot aobserve while in the lobby. Please join or observe first.</span>")
		return

	if(isnewplayer(target))
		to_chat(src, "<span class='warning'>[target] is currently in the lobby.</span>")
		return

	if(isobserver(target))
		to_chat(src, "<span class='warning'>You can't observe a ghost.</span>")
		return

	var/mob/dead/observer/observer = mob
	if(istype(observer) && target == locateUID(observer.mob_observed))
		cleanup_admin_observe(mob)
		return
	cleanup_admin_observe(mob)

	if(isnull(target) || target == src)
		// let the default one find the target if there isn't one
		admin_observe()
		return

	// observers don't need to ghost, so we don't need to worry about adding any traits
	if(isobserver(mob))
		var/mob/dead/observer/ghost = mob
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aobserve")
		ghost.do_observe(target)
		return

	log_admin("[key_name(src)] has Aobserved out of their body to follow [target]")
	do_aghost()
	var/mob/dead/observer/ghost = mob

	if(!full_admin)
		// if they're a me and they're alive, add the MENTOR_OBSERVINGtrait to ensure that they can only go back to their body.
		// we need to handle this here because when you aghost, your mob gets set to the ghost. Oops!
		ADD_TRAIT(mob.mind, TRAIT_MENTOR_OBSERVING, MENTOR_OBSERVING)
		RegisterSignal(ghost, COMSIG_ATOM_ORBITER_STOP, PROC_REF(on_mentor_observe_end), override = TRUE)
		to_chat(src, "<span class='notice'>You have temporarily observed [target], either move or observe again to un-observe.</span>")
		log_admin("[key_name(src)] has mobserved out of their body to follow [target].")
	else
		log_admin("[key_name(src)] is aobserving [target].")


	ghost.do_observe(target)

/client/proc/on_mentor_observe_end(atom/movable/us, atom/movable/orbited)
	SIGNAL_HANDLER  // COMSIG_ATOM_ORBITER_STOP
	if(!isobserver(mob))
		log_and_message_admins("A mentor somehow managed to end observing while not being a ghost. Please investigate and notify coders.")
		return
	var/mob/dead/observer/ghost = mob

	// just to be safe
	ghost.cleanup_observe()

	REMOVE_TRAIT(mob.mind, TRAIT_MENTOR_OBSERVING, MENTOR_OBSERVING)
	UnregisterSignal(mob, COMSIG_ATOM_ORBITER_STOP)

	if(!ghost.reenter_corpse())
		// tell everyone since this is kinda nasty.
		log_debug("Mentor [key_name_mentor(src)] was unable to re-enter their body after mentor observing.")
		log_and_message_admins("[key_name_mentor(src)] was unable to re-enter their body after mentor observing.")
		to_chat(src, "<span class='userdanger'>Unable to return you to your body after mentor ghosting. If your body still exists, please contact a coder, and you should probably ahelp.</span>")

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"

	if(!check_rights(R_ADMIN))
		return
	if(!isliving(mob))
		return

	if(mob.invisibility == INVISIBILITY_OBSERVER)
		mob.invisibility = initial(mob.invisibility)
		mob.add_to_all_human_data_huds()
		to_chat(mob, "<span class='danger'>Invisimin off. Invisibility reset.</span>")
		log_admin("[key_name(mob)] has turned Invisimin OFF")
	else
		mob.invisibility = INVISIBILITY_OBSERVER
		mob.remove_from_all_data_huds()
		to_chat(mob, "<span class='notice'>Invisimin on. You are now as invisible as a ghost.</span>")
		log_admin("[key_name(mob)] has turned Invisimin ON")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Invisimin")

/client/proc/player_panel_new()
	set name = "Player Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	holder.player_panel_new()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.check_antagonists()
	log_admin("[key_name(usr)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists2()
	set name = "TGUI - Antagonists"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/datum/ui_module/admin = get_admin_ui_module(/datum/ui_module/admin/antagonist_menu)
	admin.ui_interact(usr)
	log_admin("[key_name(usr)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/ban_panel()
	set name = "Ban Panel"
	set category = "Admin"

	if(!check_rights(R_BAN))
		return

	holder.DB_ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ban Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.Secrets()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"

	if(!check_rights(R_ADMIN))
		return

	if(holder)
		holder.big_brother = 0
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name.", "Fake Key", key))
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			createStealthKey()
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/big_brother()
	set category = "Admin"
	set name = "Big Brother Mode"

	if(!check_rights(R_PERMISSIONS))
		return

	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			holder.big_brother = 0
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name. Unlike normal stealth mode, this will not appear in Who at all, except for other heads.", "Fake Key", key))
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			holder.big_brother = 1
			if(isobserver(mob))
				mob.invisibility = 90
				mob.see_invisible = 90
			createStealthKey()
		log_admin("[key_name(usr)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]", TRUE)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Big Brother Mode")

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Event"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	if(!check_rights(R_EVENT))
		return

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = tgui_input_list(src, "What size explosion would you like to produce?", "Drop Bomb", choices)
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3, cause = "[ckey]: Drop Bomb command")
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4, cause = "[ckey]: Drop Bomb command")
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5, cause = "[ckey]: Drop Bomb command")
		if("Custom Bomb")
			var/devastation_range = tgui_input_number(src, "Devastation range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(devastation_range))
				return
			var/heavy_impact_range = tgui_input_number(src, "Heavy impact range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(heavy_impact_range))
				return
			var/light_impact_range = tgui_input_number(src, "Light impact range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(light_impact_range))
				return
			var/flash_range = tgui_input_number(src, "Flash range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(flash_range))
				return
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, 1, 1, cause = "[ckey]: Drop Bomb command")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] created an admin explosion at [epicenter.loc]</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in GLOB.mob_list) // -- Urist
	set category = "Event"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	if(!check_rights(R_EVENT))
		return

	var/list/spell_list = list()
	var/type_length = length("/datum/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext("[A]", type_length)] = A
	var/datum/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_list
	if(!S)
		return
	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("[key_name_admin(usr)] gave [key_name(T)] the spell [S].", 1)

/client/proc/give_disease(mob/T in GLOB.mob_list)
	set category = "Event"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	var/datum/disease/given_disease = null

	if(tgui_input_list(usr, "Create own disease", "Would you like to create your own disease?", list("Yes","No")) == "Yes")
		given_disease = AdminCreateVirus(usr)
	else
		given_disease = tgui_input_list(usr, "ACHOO", "Choose the disease to give to that guy", GLOB.diseases)

	if(!given_disease)
		return

	if(!istype(given_disease, /datum/disease/advance))
		given_disease = new given_disease
	T.ForceContractDisease(given_disease)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [given_disease].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] gave [key_name(T)] the disease [given_disease].</span>")

/client/proc/disease_outbreak()
	set category = "Event"
	set name = "Disease Outbreak"
	set desc = "Creates a disease and infects a random player with it"
	var/datum/disease/given_disease = null
	if(tgui_input_list(usr, "Create own disease", "Would you like to create your own disease?", list("Yes","No")) == "Yes")
		given_disease = AdminCreateVirus(usr)
	else
		given_disease = tgui_input_list(usr, "ACHOO", "Choose the disease to give to that guy", GLOB.diseases)
	if(!given_disease)
		return

	if(!istype(given_disease, /datum/disease/advance))
		given_disease = new given_disease

	for(var/thing in shuffle(GLOB.human_list))
		var/mob/living/carbon/human/H = thing
		if(H.stat == DEAD || !is_station_level(H.z))
			continue
		if(!H.HasDisease(given_disease))
			H.ForceContractDisease(given_disease)
			break
	if(istype(given_disease, /datum/disease/advance))
		var/datum/disease/advance/given_advanced_disease = given_disease
		var/list/name_symptoms = list()
		for(var/datum/symptom/S in given_advanced_disease.symptoms)
			name_symptoms += S.name
		message_admins("[key_name_admin(usr)] has triggered a custom virus outbreak of [given_advanced_disease.name]! It has these symptoms: [english_list(name_symptoms)] and these base stats [english_map(given_advanced_disease.base_properties)]")
	else
		message_admins("[key_name_admin(usr)] has triggered a custom virus outbreak of [given_disease.name]!")

/client/proc/make_sound(obj/O in view()) // -- TLE
	set name = "\[Admin\] Make Sound"
	set desc = "Display a message to everyone who can hear the target"

	if(!check_rights(R_EVENT))
		return

	if(O)
		var/message = clean_input("What do you want the message to be?", "Make Sound")
		if(!message)
			return
		for(var/mob/V in hearers(O))
			V.show_message(admin_pencode_to_html(message), 2)
		log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z] make a sound")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z] make a sound</span>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Event"

	if(!check_rights(R_EVENT))
		return

	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/object_talk(msg as text) // -- TLE
	set name = "oSay"
	set desc = "Display a message to everyone who can hear the target"

	if(!check_rights(R_EVENT))
		return

	if(mob.control_object)
		if(!msg)
			return
		for(var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)
		log_admin("[key_name(usr)] used oSay on [mob.control_object]: [msg]")
		message_admins("[key_name_admin(usr)] used oSay on [mob.control_object]: [msg]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "oSay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/deadmin_self()
	set name = "De-admin self"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	log_admin("[key_name(usr)] deadmined themself.")
	message_admins("[key_name_admin(usr)] deadmined themself.")
	deadmin()
	to_chat(src, "<span class='interface'>You are now a normal player.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "De-admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	if(!usr.client.is_connecting_from_localhost())
		if(tgui_alert(usr, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	// Why would we ever turn this off?
	if(GLOB.configuration.logging.href_logging)
		GLOB.configuration.logging.href_logging = FALSE
		to_chat(src, "<b>Stopped logging hrefs</b>")
	else
		GLOB.configuration.logging.href_logging = TRUE
		to_chat(src, "<b>Started logging hrefs</b>")

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.output_ai_laws()

/client/proc/manage_silicon_laws()
	set name = "Manage Silicon Laws"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/silicon/S = input("Select silicon.", "Manage Silicon Laws") as null|anything in GLOB.silicon_mob_list
	if(!S) return

	var/datum/ui_module/law_manager/L = new(S)
	L.ui_interact(usr)
	log_and_message_admins("has opened [S]'s law manager.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Silicon Laws") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/change_human_appearance_admin(mob/living/carbon/human/H in GLOB.mob_list)
	set name = "\[Admin\] C.M.A. - Admin"
	set desc = "Allows you to change the mob appearance"

	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		if(isbrain(H))
			var/mob/living/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(holder)
		log_and_message_admins("is altering the appearance of [H].")
		H.change_appearance(APPEARANCE_ALL, usr, usr, check_species_whitelist = 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "CMA - Admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/change_human_appearance_self(mob/living/carbon/human/H in GLOB.mob_list)
	set name = "\[Admin\] C.M.A. - Self"
	set desc = "Allows the mob to change its appearance"

	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		if(isbrain(H))
			var/mob/living/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(!H.client)
		to_chat(usr, "Only mobs with clients can alter their own appearance.")
		return

	switch(alert("Do you wish for [H] to be allowed to select non-whitelisted races?","Alter Mob Appearance","Yes","No","Cancel"))
		if("Yes")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, without whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 0)
		if("No")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, with whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "CMA - Self") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/free_slot()
	set name = "Free Job Slot"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/list/jobs = list()
	for(var/datum/job/J in SSjobs.occupations)
		if(J.current_positions >= J.total_positions && J.total_positions != -1)
			jobs += J.title
	if(!length(jobs))
		to_chat(usr, "There are no fully staffed jobs.")
		return
	var/job = input("Please select job slot to free", "Free Job Slot") as null|anything in jobs
	if(job)
		SSjobs.FreeRole(job, force = TRUE)
		log_admin("[key_name(usr)] has freed a job slot for [job].")
		message_admins("[key_name_admin(usr)] has freed a job slot for [job].")

/client/proc/man_up(mob/T as mob in GLOB.player_list)
	set name = "\[Admin\] Man Up"
	set desc = "Tells mob to man up and deal with it."

	if(!check_rights(R_ADMIN))
		return

	to_chat(T, chat_box_notice_thick("<span class='notice'><b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.</span>"))
	SEND_SOUND(T, sound('sound/voice/manup1.ogg'))

	log_admin("[key_name(usr)] told [key_name(T)] to man up and deal with it.")
	message_admins("[key_name_admin(usr)] told [key_name(T)] to man up and deal with it.")

/client/proc/global_man_up()
	set category = "Admin"
	set name = "Man Up Global"
	set desc = "Tells everyone to man up and deal with it."

	if(!check_rights(R_ADMIN))
		return

	if(tgui_alert("Are you sure you want to send the global message?", "Confirm Man Up Global", list("Yes", "No")) != "No")
		var/manned_up_sound = sound('sound/voice/manup1.ogg')
		for(var/sissy in GLOB.player_list)
			to_chat(sissy, chat_box_notice_thick("<span class='notice'><b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.</span>"))
			SEND_SOUND(sissy, manned_up_sound)

		log_admin("[key_name(usr)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(usr)] told everyone to man up and deal with it.")

/client/proc/toggle_advanced_interaction()
	set name = "Toggle Advanced Admin Interaction"
	set category = "Admin"
	set desc = "Allows you to interact with atoms such as buttons and doors, on top of regular machinery interaction."

	if(!check_rights(R_ADMIN))
		return

	advanced_admin_interaction = !advanced_admin_interaction

	log_admin("[key_name(usr)] has [advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")
	message_admins("[key_name_admin(usr)] has [advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")

/client/proc/show_watchlist()
	set name = "Show Watchlist"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	watchlist_show()

/client/proc/cmd_admin_alert_message(mob/about_to_be_banned)
	set name = "Send Alert Message"
	set category = "Admin"

	if(!ismob(about_to_be_banned))
		return

	if(!check_rights(R_ADMIN))
		return

	var/default_text = "An admin is trying to talk to you!\nCheck your chat window and click their name to respond or you may be banned!"
	var/new_text = tgui_input_text(src, "Input your message, or use the default.", "Admin Message - Text Selector", default_text, 500, TRUE)

	if(!new_text)
		return

	if(default_text == new_text)
		show_blurb(about_to_be_banned, 15, new_text, null, "center", "center", COLOR_RED, null, null, 1)
		log_admin("[key_name(src)] sent a default admin alert to [key_name(about_to_be_banned)].")
		message_admins("[key_name(src)] sent a default admin alert to [key_name(about_to_be_banned)].")
		return

	new_text = strip_html(new_text, 500)

	var/message_color = tgui_input_color(src, "Input your message color:", "Admin Message - Color Selector", COLOR_RED)
	if(isnull(message_color))
		return

	show_blurb(about_to_be_banned, 15, new_text, null, "center", "center", message_color, null, null, 1)
	log_admin("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[new_text]\".")
	message_admins("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[new_text]\".")

/client/proc/debugstatpanel()
	set name = "Debug Stat Panel"
	set category = "Debug"

	src.stat_panel.send_message("create_debug")

/client/proc/profile_code()
	set name = "Profile Code"
	set category = "Debug"

	winset(usr, null, "command=.profile")

/client/proc/export_current_character()
	set name = "Export Character DMI/JSON"
	set category = "Admin"

	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.export_dmi_json()

/client/proc/raw_gas_scan()
	set name = "Raw Gas Scan"
	set category = "Debug"
	set desc = "Scans your current tile, including LINDA data not normally displayed."

	if(!check_rights(R_DEBUG | R_VIEWRUNTIMES))
		return

	atmos_scan(mob, get_turf(mob), silent = TRUE, milla_turf_details = TRUE)

/client/proc/teleport_interesting_turf()
	set name = "Interesting Turf"
	set category = "Debug"
	set desc = "Teleports you to a random Interesting Turf from MILLA"

	if(!check_rights(R_DEBUG | R_VIEWRUNTIMES))
		return

	if(!isobserver(mob))
		to_chat(mob, "<span class='warning'>You must be an observer to do this!</span>")
		return

	var/list/interesting_tile = get_random_interesting_tile()
	if(!length(interesting_tile))
		to_chat(mob, "<span class='notice'>There are no interesting turfs. How interesting!</span>")
		return

	var/turf/T = interesting_tile[MILLA_INDEX_TURF]
	var/mob/dead/observer/O = mob
	admin_forcemove(O, T)
	O.manual_follow(T)

/client/proc/visualize_interesting_turfs()
	set name = "Visualize Interesting Turfs"
	set category = "Debug"
	set desc = "Shows all the Interesting Turfs from MILLA"

	if(!check_rights(R_DEBUG | R_VIEWRUNTIMES))
		return

	if(SSair.interesting_tile_count > 500)
		// This can potentially iterate through a list thats 20k things long. Give ample warning to the user
		if(tgui_alert(usr, "WARNING: There are [SSair.interesting_tile_count] Interesting Turfs. This process will be lag intensive and should only be used if the atmos controller \
			is screaming bloody murder. Are you sure you with to continue", "WARNING", list("I am sure", "Nope")) != "I am sure")
			return
	else
		if(tgui_alert(usr, "Visualizing turfs may cause server to lag. Are you sure?", "Warning", list("Yes", "No")) != "Yes")
			return

	var/display_turfs_overlay = FALSE
	if(tgui_alert(usr, "Would you like to have all interesting turfs have a client side overlay applied as well?", "Optional", list("Yes", "No")) != "No")
		display_turfs_overlay = TRUE

	message_admins("[key_name_admin(usr)] is visualizing interesting atmos turfs. Server may lag.")

	var/list/zlevel_turf_indexes = list()

	var/list/coords = get_interesting_atmos_tiles()
	if(!length(coords))
		to_chat(mob, "<span class='notice'>There are no interesting turfs. How interesting!</span>")
		return

	while(length(coords))
		var/offset = length(coords) - MILLA_INTERESTING_TILE_SIZE
		var/turf/T = coords[offset + MILLA_INDEX_TURF]
		coords.len -= MILLA_INTERESTING_TILE_SIZE


		// ENSURE YOU USE STRING NUMBERS HERE, THIS IS A DICTIONARY KEY NOT AN INDEX!!!
		if(!zlevel_turf_indexes["[T.z]"])
			zlevel_turf_indexes["[T.z]"] = list()
		zlevel_turf_indexes["[T.z]"] |= T
		if(display_turfs_overlay)
			usr.client.images += image('icons/effects/alphacolors.dmi', T, "red")
		CHECK_TICK

	// Sort the keys
	zlevel_turf_indexes = sortAssoc(zlevel_turf_indexes)

	for(var/key in zlevel_turf_indexes)
		to_chat(usr, "<span class='notice'>Z[key]: <b>[length(zlevel_turf_indexes["[key]"])] Interesting Turfs</b></span>")

	var/z_to_view = tgui_input_number(usr, "A list of z-levels their ITs has appeared in chat. Please enter a Z to visualize. Enter 0 or close the window to cancel", "Selection", 0)

	if(!z_to_view)
		return

	// Do not combine these
	var/list/ui_dat = list()
	var/list/turf_markers = list()

	var/datum/browser/vis = new(usr, "atvis", "Interesting Turfs (Z[z_to_view])", 300, 315)
	ui_dat += "<center><canvas width=\"255px\" height=\"255px\" id=\"atmos\"></canvas></center>"
	ui_dat += "<script>e=document.getElementById(\"atmos\");c=e.getContext('2d');c.fillStyle='#ffffff';c.fillRect(0,0,255,255);function s(x,y){var p=c.createImageData(1,1);p.data\[0]=255;p.data\[1]=0;p.data\[2]=0;p.data\[3]=255;c.putImageData(p,(x-1),255-Math.abs(y-1));}</script>"
	// Now generate the other list
	for(var/x in zlevel_turf_indexes["[z_to_view]"])
		var/turf/T = x
		turf_markers += "s([T.x],[T.y]);"
		CHECK_TICK

	ui_dat += "<script>[turf_markers.Join("")]</script>"

	vis.set_content(ui_dat.Join(""))
	vis.open(FALSE)


/client/proc/create_rnd_restore_disk()
	set name = "Create RnD Backup Restore Disk"
	set category = "Event" // Im putting this in event because the name is long and will offset everything

	if(!check_rights(R_ADMIN))
		return

	var/list/targets = list()

	for(var/rnc_uid in SSresearch.backups)
		var/datum/rnd_backup/B = SSresearch.backups[rnc_uid]

		targets["[B.last_name] - [B.last_timestamp]"] = rnc_uid

	var/choice = input(src, "Select a backup to restore", "RnD Backup Restore") as null|anything in targets
	if(!choice || !(choice in targets))
		return

	var/actual_target = targets[choice]
	if(!(actual_target in SSresearch.backups))
		return

	var/datum/rnd_backup/B = SSresearch.backups[actual_target]
	if(tgui_alert("Are you sure you want to restore this RnD backup? The disk will spawn below your character.", "Are you sure?", list("Yes", "No")) != "Yes")
		return

	B.to_backup_disk(get_turf(usr))

/proc/ghost_follow_uid(mob/user, uid)
	var/client/client = user.client
	if(!isobserver(user))
		if(!check_rights(R_ADMIN|R_MOD)) // Need to be mod or admin to aghost
			return
		user.client.admin_ghost()
	var/datum/target = locateUID(uid)
	if(QDELETED(target))
		to_chat(user, "<span class='warning'>This datum has been deleted!</span>")
		return

	if(istype(target, /datum/mind))
		var/datum/mind/mind = target
		if(!ismob(mind.current))
			to_chat(user, "<span class='warning'>This can only be used on instances of type /mob</span>")
			return
		target = mind.current

	var/mob/dead/observer/A = client.mob
	A.manual_follow(target)
