/////////////////////////////////////////
///////////Janitorial Designs////////////
/////////////////////////////////////////
/datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2500, "$glass" = 200)
	build_path = /obj/item/weapon/mop/advanced
	category = list("Janitorial")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	req_tech = list("magnets" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 1000)
	build_path = /obj/item/weapon/holosign_creator
	category = list("Janitorial")
	
/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$silver" = 150, "$glass" = 3000)
	build_path = /obj/item/device/lightreplacer
	category = list("Janitorial")