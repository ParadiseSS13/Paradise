/obj/tgvehicle/speedbike
	name = "Speedbike"
	desc = "A futuristic and incredibly fast hovering bike with a small thruster on the back."
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/cover_iconstate = "cover_blue"

/obj/tgvehicle/speedbike/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, cover_iconstate, ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)

/obj/tgvehicle/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc)
	. = ..()

/obj/tgvehicle/speedbike/red
	icon_state = "speedbike_red"
	cover_iconstate = "cover_red"

/datum/component/riding/vehicle/speedbike
	vehicle_move_delay = 1
	override_allow_spacemove = TRUE
	ride_check_flags = RIDER_NEEDS_LEGS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/speedbike/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, -8), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-10, 5), TEXT_WEST = list(10, 5)))
	set_vehicle_dir_offsets(NORTH, -16, -16)
	set_vehicle_dir_offsets(SOUTH, -16, -16)
	set_vehicle_dir_offsets(EAST, -18, 0)
	set_vehicle_dir_offsets(WEST, -18, 0)

/datum/component/riding/vehicle/speedbike/on_rider_try_pull(mob/living/rider_pulling, atom/movable/target, force)
	return
