/obj/tgvehicle/sealed/car/engineering_pod
	name = "engineering pod"
	desc = "A state of the art pod featuring an experimental nuclear engine."
	icon_state = "engineering_pod"
	key_type = /obj/item/nuclear_rod/moderator/heavy_water
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 100, FIRE = 100, ACID = 80)

/obj/tgvehicle/sealed/car/engineering_pod/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/mobile_brig
	name = "mobile brig"
	desc = "...Who gave the security team a tank?"
	icon_state = "sec_tank"
	key_type = /obj/item/melee/baton
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, RAD = 0, FIRE = 80, ACID = 80)

/obj/tgvehicle/sealed/car/mobile_brig/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
