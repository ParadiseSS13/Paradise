//Items

/obj/item/bedsheet/rd/royal_cape
	name = "Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("mining", "stone", "a golem", "freedom", "doing whatever")

/obj/item/storage/box/rndboards
	name = "the Liberator's legacy"
	desc = "A box containing a gift for worthy golems."

/obj/item/storage/box/rndboards/New()
	..()
	contents = list()
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole(src)

/obj/item/areaeditor/golem
	name = "golem land claim"
	desc = "Used to define new areas in space or on an asteroid."
	fluffnotice = "Praise the Liberator!"

/obj/item/areaeditor/golem/attack_self(mob/user)
	. = ..()
	var/area/A = get_area()
	if(get_area_type() == AREA_STATION)
		. += "<p>According to the [src], you are now in <b>\"[sanitize(A.name)]\"</b>.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(usr, "blueprints")

/obj/item/disk/design_disk/golem_shell
	name = "golem creation disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"
	max_blueprints = 1

/obj/item/disk/design_disk/golem_shell/Initialize()
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprints[1] = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")


//Structures

//Areas

/area/shuttle/freegolem
	name = "Free Golem Ship"
	icon_state = "purple"

/area/mine/dangerous/explored/golem
	name = "Small Asteroid"

