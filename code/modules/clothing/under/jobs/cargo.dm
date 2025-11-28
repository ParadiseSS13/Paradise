/obj/item/clothing/under/rank/cargo
	icon = 'icons/obj/clothing/under/cargo.dmi'
	worn_icon = 'icons/mob/clothing/under/cargo.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/cargo.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/cargo.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/cargo.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/cargo.dmi'
	)

/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's uniform"
	desc = "It's a brown dress shirt and black slacks worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's skirt"
	desc = "It's a brown dress shirt and black skirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/cargo/qm/dress
	name = "quartermaster's dress"
	desc = "An elegant dress for the style conscious quartermaster."
	icon_state = "qm_dress"

/obj/item/clothing/under/rank/cargo/qm/formal
	name = "quartermaster's formal uniform"
	desc = "A pinstripe suit historically worn by schemers. Perfect for the quartermaster!"
	icon_state = "qm_formal"

/obj/item/clothing/under/rank/cargo/qm/whimsy
	name = "quartermaster's sweater"
	desc = "A snazzy brown sweater vest and black tie. Warms the core in the cold warehouse."
	icon_state = "qm_whimsy"

/obj/item/clothing/under/rank/cargo/qm/turtleneck
	name = "quartermaster's turtleneck"
	desc = "A fancy turtleneck designed to keep the wearer cozy in a cold cargo bay. Due to budget cuts, the material does not offer any external protection."
	icon_state = "qm_turtle"

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "A standard issue jumpsuit for cargo technicians. Snazzy!"
	icon_state = "cargo"

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "A standard issue jumpskirt for cargo technicians. Jazzy!"
	icon_state = "cargo_skirt"

/obj/item/clothing/under/rank/cargo/tech/overalls
	name = "cargo technician's overalls"
	desc = "Protective overalls to keep spills from the warehouse off your legs."
	icon_state = "cargo_overalls"

/obj/item/clothing/under/rank/cargo/tech/delivery
	name = "delivery uniform"
	desc = "It's a jumpsuit worn by the cargo delivery crew."
	icon_state = "delivery"

/obj/item/clothing/under/rank/cargo/miner
	name = "shaft miner's jumpsuit"
	desc = "It's an outdated jumpsuit, designed specifically to withstand the harsh conditions of Lavaland. It is very dirty."
	icon_state = "miner"

/obj/item/clothing/under/rank/cargo/miner/skirt
	name = "shaft miner's jumpskirt"
	desc = "It's an outdated jumpskirt, designed specifically to withstand the harsh conditions of Lavaland while remaining pretty. It is very dirty."
	icon_state = "miner_skirt"

/obj/item/clothing/under/rank/cargo/miner/lavaland
	name = "shaft miner's harshsuit"
	desc = "It's an brown uniform with some padded armour for operating in hazardous environments."
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	icon_state = "explorer"

/obj/item/clothing/under/rank/cargo/miner/lavaland/skirt
	name = "shaft miner's harshskirt"
	desc = "It's an brown uniform with some padded armour for operating in hazardous environments while remaining pretty."
	icon_state = "explorer_skirt"

/obj/item/clothing/under/rank/cargo/miner/lavaland/overalls
	name = "shaft miner's overalls"
	desc = "It's an dark purple turtleneck with a sturdy set of overalls. Sadly, doesn't have any extra pockets to carry some sandwiches. It is very dirty."
	icon_state = "explorer_overalls"

/obj/item/clothing/under/rank/cargo/expedition
	name = "expedition jumpsuit"
	desc = "An armored brown jumpsuit with Nanotrasen markings for identification, and a black safety harness for their space suits."
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	icon_state = "expedition"

/obj/item/clothing/under/rank/cargo/expedition/skirt
	name = "expedition jumpskirt"
	desc = "An armoured brown jumpskirt with Nanotrasen markings for identification, and a black safety harness for their space suits."
	icon_state = "expedition_skirt"

/obj/item/clothing/under/rank/cargo/expedition/overalls
	name = "expedition overalls"
	desc = "A brown set of overalls over a blue turtleneck, designed to protect the wearer from microscopic space debris. Does not protect against larger objects."
	icon_state = "expedition_overalls"

/obj/item/clothing/under/rank/cargo/smith
	name = "smith's jumpsuit"
	desc = "A brown jumpsuit with some extra metal pieces strapped to it. You're not sure why, but the added armor doesn't make you feel any safer..."
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 20)
	icon_state = "smith"

/obj/item/clothing/under/rank/cargo/smith/skirt
	name = "smith's jumpskirt"
	desc = "A brown jumpskirt with some extra metal pieces strapped to it. You're not sure why, but the added armor doesn't make you feel any safer..."
	icon_state = "smith_skirt"

/obj/item/clothing/under/rank/cargo/smith/overalls
	name = "smith's overalls"
	desc = "A brown set of overalls over a black turtleneck, designed with thinner materials to keep the wearer cool in the heat of the forge."
	icon_state = "smith_overalls"
