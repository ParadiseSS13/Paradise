/*
VOX HEIST ROUNDTYPE
*/

var/global/list/raider_spawn = list()
var/global/list/obj/cortical_stacks = list() //Stacks for 'leave nobody behind' objective. Clumsy, rewrite sometime.

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.
	var/list/raid_objectives = list()     //Raid objectives

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	required_players = 25
	required_enemies = 4
	recommended_enemies = 5
	votable = 0

	var/list/obj/cortical_stacks = list() //Stacks for 'leave nobody behind' objective.
	var/win_button_triggered = 0

/datum/game_mode/heist/announce()
	to_chat(world, "<B>The current game mode is - Heist!</B>")
	to_chat(world, "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>")
	to_chat(world, "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!")
	to_chat(world, "<B>Raiders:</B> Loot [station_name()] for anything and everything you need, or choose the peaceful route and attempt to trade with them.")
	to_chat(world, "<B>Personnel:</B> Trade with the raiders, or repel them and their low, low prices and/or crossbows.")

/datum/game_mode/heist/can_start()

	if(!..())
		return 0

	var/list/candidates = get_players_for_role(ROLE_RAIDER)
	var/raider_num = 0

	//Check that we have enough vox.
	if(candidates.len < required_enemies)
		return 0
	else if(candidates.len < recommended_enemies)
		raider_num = candidates.len
	else
		raider_num = recommended_enemies

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(candidates)
		raiders += new_raider
		candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = SPECIAL_ROLE_RAIDER
		raider.special_role = SPECIAL_ROLE_RAIDER
		raider.offstation_role = TRUE
	..()
	return 1

/datum/game_mode/heist/pre_setup()
	return 1

/datum/game_mode/heist/post_setup()

	//Generate objectives for the group.
	raid_objectives = forge_vox_objectives()

	var/index = 1

	//Spawn the vox!
	for(var/datum/mind/raider in raiders)

		if(index > raider_spawn.len)
			index = 1

		raider.current.loc = raider_spawn[index]
		index++

		create_vox(raider)
		greet_vox(raider)

		if(raid_objectives)
			raider.objectives = raid_objectives

	return ..()

/datum/game_mode/proc/create_vox(var/datum/mind/newraider)

	var/sounds = rand(2,8)
	var/i = 0
	var/newname = ""

	while(i<=sounds)
		i++
		newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))

	var/mob/living/carbon/human/vox = newraider.current
	var/obj/item/organ/external/head/head_organ = vox.get_organ("head")

	vox.real_name = capitalize(newname)
	vox.dna.real_name = vox.real_name
	vox.name = vox.real_name
	newraider.name = vox.name
	vox.age = rand(12,20)
	vox.set_species(/datum/species/vox)
	vox.s_tone = rand(1, 6)
	vox.languages = list() // Removing language from chargen.
	vox.flavor_text = ""
	vox.add_language("Vox-pidgin")
	vox.add_language("Galactic Common")
	vox.add_language("Tradeband")
	head_organ.h_style = "Short Vox Quills"
	head_organ.f_style = "Shaved"
	vox.change_hair_color(97, 79, 25) //Same as the species default colour.
	vox.change_eye_color(rand(1, 255), rand(1, 255), rand(1, 255))
	vox.underwear = "Nude"
	vox.undershirt = "Nude"
	vox.socks = "Nude"

	// Do the initial caching of the player's body icons.
	vox.force_update_limbs()
	vox.update_dna()
	vox.update_eyes()

	for(var/obj/item/organ/external/limb in vox.bodyparts)
		limb.status &= ~ORGAN_ROBOT

	//Now apply cortical stack.
	var/obj/item/implant/cortical/I = new(vox)
	I.implant(vox)
	cortical_stacks += I

	vox.equip_vox_raider()
	vox.regenerate_icons()

/datum/game_mode/proc/is_raider_crew_safe()
	if(cortical_stacks.len == 0)
		return 0

	for(var/obj/stack in cortical_stacks)
		if(get_area(stack) != locate(/area/shuttle/vox) && get_area(stack) != locate(/area/vox_station))
			return 0 //this is stupid as fuck
	return 1

/datum/game_mode/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(istype(raider.current,/mob/living/carbon/human) && raider.current.stat != DEAD)
				return 1
	return 0

/datum/game_mode/proc/forge_vox_objectives()
	var/i = 1
	var/max_objectives = pick(2,2,2,2,3,3,3,4)
	var/list/objs = list()
	var/list/goals = list("kidnap","loot","salvage")
	while(i<= max_objectives)
		var/goal = pick(goals)
		var/datum/objective/heist/O

		if(goal == "kidnap")
			goals -= "kidnap"
			O = new /datum/objective/heist/kidnap()
		else if(goal == "loot")
			O = new /datum/objective/heist/loot()
		else
			O = new /datum/objective/heist/salvage()
		O.choose_target()
		objs += O

		i++

	//-All- vox raids have these two objectives. Failing them loses the game.
	objs += new /datum/objective/heist/inviolate_crew
	objs += new /datum/objective/heist/inviolate_death

	return objs

/datum/game_mode/proc/greet_vox(var/datum/mind/raider)
	to_chat(raider.current, "<span class='boldnotice'>You are a Vox Raider, fresh from the Shoal!</span>")
	to_chat(raider.current, "<span class='notice'>The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to the frontier and much of the unexplored galaxy. You and the crew have come to the [station_name()] for plunder, trade or both.</span>")
	to_chat(raider.current, "<span class='notice'>Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.</span>")
	to_chat(raider.current, "<span class='notice'>Use :V to voxtalk, :H to talk on your encrypted channel, and don't forget to turn on your nitrogen internals!</span>")
	to_chat(raider.current, "<span class='notice'>Choose to accomplish your objectives by either raiding the crew and taking what you need, or by attempting to trade with them.</span>")
	spawn(25)
		show_objectives(raider)

/datum/game_mode/heist/declare_completion()
	//No objectives, go straight to the feedback.
	if(!(raid_objectives.len)) return ..()

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = raid_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion())) success--

	//Set result by objectives.
	if(success == raid_objectives.len)
		win_type = "Major"
		win_group = "Vox"
	else if(success > 2)
		win_type = "Minor"
		win_group = "Vox"
	else
		win_type = "Minor"
		win_group = "Crew"

	//Now we modify that result by the state of the vox crew.
	if(!is_raider_crew_alive())

		win_type = "Major"
		win_group = "Crew"
		win_msg += "<B>The Vox Raiders have been wiped out!</B>"

	else if(!is_raider_crew_safe())

		if(win_group == "Crew" && win_type == "Minor")
			win_type = "Major"

		win_group = "Crew"
		win_msg += "<B>The Vox Raiders have left someone behind!</B>"

	else

		if(win_group == "Vox")
			if(win_type == "Minor")

				win_type = "Major"
			win_msg += "<B>The Vox Raiders escaped the station!</B>"
		else
			win_msg += "<B>The Vox Raiders were repelled!</B>"

	to_chat(world, "<span class='warning'><FONT size = 3><B>[win_type] [win_group] victory!</B></FONT></span>")
	to_chat(world, "[win_msg]")
	feedback_set_details("round_end_result","heist - [win_type] [win_group]")

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
		var/text = "<FONT size = 2><B>The Vox raiders were:</B></FONT>"

		for(var/datum/mind/vox in raiders)
			text += "<br>[vox.key] was [vox.name] ("
			if(check_return)
				var/obj/stack = raiders[vox]
				if(get_area(stack.loc) != locate(/area/shuttle/vox))
					text += "left behind)"
					continue
			if(vox.current)
				if(vox.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vox.current.real_name != vox.name)
					text += " as [vox.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		to_chat(world, text)

	return 1

/datum/game_mode/heist/check_finished()
	if(!(is_raider_crew_alive()))
		return 1
	if(win_button_triggered)
		return 1
	return ..()


/obj/vox/win_button
	name = "shoal contact computer"
	desc = "Used to contact the Vox Shoal, generally to arrange for pickup."
	icon = 'icons/obj/computer.dmi'
	icon_state = "tcstation"

/obj/vox/win_button/New()
	. = ..()
	overlays += icon('icons/obj/computer.dmi', "syndie")

/obj/vox/win_button/attack_hand(mob/user)
	if(!GAMEMODE_IS_HEIST || (world.time < 10 MINUTES)) //has to be heist, and at least ten minutes into the round
		to_chat(user, "<span class='warning'>\The [src] does not appear to have a connection.</span>")
		return 0

	if(alert(user, "Warning: This will end the round. Are you sure you wish to end the round?", "Vox End", "Yes", "No") == "No")
		return 0

	if(alert(user, "Are you *absolutely* sure you want to end the round?", "!!WARNING!!", "Yes", "No") == "No")
		return 0

	message_admins("[key_name_admin(user)] has pressed the vox win button.")
	log_admin("[key_name(user)] pressed the vox win button during a vox round.")

	var/datum/game_mode/heist/H = ticker.mode
	H.win_button_triggered = 1
