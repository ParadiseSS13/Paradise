/datum/game_mode/nations/proc/set_nation_name()
	set name = "Rename Nation"
	set category = "Nations"
	set desc = "Click to rename your nation. You are only able to do this once."

	if(!kickoff) return 1

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.mind && H.mind.nation && H.mind.nation.current_leader == H)
			var/input = stripped_input(H,"What do you want to name your nation?", ,"", MAX_NAME_LEN)

			if(input)
				H.mind.nation.current_name = input
				H.mind.nation.update_nation_id()
				H << "You rename your nation to [input]."
				H.verbs -= /datum/game_mode/nations/proc/set_nation_name
				return 1


/datum/game_mode/nations/proc/set_ranks()
	set name = "Set Ranks"
	set category = "Nations"
	set desc = "Click to set a rank for Leaders and Members."

	if(!kickoff) return 1

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.mind && H.mind.nation && H.mind.nation.current_leader == H)
			var/type = input(H, "What rank do you want to change?", "Rename Rank", "") in list("Leader","Member")
			var/input = stripped_input(H,"What rank do you want?", ,"", MAX_NAME_LEN)
			if(input)
				if(type == "Leader")
					H.mind.nation.leader_rank = input
					H.mind.nation.update_nation_id()

				if(type == "Member")
					H.mind.nation.member_rank = input
					H.mind.nation.update_nation_id()
				H << "You changed the [type] rank of your nation to [input]."
				return 1


/datum/nations/proc/update_nation_id()
	for(var/mob/living/carbon/human/M in membership)
		for(var/obj/item/weapon/card/id/I in M.contents)
			if(I.registered_name == M.real_name)
				if(M == current_leader)
					I.name = "[I.registered_name]'s ID Card ([current_name] [leader_rank])"
					I.assignment = "[current_name] [leader_rank]"
				else
					I.name = "[I.registered_name]'s ID Card ([current_name] [member_rank])"
					I.assignment = "[current_name] [member_rank]"

