/datum/event/respawn_salvage
	name = "Respawn Salvage"
	role_weights = list(ASSIGNMENT_CARGO = 4)

/datum/event/respawn_salvage/start()
	var/salvage_to_spawn = rand(8, 16)
	var/list/possible_objects = GLOB.possible_salvage_objects
	while(salvage_to_spawn)
		if(!length(possible_objects))
			break
		var/obj/salvage_obj = pick_n_take(possible_objects)
		if(salvage_obj.has_salvage)
			continue
		salvage_obj.has_salvage = TRUE
		GLOB.salvage_objects += salvage_obj
		salvage_to_spawn--
