/client/proc/add_user_verbs()
	SSuser_verbs.associate(src)
	if(check_rights_client(R_ADMIN|R_DEBUG|R_VIEWRUNTIMES, FALSE, src))
		// This setting exposes the profiler & client side tools
		spawn(1)
			control_freak = 0

/client/proc/remove_user_verbs()
	SSuser_verbs.deassociate(src)

USER_VERB(hide_verbs, R_NONE, "Adminverbs - Hide All", "Hide most of your admin verbs.", VERB_CATEGORY_ADMIN)
	client.remove_user_verbs()
	add_verb(client, /client/proc/show_verbs)
//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
GLOBAL_LIST_INIT(admin_verbs_default, list(
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/cmd_mentor_check_new_players,
	/client/proc/cmd_mentor_check_player_exp /* shows players by playtime */
	))
GLOBAL_LIST_INIT(admin_verbs_admin, list(
	/client/proc/check_antagonists,		/*shows all antags*/
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
	/datum/admins/proc/PlayerNotes,
	/client/proc/cmd_mentor_say,
	/datum/admins/proc/show_player_notes,
	/client/proc/free_slot,			/*frees slot for chosen job*/
	/client/proc/update_mob_sprite,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/library_manager,
	/client/proc/view_asays,
	/client/proc/view_msays,
	/client/proc/view_devsays,
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
	/client/proc/create_rnd_restore_disk
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
	/client/proc/stop_global_admin_sounds
	))
GLOBAL_LIST_INIT(admin_verbs_event, list(
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/one_click_antag,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/economy_manager,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/toggle_random_events,
	/client/proc/toggle_ert_calling,
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
	/datum/admins/proc/station_traits_panel
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
	/client/proc/Set_Holiday,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/client/proc/toggle_log_hrefs,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_sing,
	/client/proc/library_manager,
	/client/proc/view_asays,
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
	/client/proc/cmd_admin_delete,
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
	/client/proc/powernet_debugger,
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
	/client/proc/debug_bloom
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
	// cmd_mentor_say is added/removed by the toggle_mentor_chat verb
))
GLOBAL_LIST_INIT(admin_verbs_proccall, list(
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query
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
	/client/proc/allow_browser_inspect, // XSS prevention
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
	/client/proc/profile_code
))

/client/proc/add_admin_verbs()
	if(holder)
		// If they have ANYTHING OTHER THAN ONLY VIEW RUNTIMES (65536), then give them the default admin verbs
		if(holder.rights != R_VIEWRUNTIMES)
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
		GLOB.admin_verbs_maintainer
	))
	add_verb(src, /client/proc/show_verbs)

	to_chat(client, SPAN_INTERFACE("Almost all of your adminverbs have been hidden."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = VERB_CATEGORY_ADMIN

	remove_verb(src, /client/proc/show_verbs)
	add_user_verbs()

	to_chat(src, SPAN_INTERFACE("All of your adminverbs are now visible."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_drop_everything(mob/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Drop Everything"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.drop_item_to_ground(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(imprison, R_ADMIN, "Prison", "Send a mob to prison.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	if(ismob(M))
		if(is_ai(M))
			alert(client, "The AI can't be sent to prison you jerk!", null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.drop_item_to_ground(W)
		//teleport person to cell
		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)	//so they black out before warping
		M.loc = pick(GLOB.prisonwarp)
		if(ishuman(M))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), ITEM_SLOT_JUMPSUIT)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), ITEM_SLOT_SHOES)
		spawn(50)
			to_chat(M, SPAN_WARNING("You have been sent to the prison station!"))
		log_admin("[key_name(client)] sent [key_name(M)] to the prison station.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] sent [key_name_admin(M)] to the prison station."), 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Prison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mentor_ghost()
	var/is_mentor = check_rights(R_MENTOR, FALSE)
	var/is_full_admin = check_rights(R_ADMIN|R_MOD, FALSE)

	if(!is_mentor && !is_full_admin)
		to_chat(src, SPAN_WARNING("You aren't allowed to use this!"))
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

USER_VERB(admin_ghost, R_ADMIN|R_MOD, "Aghost", "Aghost self.", VERB_CATEGORY_ADMIN)
	client.do_aghost()

/// Allow an admin to observe someone.
/// mentors are allowed to use this verb while living, but with some stipulations:
/// if they attempt to do anything that would stop their orbit, they will immediately be returned to their body.
USER_VERB(admin_observe, R_ADMIN|R_MOD|R_MENTOR, "Aobserve", "Admin-observe a player mob.", VERB_CATEGORY_ADMIN)
	if(isnewplayer(client.mob))
		to_chat(client, SPAN_WARNING("You cannot aobserve while in the lobby. Please join or observe first."))
		return

	var/mob/target

	target = tgui_input_list(client, "Select a mob to observe", "Aobserve", GLOB.player_list)
	if(isnull(target))
		return
	if(target == client)
		to_chat(client, SPAN_WARNING("You can't observe yourself!"))
		return

	if(isobserver(target))
		to_chat(client, SPAN_WARNING("[target] is a ghost, and cannot be observed."))
		return

	if(isnewplayer(target))
		to_chat(client, SPAN_WARNING("[target] is in the lobby, and cannot be observed."))
		return

	SSuser_verbs.invoke_verb(client, /datum/user_verb/admin_observe_target, target)

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
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Aobserve") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return TRUE

USER_CONTEXT_MENU(admin_observe_target, R_ADMIN|R_MOD|R_MENTOR, "\[Admin\] Aobserve", mob/target as mob)
	if(isnewplayer(client.mob))
		to_chat(client, SPAN_WARNING("You cannot aobserve while in the lobby. Please join or observe first."))
		return

	if(isnewplayer(target))
		to_chat(client, SPAN_WARNING("[target] is currently in the lobby."))
		return

	if(isobserver(target))
		to_chat(client, SPAN_WARNING("You can't observe a ghost."))
		return

	var/mob/dead/observer/observer = client.mob
	if(istype(observer) && target == locateUID(observer.mob_observed))
		client.cleanup_admin_observe(client.mob)
		return
	client.cleanup_admin_observe(client.mob)

	if(isnull(target) || target == client.mob)
		// let the default one find the target if there isn't one
		SSuser_verbs.invoke_verb(client, /datum/user_verb/admin_observe)
		return

	// observers don't need to ghost, so we don't need to worry about adding any traits
	if(isobserver(client.mob))
		var/mob/dead/observer/ghost = client.mob
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aobserve") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		ghost.do_observe(target)
		return

	log_admin("[key_name(client)] has Aobserved out of their body to follow [target]")
	client.do_aghost()
	var/mob/dead/observer/ghost = client.mob

	var/full_admin = check_rights_client(R_ADMIN|R_MOD, FALSE, client)
	if(!full_admin)
		// if they're a me and they're alive, add the MENTOR_OBSERVINGtrait to ensure that they can only go back to their body.
		// we need to handle this here because when you aghost, your mob gets set to the ghost. Oops!
		ADD_TRAIT(client.mob.mind, TRAIT_MENTOR_OBSERVING, MENTOR_OBSERVING)
		RegisterSignal(ghost, COMSIG_ATOM_ORBITER_STOP, TYPE_PROC_REF(/client, on_mentor_observe_end), override = TRUE)
		to_chat(client, SPAN_NOTICE("You have temporarily observed [target], either move or observe again to un-observe."))
		log_admin("[key_name(client)] has mobserved out of their body to follow [target].")
	else
		log_admin("[key_name(client)] is aobserving [target].")

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
		to_chat(src, SPAN_USERDANGER("Unable to return you to your body after mentor ghosting. If your body still exists, please contact a coder, and you should probably ahelp."))

USER_VERB(invisimin, R_ADMIN, "Invisimin", "Toggles ghost-like invisibility (Don't abuse this)", VERB_CATEGORY_ADMIN)
	if(!isliving(client.mob))
		return

	var/mob/living/client_mob = client.mob
	if(client_mob.invisibility == INVISIBILITY_OBSERVER)
		client_mob.invisibility = initial(client_mob.invisibility)
		client_mob.add_to_all_human_data_huds()
		to_chat(client, SPAN_DANGER("Invisimin off. Invisibility reset."))
		log_admin("[key_name(client)] has turned Invisimin OFF")
	else
		client_mob.invisibility = INVISIBILITY_OBSERVER
		client_mob.remove_from_all_data_huds()
		to_chat(client, SPAN_NOTICE("Invisimin on. You are now as invisible as a ghost."))
		log_admin("[key_name(client)] has turned Invisimin ON")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Invisimin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(player_panel, R_ADMIN|R_MOD, "Player Panel", "Opens the player panel.", VERB_CATEGORY_ADMIN)
	client.holder.player_panel_new()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(check_antagonists, R_ADMIN, "Check Antagonists", "Open the Antagonists panel.", VERB_CATEGORY_ADMIN)
	client.holder.check_antagonists()
	log_admin("[key_name(client)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(check_antagonists_tgui, R_ADMIN, "TGUI - Antagonists", "Open the TGUI Antagonists panel.", VERB_CATEGORY_ADMIN)
	var/datum/ui_module/admin = get_admin_ui_module(/datum/ui_module/admin/antagonist_menu)
	admin.ui_interact(client.mob)
	log_admin("[key_name(client)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(ban_panel, R_BAN, "Ban Panel", "Opens the ban panel.", VERB_CATEGORY_ADMIN)
	client.holder.DB_ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ban Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(game_panel, R_ADMIN, "Game Panel", "Opens the game panel.", VERB_CATEGORY_ADMIN)
	client.holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(secrets_panel, R_ADMIN, "Secrets", "Opens the secrets panel.", VERB_CATEGORY_ADMIN)
	client.holder.Secrets()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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

USER_VERB(stealth_mode, R_ADMIN, "Stealth Mode", "Enables stealth mode.", VERB_CATEGORY_ADMIN)
	var/datum/admins/holder = client.holder
	if(istype(holder))
		holder.big_brother = 0
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name.", "Fake Key", client.key, user = client))
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			client.createStealthKey()
		log_admin("[key_name(client)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(client)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(big_brother, R_PERMISSIONS, "Big Brother Mode", "Enables Big Brother mode.", VERB_CATEGORY_ADMIN)
	var/datum/admins/holder = client.holder
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			holder.big_brother = 0
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name. Unlike normal stealth mode, this will not appear in Who at all, except for other heads.", "Fake Key", client.key, user = client))
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			holder.big_brother = 1
			if(isobserver(client.mob))
				client.mob.invisibility = 90
				client.mob.see_invisible = 90
			client.createStealthKey()
		log_admin("[key_name(client)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]", TRUE)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Big Brother Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(deadmin_self, R_ADMIN|R_MENTOR, "De-admin self", "De-admin yourself.", VERB_CATEGORY_ADMIN)
	log_admin("[key_name(client)] deadmined themself.")
	message_admins("[key_name_admin(client)] deadmined themself.")
	client.deadmin()
	to_chat(client, SPAN_INTERFACE("You are now a normal player."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "De-admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(check_ai_laws, R_ADMIN, "Check AI Laws", "Output AI laws.", VERB_CATEGORY_ADMIN)
	client.holder.output_ai_laws()

USER_VERB(open_law_manager, R_ADMIN, "Manage Silicon Laws", "Open the law manager.", VERB_CATEGORY_ADMIN)
	var/mob/living/silicon/S = input(client, "Select silicon.", "Manage Silicon Laws") as null|anything in GLOB.silicon_mob_list
	if(!S) return

	var/datum/ui_module/law_manager/L = new(S)
	L.ui_interact(client.mob)
	log_and_message_admins("has opened [S]'s law manager.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Silicon Laws") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(free_job_slot, R_ADMIN, "Free Job Slot", "Frees a station job role.", VERB_CATEGORY_ADMIN)
	var/list/jobs = list()
	for(var/datum/job/J in SSjobs.occupations)
		if(J.current_positions >= J.total_positions && J.total_positions != -1)
			jobs += J.title
	if(!length(jobs))
		to_chat(client, "There are no fully staffed jobs.")
		return
	var/job = input(client, "Please select job slot to free", "Free Job Slot") as null|anything in jobs
	if(job)
		SSjobs.FreeRole(job, force = TRUE)
		log_admin("[key_name(client)] has freed a job slot for [job].")
		message_admins("[key_name_admin(client)] has freed a job slot for [job].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Free Job Slot") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(man_up, R_ADMIN, "\[Admin\] Man Up", mob/T as mob in GLOB.player_list)
	to_chat(T, chat_box_notice_thick(SPAN_NOTICE("<b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.")))
	SEND_SOUND(T, sound('sound/voice/manup1.ogg'))

	log_admin("[key_name(client)] told [key_name(T)] to man up and deal with it.")
	message_admins("[key_name_admin(client)] told [key_name(T)] to man up and deal with it.")

USER_VERB(global_man_up, R_ADMIN, "Man Up Global", "Tells everyone to man up and deal with it.", VERB_CATEGORY_ADMIN)
	if(tgui_alert(client, "Are you sure you want to send the global message?", "Confirm Man Up Global", list("Yes", "No")) == "Yes")
		var/manned_up_sound = sound('sound/voice/manup1.ogg')
		for(var/sissy in GLOB.player_list)
			to_chat(sissy, chat_box_notice_thick(SPAN_NOTICE("<b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.")))
			SEND_SOUND(sissy, manned_up_sound)

		log_admin("[key_name(client)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(client)] told everyone to man up and deal with it.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Man Up Global") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_advanced_interaction, R_ADMIN, "Toggle Advanced Admin Interaction", \
		"Allows you to interact with atoms such as buttons and doors, on top of regular machinery interaction.", VERB_CATEGORY_ADMIN)
	client.advanced_admin_interaction = !client.advanced_admin_interaction

	log_admin("[key_name(client)] has [client.advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")
	message_admins("[key_name_admin(client)] has [client.advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")

USER_VERB(show_watchlist, R_ADMIN, "Show Watchlist", "Show the watchlist.", VERB_CATEGORY_ADMIN)
	client.watchlist_show()

USER_VERB(send_alert_message, R_ADMIN, "Send Alert Message", "Sends a large notice to a player.", VERB_CATEGORY_ADMIN, mob/about_to_be_banned)
	if(!ismob(about_to_be_banned))
		return

	var/default_text = "An admin is trying to talk to you!\nCheck your chat window and click their name to respond or you may be banned!"
	var/new_text = tgui_input_text(client, "Input your message, or use the default.", "Admin Message - Text Selector", default_text, 500, TRUE)

	if(!new_text)
		return

	if(default_text == new_text)
		show_blurb(about_to_be_banned, 15, new_text, null, "center", "center", COLOR_RED, null, null, 1)
		log_admin("[key_name(client)] sent a default admin alert to [key_name(about_to_be_banned)].")
		message_admins("[key_name(client)] sent a default admin alert to [key_name(about_to_be_banned)].")
		return

	new_text = strip_html(new_text, 500)

	var/message_color = tgui_input_color(client, "Input your message color:", "Admin Message - Color Selector", COLOR_RED)
	if(isnull(message_color))
		return

	show_blurb(about_to_be_banned, 15, new_text, null, "center", "center", message_color, null, null, 1)
	log_admin("[key_name(client)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[new_text]\".")
	message_admins("[key_name(client)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[new_text]\".")

USER_VERB(export_character, R_ADMIN, "Export Character DMI/JSON", "Saves character DMI and JSON to data directory.", VERB_CATEGORY_ADMIN)
	if(ishuman(client.mob))
		var/mob/living/carbon/human/H = client.mob
		H.export_dmi_json()

USER_VERB(create_rnd_restore_disk, R_ADMIN, "Create RnD Backup Restore Disk", "Create RnD Backup Restore Disk", VERB_CATEGORY_EVENT)
	var/list/targets = list()

	for(var/rnc_uid in SSresearch.backups)
		var/datum/rnd_backup/B = SSresearch.backups[rnc_uid]

		targets["[B.last_name] - [B.last_timestamp]"] = rnc_uid

	var/choice = input(client, "Select a backup to restore", "RnD Backup Restore") as null|anything in targets
	if(!choice || !(choice in targets))
		return

	var/actual_target = targets[choice]
	if(!(actual_target in SSresearch.backups))
		return

	var/datum/rnd_backup/B = SSresearch.backups[actual_target]
	if(tgui_alert(client, "Are you sure you want to restore this RnD backup? The disk will spawn below your character.", "Are you sure?", list("Yes", "No")) != "Yes")
		return

	B.to_backup_disk(get_turf(client.mob))

/proc/ghost_follow_uid(mob/user, uid)
	var/client/client = user.client
	if(!isobserver(user))
		SSuser_verbs.invoke_verb(user, /datum/user_verb/admin_ghost)
	var/datum/target = locateUID(uid)
	if(QDELETED(target))
		to_chat(user, SPAN_WARNING("This datum has been deleted!"))
		return

	if(istype(target, /datum/mind))
		var/datum/mind/mind = target
		if(!ismob(mind.current))
			to_chat(user, SPAN_WARNING("This can only be used on instances of type /mob"))
			return
		target = mind.current

	var/mob/dead/observer/A = client.mob
	A.manual_follow(target)

USER_VERB(check_new_players, R_MENTOR|R_MOD|R_ADMIN, "Check New Players", "Perform a player account age check.", VERB_CATEGORY_ADMIN)
	var/age = input(client, "Show accounts younger then ____ days", "Age check") as num|null
	var/playtime_hours = input(client, "Show accounts with less than ____ hours", "Playtime check") as num|null
	if(isnull(age))
		age = -1
	if(isnull(playtime_hours))
		playtime_hours = -1
	if(age <= 0 && playtime_hours <= 0)
		return

	var/missing_ages = 0
	var/msg = ""
	var/is_admin = check_rights(R_ADMIN, 0)
	for(var/client/C in GLOB.clients)
		if(C?.holder?.fakekey && !check_rights(R_ADMIN, FALSE))
			continue // Skip those in stealth mode if an admin isnt viewing the panel

		if(!isnum(C.player_age))
			missing_ages = 1
			continue
		if(C.player_age < age)
			if(is_admin)
				msg += "[key_name_admin(C.mob)]: [C.player_age] days old<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [C.player_age] days old<br>"

		var/client_hours = C.get_exp_type_num(EXP_TYPE_LIVING) + C.get_exp_type_num(EXP_TYPE_GHOST)
		client_hours /= 60 // minutes to hours
		if(client_hours < playtime_hours)
			if(is_admin)
				msg += "[key_name_admin(C.mob)]: [client_hours] living + ghost hours<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [client_hours] living + ghost hours<br>"

	if(missing_ages)
		to_chat(client, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		client << browse(msg, "window=Player_age_check")
	else
		to_chat(client, "No matches for that age range found.")

USER_VERB_VISIBILITY(show_traitor_panel, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(show_traitor_panel, R_ADMIN|R_MOD, "Show Traitor Panel", "Edit mob's memory and role", VERB_CATEGORY_ADMIN, mob/M in GLOB.mob_list)
	if(!istype(M))
		to_chat(client, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(client, "This mob has no mind!")
		return

	M.mind.edit_memory()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(player_notes, R_ADMIN|R_MOD, "Player Notes", "Open Player Notes panel.", VERB_CATEGORY_ADMIN)
	show_note()

USER_VERB(player_notes_target, R_ADMIN|R_MOD, "Show Player Notes", "Show Player Notes panel for a given ckey.", VERB_CATEGORY_ADMIN, key as text)
	show_note(key)

USER_VERB(vpn_whitelist, R_BAN, "VPN Ckey Whitelist", "Modify ckey's presence on VPN whitelist", VERB_CATEGORY_ADMIN)
	var/key = stripped_input(client, "Enter ckey to add/remove, or leave blank to cancel:", "VPN Whitelist add/remove", max_length=32)
	if(key)
		GLOB.ipintel_manager.vpn_whitelist_panel(key)

USER_VERB(godmode, R_ADMIN, "Godmode", "Toggles godmode on a mob.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	M.status_flags ^= GODMODE
	to_chat(client, SPAN_NOTICE("Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]"))

	log_admin("[key_name(client)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(client)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Godmode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!GLOB.configuration.general.enable_auto_mute)
			return
	else
		if(!usr || !usr.client)
			return
		if(!check_rights(R_ADMIN|R_MOD))
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: You don't have permission to do this.</font>")
			return
		if(!M.client)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: This mob doesn't have a client tied to it.</font>")
	if(!M.client)
		return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
		if(MUTE_EMOTE)
			mute_string = "emote"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	if(automute)
		muteunmute = "auto-muted"
		force_add_mute(M.client.ckey, mute_type)
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Automute") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	toggle_mute(M.client.ckey, mute_type)

	if(check_mute(M.client.ckey, mute_type))
		muteunmute = "muted"
	else
		muteunmute = "unmuted"

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
	to_chat(M, "You have been [muteunmute] from [mute_string].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mute") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(admin_rejuvenate, R_REJUVINATE, "\[Admin\] Rejuvenate", mob/living/M as mob in GLOB.mob_list)
	if(!istype(M))
		alert(client, "Cannot revive a ghost")
		return
	M.revive()

	log_admin("[key_name(client)] healed / revived [key_name(M)]")
	message_admins(SPAN_WARNING("Admin [key_name_admin(client)] healed / revived [key_name_admin(M)]!"), 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvenate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(admin_delete, R_ADMIN, "\[Admin\] Delete", atom/A as obj|mob|turf in view())
	client.admin_delete(A)

/client/proc/admin_delete(datum/D)
	if(istype(D) && !D.can_vv_delete())
		to_chat(src, "[D] rejected your deletion")
		return
	var/atom/A = D
	var/coords = istype(A) ? "at ([A.x], [A.y], [A.z])" : ""
	if(alert(src, "Are you sure you want to delete:\n[D]\n[coords]?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [D] [coords]")
		message_admins("[key_name_admin(usr)] deleted [D] [coords]", 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(isturf(D))
			var/turf/T = D
			T.ChangeTurf(T.baseturf)
		else
			qdel(D)

USER_VERB(list_open_jobs, R_ADMIN, "List free slots", "List available station jobs.", VERB_CATEGORY_ADMIN)
	if(SSjobs)
		var/currentpositiontally
		var/totalpositiontally
		to_chat(client, SPAN_NOTICE("Job Name: Filled job slot / Total job slots <b>(Free job slots)</b>"))
		for(var/datum/job/job in SSjobs.occupations)
			to_chat(client, "<span class='notice'>[job.title]: [job.current_positions] / \
			[job.total_positions == -1 ? "<b>UNLIMITED</b>" : job.total_positions] \
			<b>([job.total_positions == -1 ? "UNLIMITED" : job.total_positions - job.current_positions])</b></span>")
			if(job.total_positions != -1) // Only count position that isn't unlimited
				currentpositiontally += job.current_positions
				totalpositiontally += job.total_positions
		to_chat(client, "<b>Currently filled job slots (Excluding unlimited): [currentpositiontally] / [totalpositiontally] ([totalpositiontally - currentpositiontally])</b>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Free Slots") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(admin_check_contents, R_ADMIN, "\[Admin\] Check Contents", mob/living/M as mob)
	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(client, "[t]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_view_range, R_ADMIN, "Change View Range", "Change tile view range.", VERB_CATEGORY_ADMIN)
	if(client.view == world.view)
		client.view = input(client, "Select view range:", "View Range", world.view) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		client.view = world.view

	log_admin("[key_name(client)] changed their view range to [client.view].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Change View Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(call_shuttle, R_ADMIN, "Call Shuttle", "Calls the shuttle.", VERB_CATEGORY_ADMIN)
	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return

	var/confirm = alert(client, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	if(alert(client, "Set Shuttle Recallable (Select Yes unless you know what this does)", "Recallable?", "Yes", "No") == "Yes")
		SSshuttle.emergency.canRecall = TRUE
	else
		SSshuttle.emergency.canRecall = FALSE

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		SSshuttle.emergency.request(coefficient = 0.5, redAlert = TRUE)
	else
		SSshuttle.emergency.request()

	log_admin("[key_name(client)] admin-called the emergency shuttle.")
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] admin-called the emergency shuttle."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(cancel_shuttle, R_ADMIN, "Cancel Shuttle", "Cancels the shuttle.", VERB_CATEGORY_ADMIN)
	if(alert(client, "You sure?", "Confirm", "Yes", "No") != "Yes") return

	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return

	if(!SSshuttle.emergency.canRecall)
		if(alert(client, "Shuttle is currently set to be nonrecallable. Recalling may break things. Respect Recall Status?", "Override Recall Status?", "Yes", "No") == "Yes")
			return
		else
			var/keepStatus = alert(client, "Maintain recall status on future shuttle calls?", "Maintain Status?", "Yes", "No") == "Yes" //Keeps or drops recallability
			SSshuttle.emergency.canRecall = TRUE // must be true for cancel proc to work
			SSshuttle.emergency.cancel(byCC = TRUE)
			if(keepStatus)
				SSshuttle.emergency.canRecall = FALSE // restores original status
	else
		SSshuttle.emergency.cancel(byCC = TRUE)

	log_admin("[key_name(client)] admin-recalled the emergency shuttle.")
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] admin-recalled the emergency shuttle."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(deny_shuttle, R_ADMIN, "Toggle Deny Shuttle", "Toggles crew shuttle calling-ability.", VERB_CATEGORY_ADMIN)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "The game hasn't started yet!")
		return

	var/alert = alert(client, "Do you want to ALLOW or DENY shuttle calls?", "Toggle Deny Shuttle", "Allow", "Deny", "Cancel")
	if(alert == "Cancel")
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Deny Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(alert == "Allow")
		if(!length(SSshuttle.hostile_environments))
			to_chat(client, SPAN_NOTICE("No hostile environments found, cleared for takeoff!"))
			return
		if(alert(client, "[english_list(SSshuttle.hostile_environments)] is currently blocking the shuttle call, do you want to clear them?", "Toggle Deny Shuttle", "Yes", "No") == "Yes")
			SSshuttle.hostile_environments.Cut()
			var/log = "[key_name(client)] has cleared all hostile environments, allowing the shuttle to be called."
			log_admin(log)
			message_admins(log)
		return

	SSshuttle.registerHostileEnvironment(client) // wow, a client blocking the shuttle
	log_and_message_admins("has denied the shuttle to be called.")

USER_VERB(open_attack_log, R_ADMIN, "Attack Log", "Prints the attack log.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	to_chat(client, SPAN_DANGER("Attack Log for [M]"))
	for(var/t in M.attack_log_old)
		to_chat(client, t)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Attack Log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(reset_telecoms, R_ADMIN, "Reset NTTC Configuration", "Resets NTTC to the default configuration.", VERB_CATEGORY_ADMIN)
	var/confirm = alert(client, "You sure you want to reset NTTC?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.nttc.reset()

	log_admin("[key_name(client)] reset NTTC scripts.")
	message_admins("[key_name_admin(client)] reset NTTC scripts.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reset NTTC Configuration") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(list_ssds_afks, R_ADMIN, "List SSDs and AFKs", "List SSDs and AFK players", VERB_CATEGORY_ADMIN)
	/* ======== SSD Section ========= */
	var/msg = "<html><meta charset='utf-8'><head><title>SSD & AFK Report</title></head><body>"
	msg += "SSD Players:<br><TABLE border='1'>"
	msg += "<tr><td><b>Key</b></td><td><b>Real Name</b></td><td><b>Job</b></td><td><b>Mins SSD</b></td><td><b>Special Role</b></td><td><b>Area</b></td><td><b>PPN</b></td><td><b>Cryo</b></td></tr>"
	var/mins_ssd
	var/job_string
	var/key_string
	var/role_string
	var/obj_count = 0
	var/obj_string = ""
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(!isLivingSSD(H))
			continue
		mins_ssd = round((world.time - H.last_logout) / 600)
		if(H.job)
			job_string = H.job
		else
			job_string = "-"
		key_string = H.key
		if(job_string in GLOB.command_positions)
			job_string = "<U>" + job_string + "</U>"
		role_string = "-"
		obj_count = 0
		obj_string = ""
		if(H.mind)
			if(H.mind.special_role)
				role_string = "<U>[H.mind.special_role]</U>"
			if(!H.key && H.mind.key)
				key_string = H.mind.key
			for(var/datum/objective/O in GLOB.all_objectives)
				if(O.target == H.mind)
					obj_count++
			if(obj_count > 0)
				obj_string = "<BR><U>Obj Target</U>"
		msg += "<TR><TD>[key_string]</TD><TD>[H.real_name]</TD><TD>[job_string]</TD><TD>[mins_ssd]</TD><TD>[role_string][obj_string]</TD>"
		msg += "<TD>[get_area(H)]</TD><TD>[ADMIN_PP(H,"PP")]</TD>"
		if(istype(H.loc, /obj/machinery/cryopod))
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()]'>De-Spawn</A></TD>"
		else
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()]'>Cryo</A></TD>"
		msg += "</TR>"
	msg += "</TABLE><br></BODY></HTML>"

	/* ======== AFK Section ========= */
	msg += "AFK Players:<BR><TABLE border='1'>"
	msg += "<TR><TD><B>Key</B></TD><TD><B>Real Name</B></TD><TD><B>Job</B></TD><TD><B>Mins AFK</B></TD><TD><B>Special Role</B></TD><TD><B>Area</B></TD><TD><B>PPN</B></TD><TD><B>Cryo</B></TD></TR>"
	var/mins_afk
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.client == null || H.stat == DEAD) // No clientless or dead
			continue
		mins_afk = round(H.client.inactivity / 600)
		if(mins_afk < 5)
			continue
		if(H.job)
			job_string = H.job
		else
			job_string = "-"
		key_string = H.key
		if(job_string in GLOB.command_positions)
			job_string = "<U>" + job_string + "</U>"
		role_string = "-"
		obj_count = 0
		obj_string = ""
		if(H.mind)
			if(H.mind.special_role)
				role_string = "<U>[H.mind.special_role]</U>"
			if(!H.key && H.mind.key)
				key_string = H.mind.key
			for(var/datum/objective/O in GLOB.all_objectives)
				if(O.target == H.mind)
					obj_count++
			if(obj_count > 0)
				obj_string = "<BR><U>Obj Target</U>"
		msg += "<TR><TD>[key_string]</TD><TD>[H.real_name]</TD><TD>[job_string]</TD><TD>[mins_afk]</TD><TD>[role_string][obj_string]</TD>"
		msg += "<TD>[get_area(H)]</TD><TD>[ADMIN_PP(H,"PP")]</TD>"
		if(istype(H.loc, /obj/machinery/cryopod))
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()];cryoafk=1'>De-Spawn</A></TD>"
		else
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()];cryoafk=1'>Cryo</A></TD>"
		msg += "</TR>"
	msg += "</TABLE></BODY></HTML>"
	client << browse(msg, "window=Player_ssd_afk_check;size=600x300")
