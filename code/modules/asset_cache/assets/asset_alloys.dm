/datum/asset/spritesheet/alloys
	name = "alloys"

/datum/asset/spritesheet/alloys/create_spritesheets()
	for(var/datum/design/smelter/alloy_typepath as anything in subtypesof(/datum/design/smelter) + /datum/design/rglass)
		var/obj/item/stack/stack_type = initial(alloy_typepath.build_path)
		if(!stack_type)
			continue

		Insert(alloy_typepath.id, stack_type.icon, stack_type.icon_state)
