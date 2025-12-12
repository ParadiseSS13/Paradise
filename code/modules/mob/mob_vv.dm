/mob/vv_modify_name_link()
	return "byond://?_src_=vars;rename=TRUE;[VV_HK_TARGET]=[UID()]"

/mob/vv_get_header()
	. = ..()
	. += "<br><font size='1'><a href='byond://?_src_=vars;datumedit=[UID()];varnameedit=ckey'>[ckey ? ckey : "No ckey"]</a> / <a href='byond://?_src_=vars;datumedit=[UID()];varnameedit=real_name'>[real_name ? real_name : "No real name"]</a></font>"

/mob/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_MOB_PLAYER_PANEL, "Show player panel")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_SPELL, "Give Spell")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_DISEASE, "Give Disease")
	VV_DROPDOWN_OPTION(VV_HK_GODMODE, "Toggle Godmode")
	VV_DROPDOWN_OPTION(VV_HK_BUILD_MODE, "Toggle Build Mode")
	VV_DROPDOWN_OPTION(VV_HK_DIRECT_CONTROL, "Assume Direct Control")
	VV_DROPDOWN_OPTION(VV_HK_OFFER_CONTROL, "Offer Control to Ghosts")
	VV_DROPDOWN_OPTION(VV_HK_DROP_EVERYTHING, "Drop Everything")
	VV_DROPDOWN_OPTION(VV_HK_REGENERATEICONS, "Regenerate Icons")
	VV_DROPDOWN_OPTION(VV_HK_ADDLANGUAGE, "Add Language")
	VV_DROPDOWN_OPTION(VV_HK_REMLANGUAGE, "Remove Language")
	VV_DROPDOWN_OPTION(VV_HK_ADDVERB, "Add Verb")
	VV_DROPDOWN_OPTION(VV_HK_REMVERB, "Remove Verb")
	VV_DROPDOWN_OPTION(VV_HK_GIB, "Gib")

/mob/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	if(href_list["rename"])
		if(!check_rights(R_ADMIN))
			return

		var/new_name = reject_bad_name(sanitize(copytext_char(input(usr, "What would you like to name this mob?", "Input a name", real_name) as text|null, 1, MAX_NAME_LEN)), allow_numbers = TRUE)
		if(!new_name || QDELETED(src))
			return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(src)] to [new_name].")
		rename_character(real_name, new_name)
		href_list["datumrefresh"] = UID()
	if(href_list[VV_HK_MOB_PLAYER_PANEL])
		SSuser_verbs.invoke_verb(usr, /datum/user_verb/show_player_panel, src)
		href_list["datumrefresh"] = UID()
	if(href_list[VV_HK_GIVE_SPELL])
		SSuser_verbs.invoke_verb(usr, /datum/user_verb/give_spell, src)
		href_list["datumrefresh"] = UID()
	if(href_list[VV_HK_GIVE_DISEASE])
		SSuser_verbs.invoke_verb(usr, /datum/user_verb/give_disease, src)
		href_list["datumrefresh"] = UID()
	if(href_list[VV_HK_GODMODE])
		SSuser_verbs.invoke_verb(usr, /datum/user_verb/godmode, src)
		href_list["datumrefresh"] = UID()
	if(href_list[VV_HK_GIB])
		SSuser_verbs.invoke_verb(usr, /datum/user_verb/gib_mob, src)
	if(href_list[VV_HK_BUILD_MODE])
		if(!check_rights(R_BUILDMODE))
			return

		togglebuildmode(src)
		href_list["datumrefresh"] = UID()
	if(href_list[VV_HK_DROP_EVERYTHING])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(src)
	if(href_list[VV_HK_DIRECT_CONTROL])
		SSuser_verbs.invoke_verb(usr, /datum/user_verb/assume_direct_control, src)
	if(href_list[VV_HK_OFFER_CONTROL])
		if(!check_rights(R_ADMIN))
			return

		offer_control(src)
	if(href_list[VV_HK_REGENERATEICONS])
		if(!check_rights(0))
			return

		regenerate_icons()
	if(href_list[VV_HK_ADDLANGUAGE])
		if(!check_rights(R_SPAWN))
			return

		var/new_language = tgui_input_list(usr, "Please choose a language to add.", "Language", GLOB.all_languages)

		if(!new_language)
			return

		if(QDELETED(src))
			to_chat(usr, SPAN_NOTICE("Mob doesn't exist anymore."))
			return

		if(add_language(new_language, TRUE))
			to_chat(usr, SPAN_NOTICE("Added [new_language] to [src]."))
			message_admins("[key_name_admin(usr)] has given [key_name_admin(src)] the language [new_language]")
			log_admin("[key_name(usr)] has given [key_name(src)] the language [new_language]")
		else
			to_chat(usr, SPAN_NOTICE("Mob already knows that language."))
	if(href_list[VV_HK_REMLANGUAGE])
		if(!check_rights(R_SPAWN))
			return

		if(!length(languages))
			to_chat(usr, SPAN_NOTICE("This mob knows no languages."))
			return

		var/datum/language/rem_language = tgui_input_list(usr, "Please choose a language to remove.", "Language", src.languages)

		if(!rem_language)
			return

		if(QDELETED(src))
			to_chat(usr, SPAN_NOTICE("Mob doesn't exist anymore."))
			return

		if(remove_language(rem_language.name, TRUE))
			to_chat(usr, SPAN_NOTICE("Removed [rem_language] from [src]."))
			message_admins("[key_name_admin(usr)] has removed language [rem_language] from [key_name_admin(src)]")
			log_admin("[key_name(usr)] has removed language [rem_language] from [key_name(src)]")
		else
			to_chat(usr, SPAN_NOTICE("Mob doesn't know that language."))
	if(href_list[VV_HK_ADDVERB])
		if(!check_rights(R_DEBUG))
			return

		var/list/possibleverbs = list()
		possibleverbs += "Cancel" // One for the top...
		possibleverbs += typesof(/mob/proc, /mob/verb, /mob/living/proc, /mob/living/verb)
		switch(type) // Horrid
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc, /mob/living/carbon/verb, /mob/living/carbon/human/verb, /mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc, /mob/living/silicon/robot/proc, /mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc, /mob/living/silicon/ai/proc, /mob/living/silicon/ai/verb)
		possibleverbs -= verbs
		possibleverbs += "Cancel" // ...And one for the bottom

		var/verb = input("Select a verb!", "Verbs",null) as anything in possibleverbs
		if(QDELETED(src))
			to_chat(usr, SPAN_NOTICE("Mob doesn't exist anymore."))
			return
		if(!verb || verb == "Cancel")
			return
		else
			add_verb(src, verb)
			message_admins("[key_name_admin(usr)] has given [key_name_admin(src)] the verb [verb]")
			log_admin("[key_name(usr)] has given [key_name(src)] the verb [verb]")
	if(href_list[VV_HK_REMVERB])
		if(!check_rights(R_DEBUG))
			return

		var/verb = tgui_input_list(usr, "Please choose a verb to remove.", "Verbs", src.verbs)
		if(QDELETED(src))
			to_chat(usr, SPAN_NOTICE("Mob doesn't exist anymore."))
			return
		if(!verb)
			return
		else
			remove_verb(src, verb)
			message_admins("[key_name_admin(usr)] has removed verb [verb] from [key_name_admin(src)]")
			log_admin("[key_name(usr)] has removed verb [verb] from [key_name(src)]")
