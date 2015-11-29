/mob/living/carbon/human/proc/set_nation_name()
	set name = "Rename Nation"
	set category = "Nations"
	set desc = "Click to rename your nation. You are only able to do this once."


	var/datum/game_mode/nations/mode = get_nations_mode()
	if (!mode) return 1
	if(!mode.kickoff) return 1

	if(mind && mind.nation && mind.nation.current_leader == src)
		var/input = stripped_input(src,"What do you want to name your nation?", ,"", MAX_NAME_LEN)

		if(input)
			mind.nation.current_name = input
			src << "You rename your nation to [input]."
			verbs -= /mob/living/carbon/human/proc/set_nation_name
			return 1