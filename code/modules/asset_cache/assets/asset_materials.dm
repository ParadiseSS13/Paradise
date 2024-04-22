/datum/asset/spritesheet/materials
	name = "materials"

/datum/asset/spritesheet/materials/create_spritesheets()
	for(var/datum/material/material_typepath as anything in subtypesof(/datum/material))
		var/obj/item/stack/stack_type = initial(material_typepath.sheet_type)
		if(!stack_type)
			continue

		Insert(material_typepath.id, stack_type.icon, stack_type.icon_state)
