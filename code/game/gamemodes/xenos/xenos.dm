/datum/game_mode
	var/list/datum/mind/xenos = list()


/datum/game_mode/xenos
	name = "xenos"
	config_tag = "xenos"
	required_players = 0
	recommended_players = 30
	required_players_secret = 20
	required_enemies = 3
	recommended_enemies = 3
	var/result = 0
	var/checkwin_counter = 0
	var/xenos_list = list()
	var/gammacalled = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/xenoai = 0 //Should the Xenos have their own AI?
	var/xenoborg = 0 //Should the Xenos have their own borg?
	var/gammaratio = 4 //At what alien to human ratio will the Gamma security level be called and the nuke be made available?

/datum/game_mode/xenos/announce()
	world << "<B>The current game mode is - Xenos!</B>"
	world << "<B>There is an Xenomorph attack on the station.<BR>Aliens - Kill or infect the crew. Protect the Queen. <BR>Crew - Protect the station. Exterminate all aliens.</B>"

/datum/game_mode/xenos/can_start()
	if(!..())
		return 0

	var/list/candidates = get_players_for_role(BE_ALIEN)
	var/playersready = 0
	var/xenos_num
	for(var/mob/new_player/player in player_list)
		if((player.client)&&(player.ready))
			playersready += 1

	//Check that we have enough alien candidates
	if(candidates.len < required_enemies)
		return 0
	if (playersready < recommended_players)
		xenos_num = required_enemies
	if (playersready >= recommended_players)
		xenos_num = recommended_enemies

	//Grab candidates randomly until we have enough.
	while(xenos_num > 0)
		var/datum/mind/new_xenos = pick(candidates)
		xenos += new_xenos
		candidates -= new_xenos
		xenos_num--

	for(var/datum/mind/xeno in xenos)
		xeno.assigned_role = "MODE"
		xeno.special_role = "Alien"
	return 1

/datum/game_mode/xenos/pre_setup()
	return 1

/datum/game_mode/xenos/post_setup()

	var/list/turf/xenos_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Xenos-Spawn")
			xenos_spawn += get_turf(A)
			del(A)
			continue

	var/xenoai_selected = 0
	var/xenoborg_selected = 0
	var/xenoqueen_selected = 0
	var/spawnpos = 1

	for(var/datum/mind/xeno_mind in xenos)
		if(spawnpos > xenos_spawn.len)
			spawnpos = 1
		//XenoAI selection
		if(xenoai && !xenoai_selected)
			var/mob/living/silicon/ai/O = new(xenos_spawn[spawnpos],,,1)//No MMI but safety is in effect.
			O.invisibility = 0
			O.aiRestorePowerRoutine = 0

			if(xeno_mind.current)
				xeno_mind.transfer_to(O)
				O.mind.original = O
			else
				O.key = xeno_mind.current.key

			//del(xeno_mind)
			var/obj/loc_landmark
			for(var/obj/effect/landmark/start/sloc in landmarks_list)
				if (sloc.name == "XenoAI")
					loc_landmark = sloc
			O.loc = loc_landmark.loc
			O.icon_state = "ai-alien"
			O.verbs.Remove(,/mob/living/silicon/ai/proc/ai_call_shuttle,/mob/living/silicon/ai/proc/ai_camera_track, \
			/mob/living/silicon/ai/proc/ai_camera_list, /mob/living/silicon/ai/proc/ai_network_change, \
			/mob/living/silicon/ai/proc/ai_statuschange, /mob/living/silicon/ai/proc/ai_hologram_change, \
			/mob/living/silicon/ai/proc/toggle_camera_light,/mob/living/silicon/ai/verb/pick_icon)
			O.laws = new /datum/ai_laws/alienmov
			O.name = "Alien AI"
			O.real_name = name
			xeno_mind.name = O.name
			O.alienAI = 1
			O.network = list("SS13","Xeno")
			O.holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
			O.alien_talk_understand = 1
			xenoai_selected = 1
			spawnpos++
			continue
		//XenoQueen Selection
		if(!xenoqueen_selected)
			var/mob/living/carbon/alien/humanoid/queen/O = new(xenos_spawn[spawnpos])
			if(xeno_mind.current)
				xeno_mind.transfer_to(O)
			else
				O.key = xeno_mind.current.key
			xeno_mind.name = O.name
			//del(xeno_mind)
			xenoqueen_selected = 1
			spawnpos++
			continue
		//XenoBorg Selection
		if(xenoborg && !xenoborg_selected)
			var/mob/living/silicon/robot/O = new(xenos_spawn[spawnpos],0,0,1)
			O.mmi = new /obj/item/device/mmi(O)
			O.mmi.alien = 1
			O.mmi.transfer_identity(xeno_mind.current)//Does not transfer key/client.
			O.cell = new(O)
			O.cell.maxcharge = 25000
			O.cell.charge = 25000
			O.gender = xeno_mind.current.gender
			O.invisibility = 0
			O.key = xeno_mind.current.key
			//del(xeno_mind)
			O.job = "Alien Cyborg"
			O.name = "Alien Cyborg"
			O.real_name = name
			xeno_mind.name = O.name
			O.module = new /obj/item/weapon/robot_module/alien/hunter(src)
			O.hands.icon_state = "standard"
			O.icon = 'icons/mob/alien.dmi'
			O.icon_state = "xenoborg-state-a"
			O.modtype = "Xeno-Hu"
			O.connected_ai = select_active_alien_ai()
			O.laws = new /datum/ai_laws/alienmov()
			O.scrambledcodes = 1
			O.hiddenborg = 1
			O.alien_talk_understand = 1
			feedback_inc("xeborg_hunter",1)
			xenoborg_selected = 1
			spawnpos++
			continue
		//Additional larvas if playercount > 20
		else
			var/mob/living/carbon/alien/larva/O = new(xenos_spawn[spawnpos])
			if(xeno_mind.current)
				xeno_mind.transfer_to(O)
			else
				O.key = xeno_mind.current.key
			xeno_mind.name = O.name
			//del(xeno_mind)
		spawnpos++

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

	return ..()

/datum/game_mode/xenos/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!result)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0


/datum/game_mode/xenos/check_win()
	var/xenosalive = xenos_alive()
	var/playersalive = players_alive()
	var/playeralienratio = 0
	if(playersalive)
		playeralienratio = xenosalive / playersalive
	if(emergency_shuttle && emergency_shuttle.returned())
		return ..()
	if(!xenosalive)
		result = 1
		return 1
	else if(!playersalive)
		result = 2
		return 1
	else if(station_was_nuked)
		result = 3
		return 1
	else
		if(playeralienratio >= gammaratio && !gammacalled)
			gammacalled = 1
			command_alert("The aliens have nearly succeeded in capturing the station and exterminating the crew. Activate the nuclear failsafe to stop the alien threat once and for all. The Nuclear Authentication Code is [get_nuke_code()] ", "Alien Lifeform Alert")
			set_security_level("gamma")
			var/obj/machinery/door/airlock/vault/V = locate(/obj/machinery/door/airlock/vault) in world
			if(V && V.z == 1)
				V.locked = 0
				V.update_icon()
		return ..()

/datum/game_mode/xenos/check_finished()
	if(config.continous_rounds)
		if(result)
			return ..()
	if(emergency_shuttle && emergency_shuttle.returned())
		return ..()
	if(result || station_was_nuked)
		return 1
	else
		return 0

/datum/game_mode/xenos/proc/get_nuke_code()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in world)
		if(bomb && bomb.r_code && bomb.z == 1)
			nukecode = bomb.r_code
	return nukecode

/datum/game_mode/xenos/proc/xenos_alive()
	var/list/livingxenos = list()
	for(var/datum/mind/xeno in xenos)
		if((xeno) && (xeno.current) && (xeno.current.stat != 2) && (xeno.current.client))
			if(istype(xeno.current,/mob/living/carbon/alien) || (xenoborg && isrobot(xeno.current)) || (xenoai && isAI(xeno.current)))
				livingxenos += xeno
	return livingxenos.len

/datum/game_mode/xenos/proc/players_alive()
	var/list/livingplayers = list()
	for(var/mob/M in player_list)
		var/turf/T = get_turf(M)
		if((M) && (M.stat != 2) && M.client && T && (T.z == 1 || emergency_shuttle.departed && (T.z == 1 || T.z == 2)))
			if(ishuman(M))
				livingplayers += 1
	return livingplayers.len

/datum/game_mode/xenos/declare_completion()
	if(result == 1)
		feedback_set_details("round_end_result","win - xenos killed")
		world << "<FONT size = 3><B>Crew Victory</B></FONT>"
		world << "<B>The aliens did not succeed and were exterminated by the crew!</B>"
	else if(result == 2)
		feedback_set_details("round_end_result","win - crew killed")
		world << "<FONT size = 3><B>Alien Victory</B></FONT>"
		world << "<B>The aliens were successful and slaughtered the crew!</B>"
	else if(station_was_nuked)
		feedback_set_details("round_end_result","win - xenos nuked")
		world << "<FONT size = 3><B>Crew Victory</B></FONT>"
		world << "<B>The station was destroyed in a nuclear explosion, preventing the aliens from overrunning it!</B>"
	else
		feedback_set_details("round_end_result","win - crew escaped")
		world << "<FONT size = 3><B>Draw</B></FONT>"
		world << "<B>The crew has escaped from the aliens but did not exterminate them, allowing them to overrun the station.</B>"

	var/text = "<br><FONT size=3><B>There were [xenos.len] aliens.</B></FONT>"
	text += "<br><FONT size=3><B>The aliens were:</B></FONT>"
	for(var/datum/mind/xeno in xenos)
		text += "<br><b>[xeno.key]</b> was <b>[xeno.name]</b> ("
		if(xeno.current)
			if(xeno.current.stat == DEAD)
				text += "died"
			else if(!xeno.current.client)
				text += "SSD"
			else
				text += "survived"
		else
			text += "body destroyed"
		text += ")"
	world << text

	..()
	return 1