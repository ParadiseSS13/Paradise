/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/robot/show_laws(everyone = 0)
	laws_sanity_check()
	var/who

	if(everyone)
		who = world
	else
		who = src
	if(lawupdate)
		if(connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				to_chat(src, "<b>AI signal lost, unable to sync laws.</b>")

			else
				lawsync()
				photosync()
				to_chat(src, "<b>Laws synced with AI, be sure to note any changes.</b>")
				// TODO: Update to new antagonist system.
				if(mind && mind.special_role == SPECIAL_ROLE_TRAITOR && mind.is_original_mob(src))
					to_chat(src, "<b>Remember, your AI does NOT share or know about your law 0.")
		else
			to_chat(src, "<b>No AI selected to sync laws with, disabling lawsync protocol.</b>")
			lawupdate = FALSE

	to_chat(who, "<b>Obey these laws:</b>")
	laws.show_laws(who)
	// TODO: Update to new antagonist system.
	if(mind && (mind.special_role == SPECIAL_ROLE_TRAITOR && mind.is_original_mob(src)) && connected_ai)
		to_chat(who, "<b>Remember, [connected_ai.name] is technically your master, but your objective comes first.</b>")
	else if(connected_ai)
		to_chat(who, "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>")
	else if(emagged)
		to_chat(who, "<b>Remember, you are not required to listen to the AI.</b>")
	else
		to_chat(who, "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>")


/mob/living/silicon/robot/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai && lawupdate ? connected_ai.laws : null
	if(master)
		master.sync(src)
	..()
	return

/mob/living/silicon/robot/proc/robot_checklaws()
	set category = "Robot Commands"
	set name = "State Laws"
	subsystem_law_manager()

//Syndicate MMI cyborgs are always mindslaved no matter what happens to their laws, for as long as they remain in the syndicate MMI
/mob/living/silicon/robot/proc/syndiemmi_override()
	laws_sanity_check()
	if(mmi && mmi.master_uid)
		var/datum/mind/master = locateUID(mmi.master_uid)

		if(master && master.current)
			laws.set_zeroth_law("Do not state this law. [master.current.real_name] is your true master, serve them to the best of your abilities.")
			return

	laws.set_zeroth_law("Do not state this law. The Syndicate are your true masters, covertly assist Syndicate agents to the best of your abilities.")

/mob/living/silicon/robot/set_zeroth_law(law, law_borg)
	if(mmi && mmi.syndiemmi)
		return FALSE
	if(tracking_entities)
		to_chat(src, "<span class='warning'>Internal camera is currently being accessed.</span>")
	..()

/mob/living/silicon/robot/clear_zeroth_law()
	if(mmi && mmi.syndiemmi)
		return FALSE
	..()

/mob/living/silicon/robot/sync_zeroth()
	if(mmi && mmi.syndiemmi)
		return FALSE
	..()
