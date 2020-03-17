var/global/list/all_cults = list()

/datum/game_mode
	var/list/datum/mind/cult = list()

/proc/iscultist(mob/living/M as mob)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.cult)


/proc/is_convertable_to_cult(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(iscultist(mind.current))
		return TRUE //If they're already in the cult, assume they are convertable
	if(ishuman(mind.current) && (mind.assigned_role in list("Captain", "Chaplain")))
		return FALSE
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(ismindshielded(H)) //mindshield protects against conversions unless removed
			return FALSE
//	if(mind.offstation_role) cant convert offstation roles such as ghost spawns
//		return FALSE Commented out until we can figure out why offstation_role is getting set to TRUE on normal crew
	if(issilicon(mind.current))
		return FALSE //can't convert machines, that's ratvar's thing
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(!iscultist(G.summoner))
			return FALSE //can't convert it unless the owner is converted
	if(isgolem(mind.current))
		return FALSE
	return TRUE

/proc/is_sacrifice_target(datum/mind/mind)
	if(SSticker.mode.name == "cult")
		var/datum/game_mode/cult/cult_mode = SSticker.mode
		if(mind == cult_mode.sacrifice_target)
			return 1
	return 0

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Security Pod Pilot", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Brig Physician", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/datum/mind/sacrifice_target = null
	var/finished = 0


	var/list/objectives = list()

	var/eldergod = 1 //for the summon god objective
	var/demons_summoned = 0

	var/acolytes_needed = 4 //for the survive objective - base number of acolytes, increased by 1 for every 10 players
	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4
	var/acolytes_survived = 0

	var/narsie_condition_cleared = 0	//allows Nar-Sie to be summonned during cult rounds. set to 1 once the cult reaches the second phase.
	var/current_objective = 1	//equals the number of cleared objectives + 1
	var/prenarsie_objectives = 2 //how many objectives at most before the cult gets to summon narsie
	var/list/bloody_floors = list()
	var/spilltarget = 100	//how many floor tiles must be covered in blood to complete the bloodspill objective
	var/convert_target = 0	//how many members the cult needs to reach to complete the convert objective
	var/harvested = 0

	var/list/sacrificed = list()	//contains the mind of the sacrifice target ONCE the sacrifice objective has been completed
	var/mass_convert = 0	//set to 1 if the convert objective has been accomplised once that round
	var/spilled_blood = 0	//set to 1 if the bloodspill objective has been accomplised once that round
	var/max_spilled_blood = 0	//highest quantity of blood covered tiles during the round
	var/bonus = 0	//set to 1 if the cult has completed the bonus (third phase) objective (harvest, hijack, massacre)

	var/harvest_target = 10
	var/massacre_target = 5

	var/escaped_shuttle = 0
	var/escaped_pod = 0
	var/survivors = 0

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentComm-allowed faith they had.</B>")


/datum/game_mode/cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	..()
	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist
		cultist.restricted_roles = restricted_jobs
		cultist.special_role = SPECIAL_ROLE_CULTIST
	..()
	return (cult.len>0)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	acolytes_needed = acolytes_needed + round((num_players_started() / 10))

	if(!summon_spots.len)
		while(summon_spots.len < SUMMON_POSSIBILITIES)
			var/area/summon = pick(return_sorted_areas() - summon_spots)
			if(summon && is_station_level(summon.z) && summon.valid_territory)
				summon_spots += summon

	for(var/datum/mind/cult_mind in cult)
		SEND_SOUND(cult_mind.current, 'sound/ambience/antag/bloodcult.ogg')
		equip_cultist(cult_mind.current)
		cult_mind.current.faction |= "cult"
		var/datum/action/innate/cultcomm/C = new()
		C.Grant(cult_mind.current)
		update_cult_icons_added(cult_mind)
		to_chat(cult_mind.current, "<span class='cultitalic'>You catch a glimpse of the Realm of [SSticker.cultdat.entity_name], [SSticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [SSticker.cultdat.entity_name].</span>")

	first_phase()

	..()


/datum/game_mode/cult/proc/memorize_cult_objectives(datum/mind/cult_mind)
	for(var/obj_count in 1 to objectives.len)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				explanation = "Our knowledge must live on. Make sure at least [acolytes_needed] acolytes escape on the shuttle to spread their work on an another station."
			if("convert")
				explanation = "We must increase our influence before we can summon [SSticker.cultdat.entity_name], Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
			if("bloodspill")
				explanation = "We must prepare this place for [SSticker.cultdat.entity_title1]'s coming. Spill blood and gibs over [spilltarget] floor tiles."
			if("sacrifice")
				if(sacrifice_target)
					explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune and three acolytes to do so."
				else
					explanation = "Free objective."
			if("eldergod")
				explanation = "Summon [SSticker.cultdat.entity_name] by invoking the 'Tear Reality' rune.<b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"
		to_chat(cult_mind.current, "<B>Objective #[obj_count]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"


/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(mob)
	var/obj/item/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(mob, "<span class='danger'>Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.</span>")
	else
		to_chat(mob, "<span class='cult'>You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.</span>")
		mob.update_icons()
		return 1


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if(!istype(cult_mind))
		return 0
	var/datum/game_mode/cult/cult_mode = SSticker.mode
	if(!(cult_mind in cult))
		cult += cult_mind
		cult_mind.current.faction |= "cult"
		var/datum/action/innate/cultcomm/C = new()
		C.Grant(cult_mind.current)
		SEND_SOUND(cult_mind.current, 'sound/ambience/antag/bloodcult.ogg')
		cult_mind.current.create_attack_log("<span class='danger'>Has been converted to the cult!</span>")
		if(jobban_isbanned(cult_mind.current, ROLE_CULTIST) || jobban_isbanned(cult_mind.current, ROLE_SYNDICATE))
			replace_jobbanned_player(cult_mind.current, ROLE_CULTIST)
		update_cult_icons_added(cult_mind)
		cult_mode.memorize_cult_objectives(cult_mind)
		if(GAMEMODE_IS_CULT)
			cult_mode.check_numbers()
		return 1

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		to_chat(cult_mind.current, "<span class='danger'>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</span>")
		cult_mind.current.faction -= "cult"
		cult_mind.memory = ""
		cult_mind.special_role = null
		for(var/datum/action/innate/cultcomm/C in cult_mind.current.actions)
			qdel(C)
		update_cult_icons_removed(cult_mind)
		if(show_message)
			for(var/mob/M in viewers(cult_mind.current))
				to_chat(M, "<FONT size = 3>[cult_mind.current] looks like [cult_mind.current.p_they()] just reverted to [cult_mind.current.p_their()] old faith!</FONT>")


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "hudcultist")


/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

/datum/game_mode/proc/update_cult_comms_added(datum/mind/cult_mind)
	var/datum/action/innate/cultcomm/C = new()
	C.Grant(cult_mind.current)

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs


/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(objectives.Find("slaughter"))
		if(!demons_summoned)
			cult_fail++
	if(objectives.Find("sacrifice"))
		if(sacrifice_target && !(sacrifice_target in sacrificed)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++
	if(objectives.Find("convert"))
		if(cult.len < convert_target)
			cult_fail++
	if(objectives.Find("bloodspill"))
		if(max_spilled_blood < spilltarget)
			cult_fail++

	return cult_fail //if any objectives aren't met, failure


/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if(cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if( is_type_in_list(A, centcom_areas))
				acolytes_survived++
			else if(A == SSshuttle.emergency.areaInstance && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)  //snowflaked into objectives because shitty bay shuttles had areas to auto-determine this
				acolytes_survived++

	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/atom/proc/cult_log(var/message)
	investigate_log(message, "cult")


/datum/game_mode/cult/declare_completion()
	bonus_check()

	if(!check_cult_victory())
		feedback_set_details("round_end_result","cult win - cult win")
		feedback_set("round_end_result",acolytes_survived)
		to_chat(world, "<span class='danger'> <FONT size = 3> The cult wins! It has succeeded in serving its dark masters!</FONT></span>")
	else
		feedback_set_details("round_end_result","cult loss - staff stopped the cult")
		feedback_set("round_end_result",acolytes_survived)
		to_chat(world, "<span class='warning'> <FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	var/text = "<b>Cultists escaped:</b> [acolytes_survived]"

	if(objectives.len)
		text += "<br><b>The cultists' objectives were:</b>"
		for(var/obj_count=1, obj_count <= objectives.len, obj_count++)
			var/explanation
			switch(objectives[obj_count])
				if("survive")
					if(!check_survive())
						explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
					else
						explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <font color='red'>Fail.</font>"
						feedback_add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
				if("sacrifice")
					if(sacrifice_target)
						if(sacrifice_target in sacrificed)
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='green'><B>Success!</B></font>"
							feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
						else if(sacrifice_target && sacrifice_target.current)
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Fail.</font>"
							feedback_add_details("cult_objective","cult_sacrifice|FAIL")
						else
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Fail (Gibbed).</font>"
							feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")
				if("eldergod")
					if(!eldergod)
						explanation = "Summon [SSticker.cultdat.entity_name]. <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_narsie|SUCCESS")
					else
						explanation = "Summon [SSticker.cultdat.entity_name]. <font color='red'>Fail.</font>"
						feedback_add_details("cult_objective","cult_narsie|FAIL")
				if("slaughter")
					if(demons_summoned)
						explanation = "Bring the Slaughter. <span class='greenannounce'>Success!</span>"
						feedback_add_details("cult_objective","cult_demons|SUCCESS")
					else
						explanation = "Bring the Slaughter. <span class='boldannounce'>Fail.</span>"
						feedback_add_details("cult_objective","cult_demons|FAIL")

				if("convert")//convert half the crew
					if(cult.len >= convert_target)
						explanation = "Convert [convert_target] crewmembers ([cult.len] cultists at round end). <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_convertion|SUCCESS")
					else
						explanation = "Convert [convert_target] crewmembers ([cult.len] total cultists). <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_convertion|FAIL")

				if("bloodspill")//cover a large portion of the station in blood
					if(max_spilled_blood >= spilltarget)
						explanation = "Cover [spilltarget] tiles of the station in blood (The peak number of covered tiles was: [max_spilled_blood]). <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_bloodspill|SUCCESS")
					else
						explanation = "Cover [spilltarget] tiles of the station in blood (The peak number of covered tiles was: [max_spilled_blood]). <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_bloodspill|FAIL")

				if("harvest")
					if(harvested > harvest_target)
						explanation = "Offer [harvest_target] humans for [SSticker.cultdat.entity_name]'s first meal of the day. ([harvested] sacrificed) <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_harvest|SUCCESS")
					else
						explanation = "Offer [harvest_target] humans for [SSticker.cultdat.entity_name]'s first meal of the day. ([harvested] sacrificed) <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_harvest|FAIL")

				if("hijack")
					if(!escaped_shuttle)
						explanation = "Do not let a single non-cultist board the Escape Shuttle. ([escaped_shuttle] escaped on the shuttle) ([escaped_pod] escaped on pods) <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_hijack|SUCCESS")
					else
						explanation = "Do not let a single non-cultist board the Escape Shuttle. ([escaped_shuttle] escaped on the shuttle) ([escaped_pod] escaped on pods) <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_hijack|FAIL")

				if("massacre")
					if(survivors < massacre_target)
						explanation = "Massacre the crew until less than [massacre_target] people are left on the station. ([survivors] humans left alive) <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_massacre|SUCCESS")
					else
						explanation = "Massacre the crew until less than [massacre_target] people are left on the station. ([survivors] humans left alive) <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_massacre|FAIL")

			text += "<br><B>Objective #[obj_count]</B>: [explanation]"

	to_chat(world, text)
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_cult()
	if(cult.len || (SSticker && GAMEMODE_IS_CULT))
		var/text = "<FONT size = 2><B>The cultists were:</B></FONT>"
		for(var/datum/mind/cultist in cult)

			text += "<br>[cultist.key] was [cultist.name] ("
			if(cultist.current)
				if(cultist.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(cultist.current.real_name != cultist.name)
					text += " as [cultist.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		to_chat(world, text)
