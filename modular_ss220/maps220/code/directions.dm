/* Intercom */
/obj/item/radio/intercom/directional
	name = "\improper station intercom"

/obj/item/radio/intercom/directional/south
	pixel_y = -22
	dir = 1

/obj/item/radio/intercom/directional/north
	pixel_y = 22

/obj/item/radio/intercom/directional/west
	pixel_x = -22
	dir = 4

/obj/item/radio/intercom/directional/east
	pixel_x = 22
	dir = 8

/* Nanotrasen WallMed */
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/economy/vending/wallmed/emergency_ntmed, 32, 32)

/* Fire Alarm */
// TODO: Cringe dirs, should be fixed in .dmi
/obj/machinery/firealarm/directional/south
	dir = 1

/obj/machinery/firealarm/directional/north
	dir = 2

/obj/machinery/firealarm/no_alarm/directional/south
	dir = 1

/obj/machinery/firealarm/no_alarm/directional/north
	dir = 2

/obj/machinery/firealarm/syndicate/directional/south
	dir = 1

/obj/machinery/firealarm/syndicate/directional/north
	dir = 2

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
/obj/machinery/keycard_auth
	name = "\improper Keycard Authentication Device"

/obj/machinery/keycard_auth/south
	pixel_y = -24
	dir = 1

/obj/machinery/keycard_auth/north
	pixel_y = 24

/obj/machinery/keycard_auth/west
	pixel_x = -24
	dir = 4

/obj/machinery/keycard_auth/east
	pixel_x = 24
	dir = 8

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
/obj/machinery/light/directional
	name = "\improper light fixture"

/obj/machinery/light/directional/north
	dir = 1

/obj/machinery/light/directional/south

/obj/machinery/light/directional/east
	dir = 4

/obj/machinery/light/directional/west
	dir = 8

/obj/machinery/light/nightshifted
	name = "\improper light fixture"
	nightshift_allowed = FALSE
	nightshift_enabled = TRUE

/obj/machinery/light/nightshifted/north
	dir = 1

/obj/machinery/light/nightshifted/south

/obj/machinery/light/nightshifted/east
	dir = 4

/obj/machinery/light/nightshifted/west
	dir = 8

/obj/machinery/light/built
	name = "\improper light fixture"

/obj/machinery/light/built/north
	dir = 1

/obj/machinery/light/built/south

/obj/machinery/light/built/east
	dir = 4

/obj/machinery/light/built/west
	dir = 8

/obj/machinery/light/small/directional
	name = "\improper light fixture"

/obj/machinery/light/small/directional/north
	dir = 1

/obj/machinery/light/small/directional/south

/obj/machinery/light/small/directional/east
	dir = 4

/obj/machinery/light/small/directional/west
	dir = 8

/obj/machinery/light/small/nightshifted
	name = "\improper light fixture"
	nightshift_allowed = FALSE
	nightshift_enabled = TRUE

/obj/machinery/light/small/nightshifted/north
	dir = 1

/obj/machinery/light/small/nightshifted/south

/obj/machinery/light/small/nightshifted/east
	dir = 4

/obj/machinery/light/small/nightshifted/west
	dir = 8

/obj/machinery/light/small/built
	name = "\improper light fixture"

/obj/machinery/light/small/built/north
	dir = 1

/obj/machinery/light/small/built/south

/obj/machinery/light/small/built/east
	dir = 4

/obj/machinery/light/small/built/west
	dir = 8

/obj/machinery/light_construct/directional
	name = "\improper light fixture frame"

/obj/machinery/light_construct/directional/north
	dir = 1

/obj/machinery/light_construct/directional/south

/obj/machinery/light_construct/directional/east
	dir = 4

/obj/machinery/light_construct/directional/west
	dir = 8

/obj/machinery/light_construct/small/north
	dir = 1

/obj/machinery/light_construct/small/south

/obj/machinery/light_construct/small/east
	dir = 4

/obj/machinery/light_construct/small/west
	dir = 8

/* Extinguisher */
/obj/structure/extinguisher_cabinet/directional
	name = "\improper extinguisher cabinet"

/obj/structure/extinguisher_cabinet/directional/south
	pixel_y = -32
	dir = 1

/obj/structure/extinguisher_cabinet/directional/north
	pixel_y = 32

/obj/structure/extinguisher_cabinet/directional/west
	pixel_x = -24
	dir = 4

/obj/structure/extinguisher_cabinet/directional/east
	pixel_x = 24
	dir = 8

/obj/structure/extinguisher_cabinet/empty/south
	pixel_y = -32
	dir = 1

/obj/structure/extinguisher_cabinet/empty/north
	pixel_y = 32

/obj/structure/extinguisher_cabinet/empty/west
	pixel_x = -24
	dir = 4

/obj/structure/extinguisher_cabinet/empty/east
	pixel_x = 24
	dir = 8

/* Wall Tanks */
/obj/structure/reagent_dispensers/fueltank/chem
	name = "\improper fuel tank"

/obj/structure/reagent_dispensers/fueltank/chem/south
	pixel_y = -32
	dir = 1

/obj/structure/reagent_dispensers/fueltank/chem/north
	pixel_y = 32

/obj/structure/reagent_dispensers/fueltank/chem/west
	pixel_x = -32
	dir = 4

/obj/structure/reagent_dispensers/fueltank/chem/east
	pixel_x = 32
	dir = 8

/obj/structure/reagent_dispensers/virusfood
	name = "\improper virus food dispenser"

/obj/structure/reagent_dispensers/virusfood/south
	pixel_y = -32
	dir = 1

/obj/structure/reagent_dispensers/virusfood/north
	pixel_y = 32

/obj/structure/reagent_dispensers/virusfood/west
	pixel_x = -32
	dir = 4

/obj/structure/reagent_dispensers/virusfood/east
	pixel_x = 32
	dir = 8

/obj/structure/reagent_dispensers/spacecleanertank
	name = "\improper space cleaner refiller"

/obj/structure/reagent_dispensers/spacecleanertank/south
	pixel_y = -32
	dir = 1

/obj/structure/reagent_dispensers/spacecleanertank/north
	pixel_y = 32

/obj/structure/reagent_dispensers/spacecleanertank/west
	pixel_x = -32
	dir = 4

/obj/structure/reagent_dispensers/spacecleanertank/east
	pixel_x = 32
	dir = 8

/obj/structure/reagent_dispensers/peppertank
	name = "\improper pepper spray refiller"

/obj/structure/reagent_dispensers/peppertank/south
	pixel_y = -32
	dir = 1

/obj/structure/reagent_dispensers/peppertank/north
	pixel_y = 32

/obj/structure/reagent_dispensers/peppertank/west
	pixel_x = -32
	dir = 4

/obj/structure/reagent_dispensers/peppertank/east
	pixel_x = 32
	dir = 8

/* NewsCaster */
/obj/machinery/newscaster/directional
	name = "\improper newscaster"

/obj/machinery/newscaster/directional/south
	pixel_y = -28
	dir = 1

/obj/machinery/newscaster/directional/north
	pixel_y = 28

/obj/machinery/newscaster/directional/west
	pixel_x = -28
	dir = 4

/obj/machinery/newscaster/directional/east
	pixel_x = 28
	dir = 8

/obj/machinery/newscaster/security_unit
	name = "\improper security newscaster"

/obj/machinery/newscaster/security_unit/south
	pixel_y = -28
	dir = 1

/obj/machinery/newscaster/security_unit/north
	pixel_y = 28

/obj/machinery/newscaster/security_unit/west
	pixel_x = -28
	dir = 4

/obj/machinery/newscaster/security_unit/east
	pixel_x = 28
	dir = 8

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

/* Posters */
/obj/structure/sign/poster/random/south
	pixel_y = -32

/obj/structure/sign/poster/random/north
	pixel_y = 32

/obj/structure/sign/poster/random/west
	pixel_x = -32

/obj/structure/sign/poster/random/east
	pixel_x = 32

/obj/structure/sign/poster/contraband/random/south
	pixel_y = -32

/obj/structure/sign/poster/contraband/random/north
	pixel_y = 32

/obj/structure/sign/poster/contraband/random/west
	pixel_x = -32

/obj/structure/sign/poster/contraband/random/east
	pixel_x = 32

/obj/structure/sign/poster/official/random/south
	pixel_y = -32

/obj/structure/sign/poster/official/random/north
	pixel_y = 32

/obj/structure/sign/poster/official/random/west
	pixel_x = -32

/obj/structure/sign/poster/official/random/east
	pixel_x = 32

/* Displays */
/obj/machinery/status_display/directional
	name = "\improper status display"
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/status_display/directional/south
	pixel_y = -32

/obj/machinery/status_display/directional/north
	pixel_y = 32

/obj/machinery/status_display/directional/west
	pixel_x = -32

/obj/machinery/status_display/directional/east
	pixel_x = 32

/obj/machinery/status_display/supply_display/south
	pixel_y = -32

/obj/machinery/status_display/supply_display/north
	pixel_y = 32

/obj/machinery/status_display/supply_display/west
	pixel_x = -32

/obj/machinery/status_display/supply_display/east
	pixel_x = 32

/obj/machinery/ai_status_display
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/ai_status_display/south
	pixel_y = -32

/obj/machinery/ai_status_display/north
	pixel_y = 32

/obj/machinery/ai_status_display/west
	pixel_x = -32

/obj/machinery/ai_status_display/east
	pixel_x = 32

/obj/machinery/computer/security/telescreen/entertainment/directional
	name = "\improper entertainment monitor"
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/computer/security/telescreen/entertainment/directional/south
	pixel_y = -32

/obj/machinery/computer/security/telescreen/entertainment/directional/north
	pixel_y = 32

/obj/machinery/computer/security/telescreen/entertainment/directional/west
	pixel_x = -32

/obj/machinery/computer/security/telescreen/entertainment/directional/east
	pixel_x = 32

/* Airlock Cycle Button */
/obj/machinery/access_button/south
	pixel_y = -24

/obj/machinery/access_button/north
	pixel_y = 24

/obj/machinery/access_button/west
	pixel_x = -24

/obj/machinery/access_button/east
	pixel_x = 24
