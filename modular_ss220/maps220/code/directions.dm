/* Intercom */
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom, 28, 28)

MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/locked/prison, 28, 28)

/* Nanotrasen WallMed */
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/economy/vending/wallmed/emergency_ntmed, 32, 32)

/* Fire Alarm */
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/firealarm/no_alarm, 24, 24)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/firealarm/syndicate, 24, 24)

/* Light Switch */
/obj/machinery/light_switch
	name = "\improper light switch"

/obj/machinery/light_switch/south
	pixel_y = -24
	dir = 1

/obj/machinery/light_switch/north
	pixel_y = 24

/obj/machinery/light_switch/west
	pixel_x = -24
	dir = 4

/obj/machinery/light_switch/east
	pixel_x = 24
	dir = 8

/obj/machinery/holosign_switch
	name = "\improper holosign switch"

/obj/machinery/holosign_switch/south
	pixel_y = -24
	dir = 1

/obj/machinery/holosign_switch/north
	pixel_y = 24

/obj/machinery/holosign_switch/west
	pixel_x = -24
	dir = 4

/obj/machinery/holosign_switch/east
	pixel_x = 24
	dir = 8

/* Keycard Authentication Device */
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/keycard_auth, 24, 24)

/* Buttons */
/obj/machinery/door_control/bolt_control
	name = "\improper Door Bolt Control"
	normaldoorcontrol = 1
	specialfunctions = 4

/obj/machinery/door_control/bolt_control/south
	pixel_y = -24
	dir = 1

/obj/machinery/door_control/bolt_control/north
	pixel_y = 24

/obj/machinery/door_control/bolt_control/west
	pixel_x = -24
	dir = 4

/obj/machinery/door_control/bolt_control/east
	pixel_x = 24
	dir = 8

/obj/machinery/door_control/normal
	name = "\improper Door Control"
	normaldoorcontrol = 1

/obj/machinery/door_control/normal/south
	pixel_y = -24
	dir = 1

/obj/machinery/door_control/normal/north
	pixel_y = 24

/obj/machinery/door_control/normal/west
	pixel_x = -24
	dir = 4

/obj/machinery/door_control/normal/east
	pixel_x = 24
	dir = 8

/obj/machinery/door_control/shutter
	name = "\improper Shutters Control"

/obj/machinery/door_control/shutter/south
	pixel_y = -24
	dir = 1

/obj/machinery/door_control/shutter/north
	pixel_y = 24

/obj/machinery/door_control/shutter/west
	pixel_x = -24
	dir = 4

/obj/machinery/door_control/shutter/east
	pixel_x = 24
	dir = 8

/obj/machinery/door_control/no_emag
	name = "\improper Door Bolt Control (Secured)"

/obj/machinery/door_control/no_emag/south
	pixel_y = -24
	dir = 1

/obj/machinery/door_control/no_emag/north
	pixel_y = 24

/obj/machinery/door_control/no_emag/west
	pixel_x = -24
	dir = 4

/obj/machinery/door_control/no_emag/east
	pixel_x = 24
	dir = 8

/obj/machinery/button/windowtint
	name = "\improper Window Tint Control"

/obj/machinery/button/windowtint/south
	pixel_y = -24
	dir = 1

/obj/machinery/button/windowtint/north
	pixel_y = 24

/obj/machinery/button/windowtint/west
	pixel_x = -24
	dir = 4

/obj/machinery/button/windowtint/east
	pixel_x = 24
	dir = 8

/* Light Fixtures */
/obj/machinery/light/nightshifted
	nightshift_allowed = FALSE
	nightshift_enabled = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/nightshifted, 0, 0)

/obj/machinery/light/small/nightshifted
	nightshift_allowed = FALSE
	nightshift_enabled = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/nightshifted, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/spot, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/built, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/small/built, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light_construct, 0, 0)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light_construct/small, 0, 0)

/* Extinguisher */
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/extinguisher_cabinet, 32, 32)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/extinguisher_cabinet/empty, 32, 32)

/* Wall Tanks */
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/reagent_dispensers/fueltank/chem, 32, 32)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/reagent_dispensers/virusfood, 32, 32)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/reagent_dispensers/spacecleanertank, 32, 32)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/reagent_dispensers/peppertank, 32, 32)

/* Sinks */
/obj/structure/sink/directional
	name = "\improper sink"

/obj/structure/sink/directional/south
	pixel_y = -4
	dir = 1

/obj/structure/sink/directional/north
	pixel_y = 18

/obj/structure/sink/directional/west
	pixel_x = 12
	dir = 4

/obj/structure/sink/directional/east
	pixel_x = -12
	dir = 8

/obj/structure/sink/kitchen/south
	pixel_y = -4
	dir = 1

/obj/structure/sink/kitchen/north
	pixel_y = 18

/obj/structure/sink/kitchen/west
	pixel_x = -11
	dir = 4

/obj/structure/sink/kitchen/east
	pixel_x = 11
	dir = 8

/* Displays */
/obj/machinery/status_display
	layer = ABOVE_WINDOW_LAYER

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display, 32, 32)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/supply_display, 32, 32)

/obj/machinery/ai_status_display
	layer = ABOVE_WINDOW_LAYER

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/ai_status_display, 32, 32)

/obj/machinery/computer/security/telescreen/entertainment
	layer = ABOVE_WINDOW_LAYER

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/entertainment, 32, 32)

/* Airlock Cycle Button */
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/access_button, 24, 24)
