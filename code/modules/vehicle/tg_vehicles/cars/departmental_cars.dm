/obj/tgvehicle/sealed/car/fax_mobile
	name = "fax mobile"
	desc = "The long arm of the legal team meets the road."
	icon_state = "fax_mobile"
	key_type = /obj/item/stamp/law
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, RAD = 0, FIRE = 80, ACID = 80)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/fax_mobile/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/forklift
	name = "forklift"
	desc = "Are you certified?"
	icon_state = "engineering_pod"
	key_type = /obj/item/stamp/granted
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 100, FIRE = 100, ACID = 80)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/forklift/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/engineering_pod
	name = "engineering pod"
	desc = "A state of the art pod featuring an experimental nuclear engine."
	icon_state = "engineering_pod"
	key_type = /obj/item/nuclear_rod/moderator/heavy_water
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 100, FIRE = 100, ACID = 80)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/engineering_pod/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/command_caddy
	name = "command caddy"
	desc = "Ride in style with fashionable leather seats, reinforced chassis, and a classic V8 internal-combustion engine."
	icon_state = "wizmobile"
	key_type = /obj/item/multitool/command
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 60, RAD = 40, FIRE = 80, ACID = 80)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/command_caddy/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/anomalous_auto
	name = "anomalous automobile"
	desc = "Experimental science, to go where there are no roads."
	icon_state = "fax_mobile"
	key_type = /obj/item/assembly/signaler/anomaly
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 30, BULLET = 20, LASER = 60, ENERGY = 60, BOMB = 95, RAD = 30, FIRE = 90, ACID = 90)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/anomalous_auto/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/docwagon
	name = "doctor wagon"
	desc = "Injured patients coming through!"
	icon_state = "docwagon"
	key_type = /obj/item/reagent_containers/hypospray
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	trailer = /obj/structure/bed/amb_trolley
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 70, FIRE = 70, ACID = 70)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/docwagon/Initialize(mapload)
	. = ..()
	trailer = new(get_step(src, NORTH))

/obj/tgvehicle/sealed/car/docwagon/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/sealed/car/mobile_brig
	name = "mobile brig"
	desc = "...Who gave the security team a tank?"
	icon_state = "fax_mobile"
	key_type = /obj/item/melee/baton
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, RAD = 0, FIRE = 80, ACID = 80)
	access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/tgvehicle/sealed/car/mobile_brig/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
