/obj/item/smithed_item/component/trim
	name = "Debug trim"
	icon_state = "trim"
	desc = "Debug smithed component part of any smithed item. If you see this, notify the development team."
	part_type = PART_TRIM

/obj/item/smithed_item/component/trim/Initialize(mapload)
	. = ..()
	if((material == /datum/smith_material/uranium || istype(material, /datum/smith_material/uranium)) && quality)
		var/datum/component/inherent_radioactivity/radioactivity = AddComponent(/datum/component/inherent_radioactivity, 50 * quality.stat_mult, 0, 0, 1.5)
		START_PROCESSING(SSradiation, radioactivity)

/obj/item/smithed_item/component/trim/set_name()
	if(!quality)
		return
	name = "[quality.name] " + name
	return

/obj/item/smithed_item/component/trim/metal
	name = "metal trim"
	desc = "Smithed component of any smithing item. Made of metal."
	materials = list(MAT_METAL = 10000)
	material = /datum/smith_material/metal

/obj/item/smithed_item/component/trim/silver
	name = "silver trim"
	desc = "Smithed component of any smithing item. Made of silver."
	materials = list(MAT_SILVER = 10000)
	material = /datum/smith_material/silver

/obj/item/smithed_item/component/trim/gold
	name = "gold trim"
	desc = "Smithed component of any smithing item. Made of gold."
	materials = list(MAT_GOLD = 10000)
	material = /datum/smith_material/gold

/obj/item/smithed_item/component/trim/plasma
	name = "plasma trim"
	desc = "Smithed component of any smithing item. Made of solid plasma."
	materials = list(MAT_PLASMA = 10000)
	material = /datum/smith_material/plasma

/obj/item/smithed_item/component/trim/titanium
	name = "titanium trim"
	desc = "Smithed component of any smithing item. Made of titanium."
	materials = list(MAT_TITANIUM = 10000)
	material = /datum/smith_material/titanium

/obj/item/smithed_item/component/trim/uranium
	name = "uranium trim"
	desc = "Smithed component of any smithing item. Made of uranium."
	materials = list(MAT_URANIUM = 10000)
	material = /datum/smith_material/uranium

/obj/item/smithed_item/component/trim/diamond
	name = "diamond trim"
	desc = "Smithed component of any smithing item. Made of diamond."
	materials = list(MAT_DIAMOND = 10000)
	material = /datum/smith_material/diamond

/obj/item/smithed_item/component/trim/bluespace
	name = "bluespace trim"
	desc = "Smithed component of any smithing item. Made of bluespace crystals."
	materials = list(MAT_BLUESPACE = 10000)
	material = /datum/smith_material/bluespace

/obj/item/smithed_item/component/trim/plasteel
	name = "plasteel trim"
	desc = "Smithed component of any smithing item. Made of plasteel."
	materials = list(MAT_METAL = 10000, MAT_PLASMA = 10000)
	material = /datum/smith_material/plasteel

/obj/item/smithed_item/component/trim/plastitanium
	name = "plastitanium trim"
	desc = "Smithed component of any smithing item. Made of plastitanium."
	materials = list(MAT_TITANIUM = 10000, MAT_PLASMA = 10000)
	material = /datum/smith_material/plastitanium

/obj/item/smithed_item/component/trim/iridium
	name = "iridium trim"
	desc = "Smithed component of any smithing item. Made of iridium."
	materials = list(MAT_IRIDIUM = 10000)
	material = /datum/smith_material/iridium

/obj/item/smithed_item/component/trim/palladium
	name = "palladium trim"
	desc = "Smithed component of any smithing item. Made of palladium."
	materials = list(MAT_PALLADIUM = 10000)
	material = /datum/smith_material/palladium

/obj/item/smithed_item/component/trim/platinum
	name = "platinum trim"
	desc = "Smithed component of any smithing item. Made of platinum."
	materials = list(MAT_PLATINUM = 10000)
	material = /datum/smith_material/platinum

/obj/item/smithed_item/component/trim/brass
	name = "brass trim"
	desc = "Smithed component of any smithing item. Made of brass."
	materials = list(MAT_BRASS = 10000)
	material = /datum/smith_material/brass
