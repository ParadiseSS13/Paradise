/obj/item/stock_parts/cell/xenoblue
	icon = 'icons/HISPANIA/obj/xenobluecell.dmi'
	icon_state = "xenobluecell"
	item_state = "xenobluecell"
	name = "Xenobluespace power cell"
	desc = "Created using xeno-bluespace technology. Designed by the renowned research director Adam Wolf."
	origin_tech = "powerstorage=7;biotech=4;materials=5; engineering=5;bluespace =5"
	maxcharge = 50000
	materials = list(MAT_GLASS = 800)
	rating = 7
	self_recharge = 1 // Infused slime cores self-recharge, over time
	chargerate = 600

/obj/item/xenobluecellmaker
	icon = 'icons/HISPANIA/obj/xenobluecell.dmi'
	icon_state = "xenobluecellmaker"
	item_state = "xenobluecellmaker"
	name = "Xenobluespace power cell Maker"
	desc = "High-tech porwer cell shell capable of creating a porwer cell that combines Bluespace and Xenobiology technology. has inscribed: -en Honor a Blob Bob, Maestro de la Teleciencia, Sticky Gum, Maestra de la Xenobiologia y a Baldric Chapman, Maestro de la Robotica-"
	origin_tech = "powerstorage=6;biotech=4"
	materials = list(MAT_GLASS = 1000)

/datum/design/xenobluecellmaker
	name = "Xenobluespace power cell Maker"
	desc = "High-tech porwer cell shell capable of creating a porwer cell that combines Bluespace and xenobiology technology."
	id = "xenobluecell"
	req_tech = list("powerstorage" = 7, "materials" = 6, "engineering" = 6, "bluespace" = 6)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1600, MAT_GOLD = 240, MAT_GLASS = 320, MAT_DIAMOND = 320, MAT_TITANIUM = 600, MAT_BLUESPACE = 200)
	construction_time=50
	build_path = /obj/item/xenobluecellmaker
	category = list("Misc","Power")

/datum/crafting_recipe/xenobluespacecell
	name = "Xenobluespace power cell"
	result = /obj/item/stock_parts/cell/xenoblue
	reqs = list(/obj/item/stock_parts/cell/high/slime = 1,
				/obj/item/stock_parts/capacitor/quadratic = 1,
				/obj/item/xenobluecellmaker = 1,
				/obj/item/stock_parts/cell/bluespace = 1,
				/obj/item/stock_parts/micro_laser/quadultra  = 1)
	time = 30
	category = CAT_ROBOT
