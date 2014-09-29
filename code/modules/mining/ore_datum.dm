/datum/ore
	var/oretag
	var/alloy
	var/smelts_to
	var/compresses_to

/datum/ore/uranium
	smelts_to = /obj/item/stack/sheet/mineral/uranium
	oretag = "uranium"

/datum/ore/iron
	smelts_to = /obj/item/stack/sheet/mineral/iron
	alloy = 1
	oretag = "hematite"

/datum/ore/coal
	smelts_to = /obj/item/stack/sheet/mineral/plastic
	alloy = 1
	oretag = "coal"

/datum/ore/glass
	smelts_to = /obj/item/stack/sheet/glass
	compresses_to = /obj/item/stack/sheet/mineral/sandstone
	oretag = "sand"

/datum/ore/plasma
	smelts_to = /obj/item/stack/sheet/mineral/plasma
	oretag = "plasma"

/datum/ore/silver
	smelts_to = /obj/item/stack/sheet/mineral/silver
	oretag = "silver"

/datum/ore/gold
	smelts_to = /obj/item/stack/sheet/mineral/gold
	oretag = "gold"

/datum/ore/diamond
	compresses_to = /obj/item/stack/sheet/mineral/diamond
	oretag = "diamond"

/datum/ore/osmium
	smelts_to = /obj/item/stack/sheet/mineral/platinum
	compresses_to = /obj/item/stack/sheet/mineral/osmium
	alloy = 1
	oretag = "platinum"

/datum/ore/hydrogen
	smelts_to = /obj/item/stack/sheet/mineral/tritium
	compresses_to = /obj/item/stack/sheet/mineral/mhydrogen
	oretag = "hydrogen"

/datum/ore/clown
	smelts_to = /obj/item/stack/sheet/mineral/clown
	oretag = "clown"