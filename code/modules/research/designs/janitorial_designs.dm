/////////////////////////////////////////
///////////Janitorial Designs////////////
/////////////////////////////////////////
/datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/mop/advanced
	category = list("Janitorial")

/datum/design/blutrash
	name = "Trash Bag of Holding"
	desc = "An advanced trash bag that uses experimental Bluespace technology to send stored trash to a specialized pocket dimension."
	id = "blutrash"
	req_tech = list("materials" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PLASMA = 1500)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list("Janitorial")

/datum/design/holosign
	name = "Janitorial Holographic Sign Projector"
	desc = "A holograpic projector used to project wet warning signs."
	id = "holosign"
	req_tech = list("programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/holosign_creator/janitor
	category = list("Janitorial")

/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working light bulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 3000)
	build_path = /obj/item/lightreplacer
	category = list("Janitorial")

/datum/design/light_replacer_bluespace
	name = "Bluespace Light Replacer"
	desc = "A device to automatically replace lights from a distance. Refill with working light bulbs."
	id = "light_replacer_bluespace"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 6, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 6000, MAT_BLUESPACE = 300)
	build_path = /obj/item/lightreplacer/bluespace
	category = list("Janitorial")

/datum/design/abductor_mop
	name = "Alien Mop"
	desc = "An advanced mop obtained through Abductor technology."
	id = "alien_mop"
	req_tech = list("materials" = 5, "engineering" = 5, "abductor" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500, MAT_DIAMOND = 1000)
	build_path = /obj/item/mop/advanced/abductor
	category = list("Janitorial")

/datum/design/abductor_light_replacer
	name = "Alien Light Replacer"
	desc = "An advanced light replacer obtained through Abductor technology."
	id = "alien_light_replacer"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 5, "abductor" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500, MAT_DIAMOND = 1000)
	build_path = /obj/item/lightreplacer/bluespace/abductor
	category = list("Janitorial")

/datum/design/abductor_flyswatter
	name = "Alien Flyswatter"
	desc = "An advanced flyswatter obtained through Abductor technology."
	id = "alien_flyswatter"
	req_tech = list("combat" = 5, "abductor" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500, MAT_DIAMOND = 1000)
	build_path = /obj/item/melee/flyswatter/abductor
	category = list("Janitorial")
