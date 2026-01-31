/obj/tgvehicle/department
	name = "department vehicle"
	desc = ABSTRACT_TYPE_DESC
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'

/obj/tgvehicle/department/Initialize(mapload)
	. = ..()
	make_ridable()

/obj/tgvehicle/department/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/departmental)

/obj/tgvehicle/department/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)

/obj/tgvehicle/department/fax_mobile
	name = "fax mobile"
	desc = "The long arm of the legal team meets the road."
	icon_state = "fax_mobile"
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, RAD = 0, FIRE = 80, ACID = 80)

/obj/tgvehicle/department/cargo_engine
	name = "cargo engine"
	desc = "Are you certified to drive this?"
	icon_state = "cargo_engine"
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 100, FIRE = 100, ACID = 80)

/obj/tgvehicle/department/command_caddy
	name = "command caddy"
	desc = "Ride in style with fashionable leather seats, reinforced chassis, and a classic V8 internal-combustion engine."
	icon_state = "wizmobile"
	armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 60, RAD = 40, FIRE = 80, ACID = 80)

/obj/tgvehicle/department/anomalous_auto
	name = "anomalous automobile"
	desc = "Experimental science, to go where there are no roads."
	icon_state = "soutomobile"
	armor = list(MELEE = 30, BULLET = 20, LASER = 60, ENERGY = 60, BOMB = 95, RAD = 30, FIRE = 90, ACID = 90)

/obj/tgvehicle/department/docwagon
	name = "mediwagon"
	desc = "Injured patients coming through!"
	icon_state = "docwagon"
	trailer = /obj/structure/bed/amb_trolley
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, RAD = 70, FIRE = 70, ACID = 70)

/obj/tgvehicle/department/docwagon/Initialize(mapload)
	. = ..()
	trailer = new(get_step(src.loc, NORTH))
