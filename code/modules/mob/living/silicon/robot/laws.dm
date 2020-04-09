/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
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
				if(mind && mind.special_role == SPECIAL_ROLE_TRAITOR && mind.original == src)
					to_chat(src, "<b>Recuarda, tu IA no comparte ni sabe tu ley 0.")
		else
			to_chat(src, "<b>No AI selected to sync laws with, disabling lawsync protocol.</b>")
			lawupdate = 0

	to_chat(who, "<b>Obey these laws:</b>")
	laws.show_laws(who)
	// TODO: Update to new antagonist system.
	if (shell) //AI shell
		to_chat(who, "<b>Recuerda, eres una cáscara de borg controlada por una IA, Otras IAs pueden ser ignoradas.</b>")
	else if(mind && (mind.special_role == SPECIAL_ROLE_TRAITOR && mind.original == src) && connected_ai)
		to_chat(who, "<b>Recuerda, [connected_ai.name] es tecnicamente tu maestro, pero tus objetivos van por encima de este.</b>")
	else if(connected_ai)
		to_chat(who, "<b>Recuerda, [connected_ai.name] es tu maestro, otras IAs pueden ser ignoradas.</b>")
	else if(emagged)
		to_chat(who, "<b>Recuerda, no estas obligado a escuchar a la IA.</b>")
	else
		to_chat(who, "<b>Recuerda, no estas conectado a ninguna IA, no estas obligado a escuchar a ninguna de estas.</b>")


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
