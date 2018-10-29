//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access_in(client)
	create_attack_log("<font color='red'>Logged in at [atom_loc_line(get_turf(src))]</font>")
	if(config.log_access)
		for(var/mob/M in GLOB.player_list)
			if(M == src)	continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (M.computer_id == client.computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([client.computer_id])"
					if(!config.disable_cid_warn_popup)
						spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=[usr.UID()];priv_msg=[src.UID()]'>[key_name_admin(src)]</A> has the same [matches] as <A href='?src=[usr.UID()];priv_msg=[M.UID()]'>[key_name_admin(M)]</A>.</font>", 1)
						log_adminwarn("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=[usr.UID()];priv_msg=[src.UID()]'>[key_name_admin(src)]</A> has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", 1)
						log_adminwarn("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/Login()
	GLOB.player_list |= src
	update_Login_details()
	world.update_status()

	client.images = null				//remove the images such as AIs being unable to see runes
	client.screen = list()				//remove hud items just in case
	if(client.click_intercept)
		client.click_intercept.quit() // Let's not keep any old click_intercepts

	if(!hud_used)
		create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

	next_move = 1
	sight |= SEE_SELF
	..()

	reset_perspective(loc)


	if(ckey in GLOB.deadmins)
		verbs += /client/proc/readmin

	//Clear ability list and update from mob.
	client.verbs -= ability_verbs

	if(abilities)
		client.verbs |= abilities

	if(ishuman(src))
		client.screen += client.void

	//HUD updates (antag hud, etc)
	//readd this mob's HUDs (antag, med, etc)
	reload_huds()

	add_click_catcher()

	if(viewing_alternate_appearances && viewing_alternate_appearances.len)
		for(var/datum/alternate_appearance/AA in viewing_alternate_appearances)
			AA.display_to(list(src))

	update_client_colour(0)

	callHook("mob_login", list("client" = client, "mob" = src))

// Calling update_interface() in /mob/Login() causes the Cyborg to immediately be ghosted; because of winget().
// Calling it in the overriden Login, such as /mob/living/Login() doesn't cause this.
/mob/proc/update_interface()
	spawn() // Spawn off so winget/winset don't delay callers.
		if(client)
			if(winget(src, "mainwindow.hotkey_toggle", "is-checked") == "true")
				update_hotkey_mode()
			else
				update_normal_mode()

/mob/proc/update_hotkey_mode()
	var/hotkeyname = "hotkeymode"
	if(client)
		var/hotkeys = client.hotkeylist[client.hotkeytype]
		hotkeyname = hotkeys[client.hotkeyon ? "on" : "off"]
		client.hotkeyon = 1
		winset(src, null, "mainwindow.macro=[hotkeyname] hotkey_toggle.is-checked=true mapwindow.map.focus=true input.background-color=#F0F0F0")

/mob/proc/update_normal_mode()
	var/hotkeyname = "macro"
	if(client)
		var/hotkeys = client.hotkeylist[client.hotkeytype]//get the list containing the hotkey names
		hotkeyname = hotkeys[client.hotkeyon ? "on" : "off"]//get the name of the hotkey, to not clutter winset() to much
		client.hotkeyon = 0
		winset(src, null, "mainwindow.macro=[hotkeyname] hotkey_toggle.is-checked=false input.focus=true input.background-color=#D3B5B5")
