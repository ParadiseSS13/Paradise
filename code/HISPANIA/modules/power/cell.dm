/obj/item/stock_parts/cell/xenoblue
	icon = 'icons/HISPANIA/obj/power.dmi'
	icon_state = "xenobluecell"
	item_state = "xenobluecell"
	name = "Xenobluespace power cell"
	desc = "Created using xeno-bluespace technology. Designed by the renowned research director Adam Wolf."
	origin_tech = "powerstorage=6;biotech=4;materials=5; engineering=5;bluespace =5"
	maxcharge = 50000
	materials = list(MAT_GLASS = 800)
	rating = 7
	self_recharge = 1 // Infused slime cores self-recharge, over time
	chargerate = 600

/obj/item/xenobluecellmaker
	icon = 'icons/HISPANIA/obj/power.dmi'
	icon_state = "xenobluecellmaker"
	item_state = "xenobluecellmaker"
	name = "Xenobluespace power cell Maker"
	desc = "High-tech power cell shell capable of creating a power cell that combines Bluespace and Xenobiology technology. has inscribed: -en Honor a Blob Bob, Maestro de la Teleciencia, Sticky Gum, Maestra de la Xenobiologia y a Baldric Chapman, Maestro de la Robotica-"
	origin_tech = "powerstorage=6;biotech=4"
	materials = list(MAT_GLASS = 1000)

