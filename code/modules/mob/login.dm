//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version]")
	if(config.log_access)
		for(var/mob/M in player_list)
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
						message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A>.</font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/Login()
	player_list |= src
	update_Login_details()
	world.update_status()

	client.images = null				//remove the images such as AIs being unable to see runes
	client.screen = list()				//remove hud items just in case
	if(hud_used)
		qdel(hud_used)		//remove the hud objects
		hud_used = null
	hud_used = new /datum/hud(src)

	next_move = 1
	sight |= SEE_SELF
	..()

	if(loc && !isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	else
		client.eye = src
		client.perspective = MOB_PERSPECTIVE


	if(ckey in deadmins)
		verbs += /client/proc/readmin

	//Clear ability list and update from mob.
	client.verbs -= ability_verbs

	if(abilities)
		client.verbs |= abilities

	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.species && H.species.abilities)
			client.verbs |= H.species.abilities

		client.screen += client.void

	//HUD updates (antag hud, etc)
	//readd this mob's HUDs (antag, med, etc)
	reload_huds()

	CallHook("Login", list("client" = src.client, "mob" = src))

// Calling update_interface() in /mob/Login() causes the Cyborg to immediately be ghosted; because of winget().
// Calling it in the overriden Login, such as /mob/living/Login() doesn't cause this.
/mob/proc/update_interface()
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
