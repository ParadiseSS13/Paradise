//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
GLOBAL_LIST_INIT(admin_verbs_default, list(
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/toggleadminhelpsound,
	/client/proc/togglementorhelpsound,
	/client/proc/cmd_mentor_check_new_players,
	/client/proc/cmd_mentor_check_player_exp /* shows players by playtime */
	))
GLOBAL_LIST_INIT(admin_verbs_admin, list(
	/client/proc/check_antagonists,		/*shows all antags*/
	/datum/admins/proc/show_player_panel,
	/client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/client/proc/colorooc,				/*allows us to set a custom colour for everything we say in ooc*/
	/client/proc/resetcolorooc,			/*allows us to set a reset our ooc color*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
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
	/client/proc/toggleprayers,			/*toggles prayers on/off*/
	/client/proc/toggle_hear_radio,     /*toggles whether we hear the radio*/
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
	/client/proc/toggleattacklogs,
	/client/proc/toggleadminlogs,
	/client/proc/toggledebuglogs,
	/client/proc/update_mob_sprite,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/library_manager,
	/client/proc/view_asays,
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
	/client/proc/show_watchlist
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
	/client/proc/change_human_appearance_self	/* Allows the human-based mob itself to change its basic appearance */
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
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
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
	/client/proc/toggledebuglogs,
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
	/client/proc/jump_to_ruin,
	/client/proc/uid_log,
	/client/proc/visualise_active_turfs,
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
	/client/proc/toggle_mctabs,
	/client/proc/debug_global_variables
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
	/client/proc/debug_variables		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
))
GLOBAL_LIST_INIT(admin_verbs_mentor, list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/openMentorTicketUI,
	/client/proc/toggleMentorTicketLogs,
	/client/proc/cmd_mentor_say	/* mentor say*/
	// cmd_mentor_say is added/removed by the toggle_mentor_chat verb
))
GLOBAL_LIST_INIT(admin_verbs_proccall, list(
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query
))
GLOBAL_LIST_INIT(admin_verbs_ticket, list(
	/client/proc/openAdminTicketUI,
	/client/proc/toggleticketlogs,
	/client/proc/openMentorTicketUI,
	/client/proc/toggleMentorTicketLogs,
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
	/client/proc/toggledebuglogs,
	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/ss_breakdown,
	/client/proc/show_gc_queues,
	/client/proc/toggle_mctabs,
	/client/proc/debug_global_variables,
	/client/proc/visualise_active_turfs,
	/client/proc/debug_timers,
	/client/proc/timer_log
))

/client/proc/on_holder_add()
	if(chatOutput && chatOutput.loaded)
		chatOutput.loadAdmin()

/client/proc/add_admin_verbs()
	if(holder)
		// If they have ANYTHING OTHER THAN ONLY VIEW RUNTIMES (65536), then give them the default admin verbs
		if(holder.rights != R_VIEWRUNTIMES)
			verbs += GLOB.admin_verbs_default
		if(holder.rights & R_BUILDMODE)
			verbs += /client/proc/togglebuildmodeself
		if(holder.rights & R_ADMIN)
			verbs += GLOB.admin_verbs_admin
			verbs += GLOB.admin_verbs_ticket
			spawn(1)
				control_freak = 0
		if(holder.rights & R_BAN)
			verbs += GLOB.admin_verbs_ban
		if(holder.rights & R_EVENT)
			verbs += GLOB.admin_verbs_event
		if(holder.rights & R_SERVER)
			verbs += GLOB.admin_verbs_server
		if(holder.rights & R_DEBUG)
			verbs += GLOB.admin_verbs_debug
			spawn(1)
				control_freak = 0 // Setting control_freak to 0 allows you to use the Profiler and other client-side tools
		if(holder.rights & R_POSSESS)
			verbs += GLOB.admin_verbs_possess
		if(holder.rights & R_PERMISSIONS)
			verbs += GLOB.admin_verbs_permissions
		if(holder.rights & R_STEALTH)
			verbs += /client/proc/stealth
		if(holder.rights & R_REJUVINATE)
			verbs += GLOB.admin_verbs_rejuv
		if(holder.rights & R_SOUNDS)
			verbs += GLOB.admin_verbs_sounds
		if(holder.rights & R_SPAWN)
			verbs += GLOB.admin_verbs_spawn
		if(holder.rights & R_MOD)
			verbs += GLOB.admin_verbs_mod
		if(holder.rights & R_MENTOR)
			verbs += GLOB.admin_verbs_mentor
		if(holder.rights & R_PROCCALL)
			verbs += GLOB.admin_verbs_proccall
		if(holder.rights & R_MAINTAINER)
			verbs += GLOB.admin_verbs_maintainer
		if(holder.rights & R_VIEWRUNTIMES)
			verbs += GLOB.view_runtimes_verbs
			spawn(1) // This setting exposes the profiler for people with R_VIEWRUNTIMES. They must still have it set in cfg/admin.txt
				control_freak = 0


/client/proc/remove_admin_verbs()
	verbs.Remove(
		GLOB.admin_verbs_default,
		/client/proc/togglebuildmodeself,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_event,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		/client/proc/stealth,
		GLOB.admin_verbs_rejuv,
		GLOB.admin_verbs_sounds,
		GLOB.admin_verbs_spawn,
		GLOB.admin_verbs_mod,
		GLOB.admin_verbs_mentor,
		GLOB.admin_verbs_proccall,
		GLOB.admin_verbs_show_debug_verbs,
		/client/proc/readmin,
		GLOB.admin_verbs_ticket,
		GLOB.admin_verbs_maintainer,
	)

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	if(!holder)
		return

	remove_admin_verbs()
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	if(!holder)
		return

	verbs -= /client/proc/show_verbs
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		ghost.can_reenter_corpse = 1			//just in-case.
		ghost.reenter_corpse()
		log_admin("[key_name(usr)] re-entered their body")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.regenerate_icons() // workaround for #13269
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or observe first.</font>")
	else
		//ghostize
		var/mob/body = mob
		body.ghostize(1)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		log_admin("[key_name(usr)] has admin-ghosted")
		// TODO: SStgui.on_transfer() to move windows from old and new
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
			createStealthKey()
		log_admin("[key_name(usr)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Big Brother Mode")

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Event"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	if(!check_rights(R_EVENT))
		return

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") as null|anything in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3)
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4)
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as null|num
			if(devastation_range == null)
				return
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as null|num
			if(heavy_impact_range == null)
				return
			var/light_impact_range = input("Light impact range (in tiles):") as null|num
			if(light_impact_range == null)
				return
			var/flash_range = input("Flash range (in tiles):") as null|num
			if(flash_range == null)
				return
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, 1, 1)
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
	var/type_length = length("/obj/effect/proc_holder/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext("[A]", type_length)] = A
	var/obj/effect/proc_holder/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_list
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
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in GLOB.diseases
	if(!D) return
	T.ForceContractDisease(new D)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] gave [key_name(T)] the disease [D].</span>")

/client/proc/make_sound(obj/O in view()) // -- TLE
	set category = "Event"
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
	set category = "Event"
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
	if(check_rights(R_ADMIN, FALSE))
		GLOB.de_admins += ckey
	else
		GLOB.de_mentors += ckey
	deadmin()
	verbs += /client/proc/readmin
	to_chat(src, "<span class='interface'>You are now a normal player.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "De-admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/readmin()
	set name = "Re-admin self"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/D = GLOB.admin_datums[ckey]
	var/rank = null
	if(!GLOB.configuration.admin.use_database_admins)
		for(var/iterator_key in GLOB.configuration.admin.ckey_rank_map)
			var/_ckey = ckey(iterator_key) // Snip out formatting
			if(ckey != _ckey)
				continue
			rank = GLOB.configuration.admin.ckey_rank_map[iterator_key]
			break
	else
		if(!SSdbcore.IsConnected())
			to_chat(src, "Warning, MYSQL database is not connected.")
			return

		var/datum/db_query/rank_read = SSdbcore.NewQuery(
			"SELECT admin_rank FROM admin WHERE ckey=:ckey",
			list("ckey" = ckey)
		)

		if(!rank_read.warn_execute())
			qdel(rank_read)
			return FALSE

		while(rank_read.NextRow())
			rank = ckeyEx(rank_read.item[1])

		qdel(rank_read)
	if(!D)
		D = try_localhost_autoadmin()
		if(!D)
			if(!GLOB.configuration.admin.use_database_admins)
				if(GLOB.admin_ranks[rank] == null)
					error("Error while re-adminning [src], admin rank ([rank]) does not exist.")
					to_chat(src, "Error while re-adminning, admin rank ([rank]) does not exist.")
					return

				// Do a little check here
				if(GLOB.configuration.system.is_production && (GLOB.admin_ranks[rank] & R_ADMIN) && prefs._2fa_status == _2FA_DISABLED) // If they are an admin and their 2FA is disabled
					to_chat(src,"<span class='boldannounce'><big>You do not have 2FA enabled. Admin verbs will be unavailable until you have enabled 2FA.</big></span>") // Very fucking obvious
					return
				D = new(rank, GLOB.admin_ranks[rank], ckey)
			else
				if(!SSdbcore.IsConnected())
					to_chat(src, "Warning, MYSQL database is not connected.")
					return

				var/datum/db_query/admin_read = SSdbcore.NewQuery(
					"SELECT ckey, admin_rank, flags FROM admin WHERE ckey=:ckey",
					list("ckey" = ckey)
				)

				if(!admin_read.warn_execute())
					qdel(admin_read)
					return FALSE

				while(admin_read.NextRow())
					var/admin_ckey = admin_read.item[1]
					var/admin_rank = admin_read.item[2]
					var/flags = admin_read.item[3]
					if(!admin_ckey)
						to_chat(src, "Error while re-adminning, ckey [admin_ckey] was not found in the admin database.")
						qdel(admin_read)
						return
					if(admin_rank == "Removed") //This person was de-adminned. They are only in the admin list for archive purposes.
						to_chat(src, "Error while re-adminning, ckey [admin_ckey] is not an admin.")
						qdel(admin_read)
						return

					if(istext(flags))
						flags = text2num(flags)
					var/client/check_client = GLOB.directory[ckey]
					// Do a little check here
					if(GLOB.configuration.system.is_production && (flags & R_ADMIN) && check_client.prefs._2fa_status == _2FA_DISABLED) // If they are an admin and their 2FA is disabled
						to_chat(src,"<span class='boldannounce'><big>You do not have 2FA enabled. Admin verbs will be unavailable until you have enabled 2FA.</big></span>") // Very fucking obvious
						qdel(admin_read)
						return
					D = new(admin_rank, flags, ckey)
				qdel(admin_read)

		var/client/C = GLOB.directory[ckey]
		D.associate(C)
		message_admins("[key_name_admin(usr)] re-adminned themselves.")
		log_admin("[key_name(usr)] re-adminned themselves.")
		GLOB.de_admins -= ckey
		GLOB.de_mentors -= ckey
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Re-admin")
		return
	else
		to_chat(src, "You are already an admin.")
		verbs -= /client/proc/readmin
		GLOB.de_admins -= ckey
		GLOB.de_mentors -= ckey
		return

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"

	if(!check_rights(R_SERVER))
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
	L.ui_interact(usr, state = GLOB.admin_state)
	log_and_message_admins("has opened [S]'s law manager.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Silicon Laws") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/change_human_appearance_admin(mob/living/carbon/human/H in GLOB.mob_list)
	set name = "\[Admin\] C.M.A. - Admin"
	set desc = "Allows you to change the mob appearance"
	set category = null

	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		if(isbrain(H))
			var/mob/living/carbon/brain/B = H
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
	set category = null

	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		if(isbrain(H))
			var/mob/living/carbon/brain/B = H
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
	if(!jobs.len)
		to_chat(usr, "There are no fully staffed jobs.")
		return
	var/job = input("Please select job slot to free", "Free Job Slot") as null|anything in jobs
	if(job)
		SSjobs.FreeRole(job, force = TRUE)
		log_admin("[key_name(usr)] has freed a job slot for [job].")
		message_admins("[key_name_admin(usr)] has freed a job slot for [job].")

/client/proc/toggleattacklogs()
	set name = "Toggle Attack Log Messages"
	set category = "Preferences"

	if(!check_rights(R_ADMIN))
		return

	if(prefs.atklog == ATKLOG_ALL)
		prefs.atklog = ATKLOG_ALMOSTALL
		to_chat(usr, "Your attack logs preference is now: show ALMOST ALL attack logs (notable exceptions: NPCs attacking other NPCs, vampire bites, equipping/stripping, people pushing each other over)")
	else if(prefs.atklog == ATKLOG_ALMOSTALL)
		prefs.atklog = ATKLOG_MOST
		to_chat(usr, "Your attack logs preference is now: show MOST attack logs (like ALMOST ALL, except that it also hides player v. NPC combat, and certain areas like lavaland syndie base and thunderdome)")
	else if(prefs.atklog == ATKLOG_MOST)
		prefs.atklog = ATKLOG_FEW
		to_chat(usr, "Your attack logs preference is now: show FEW attack logs (only the most important stuff: attacks on SSDs, use of explosives, messing with the engine, gibbing, AI wiping, forcefeeding, acid sprays, and organ extraction)")
	else if(prefs.atklog == ATKLOG_FEW)
		prefs.atklog = ATKLOG_NONE
		to_chat(usr, "Your attack logs preference is now: show NO attack logs")
	else if(prefs.atklog == ATKLOG_NONE)
		prefs.atklog = ATKLOG_ALL
		to_chat(usr, "Your attack logs preference is now: show ALL attack logs")
	else
		prefs.atklog = ATKLOG_ALL
		to_chat(usr, "Your attack logs preference is now: show ALL attack logs (your preference was set to an invalid value, it has been reset)")

	prefs.save_preferences(src)


/client/proc/toggleadminlogs()
	set name = "Toggle Admin Log Messages"
	set category = "Preferences"

	if(!check_rights(R_ADMIN))
		return

	prefs.toggles ^= PREFTOGGLE_CHAT_NO_ADMINLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_CHAT_NO_ADMINLOGS)
		to_chat(usr, "You now won't get admin log messages.")
	else
		to_chat(usr, "You now will get admin log messages.")

/client/proc/toggleMentorTicketLogs()
	set name = "Toggle Mentor Ticket Messages"
	set category = "Preferences"

	if(!check_rights(R_MENTOR|R_ADMIN))
		return

	prefs.toggles ^= PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS)
		to_chat(usr, "You now won't get mentor ticket messages.")
	else
		to_chat(usr, "You now will get mentor ticket messages.")

/client/proc/toggleticketlogs()
	set name = "Toggle Admin Ticket Messgaes"
	set category = "Preferences"

	if(!check_rights(R_ADMIN))
		return

	prefs.toggles ^= PREFTOGGLE_CHAT_NO_TICKETLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)
		to_chat(usr, "You now won't get admin ticket messages.")
	else
		to_chat(usr, "You now will get admin ticket messages.")

/client/proc/toggledebuglogs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	if(!check_rights(R_VIEWRUNTIMES | R_DEBUG))
		return

	prefs.toggles ^= PREFTOGGLE_CHAT_DEBUGLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & PREFTOGGLE_CHAT_DEBUGLOGS)
		to_chat(usr, "You now will get debug log messages")
	else
		to_chat(usr, "You now won't get debug log messages")

/client/proc/man_up(mob/T as mob in GLOB.player_list)
	set category = null
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

	var/confirm = alert("Are you sure you want to send the global message?", "Confirm Man Up Global", "Yes", "No")

	if(confirm == "Yes")
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

	var/alert_type = alert(src, "Do you wish to send an admin alert to [key_name(about_to_be_banned, FALSE)]?",,"Yes", "No", "Custom Message")

	switch(alert_type)
		if("Yes")
			var/message = "An admin is trying to talk to you!\nCheck your chat window and click their name to respond or you may be banned!"
			show_blurb(about_to_be_banned, 15, message, null, "center", "center", COLOR_RED, null, null, 1)
			log_admin("[key_name(src)] sent a default admin alert to [key_name(about_to_be_banned)].")
			message_admins("[key_name(src)] sent a default admin alert to [key_name(about_to_be_banned)].")

		if("Custom Message")
			var/message = input(src, "Input your custom admin alert text:", "Message") as text|null
			if(!message)
				return
			message = strip_html(message, 500)

			var/message_color = input(src, "Input your message color:", "Color Selector") as color|null
			if(!message_color)
				return

			show_blurb(about_to_be_banned, 15, message, null, "center", "center", message_color, null, null, 1)
			log_admin("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message [message].")
			message_admins("[key_name(src)] sent an admin alert to [key_name(about_to_be_banned)] with custom message [message].")
