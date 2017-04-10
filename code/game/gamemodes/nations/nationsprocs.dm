/mob/living/carbon/human/proc/set_nation_name()
	set name = "Rename Nation"
	set category = "Nations"
	set desc = "Click to rename your nation. You are only able to do this once."

	var/datum/game_mode/nations/mode = get_nations_mode()
	if(!mode) return 1

	if(!mode.kickoff) return 1

	var/mob/living/carbon/human/H = src
	if(H.stat==DEAD) return
	if(H.mind && H.mind.nation && H.mind.nation.current_leader == H)
		var/input = stripped_input(H,"What do you want to name your nation?", ,"", MAX_NAME_LEN)

		if(input)
			H.mind.nation.current_name = input
			H.mind.nation.update_nation_id()
			to_chat(H, "You rename your nation to [input].")
			H.verbs -= /mob/living/carbon/human/proc/set_nation_name
			return 1


/mob/living/carbon/human/proc/set_ranks()
	set name = "Set Ranks"
	set category = "Nations"
	set desc = "Click to set a rank for Leaders and Members."

	var/datum/game_mode/nations/mode = get_nations_mode()
	if(!mode) return 1

	if(!mode.kickoff) return 1

	var/mob/living/carbon/human/H = src
	if(H.stat==DEAD) return
	if(H.mind && H.mind.nation && H.mind.nation.current_leader == H)
		var/type = input(H, "What rank do you want to change?", "Rename Rank", "") in list("Leader", "Heir", "Member")
		var/input = stripped_input(H,"What rank do you want?", ,"", MAX_NAME_LEN)
		if(input)
			if(type == "Leader")
				H.mind.nation.leader_rank = input
			if(type == "Heir")
				H.mind.nation.heir_rank = input
			if(type == "Member")
				H.mind.nation.member_rank = input
			H.mind.nation.update_nation_id()
			to_chat(H, "You changed the [type] rank of your nation to [input].")
			return 1

/mob/living/carbon/human/proc/choose_heir()
	set name = "Choose Heir"
	set category = "Nations"
	set desc = "Click to pick a Heir. Note that the Heir has the ability to take over your role at ANY TIME. Choose carefully."

	var/datum/game_mode/nations/mode = get_nations_mode()
	if(!mode) return 1

	if(!mode.kickoff) return 1

	var/mob/living/carbon/human/H = src
	if(H.stat==DEAD) return
	if(H.mind && H.mind.nation && H.mind.nation.current_leader == H)
		var/heir = input(H, "Who do you wish to make your heir?", "Choose Heir", "") as null|anything in H.mind.nation.membership
		if(heir)
			if(H.mind.nation.heir)
				var/mob/living/carbon/human/oldheir = H.mind.nation.heir
				to_chat(oldheir, "You are no longer the heir to your nation!")
				oldheir.verbs -= /mob/living/carbon/human/proc/takeover
			var/mob/living/carbon/human/newheir = heir
			H.mind.nation.heir = newheir
			newheir.verbs += /mob/living/carbon/human/proc/takeover
			to_chat(newheir, "You have been selected to be the heir to your nation's leadership!")
			to_chat(H, "You have selected [heir] to be your heir!")
			H.mind.nation.update_nation_id()


/mob/living/carbon/human/proc/takeover()
	set name = "Become Leader"
	set category = "Nations"
	set desc = "Click to replace your current nation's leader with yourself."

	var/datum/game_mode/nations/mode = get_nations_mode()
	if(!mode) return 1

	if(!mode.kickoff) return 1

	var/mob/living/carbon/human/H = src
	if(H.stat==DEAD) return
	if(H.mind && H.mind.nation && H.mind.nation.heir == H)
		var/confirmation = input(H, "Are you sure you want to take over leadership?", "Become Leader", "") as null|anything in list("Yes", "No")
		if(confirmation == "Yes")
			var/mob/living/carbon/human/oldleader = H.mind.nation.current_leader
			to_chat(oldleader, "You have been replaced by [H.name] as the leader of [H.mind.nation.current_name]!")
			oldleader.verbs -= /mob/living/carbon/human/proc/set_nation_name
			oldleader.verbs -= /mob/living/carbon/human/proc/set_ranks
			oldleader.verbs -= /mob/living/carbon/human/proc/choose_heir
			H.mind.nation.current_leader = H
			H.mind.nation.heir = null
			H.verbs -= /mob/living/carbon/human/proc/takeover
			H.verbs += /mob/living/carbon/human/proc/set_nation_name
			H.verbs += /mob/living/carbon/human/proc/set_ranks
			H.verbs += /mob/living/carbon/human/proc/choose_heir
			to_chat(H, "You have replaced [oldleader.name] as the leader of [H.mind.nation.current_name]!")
			H.mind.nation.update_nation_id()


/datum/nations/proc/update_nation_id()
	for(var/mob/living/carbon/human/M in membership)
		for(var/obj/item/weapon/card/id/I in M.contents)
			if(I.registered_name == M.real_name)
				if(M == current_leader)
					I.name = "[I.registered_name]'s ID Card ([current_name] [leader_rank])"
					I.assignment = "[current_name] [leader_rank]"
				else if(M == heir)
					I.name = "[I.registered_name]'s ID Card ([current_name] [heir_rank])"
					I.assignment = "[current_name] [heir_rank]"
				else
					I.name = "[I.registered_name]'s ID Card ([current_name] [member_rank])"
					I.assignment = "[current_name] [member_rank]"

