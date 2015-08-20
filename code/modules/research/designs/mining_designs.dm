/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 1000, "$diamond" = 3750) //Yes, a whole diamond is needed.
	reliability_base = 79
	build_path = /obj/item/weapon/pickaxe/drill/diamonddrill
	category = list("Mining")

/datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."
	id = "pick_diamond"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 3000)
	build_path = /obj/item/weapon/pickaxe/diamond
	category = list("Mining")

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 6000, "$glass" = 1000)
	build_path = /obj/item/weapon/pickaxe/drill
	category = list("Mining")

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 2, "plasmatech" = 2, "engineering" = 2, "combat" = 1, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$glass" = 500, "$gold" = 500, "$plasma" = 500)
	reliability_base = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter
	category = list("Mining")

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	id = "plasmacutter_adv"
	req_tech = list("materials" = 4, "plasmatech" = 3, "engineering" = 3, "combat" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 1000, "$plasma" = 2000, "$gold" = 500)
	reliability_base = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter/adv
	category = list("Mining")

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Essentially a handheld planet-cracker. Can drill through walls with ease as well."
	id = "jackhammer"
	req_tech = list("materials" = 6, "powerstorage" = 6, "engineering" = 5, "magnets" = 6)
	build_type = PROTOLATHE
	materials = list("$metal" = 8000, "$glass" = 1500, "$silver" = 2000, "$diamond" = 6000)
	build_path = /obj/item/weapon/pickaxe/drill/jackhammer
	category = list("Mining")
