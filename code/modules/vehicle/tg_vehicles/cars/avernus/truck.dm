/obj/tgvehicle/sealed/car/truck
	name = "truck"
	icon = 'icons/tgmc/objects/vehicles/64x64.dmi'
	icon_state = "truck"

	var/list/droppable_item_types

/obj/tgvehicle/sealed/car/truck/Initialize(mapload)
	. = ..()
	droppable_item_types = typecacheof(list(
		// maybe lockers too? idk
		/obj/structure/closet/body_bag,
		/obj/structure/closet/crate,
		/obj/structure/big_delivery,
	))

/obj/tgvehicle/sealed/car/truck/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/garage_door, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/truck/MouseDrop_T(atom/movable/dropped, mob/living/user)
	. = ..()

	if(!is_type_in_typecache(dropped, droppable_item_types))
		return

	if(!do_after_once(user, (3 SECONDS), TRUE, dropped))
		return

	dropped.forceMove(src)
	dropped.vis_flags |= VIS_INHERIT_LAYER
	update_visual_cargo()
	vis_contents += dropped

/obj/tgvehicle/sealed/car/truck/proc/update_visual_cargo()
	for(var/atom/movable/content in contents)
		if(is_type_in_typecache(content, droppable_item_types))
			switch(dir)
				if(SOUTH)
					content.pixel_x = 16
					content.pixel_y = 30
				if(NORTH)
					content.pixel_x = 16
					content.pixel_y = 20
				if(EAST)
					content.pixel_x = 8
					content.pixel_y = 25
				if(WEST)
					content.pixel_x = 24
					content.pixel_y = 28

/obj/tgvehicle/sealed/car/truck/setDir(newdir)
	. = ..()
	update_visual_cargo()
