/obj/item/storage/firstaid/freegolem
	name = "golem emergency treatment kit"
	desc = "A box of essential medical supplies, formulated for golems' hard skin."
	icon_state = "firstaid_freegolem"
	inhand_icon_state = "firstaid_freegolem"

/obj/item/storage/firstaid/freegolem/populate_contents()
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/patch/styptic/small(src)
	new /obj/item/reagent_containers/patch/styptic/small(src)
	new /obj/item/reagent_containers/patch/silver_sulf/small(src)
	new /obj/item/reagent_containers/patch/silver_sulf/small(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)

/obj/structure/closet/freegolem
	name = "free golem equipment locker"
	icon_state = "freegolem"

/obj/structure/closet/freegolem/populate_contents()
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/card/id/golem(src)
	new /obj/item/flashlight/lantern(src)
	new /obj/item/resonator/upgraded(src)
	new /obj/item/storage/firstaid/freegolem(src)

/**
  * # Ore Redemption Machine (Golem)
  *
  * Golem variant of the ORM.
  */
/obj/machinery/mineral/ore_redemption/golem
	req_access = list(ACCESS_FREE_GOLEMS)
	req_access_claim = ACCESS_FREE_GOLEMS

/obj/machinery/mineral/ore_redemption/golem/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/golem/RefreshParts()
	var/P = 0.65
	var/S = 0.65
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		P += 0.35 * M.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		S += 0.35 * M.rating
		// Manipulators do nothing
	// Update our values
	point_upgrade = P
	sheet_per_ore = S
	SStgui.update_uis(src)

/**********************Mining Equiment Vendor (Golem)**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"

/obj/machinery/mineral/equipment_vendor/golem/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

	desc += "\nIt seems a few selections have been added."
	prize_list["Extra"] += list(
		EQUIPMENT("Free Golem ID", /obj/item/card/id/golem, 250),
		EQUIPMENT("Science Backpack", /obj/item/storage/backpack/science, 250),
		EQUIPMENT("Full Toolbelt", /obj/item/storage/belt/utility/full/multitool, 250),
		EQUIPMENT("Monkey Cube", /obj/item/food/monkeycube, 250),
		EQUIPMENT("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 500),
		EQUIPMENT("Grey Slime Extract", /obj/item/slime_extract/grey, 1000),
		EQUIPMENT("KA Trigger Modification Kit", /obj/item/borg/upgrade/modkit/trigger_guard, 1000),
		EQUIPMENT("Shuttle Console Board", /obj/item/circuitboard/shuttle/golem_ship, 2000),
		EQUIPMENT("The Liberator's Legacy", /obj/item/storage/box/rndboards, 2000),
		EQUIPMENT("The Liberator's Fabricator", /obj/item/storage/box/smithboards, 1000),
	)

/// Free golem blueprints, like permit but can claim as much as needed.
/obj/item/areaeditor/golem
	name = "Golem Land Claim"
	desc = "Used to define new areas in space."
	fluffnotice = "Praise the Liberator!"

/obj/item/areaeditor/golem/attack_self__legacy__attackchain(mob/user)
	. = ..()
	var/area/our_area = get_area(src)
	if(get_area_type() == AREA_STATION)
		. += "<p>According to [src], you are now in <b>\"[sanitize(our_area.name)]\"</b>.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(usr, "blueprints")

/obj/item/disk/design_disk/golem_shell
	name = "golem creation disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"

/obj/item/disk/design_disk/golem_shell/Initialize(mapload)
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprint = G

/obj/machinery/computer/shuttle/golem_ship
	name = "Golem Ship Console"
	desc = "Used to control the Golem Ship."
	circuit = /obj/item/circuitboard/shuttle/golem_ship
	shuttleId = "freegolem"
	possible_destinations = "freegolem_lavaland;freegolem_space;freegolem_ussp"

/obj/machinery/computer/shuttle/golem_ship/attack_hand(mob/user)
	if(!isgolem(user) && !isobserver(user))
		to_chat(user, "<span class='notice'>The console is unresponsive. Seems only golems can use it.</span>")
		return
	..()

/obj/machinery/computer/shuttle/golem_ship/recall
	name = "golem ship recall terminal"
	desc = "Used to recall the Golem Ship."
	possible_destinations = "freegolem_lavaland"
	resistance_flags = INDESTRUCTIBLE

#define FREE_GOLEM_SHIP_WIDTH 18
#define FREE_GOLEM_SHIP_HEIGHT 19

/obj/docking_port/mobile/free_golem
	name = "Free Golem Ship"
	dir = 8
	id = "freegolem"
	dwidth = FREE_GOLEM_SHIP_WIDTH / 2
	height = FREE_GOLEM_SHIP_HEIGHT
	width = FREE_GOLEM_SHIP_WIDTH
	preferred_direction = WEST
	port_direction = SOUTH

/obj/docking_port/stationary/golem
	dir = 8
	height = FREE_GOLEM_SHIP_HEIGHT
	width = FREE_GOLEM_SHIP_WIDTH
	dwidth = FREE_GOLEM_SHIP_WIDTH / 2

/obj/docking_port/stationary/golem/space
	name = "The middle of space"
	id = "freegolem_space"

/obj/docking_port/stationary/golem/ussp
	name = "Near USSP Station"
	id = "freegolem_ussp"

/obj/docking_port/stationary/golem/lavaland
	name = "Lavaland Surface"
	id = "freegolem_lavaland"
	area_type = /area/ruin/powered/golem_ship
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface

#undef FREE_GOLEM_SHIP_WIDTH
#undef FREE_GOLEM_SHIP_HEIGHT
