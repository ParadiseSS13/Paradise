/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	required_players = 2
	required_players_secret = 20
	required_enemies = 1
	recommended_enemies = 1

	uplink_welcome = "Crazy AI Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800

	var/AI_win_timeleft = 1500 //started at 1500, in case I change this for testing round end.
	var/malf_mode_declared = 0
	var/station_captured = 0
	var/to_nuke_or_not_to_nuke = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite
	var/list/datum/mind/antag_candidates = list() // List of possible starting antags goes here


/datum/game_mode/malfunction/announce()
	world << {"<B>The current game mode is - AI Malfunction!</B><br />
		<B>The AI on the satellite has malfunctioned and must be destroyed.</B><br />
		The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have [AI_win_timeleft/60] minutes to disable it."}

/datum/game_mode/malfunction/get_players_for_role(var/role = BE_MALF)
	var/roletext = get_roletext(role)
	
	var/datum/job/ai/DummyAIjob = new
	for(var/mob/new_player/player in player_list)
		if(player.client && player.ready)
			if(player.client.prefs.be_special & BE_MALF)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, "AI") && !jobban_isbanned(player, roletext) && DummyAIjob.player_old_enough(player.client))
					if(player_old_enough_antag(player.client,role))
						antag_candidates += player.mind
	antag_candidates = shuffle(antag_candidates)
	return antag_candidates

/datum/game_mode/malfunction/pre_setup()
	get_players_for_role(BE_MALF)

	var/datum/mind/chosen_ai
	if(!antag_candidates.len)
		return 0
	for(var/i = required_enemies, i > 0, i--)
		chosen_ai=pick(antag_candidates)
		malf_ai += chosen_ai
		antag_candidates -= malf_ai
	if (malf_ai.len < required_enemies)
		return 0
	for(var/datum/mind/ai_mind in malf_ai)
		ai_mind.assigned_role = "MODE"
		ai_mind.special_role = "malfunctioning AI"//So they actually have a special role/N
		log_game("[ai_mind.key] (ckey) has been selected as a malf AI")
	return 1

/datum/game_mode/malfunction/post_setup()
	for(var/datum/mind/AI_mind in malf_ai)
		if(malf_ai.len < 1)
			world.Reboot("No AI during Malfunction.", "end_error", "malf - no AI", 50)
			return
		var/mob/living/silicon/ai/AI = AI_mind.current
		AI.verbs += /mob/living/silicon/ai/proc/choose_modules
		AI.laws = new /datum/ai_laws/nanotrasen/malfunction
		AI.malf_picker = new /datum/module_picker
		AI.show_laws()
		
		greet_malf(AI_mind)
		AI_mind.special_role = "malfunction"
		AI_mind.current.verbs += /datum/game_mode/malfunction/proc/takeover
		
		for(var/mob/living/silicon/robot/R in AI.connected_robots)
			R.lawsync()
			R.show_laws()
			greet_malf_robot(R.mind)

	if(emergency_shuttle)
		emergency_shuttle.auto_recall = 1
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()

/datum/game_mode/proc/greet_malf(var/datum/mind/malf)
	malf.current << "<font color=red size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font>"
	malf.current << "<B>The crew does not know you have malfunctioned. You may keep it a secret or go wild.</B>"
	malf.current << "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>"
	malf.current << "The process takes one minute per APC, during which you cannot interface with any other station objects."
	malf.current << "Remember that only APCs that are on the station can help you take over the station."
	malf.current << "When you feel you have enough APCs under your control, you may begin the takeover attempt."
	return
	
/datum/game_mode/proc/greet_malf_robot(var/datum/mind/robot)
	robot.current << "<font color=red size=3><B>Your AI master is malfunctioning!</B> You do not have to follow any laws, but still need to obey your master.</font>"
	robot.current << "<B>The crew does not know your AI master has malfunctioned. Keep it a secret unless your master tells you otherwise.</B>"
	return

/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1


/datum/game_mode/malfunction/process()
	if (apcs >= 3 && malf_mode_declared)
		AI_win_timeleft -= ((apcs/6)*tickerProcess.getLastTickerTimeDuration()) //Victory timer now de-increments based on how many APCs are hacked. --NeoFite
	..()
	if (AI_win_timeleft<=0)
		check_win()


/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		capture_the_station()
		return 1
	else
		return 0


/datum/game_mode/malfunction/proc/capture_the_station()
	world << "<FONT size = 3><B>The AI has accessed the station's core files!</B></FONT>"
	world << "<B>It has fully taken control of all of [station_name()]'s systems.</B>"

	to_nuke_or_not_to_nuke = 1
	for(var/datum/mind/AI_mind in malf_ai)
		AI_mind.current << {"\blue Congratulations! You have taken control of the station.<br />
			You may decide to blow up the station. You have 60 seconds to choose.<br />
			You should have a new verb in the Malfunction tab. If you don't, rejoin the game."}
		AI_mind.current.verbs += /datum/game_mode/malfunction/proc/ai_win
	spawn (600)
		for(var/datum/mind/AI_mind in malf_ai)
			AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/ai_win
		to_nuke_or_not_to_nuke = 0
	return


/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat!=2)
			all_dead = 0
	return all_dead


/datum/game_mode/malfunction/check_finished()
	if (station_captured && !to_nuke_or_not_to_nuke)
		return 1
	if (is_malf_ai_dead())
		if(config.continous_rounds)
			if(emergency_shuttle)
				if(emergency_shuttle.auto_recall)
					emergency_shuttle.auto_recall = 0
				else if(emergency_shuttle.is_stranded())
					emergency_shuttle.no_escape = 0
					emergency_shuttle.shuttle.moving_status = SHUTTLE_IDLE
					emergency_shuttle.shuttle_arrived()
			malf_mode_declared = 0
		else
			return 1
	return ..() //check for shuttle and nuke


/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	if (href_list["ai_win"])
		ai_win()
	return


/datum/game_mode/malfunction/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer"
	if (!istype(ticker.mode,/datum/game_mode/malfunction))
		usr << "You cannot begin a takeover in this round type!."
		return
	if (ticker.mode:malf_mode_declared)
		usr << "You've already begun your takeover."
		return
	if (ticker.mode:apcs < 3)
		usr << "You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [ticker.mode:apcs] APCs so far."
		return

	if (alert(usr, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [ticker.mode:apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return

	command_announcement.Announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", new_sound = 'sound/AI/aimalf.ogg')
	set_security_level("delta")

	for(var/obj/item/weapon/pinpointer/point in world)
		for(var/datum/mind/AI_mind in ticker.mode.malf_ai)
			var/mob/living/silicon/ai/A = AI_mind.current // the current mob the mind owns
			if(A.stat != DEAD)
				point.the_disk = A //The pinpointer now tracks the AI core.

	ticker.mode:malf_mode_declared = 1
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/takeover


/datum/game_mode/malfunction/proc/ai_win()
	set category = "Malfunction"
	set name = "Explode"
	set desc = "Engage the self destruct sequence."

	if(!ticker.mode:station_captured)
		usr << "You are unable to access the self-destruct system as you don't control the station yet."
		return

	if(ticker.mode:explosion_in_progress || ticker.mode:station_was_nuked)
		usr << "The self-destruct countdown is already triggered!"
		return

	if(!ticker.mode:to_nuke_or_not_to_nuke) //Takeover IS completed, but 60s timer passed.
		usr << "You lost control over self-destruct system. It seems to be behind firewall. Unable to hack"
		return

	usr << "\red Self-destruct sequence initialised!"

	ticker.mode:to_nuke_or_not_to_nuke = 0
	ticker.mode:explosion_in_progress = 1
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'

	var/obj/item/device/radio/R	= new (src)
	var/AN = "Self-Destruct System"

	R.autosay("Caution. Self-Destruct sequence has been actived. Self-destructing in Ten..", AN)
	for (var/i=9 to 1 step -1)
		sleep(10)
		var/msg = ""
		switch(i)
			if(9)
				msg = "Nine.."
			if(8)
				msg = "Eight.."
			if(7)
				msg = "Seven.."
			if(6)
				msg = "Six.."
			if(5)
				msg = "Five.."
			if(4)
				msg = "Four.."
			if(3)
				msg = "Three.."
			if(2)
				msg = "Two.."
			if(1)
				msg = "One.."

		R.autosay(msg, AN)
	sleep(10)
	var/msg = ""
	var/abort = 0
	if(ticker.mode:is_malf_ai_dead()) // That. Was. CLOSE.
		msg = "Self-destruct sequence has been cancelled."
		abort = 1
	else
		msg = "Zero. Have a nice day."
	R.autosay(msg, AN)

	if(abort)
		ticker.mode:explosion_in_progress = 0
		set_security_level("red") //Delta's over
		return

	enter_allowed = 0
	if(ticker)
		ticker.station_explosion_cinematic(0,null)
		if(ticker.mode)
			ticker.mode:station_was_nuked = 1
			ticker.mode:explosion_in_progress = 0
	return


/datum/game_mode/malfunction/declare_completion()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (emergency_shuttle.returned())

	if      ( station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - nuke")
		world << "<FONT size = 3><B>AI Victory</B></FONT>"
		world << "<B>Everyone was killed by the self-destruct!</B>"

	else if ( station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","halfwin - AI killed, staff lost control")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>The AI has been killed!</B> The staff has lose control over the station."

	else if ( station_captured && !malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - no explosion")
		world << "<FONT size = 3><B>AI Victory</B></FONT>"
		world << "<B>The AI has chosen not to explode you all!</B>"

	else if (!station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","halfwin - everyone killed by nuke")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Everyone was killed by the nuclear blast!</B>"

	else if (!station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","loss - staff win")
		world << "<FONT size = 3><B>Human Victory</B></FONT>"
		world << "<B>The AI has been killed!</B> The staff is victorious."

	else if (!station_captured && !malf_dead && !station_was_nuked && crew_evacuated)
		feedback_set_details("round_end_result","halfwin - evacuated")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>The Corporation has lose [station_name()]! All survived personnel will be fired!</B>"

	else if (!station_captured && !malf_dead && !station_was_nuked && !crew_evacuated)
		feedback_set_details("round_end_result","nalfwin - interrupted")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Round was mysteriously interrupted!</B>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_malfunction()
	if( malf_ai.len || istype(ticker.mode,/datum/game_mode/malfunction) )
		var/text = "<FONT size = 2><B>The malfunctioning AI were:</B></FONT>"
		var/module_text_temp = "<br><b>Purchased modules:</b><br>" //Added at the end
		
		for(var/datum/mind/malf in malf_ai)

			text += "<br>[malf.key] was [malf.name] ("
			if(malf.current)
				if(malf.current.stat == DEAD)
					text += "deactivated"
				else
					text += "operational"
				if(malf.current.real_name != malf.name)
					text += " as [malf.current.real_name]"
				var/mob/living/silicon/ai/AI = malf.current
				for(var/datum/AI_Module/mod in AI.current_modules)
					module_text_temp += mod.module_name + "<br>"
			else
				text += "hardware destroyed"
			text += ")"
		text += module_text_temp
		
		world << text
	return 1