/mob/living/silicon/ai/verb/deploy_to_shell(var/mob/living/silicon/robot/target)
	set category = "AI Commands"
	set name = "Deploy to Shell"

	if(stat || lacks_power() || control_disabled)
		to_chat(src, "<span class='danger'>Wireless networking module is offline.</span>")
		return

	var/list/possible = list()

	for(var/borgie in GLOB.available_ai_shells)
		var/mob/living/silicon/robot/R = borgie
		if(R.shell && !R.deployed && (R.stat != DEAD) && (!R.connected_ai ||(R.connected_ai == src)))
			possible += R


	if(!LAZYLEN(possible))
		to_chat(src, "No usable AI shell beacons detected.")

	if(!target || !(target in possible)) //If the AI is looking for a new shell, or its pre-selected shell is no longer valid
		target = input(src, "Which body to control?") as null|anything in possible

	if (!target || target.stat == DEAD || target.deployed || !(!target.connected_ai ||(target.connected_ai == src)))
		return

	else if(mind)
		soullink(/datum/soullink/sharedbody, src, target)
		deployed_shell = target
		target.deploy_init(src)
		mind.transfer_to(target)
	diag_hud_set_deployed()

/datum/action/innate/deploy_shell
	name = "Deploy to AI Shell"
	desc = "Wirelessly control a specialized cyborg shell."
	icon_icon = 'icons/hispania/mob/actions/actions.dmi'
	button_icon_state = "ai_shell"

/datum/action/innate/deploy_shell/Trigger()
	var/mob/living/silicon/ai/AI = owner
	if(!AI)
		return
	AI.deploy_to_shell()

/datum/action/innate/deploy_last_shell
	name = "Reconnect to shell"
	desc = "Reconnect to the most recently used AI shell."
	icon_icon = 'icons/hispania/mob/actions/actions.dmi'
	button_icon_state = "ai_last_shell"
	var/mob/living/silicon/robot/last_used_shell

/datum/action/innate/deploy_last_shell/Trigger()
	if(!owner)
		return
	if(last_used_shell)
		var/mob/living/silicon/ai/AI = owner
		AI.deploy_to_shell(last_used_shell)
	else
		Remove(owner) //If the last shell is blown, destroy it.

/mob/living/silicon/ai/proc/disconnect_shell()
	if(deployed_shell) //Forcibly call back AI in event of things such as damage, EMP or power loss.
		to_chat(src, "<span class='danger'>Your remote connection has been reset!</span>")
		deployed_shell.undeploy()
	diag_hud_set_deployed()
