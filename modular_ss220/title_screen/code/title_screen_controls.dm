/**
 * Enables an admin to upload a new titlescreen image.
 */
/client/proc/admin_change_title_screen()
	set category = "Event"
	set name = "Title Screen: Change"

	if(!check_rights(R_EVENT))
		return

	log_admin("[key_name(usr)] is changing the title screen.")
	message_admins("[key_name_admin(usr)] is changing the title screen.")

	switch(alert(usr, "Please select a new title screen.", "Title Screen", "Change", "Reset", "Cancel"))
		if("Change")
			var/file = input(usr) as icon|null
			if(!file)
				return

			SStitle.set_title_image(file)
		if("Reset")
			SStitle.set_title_image()
		if("Cancel")
			return

/**
 * Sets a titlescreen notice, a big red text on the main screen.
 */
/client/proc/change_title_screen_notice()
	set category = "Event"
	set name = "Title Screen: Set Notice"

	if(!check_rights(R_EVENT))
		return

	log_admin("[key_name(usr)] is setting the title screen notice.")
	message_admins("[key_name_admin(usr)] is setting the title screen notice.")

	var/new_notice = input(usr, "Please input a notice to be displayed on the title screen:", "Titlescreen Notice") as text|null
	SStitle.set_notice(new_notice)
	if(!new_notice)
		return
	for(var/mob/new_player/new_player in GLOB.player_list)
		to_chat(new_player, span_boldannounce("TITLE NOTICE UPDATED: [new_notice]"))
		SEND_SOUND(new_player,  sound('sound/items/bikehorn.ogg'))

/**
 * Reloads the titlescreen if it is bugged for someone.
 */
/client/verb/fix_title_screen()
	set name = "Fix Lobby Screen"
	set desc = "Lobbyscreen broke? Press this."
	set category = "Special Verbs"

	if(istype(mob, /mob/new_player))
		SStitle.show_title_screen_to(src)
	else
		SStitle.hide_title_screen_from(src)

/**
 * An admin debug command that enables you to change the HTML on the go.
 */
/client/proc/change_title_screen_html()
	set category = "Event"
	set name = "Title Screen: Set HTML"

	if(!check_rights(R_DEBUG))
		return

	log_admin("[key_name(usr)] is setting the title screen HTML.")
	message_admins("[key_name_admin(usr)] is setting the title screen HTML.")

	var/new_html = input(usr, "Please enter your desired HTML(WARNING: YOU WILL BREAK SHIT)", "DANGER: TITLE HTML EDIT") as message|null

	if(!new_html)
		return

	SStitle.set_title_html(new_html)

	message_admins("[key_name_admin(usr)] has changed the title screen HTML.")
