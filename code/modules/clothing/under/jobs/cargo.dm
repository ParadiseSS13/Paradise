/obj/item/clothing/under/rank/cargo
	icon = 'icons/obj/clothing/under/cargo.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/cargo.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/cargo.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/cargo.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/cargo.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/cargo.dmi'
		)


/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "qm"
	item_color = "qm"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	item_state = "qm_skirt"
	item_color = "qm_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/cargo/qm/dress
	name = "quartermaster's dress uniform"
	desc = "An elegant dress for the style conscious quartermaster."
	icon_state = "qm_dress"
	item_state = "qm_dress"
	item_color = "qm_dress"

/obj/item/clothing/under/rank/cargo/qm/formal
	name = "quartermaster's formal uniform"
	desc = "A pinstripe suit historically worn by schemers. Perfect for the quartermaster!"
	icon_state = "qm_formal"
	item_state = "qm_formal"
	item_color = "qm_formal"

/obj/item/clothing/under/rank/cargo/qm/whimsy
	name = "quartermaster's sweater"
	desc = "A snazzy brown sweater vest and black tie. Warms the core in the cold warehouse."
	icon_state = "qm_whimsy"
	item_state = "qm_whimsy"
	item_color = "qm_whimsy"

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "A standard issue jumpsuit for cargo technicians. Snazzy!"
	icon_state = "cargo"
	item_state = "cargo"
	item_color = "cargo"

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "A standard issue jumpskirt for cargo technicians. Jazzy!"
	icon_state = "cargo_skirt"
	item_state = "cargo_skirt"
	item_color = "cargo_skirt"

/obj/item/clothing/under/rank/cargo/tech/overalls
	name = "cargo technician's overalls"
	desc = "Protective overalls to keep spills from the warehouse off your legs."
	icon_state = "cargo_overalls"
	item_state = "cargo_overalls"
	item_color = "cargo_overalls"

/obj/item/clothing/under/rank/cargo/tech/delivery
	name = "delivery uniform"
	desc = "It's a jumpsuit worn by the cargo delivery crew."
	icon_state = "delivery"
	item_state = "delivery"
	item_color = "delivery"

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

/obj/item/clothing/under/rank/cargo/expedition/skirt
	name = "expedition jumpskirt"
	desc = "An armoured brown jumpskirt with Nanotrasen markings for identification, and a black safety harness for their space suits."
	icon_state = "expedition_skirt"
	item_state = "expedition_skirt"
	item_color = "expedition_skirt"

/obj/item/clothing/under/rank/cargo/expedition/overalls
	name = "expedition overalls"
	desc = "A black set of overalls over a brown turtleneck, designed to protect the wearer from microscopic space debris. Does not protect against larger objects."
	icon_state = "expedition_overalls"
	item_state = "expedition_overalls"
	item_color = "expedition_overalls"
