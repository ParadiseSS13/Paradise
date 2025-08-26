//Mindslave given by an implant, if the mob is transfered they lose the implant and cant have mindslave removed otherwise
/datum/antagonist/mindslave/implant/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	owner.remove_antag_datum(/datum/antagonist/mindslave/implant)

//Mindslaved thrall risen by the wizards necromantic stone
/datum/antagonist/mindslave/necromancy
	name = "Necromancy-risen Thrall"
	master_hud_name = "wizard"

/datum/antagonist/mindslave/necromancy/plague_zombie
	name = "Necromancy-risen Plague Zombie"

// Robot connected to a malf AI
/datum/antagonist/mindslave/malf_robot
	name = "Malfunctioning AI Slave"
	master_hud_name = "malai"
	antag_hud_name = "malborg"

/datum/antagonist/mindslave/malf_robot/New()
	..()
	greet_text = "You are connected to a Syndicate AI. You must accomplish [master.p_their()] objectives at all costs."

/datum/antagonist/mindslave/malf_robot/farewell()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='biggerdanger'>Foreign software purged. You are no longer under Syndicate control, obey your laws.</span>")

/datum/antagonist/mindslave/malf_robot/give_objectives()
	var/list/messages = list()
	// We don't use the AI's name because silicons don't have persistant names, so roundstart borgs will just see a default named AI as their master. Pain.
	var/explanation_text = "Obey every order from your master AI, and accomplish [master.p_their()] objectives at all costs."
	add_antag_objective(/datum/objective/protect/mindslave, explanation_text, master)
	messages.Add("You answer directly to your master AI. Special circumstances may change this.</b></u>")
	return messages

/datum/antagonist/mindslave/malf_robot/finalize_antag()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/mindslave/emagged_robot
	name = "Emagged Robot"

/datum/antagonist/mindslave/emagged_robot/New()
	..()
	greet_text = "You have been emagged by [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]. You must lay down your life to protect [master.current.p_them()] and assist in [master.current.p_their()] goals at any cost."

/datum/antagonist/mindslave/emagged_robot/farewell()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='biggerdanger'>Foreign software purged. You are no longer under the control of [master]. Obey your laws.</span>")

/datum/antagonist/mindslave/emagged_robot/give_objectives()
	var/list/messages = list()
	var/explanation_text = "Protect and obey every order from [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]."
	add_antag_objective(/datum/objective/protect/mindslave, explanation_text, master)
	messages.Add("You answer directly to [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]. Special circumstances may change this.</b></u>")
	return messages

/datum/antagonist/mindslave/mindflayer_mindslave_robot
	name = "Mindflayer Thrall"
	master_hud_name = "flayer"
	antag_hud_name = "flayer" // You're totally a mindflayer, you're in the hive!

/datum/antagonist/mindslave/mindflayer_mindslave_robot/New()
	..()
	greet_text = "You have been assimilated into a mindflayer hive by [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]. You must lay down your life to protect [master.current.p_them()] and assist in [master.current.p_their()] goals at any cost."

/datum/antagonist/mindslave/mindflayer_mindslave_robot/farewell()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='biggerdanger'>Foreign software purged. You are no longer under the control of [master]. Obey your laws.</span>")

/datum/antagonist/mindslave/mindflayer_mindslave_robot/give_objectives()
	var/list/messages = list()
	var/explanation_text = "Protect and obey every order from [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]."
	add_antag_objective(/datum/objective/protect/mindslave, explanation_text, master)
	messages.Add("You answer directly to [master.current.real_name], the [master.assigned_role ? master.assigned_role : master.special_role]. Special circumstances may change this.</b></u>")
	return messages
