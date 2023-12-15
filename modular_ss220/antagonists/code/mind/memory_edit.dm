/datum/mind/edit_memory()
	if(!SSticker || !SSticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/list/out = list("<meta charset='UTF-8'><B>[name]</B>[(current && (current.real_name != name))?" (as [current.real_name])" : ""]")
	out.Add("Mind currently owned by key: [key] [active ? "(synced)" : "(not synced)"]")
	out.Add("Assigned role: [assigned_role]. <a href='?src=[UID()];role_edit=1'>Edit</a>")
	out.Add("Factions and special roles:")

	var/list/sections = list(
		"implant",
		"revolution",
		"cult",
		"wizard",
		"changeling",
		"vampire", // "traitorvamp",
		"nuclear",
		"traitor", // "traitorchan",
	)
	var/mob/living/carbon/human/H = current
	if(ishuman(current))
		/** Impanted**/
		sections["implant"] = memory_edit_implant(H)
		/** REVOLUTION ***/
		sections["revolution"] = memory_edit_revolution(H)
		/** WIZARD ***/
		sections["wizard"] = memory_edit_wizard(H)
		/** CHANGELING ***/
		sections["changeling"] = memory_edit_changeling(H)
		/** VAMPIRE ***/
		sections["vampire"] = memory_edit_vampire(H)
		/** NUCLEAR ***/
		sections["nuclear"] = memory_edit_nuclear(H)
		/** Abductors **/
		sections["abductor"] = memory_edit_abductor(H)
	sections["eventmisc"] = memory_edit_eventmisc(H)
	/** TRAITOR ***/
	sections["traitor"] = memory_edit_traitor()
	/** BLOOD BROTHER **/
	sections["blood_brother"] = memory_edit_blood_brother()
	if(!issilicon(current))
		/** CULT ***/
		sections["cult"] = memory_edit_cult(H)
	/** SILICON ***/
	if(issilicon(current))
		sections["silicon"] = memory_edit_silicon()
	/*
		This prioritizes antags relevant to the current round to make them appear at the top of the panel.
		Traitorchan and traitorvamp are snowflaked in because they have multiple sections.
	*/
	if(SSticker.mode.config_tag == "traitorchan")
		if(sections["traitor"])
			out.Add(sections["traitor"])
		if(sections["changeling"])
			out.Add(sections["changeling"])
		sections -= "traitor"
		sections -= "changeling"
	// Elif technically unnecessary but it makes the following else look better
	else if(SSticker.mode.config_tag == "traitorvamp")
		if(sections["traitor"])
			out.Add(sections["traitor"])
		if(sections["vampire"])
			out.Add(sections["vampire"])
		sections -= "traitor"
		sections -= "vampire"
	else
		if(sections[SSticker.mode.config_tag])
			out.Add(sections[SSticker.mode.config_tag])
		sections -= SSticker.mode.config_tag

	for(var/i in sections)
		if(sections[i])
			out.Add(sections[i])

	out.Add(memory_edit_uplink())

	out.Add("<b>Memory:</b>")
	out.Add(memory)
	out.Add("<a href='?src=[UID()];memory_edit=1'>Edit memory</a><br>")
	out.Add("Objectives:")
	out.Add(gen_objective_text(admin = TRUE))
	out.Add("<a href='?src=[UID()];obj_add=1'>Add objective</a><br>")
	out.Add("<a href='?src=[UID()];obj_announce=1'>Announce objectives</a><br>")
	DIRECT_OUTPUT(usr, browse(out.Join("<br>"), "window=edit_memory[src];size=500x500"))

/datum/mind/proc/memory_edit_blood_brother()
	. = _memory_edit_header("blood brother")
	if(has_antag_datum(/datum/antagonist/blood_brother))
		. += "<b><font color='red'>BLOOD BROTHER</font></b>|<a href='?src=[UID()];blood_brother=clear'>Remove</a>"
	else
		. += "<a href='?src=[UID()];blood_brother=make'>Make Blood Brother</a>"

	. += _memory_edit_role_enabled(ROLE_BLOOD_BROTHER)


/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if(href_list["blood_brother"])
		switch(href_list["blood_brother"])
			if("clear")
				clear_antag_datum(/datum/antagonist/blood_brother)
			if("make")
				var/datum/antagonist/blood_brother/brother_antag_datum = new
				if(!brother_antag_datum.admin_add(usr, src))
					qdel(brother_antag_datum)

	. = ..()

/datum/mind/proc/clear_antag_datum(datum/antagonist/antag_datum_to_clear)
	if(!has_antag_datum(antag_datum_to_clear))
		return

	remove_antag_datum(antag_datum_to_clear)
	var/antag_name = initial(antag_datum_to_clear.name)
	log_admin("[key_name(usr)] has removed <b>[antag_name]</b> from [key_name(current)]")
	message_admins("[key_name_admin(usr)] has removed <b>[antag_name]</b> from [key_name_admin(current)]")
