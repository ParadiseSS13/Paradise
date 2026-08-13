/*~~~~~~~~~
	Bots!
~~~~~~~~~~*/
/mob/living/basic/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list[DIAG_HUD]
	if(stat == DEAD)
		holder.icon_state = "huddiagdead"
	else
		holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/basic/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/image/holder = hud_list[DIAG_STAT_HUD]
	if(bot_mode_flags & BOT_MODE_ON)
		holder.icon_state = "hudstat"
	else if(stat) //Generally EMP causes this
		holder.icon_state = "hudoffline"
	else //Bot is off
		holder.icon_state = "huddead2"

/mob/living/basic/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	var/image/holder = hud_list[DIAG_BOT_HUD]
	if(client) //If the bot is player controlled, it will not be following mode logic!
		holder.icon_state = "hudsentient"
		return

	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) // Responding to PDA or AI summons
			holder.icon_state = "hudcalled"
		if(BOT_CLEANING, BOT_HEALING) // Cleanbot cleaning, Floorbot fixing, or Medibot Healing
			holder.icon_state = "hudworking"
		if(BOT_PATROL) // Patrol mode
			holder.icon_state = "hudpatrol"
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT, BOT_BLOCKED, BOT_NO_ROUTE) // STOP RIGHT THERE, CRIMINAL SCUM!
			holder.icon_state = "hudalert"
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV, BOT_WAIT_FOR_NAV) // Moving to target for normal bots, moving to deliver or go home for MULES.
			holder.icon_state = "hudmove"
		else
			holder.icon_state = ""

///proc that handles moving along the bot's drawn path
/mob/living/basic/bot/proc/handle_loop_movement(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	handle_hud_path()
	on_bot_movement(source, oldloc, dir, forced)

/mob/living/basic/bot/proc/handle_hud_path()
	if(client || !length(current_pathed_turfs) || isnull(ai_controller))
		return

	var/turf/our_turf = get_turf(src)
	var/image/target_image = current_pathed_turfs[our_turf]
	if(target_image)
		animate(target_image, alpha = 0, time = 0.3 SECONDS)
	current_pathed_turfs -= our_turf

///proc that handles deleting the bot's drawn path when needed
/mob/living/basic/bot/proc/clear_path_hud(remove_hud = TRUE)
	for(var/turf/index as anything in current_pathed_turfs)
		var/image/our_image = current_pathed_turfs[index]
		animate(our_image, alpha = 0, time = 0.3 SECONDS)
		current_pathed_turfs -= index

	if(!remove_hud)
		return

	// Call hud remove handlers to ensure viewing user client images are removed
	var/list/path_huds_watching_me = list(GLOB.huds[DATA_HUD_DIAGNOSTIC], GLOB.huds[DATA_HUD_BOT_PATH])
	for(var/datum/atom_hud/hud as anything in path_huds_watching_me)
		hud.remove_atom_from_hud(src)
