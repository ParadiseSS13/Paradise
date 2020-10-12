GLOBAL_LIST_INIT(available_ai_shells, list())

/mob/living/silicon/robot/proc/make_shell(var/obj/item/borg/upgrade/ai/board)
	shell = TRUE
	braintype = "AI Shell"
	name = "[designation] AI Shell [rand(100,999)]"
	real_name = name
	GLOB.available_ai_shells |= src
	if(camera)
		camera.c_tag = real_name	//update the camera name too
	diag_hud_set_aishell()
	notify_ai(AI_SHELL)

/mob/living/silicon/robot/proc/revert_shell()
	if(!shell)
		return
	undeploy()
	for(var/obj/item/borg/upgrade/ai/boris in src)
	//A player forced reset of a borg would drop the module before this is called, so this is for catching edge cases
		qdel(boris)
	shell = FALSE
	GLOB.available_ai_shells -= src
	name = "Unformatted Cyborg [rand(100,999)]"
	real_name = name
	if(camera)
		camera.c_tag = real_name
	diag_hud_set_aishell()

/mob/living/silicon/robot/proc/deploy_init(var/mob/living/silicon/ai/AI)
	real_name = "[AI.real_name] shell [rand(100, 999)] [designation] ? "-":[designation]"	//Randomizing the name so it shows up seperately in the shells list
	name = real_name
	if(camera)
		camera.c_tag = real_name	//update the camera name too
	mainframe = AI
	deployed = TRUE
	connected_ai = mainframe
	mainframe.connected_robots |= src
	lawupdate = TRUE
	lawsync()
	if(radio && AI.aiRadio) //AI keeps all channels, including Syndie if it is a Traitor
		if(AI.aiRadio.syndie)
			radio.make_syndie()
		radio.channels = AI.aiRadio.channels
		for(var/chan in radio.channels)
			radio.secure_radio_connections[chan] = SSradio.add_object(radio, SSradio.radiochannels[chan],  RADIO_CHAT)

	diag_hud_set_aishell()
	undeployment_action.Grant(src)

/datum/action/innate/undeployment
 	name = "Disconnect from shell"
 	desc = "Stop controlling your shell and resume normal core operations."
 	icon_icon = 'icons/hispania/mob/actions/actions.dmi'
 	button_icon_state = "ai_core"

/datum/action/innate/undeployment/Trigger()
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/R = owner

	R.undeploy()
	return TRUE

/mob/living/silicon/robot/proc/undeploy()
	if(!deployed || !mind || !mainframe)
		return
	mainframe.redeploy_action.Grant(mainframe)
	mainframe.redeploy_action.last_used_shell = src
	mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	undeployment_action.Remove(src)
	if(radio) //Return radio to normal
		radio.recalculateChannels()
	if(camera)
		camera.c_tag = real_name	//update the camera name too
	diag_hud_set_aishell()
	mainframe.diag_hud_set_deployed()
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe) //Always remind the AI when switching
	mainframe = null

/mob/living/silicon/robot/attack_ai(mob/user)
	if(shell && (!connected_ai || connected_ai == user))
		var/mob/living/silicon/ai/AI = user
		AI.deploy_to_shell(src)

/mob/living/silicon/robot/shell
	shell = TRUE
