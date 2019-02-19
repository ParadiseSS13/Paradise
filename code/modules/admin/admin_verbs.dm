//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
var/list/admin_verbs_default = list(
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/toggleadminhelpsound,
	/client/proc/togglementorhelpsound,
	/client/proc/cmd_mentor_check_new_players,
	/client/proc/cmd_mentor_check_player_exp /* shows players by playtime */
	)
var/list/admin_verbs_admin = list(
	/client/proc/check_antagonists,		/*shows all antags*/
	/datum/admins/proc/show_player_panel,
	/client/proc/player_panel,			/*shows an interface for all players, with links to various panels (old style)*/
	/client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/client/proc/colorooc,				/*allows us to set a custom colour for everything we say in ooc*/
	/client/proc/resetcolorooc,			/*allows us to set a reset our ooc color*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/getserverlogs,			/*allows us to fetch server logs (diary) for other days*/
	/client/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
	/client/proc/Jump,
	/client/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcomm*/
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
	/client/proc/toggledrones,
	/client/proc/man_up,
	/client/proc/global_man_up,
	/client/proc/delbook,
	/client/proc/view_flagged_books,
	/client/proc/empty_ai_core_toggle_latejoin,
	/client/proc/aooc,
	/client/proc/freeze,
	/client/proc/freezemecha,
	/client/proc/alt_check,
	/client/proc/secrets,
	/client/proc/change_human_appearance_admin,	/* Allows an admin to change the basic appearance of human-based mobs */
	/client/proc/change_human_appearance_self,	/* Allows the human-based mob itself change its basic appearance */
	/client/proc/debug_variables,
	/client/proc/show_snpc_verbs,
	/client/proc/reset_all_tcs,			/*resets all telecomms scripts*/
	/client/proc/toggle_mentor_chat,
	/client/proc/toggle_advanced_interaction, /*toggle admin ability to interact with not only machines, but also atoms such as buttons and doors*/
	/client/proc/list_ssds,
	/client/proc/cmd_admin_headset_message,
	/client/proc/spawn_floor_cluwne,
	/client/proc/show_discord_duplicates,
)
var/list/admin_verbs_ban = list(
	/client/proc/unban_panel,
	/client/proc/jobbans,
	/client/proc/stickybanpanel
	)
var/list/admin_verbs_sounds = list(
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/play_server_sound,
	/client/proc/play_intercomm_sound,
	/client/proc/stop_global_admin_sounds
	)
var/list/admin_verbs_event = list(
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/cinematic,
	/client/proc/one_click_antag,
	/datum/admins/proc/toggle_aliens,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/toggle_random_events,
	/client/proc/toggle_ert_calling,
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_custom_event_info,
	/client/proc/cmd_view_custom_event_info,
	/datum/admins/proc/access_news_network,	/*allows access of newscasters*/
	/client/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/response_team, // Response Teams admin verb
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/fax_panel,
	/client/proc/event_manager_panel,
	/client/proc/modify_goals
	)

var/list/admin_verbs_spawn = list(
	/datum/admins/proc/spawn_atom,		/*allows us to spawn instances*/
	/client/proc/respawn_character,
	/client/proc/admin_deserialize
	)
var/list/admin_verbs_server = list(
	/client/proc/ToRban,
	/client/proc/Set_Holiday,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/toggle_log_hrefs,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_del_sing,
	/datum/admins/proc/toggle_aliens,
	/client/proc/delbook,
	/client/proc/view_flagged_books,
	/client/proc/toggle_antagHUD_use,
	/client/proc/toggle_antagHUD_restrictions,
	/client/proc/set_ooc,
	/client/proc/reset_ooc
	)
var/list/admin_verbs_debug = list(
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/Debug2,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/debug_controller,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_del_sing,
	/client/proc/reload_admins,
	/client/proc/restart_controller,
	/client/proc/enable_debug_verbs,
	/client/proc/toggledebuglogs,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_del_log_simple,
	/client/proc/debugNatureMapGenerator,
	/client/proc/check_bomb_impacts,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/client/proc/cinematic,
	/proc/machine_upgrade,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/view_runtimes,
	/client/proc/admin_serialize,
	/client/proc/jump_to_ruin,
	/client/proc/toggle_medal_disable,
	)
var/list/admin_verbs_possess = list(
	/proc/possess,
	/proc/release
	)
var/list/admin_verbs_permissions = list(
	/client/proc/edit_admin_permissions,
	/client/proc/create_poll,
	/client/proc/big_brother
	)
var/list/admin_verbs_rejuv = list(
	/client/proc/respawn_character,
	/client/proc/cmd_admin_rejuvenate
	)
var/list/admin_verbs_mod = list(
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
	/client/proc/jobbans,
	/client/proc/debug_variables		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
)
var/list/admin_verbs_mentor = list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_pm_by_key_panel,	/*admin-pm list by key*/
	/client/proc/cmd_mentor_say	/* mentor say*/
	// cmd_mentor_say is added/removed by the toggle_mentor_chat verb
)
var/list/admin_verbs_proccall = list(
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query
)
var/list/admin_verbs_snpc = list(
	/client/proc/resetSNPC,
	/client/proc/customiseSNPC,
	/client/proc/hide_snpc_verbs
)
var/list/admin_verbs_ticket = list(
	/client/proc/openTicketUI,
	/client/proc/toggleticketlogs,
	/client/proc/resolveAllTickets,
	/client/proc/openUserUI
)

/client/proc/on_holder_add()
	if(chatOutput && chatOutput.loaded)
		chatOutput.loadAdmin()

/client/proc/add_admin_verbs()
	if(holder)
		verbs += admin_verbs_default
		if(holder.rights & R_BUILDMODE)
			verbs += /client/proc/togglebuildmodeself
		if(holder.rights & R_ADMIN)
			verbs += admin_verbs_admin
			verbs += admin_verbs_ticket
			spawn(1)
				control_freak = 0
		if(holder.rights & R_BAN)
			verbs += admin_verbs_ban
		if(holder.rights & R_EVENT)
			verbs += admin_verbs_event
		if(holder.rights & R_SERVER)
			verbs += admin_verbs_server
		if(holder.rights & R_DEBUG)
			verbs += admin_verbs_debug
		if(holder.rights & R_POSSESS)
			verbs += admin_verbs_possess
		if(holder.rights & R_PERMISSIONS)
			verbs += admin_verbs_permissions
		if(holder.rights & R_STEALTH)
			verbs += /client/proc/stealth
		if(holder.rights & R_REJUVINATE)
			verbs += admin_verbs_rejuv
		if(holder.rights & R_SOUNDS)
			verbs += admin_verbs_sounds
		if(holder.rights & R_SPAWN)
			verbs += admin_verbs_spawn
		if(holder.rights & R_MOD)
			verbs += admin_verbs_mod
		if(holder.rights & R_MENTOR)
			verbs += admin_verbs_mentor
		if(holder.rights & R_PROCCALL)
			verbs += admin_verbs_proccall

/client/proc/remove_admin_verbs()
	verbs.Remove(
		admin_verbs_default,
		/client/proc/togglebuildmodeself,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_event,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_possess,
		admin_verbs_permissions,
		/client/proc/stealth,
		admin_verbs_rejuv,
		admin_verbs_sounds,
		admin_verbs_spawn,
		admin_verbs_mod,
		admin_verbs_mentor,
		admin_verbs_proccall,
		admin_verbs_show_debug_verbs,
		/client/proc/readmin,
		admin_verbs_snpc,
		/client/proc/hide_snpc_verbs,
		admin_verbs_ticket
	)

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	if(!holder)
		return

	remove_admin_verbs()
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	if(!holder)
		return

	verbs -= /client/proc/show_verbs
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(istype(mob,/mob/dead/observer))
		//re-enter
		var/mob/dead/observer/ghost = mob
		ghost.can_reenter_corpse = 1			//just in-case.
		ghost.reenter_corpse()
		log_admin("[key_name(usr)] re-entered their body")
		feedback_add_details("admin_verb","P") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else if(istype(mob,/mob/new_player))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or observe first.</font>")
	else
		//ghostize
		var/mob/body = mob
		body.ghostize(1)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		log_admin("[key_name(usr)] has admin-ghosted")
		feedback_add_details("admin_verb","O") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"

	if(!check_rights(R_ADMIN))
		return

	if(mob)
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, "<span class='danger'>Invisimin off. Invisibility reset.</span>")
			mob.add_to_all_human_data_huds()
			//TODO: Make some kind of indication for the badmin that they are currently invisible
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			to_chat(mob, "<span class='notice'>Invisimin on. You are now as invisible as a ghost.</span>")
			mob.remove_from_all_data_huds()

/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.player_panel_old()
	feedback_add_details("admin_verb","PP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/player_panel_new()
	set name = "Player Panel New"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	holder.player_panel_new()
	feedback_add_details("admin_verb","PPN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.check_antagonists()
	log_admin("[key_name(usr)] checked antagonists")
	feedback_add_details("admin_verb","CHA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jobbans()
	set name = "Display Job bans"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(config.ban_legacy_system)
		holder.Jobbans()
	else
		holder.DB_ban_panel()
	feedback_add_details("admin_verb","VJB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"

	if(!check_rights(R_BAN))
		return

	if(config.ban_legacy_system)
		holder.unbanpanel()
	else
		holder.DB_ban_panel()
	feedback_add_details("admin_verb","UBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.Game()
	feedback_add_details("admin_verb","GP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.Secrets()
	feedback_add_details("admin_verb","S") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt

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
			var/new_key = ckeyEx(input("Enter your desired display name.", "Fake Key", key) as text|null)
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			createStealthKey()
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]", 1)
	feedback_add_details("admin_verb","SM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
			var/new_key = ckeyEx(input("Enter your desired display name. Unlike normal stealth mode, this will not appear in Who at all, except for other heads.", "Fake Key", key) as text|null)
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			holder.big_brother = 1
			createStealthKey()
		log_admin("[key_name(usr)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]")
		feedback_add_details("admin_verb","BBSM")

#define MAX_WARNS 3
#define AUTOBANTIME 10

/client/proc/warn(warned_ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!warned_ckey || !istext(warned_ckey))	return
	if(warned_ckey in admin_datums)
		to_chat(usr, "<font color='red'>Error: warn(): You can't warn admins.</font>")
		return

	var/datum/preferences/D
	var/client/C = GLOB.directory[warned_ckey]
	if(C)	D = C.prefs
	else	D = preferences_datums[warned_ckey]

	if(!D)
		to_chat(src, "<font color='red'>Error: warn(): No such ckey found.</font>")
		return

	if(++D.warns >= MAX_WARNS)					//uh ohhhh...you'reee iiiiin trouuuubble O:)
		ban_unban_log_save("[ckey] warned [warned_ckey], resulting in a [AUTOBANTIME] minute autoban.")
		if(C)
			message_admins("[key_name_admin(src)] has warned [key_name_admin(C)] resulting in a [AUTOBANTIME] minute ban")
			log_admin("[key_name(src)] has warned [key_name(C)] resulting in a [AUTOBANTIME] minute ban")
			to_chat(C, "<font color='red'><BIG><B>You have been autobanned due to a warning by [ckey].</B></BIG><br>This is a temporary ban, it will be removed in [AUTOBANTIME] minutes.")
			del(C)
		else
			message_admins("[key_name_admin(src)] has warned [warned_ckey] resulting in a [AUTOBANTIME] minute ban")
			log_admin("[key_name(src)] has warned [warned_ckey] resulting in a [AUTOBANTIME] minute ban")
		AddBan(warned_ckey, D.last_id, "Autobanning due to too many formal warnings", ckey, 1, AUTOBANTIME)
		feedback_inc("ban_warn",1)
	else
		if(C)
			to_chat(C, "<font color='red'><BIG><B>You have been formally warned by an administrator.</B></BIG><br>Further warnings will result in an autoban.</font>")
			message_admins("[key_name_admin(src)] has warned [key_name_admin(C)]. They have [MAX_WARNS-D.warns] strikes remaining.")
			log_admin("[key_name(src)] has warned [key_name(C)]. They have [MAX_WARNS-D.warns] strikes remaining.")
		else
			message_admins("[key_name_admin(src)] has warned [warned_ckey] (DC). They have [MAX_WARNS-D.warns] strikes remaining.")
			log_admin("[key_name(src)] has warned [warned_ckey] (DC). They have [MAX_WARNS-D.warns] strikes remaining.")

	feedback_add_details("admin_verb","WARN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef MAX_WARNS
#undef AUTOBANTIME

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
	feedback_add_details("admin_verb","DB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in GLOB.mob_list) // -- Urist
	set category = "Event"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	if(!check_rights(R_EVENT))
		return

	var/list/spell_list = list()
	var/type_length = length("/obj/effect/proc_holder/spell") + 2
	for(var/A in spells)
		spell_list[copytext("[A]", type_length)] = A
	var/obj/effect/proc_holder/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_list
	if(!S)
		return
	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)

	feedback_add_details("admin_verb","GS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("[key_name_admin(usr)] gave [key_name(T)] the spell [S].", 1)

/client/proc/give_disease(mob/T in GLOB.mob_list)
	set category = "Event"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in diseases
	if(!D) return
	T.ForceContractDisease(new D)
	feedback_add_details("admin_verb","GD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] gave [key_name(T)] the disease [D].</span>")

/client/proc/make_sound(var/obj/O in view()) // -- TLE
	set category = "Event"
	set name = "Make Sound"
	set desc = "Display a message to everyone who can hear the target"

	if(!check_rights(R_EVENT))
		return

	if(O)
		var/message = input("What do you want the message to be?", "Make Sound") as text|null
		if(!message)
			return
		for(var/mob/V in hearers(O))
			V.show_message(message, 2)
		log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z] make a sound")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z] make a sound</span>")
		feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Event"

	if(!check_rights(R_EVENT))
		return

	if(src.mob)
		togglebuildmode(src.mob)
	feedback_add_details("admin_verb","TBMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/object_talk(var/msg as text) // -- TLE
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

	feedback_add_details("admin_verb","OT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/kill_air() // -- TLE
	set category = "Debug"
	set name = "Kill Air"
	set desc = "Toggle Air Processing"

	if(!check_rights(R_DEBUG))
		return

	if(air_processing_killed)
		air_processing_killed = 0
		to_chat(usr, "<b>Enabled air processing.</b>")
	else
		air_processing_killed = 1
		to_chat(usr, "<b>Disabled air processing.</b>")
	feedback_add_details("admin_verb","KA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] used 'kill air'.")
	message_admins("<span class='notice'>[key_name_admin(usr)] used 'kill air'.</span>", 1)

/client/proc/deadmin_self()
	set name = "De-admin self"
	set category = "Admin"

	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return

	log_admin("[key_name(usr)] deadmined themself.")
	message_admins("[key_name_admin(usr)] deadmined themself.")
	deadmin()
	verbs += /client/proc/readmin
	GLOB.deadmins += ckey
	to_chat(src, "<span class='interface'>You are now a normal player.</span>")
	feedback_add_details("admin_verb","DAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/readmin()
	set name = "Re-admin self"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/D = admin_datums[ckey]
	var/rank = null
	if(config.admin_legacy_system)
		//load text from file
		var/list/Lines = file2list("config/admins.txt")
		for(var/line in Lines)
			var/list/splitline = splittext(line, " - ")
			if(lowertext(splitline[1]) == ckey)
				if(splitline.len >= 2)
					rank = ckeyEx(splitline[2])
				break
			continue
	else
		if(!dbcon.IsConnected())
			message_admins("Warning, MySQL database is not connected.")
			to_chat(src, "Warning, MYSQL database is not connected.")
			return
		var/sql_ckey = sanitizeSQL(ckey)
		var/DBQuery/query = dbcon.NewQuery("SELECT rank FROM [format_table_name("admin")] WHERE ckey = '[sql_ckey]'")
		query.Execute()
		while(query.NextRow())
			rank = ckeyEx(query.item[1])
	if(!D)
		if(config.admin_legacy_system)
			if(admin_ranks[rank] == null)
				error("Error while re-adminning [src], admin rank ([rank]) does not exist.")
				to_chat(src, "Error while re-adminning, admin rank ([rank]) does not exist.")
				return

			D = new(rank, admin_ranks[rank], ckey)
		else
			var/sql_ckey = sanitizeSQL(ckey)
			var/DBQuery/query = dbcon.NewQuery("SELECT ckey, rank, flags FROM [format_table_name("admin")] WHERE ckey = '[sql_ckey]'")
			query.Execute()
			while(query.NextRow())
				var/admin_ckey = query.item[1]
				var/admin_rank = query.item[2]
				var/flags = query.item[3]
				if(!admin_ckey)
					to_chat(src, "Error while re-adminning, ckey [admin_ckey] was not found in the admin database.")
					return
				if(admin_rank == "Removed") //This person was de-adminned. They are only in the admin list for archive purposes.
					to_chat(src, "Error while re-adminning, ckey [admin_ckey] is not an admin.")
					return

				if(istext(flags))
					flags = text2num(flags)
				D = new(admin_rank, flags, ckey)

		var/client/C = GLOB.directory[ckey]
		D.associate(C)
		message_admins("[key_name_admin(usr)] re-adminned themselves.")
		log_admin("[key_name(usr)] re-adminned themselves.")
		GLOB.deadmins -= ckey
		feedback_add_details("admin_verb","RAS")
		return
	else
		to_chat(src, "You are already an admin.")
		verbs -= /client/proc/readmin
		GLOB.deadmins -= ckey
		return

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	if(config)
		if(config.log_hrefs)
			config.log_hrefs = 0
			to_chat(src, "<b>Stopped logging hrefs</b>")
		else
			config.log_hrefs = 1
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

	var/datum/nano_module/law_manager/L = new(S)
	L.ui_interact(usr, state = admin_state)
	log_and_message_admins("has opened [S]'s law manager.")
	feedback_add_details("admin_verb","MSL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/change_human_appearance_admin(mob/living/carbon/human/H in GLOB.mob_list)
	set name = "C.M.A. - Admin"
	set desc = "Allows you to change the mob appearance"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H))
		if(istype(H, /mob/living/carbon/brain))
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
		admin_log_and_message_admins("is altering the appearance of [H].")
		H.change_appearance(APPEARANCE_ALL, usr, usr, check_species_whitelist = 0)
	feedback_add_details("admin_verb","CHAA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/change_human_appearance_self(mob/living/carbon/human/H in GLOB.mob_list)
	set name = "C.M.A. - Self"
	set desc = "Allows the mob to change its appearance"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H))
		if(istype(H, /mob/living/carbon/brain))
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
			admin_log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, without whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 0)
		if("No")
			admin_log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, with whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 1)
	feedback_add_details("admin_verb","CMAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/free_slot()
	set name = "Free Job Slot"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/list/jobs = list()
	for(var/datum/job/J in job_master.occupations)
		if(J.current_positions >= J.total_positions && J.total_positions != -1)
			jobs += J.title
	if(!jobs.len)
		to_chat(usr, "There are no fully staffed jobs.")
		return
	var/job = input("Please select job slot to free", "Free Job Slot") as null|anything in jobs
	if(job)
		job_master.FreeRole(job)
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
		to_chat(usr, "Your attack logs preference is now: show MOST attack logs (like ALMOST ALL, except that it also hides attacks by players on NPCs)")
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

	prefs.toggles ^= CHAT_NO_ADMINLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & CHAT_NO_ADMINLOGS)
		to_chat(usr, "You now won't get admin log messages.")
	else
		to_chat(usr, "You now will get admin log messages.")

/client/proc/toggleticketlogs()
	set name = "Toggle Admin Ticket Messgaes"
	set category = "Preferences"

	if(!check_rights(R_ADMIN))
		return

	prefs.toggles ^= CHAT_NO_TICKETLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & CHAT_NO_TICKETLOGS)
		to_chat(usr, "You now won't get admin ticket messages.")
	else
		to_chat(usr, "You now will get admin ticket messages.")

/client/proc/toggledrones()
	set name = "Toggle Maintenance Drones"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	config.allow_drone_spawn = !(config.allow_drone_spawn)
	log_admin("[key_name(usr)] has [config.allow_drone_spawn ? "enabled" : "disabled"] maintenance drones.")
	message_admins("[key_name_admin(usr)] has [config.allow_drone_spawn ? "enabled" : "disabled"] maintenance drones.")

/client/proc/toggledebuglogs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	if(!check_rights(R_DEBUG))
		return

	prefs.toggles ^= CHAT_DEBUGLOGS
	prefs.save_preferences(src)
	if(prefs.toggles & CHAT_DEBUGLOGS)
		to_chat(usr, "You now will get debug log messages")
	else
		to_chat(usr, "You now won't get debug log messages")

/client/proc/man_up(mob/T as mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Man Up"
	set desc = "Tells mob to man up and deal with it."

	if(!check_rights(R_ADMIN))
		return

	to_chat(T, "<span class='notice'><b><font size=3>Man up and deal with it.</font></b></span>")
	to_chat(T, "<span class='notice'>Move on.</span>")
	T << 'sound/voice/manup1.ogg'

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
		for(var/mob/T as mob in GLOB.mob_list)
			to_chat(T, "<br><center><span class='notice'><b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.</span></center><br>")
			T << 'sound/voice/manup1.ogg'

		log_admin("[key_name(usr)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(usr)] told everyone to man up and deal with it.")

/client/proc/show_snpc_verbs()
	set name = "Show SNPC Verbs"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	verbs += admin_verbs_snpc
	verbs -= /client/proc/show_snpc_verbs
	to_chat(src, "<span class='interface'>SNPC verbs have been toggled on.</span>")

/client/proc/hide_snpc_verbs()
	set name = "Hide SNPC Verbs"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	verbs -= admin_verbs_snpc
	verbs += /client/proc/show_snpc_verbs
	to_chat(src, "<span class='interface'>SNPC verbs have been toggled off.</span>")

/client/proc/toggle_advanced_interaction()
	set name = "Toggle Advanced Admin Interaction"
	set category = "Admin"
	set desc = "Allows you to interact with atoms such as buttons and doors, on top of regular machinery interaction."

	if(!check_rights(R_ADMIN))
		return

	advanced_admin_interaction = !advanced_admin_interaction

	log_admin("[key_name(usr)] has [advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")
	message_admins("[key_name_admin(usr)] has [advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")

/client/proc/show_discord_duplicates()
	set name = "Show Duplicate Discord Links"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.discord_duplicates()