/*
SPACE PIRATES ROUNDTYPE
*/

var/global/list/raider_spawn = list()//landmarks for spawning in raiders and their gear
var/global/list/raider_gear = list()

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.
	var/list/raid_objectives = list()     //Raid objectives

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	required_players = 30
	required_enemies = 3
	recommended_enemies = 6
	votable = 0

	var/win_button_triggered = 0

/datum/game_mode/heist/announce()
	to_chat(world, "<B>The current game mode is - Heist!</B>")
	to_chat(world, "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>")
	to_chat(world, "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!")
	to_chat(world, "<B>Raiders:</B> Loot and burn the station or attempt to reach your goals using more peaceful means. You're not here by accident.")
	to_chat(world, "<B>Personnel:</B> Protect your station and employment.")

/datum/game_mode/heist/can_start()

	if(!..())
		return 0

	var/list/candidates = get_players_for_role(ROLE_RAIDER)
	var/raider_num = 0

	//Check that we have enough raiders.
	if(candidates.len < required_enemies)
		return 0


	raider_num = min(3 + round((num_players()-30)/20), 6)//3 at 30 players, plus 1 per every 20. Not more than 6

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(candidates)
		raiders += new_raider
		candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = SPECIAL_ROLE_RAIDER
	..()
	return 1

/datum/game_mode/heist/pre_setup()
	var/index = 1
	for(var/datum/mind/raider in raiders)
		if(index > raider_spawn.len)
			index = 1
		raider.current.loc = raider_spawn[index]
		make_raider_gear(raider_gear[index])
		index++
	return 1

/datum/game_mode/heist/post_setup()

	//Generate objectives for the group.
	raid_objectives = forge_raider_objectives()

	//Suit up the raider
	for(var/datum/mind/raider in raiders)

		make_raider(raider)
		greet_raider(raider)

		if(raid_objectives)
			raider.objectives = raid_objectives

	return ..()

/datum/game_mode/proc/make_raider(var/datum/mind/newraider)
	var/mob/living/carbon/human/M = newraider.current
	var/datum/preferences/P = new
	P.species = newraider.current.client.prefs.species//raiders KEEP their current species, makes for more interesting stuff
	P.random_character()
	P.copy_to(M)
	M.real_name = M.species.get_random_name(M.gender)//because the species var in prefs is only a string for some reason
	newraider.name = M.real_name
	M.dna.real_name = M.real_name

	M.underwear = "Nude"
	M.undershirt = "Nude"
	M.socks = "Nude"

	// Do the initial caching of the player's body icons. IS THIS REALLY NEEDED
	M.force_update_limbs()
	M.update_dna()
	M.update_eyes()

	M.equip_raider()
	M.rejuvenate()//removes people being stupid and taking limbless, mute and blind characters, also regenrates icons.

/datum/game_mode/heist/proc/make_raider_gear(var/location)
	if(!istype(location, /turf))
		return 0
	if(weapons && weapons.len)
		var/list/lootspawn = pick(weapons)
		weapons -= lootspawn
		if(lootspawn)
			for(var/W in lootspawn)
				new W(location)

	if(space_suits && space_suits.len)
		var/list/lootspawn = pick(space_suits)
		space_suits -= lootspawn
		if(lootspawn)
			for(var/W in lootspawn)
				new W(location)

	new /obj/item/weapon/tank/jetpack/oxygen/harness(location)
	new /obj/item/clothing/mask/breath(location)
	new /obj/item/weapon/storage/belt/military/assault(location)

	new /obj/structure/closet/syndicate(location)

/datum/game_mode/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(!ishuman(raider.current) || raider.current.stat == DEAD)
				return 0
		else
			return 0
	return 1

/datum/game_mode/proc/is_raider_crew_safe()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			var/area/A = get_area(raider.current)
			if(istype(A, /area/shuttle/raider))
				return 1
			if(istype(A, /area/raider_station))
				return 1
	return 0

/datum/game_mode/proc/forge_raider_objectives()
	var/i = 1
	var/list/objs = list()
	var/list/goals = list("kidnap/loot", "kill/loot", "loot", "loot", "loot")//4.6% chance the raiders get no kill/kidnap objs
	while(i <= 4)//4 objectives total
		var/goal = pick(goals)
		var/duplicate_obj = 0//for keeping objectives unique
		var/datum/objective/heist/O

		if(goal == "kidnap/loot")
			if(prob(90))
				O = new /datum/objective/heist/kidnap()
			else
				O = new /datum/objective/heist/loot()
		else if(goal == "kill/loot")
			if(prob(90))
				O = new /datum/objective/heist/assassinate()
			else
				O = new /datum/objective/heist/loot()
		else
			O = new /datum/objective/heist/loot()

		goals -= goal
		O.choose_target()

		for(var/datum/objective/heist/H in objs)
			if(H.target == O.target)//you can compare a string to a mind. Whoah.
				duplicate_obj = 1
				break
		if(duplicate_obj)
			continue//break the whole loop and start over. Without iterating.
			//If there is a massive shortage of targets you'll eventually have four loot objectives

		objs += O
		i++
	return objs

/datum/game_mode/proc/greet_raider(var/datum/mind/raider)
	to_chat(raider.current, "<span class='boldnotice'>You are a Space Pirate, from Tau Ceti!</span>")
	to_chat(raider.current, "<span class='warning'>You've been hired by a certain individual to disrupt the operation of [station_name()]</span>")
	to_chat(raider.current, "<span class='warning'>Stay close to your crewmates and come up with a plan better than getting shot before boarding.</span>")
	to_chat(raider.current, "<span class='warning'>Use :H to talk on your encrypted channel.</span>")
	to_chat(raider.current, "<span class='warning'>Accomplish your objectives either by unleashing chaos upon the station or using diplomatic means. Or both.</span>")
	spawn(25)
		show_objectives(raider)

/datum/game_mode/heist/declare_completion()
	//No objectives, go straight to the feedback.
	if(!(raid_objectives.len)) return ..()
	var/win_msg = ""
	var/win_type = "Major"
	var/win_group = "Crew"
	var/success = raid_objectives.len
	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion())) success--

	//Set result by objectives.
	if(success == raid_objectives.len)
		win_msg = "The Raiders were successful"
		win_group = "Raiders"
	else if(success > 1)
		win_msg = "The Raiders were partially successful"
		win_group = "Raiders"
		win_type = "Minor"
	else
		win_msg = "The Raiders have failed"

	if(!is_raider_crew_alive())
		if(success > 1)
			win_msg += " but "
		else
			win_msg += " and "
		win_msg += "were wiped out."

	else if(!is_raider_crew_safe())
		if(success > 1)
			win_msg += " but "
		else
			win_msg += " and "
		win_msg += "have left someone behind!"

	else

		if(success > 1)
			win_msg += " and escaped the station!"
		else
			win_msg += " and were repelled!"

	to_chat(world, "<span class='revenbignotice'>[win_msg]</span>")
	feedback_set_details("round_end_result","heist - [win_type] [win_group] victory")

	var/count = 1
	for(var/datum/objective/objective in raid_objectives)
		if(objective.check_completion())
			to_chat(world, "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>")
			feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			to_chat(world, "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>")
			feedback_add_details("traitor_objective","[objective.type]|FAIL")
		count++

	..()

datum/game_mode/proc/auto_declare_completion_heist()
	if(raiders.len)
		var/check_return = 0
		if(GAMEMODE_IS_HEIST)
			check_return = 1
		var/text = "<FONT size = 2><B>The Raiders were:</B></FONT>"

		for(var/datum/mind/raider in raiders)
			text += "<br>[raider.key] was [raider.name] ("
			if(check_return)
				if(!istype(get_area(raider.current), /area/shuttle/raider) && !istype(get_area(raider.current), /area/raider_station))
					text += "left behind)"
					continue
			if(raider.current)
				if(raider.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(raider.current.real_name != raider.name)
					text += " as [raider.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		to_chat(world, text)

	return 1

/datum/game_mode/heist/check_finished()
	if(win_button_triggered)
		return 1
	return ..()


/obj/raider/win_button
	name = "contact computer"
	desc = "A black market network uplink. Mostly used for dastardly deeds."//What in the world do I put here so it sounds right?
	icon = 'icons/obj/computer.dmi'
	icon_state = "tcstation"

/obj/raider/win_button/New()
	. = ..()
	overlays += icon('icons/obj/computer.dmi', "syndie")

/obj/raider/win_button/attack_hand(mob/user)
	if(!GAMEMODE_IS_HEIST || (world.time < 10 MINUTES)) //has to be heist, and at least ten minutes into the round
		to_chat(user, "<span class='warning'>\The [src] does not appear to have a connection.</span>")
		return 0

	if(alert(user, "Warning: This will end the round. Are you sure you wish to end the round?", "Raider End", "Yes", "No") == "No")
		return 0

	if(alert(user, "Are you *absolutely* sure you want to end the round?", "!!WARNING!!", "Yes", "No") == "No")
		return 0

	message_admins("[key_name_admin(user)] has pressed the Raider round end button.")
	log_admin("[key_name(user)] pressed the Raider round end button during a raider round.")

	var/datum/game_mode/heist/H = ticker.mode
	H.win_button_triggered = 1

/obj/effect/landmark/raider/raider_start
	name = "raiderstart"

/obj/effect/landmark/raider/raider_gear
	name = "raidergear"
