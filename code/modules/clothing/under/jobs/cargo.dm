/obj/item/clothing/under/rank/cargo
	icon = 'icons/obj/clothing/under/cargo.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/cargo.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/cargo.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/cargo.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/cargo.dmi'
		)


/obj/item/clothing/under/rank/cargo/quartermaster
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	item_color = "qm"

/obj/item/clothing/under/rank/cargo/deliveryboy
	name = "delivery boy uniform"
	desc = "It's a jumpsuit worn by the cargo delivery boy."
	icon_state = "delivery"
	item_state = "lb_suit"
	item_color = "delivery"

/obj/item/clothing/under/rank/cargo/quartermaster/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qmf"
	item_color = "qmf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	item_color = "cargo"

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skirrrrrts! They're comfy and easy to wear!"
	icon_state = "cargof"
	item_color = "cargof"

/obj/item/clothing/under/rank/cargo/miner
	name = "shaft miner's jumpsuit"
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	icon_state = "miner"
	item_state = "miner"
	item_color = "miner"

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"

/obj/item/clothing/under/rank/cargo/expedition
	name = "expedition jumpsuit"
	desc = "An armored brown jumpsuit with Nanotrasen markings for identification, and a black safety harness for their space suits."
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	icon_state = "expedition"
	item_state = "expedition"
	item_color = "expedition"

/obj/item/clothing/under/rank/cargo/expedition/overalls
	name = "expedition overalls"
	desc = "A black set of overalls over a brown turtleneck, designed to protect the wearer from microscopic space debris. Does not protect against larger objects."
	icon_state = "expedition_overalls"
	item_state = "expedition_overalls"
	item_color = "expedition_overalls"
