/obj/item/stock_parts/cell/bluespace/xenoblue
	name = "Xenobluespace power cell"
	desc = "Creada mediante tecnologia xeno-bluespace, ideada por el renombrado RD Adam Wolf."
	origin_tech = "powerstorage=6;biotech=4"
	icon_state = "bscell"
	maxcharge = 50000
	materials = list(MAT_GLASS = 800)
	rating = 7
	self_recharge = 1 // Infused slime cores self-recharge, over time
	chargerate = 600

/obj/item/xenobluecellmaker
	name = "Xenobluespace power cell Maker"
	desc = "Tiene inscrito -en Honor a Blob Bob, Maestro de la Teleciencia, Sticky Gum, Maestra de la Xenobiologia y en Baldric Champman, Maestro de la Robotica-"
	origin_tech = "powerstorage=6;biotech=4"
	icon_state = "bscell"
	materials = list(MAT_GLASS = 1000)

/datum/design/xenobluecellmaker
	name = "Xenobluespace power cell Maker"
	desc = "Cascara de alta tecnologia capaz de crear la una bateria que combina la tecnologia Bluespace y la Xenobiologia"
	id = "xenobluecell"
	req_tech = list("powerstorage" = 7, "materials" = 6, "engineering" = 6, "bluespace" = 6)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1600, MAT_GOLD = 240, MAT_GLASS = 320, MAT_DIAMOND = 320, MAT_TITANIUM = 600, MAT_BLUESPACE = 200)
	construction_time=50
	build_path = /obj/item/xenobluecellmaker
	category = list("Misc","Power")

/datum/crafting_recipe/xenobluespacecell
	name = "Xenobluespace power cell"
	result = /obj/item/stock_parts/cell/bluespace/xenoblue
	reqs = list(/obj/item/stock_parts/cell/high/slime = 1,
				/obj/item/stock_parts/capacitor/quadratic = 1,
				/obj/item/xenobluecellmaker = 1,
				/obj/item/stock_parts/cell/bluespace = 1,
				/obj/item/stock_parts/micro_laser/quadultra  = 1)
	tools = list(/obj/item/screwdriver)
	time = 40
	category = CAT_MISC
