//Regular syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	desc = "A suspicious-looking space helmet. It is reinforced with a layer of armour."
	icon_state = "syndicate"
	inhand_icon_state = "space_helmet_syndicate"
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 200, ACID = 285)
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_SYNDICATE_HELMET
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
	)

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	inhand_icon_state = "space_suit_syndicate"
	desc = "A suspicious-looking space suit. The fabric is reinforced with a blend of nomex and kevlar for added protection."
	w_class = WEIGHT_CLASS_NORMAL
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_SYNDICATE_SUIT
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs,/obj/item/tank/internals)
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 200, ACID = 285)
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
	)

//Green syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/green
	name = "green space helmet"
	icon_state = "syndicate-helm-green"
	inhand_icon_state = "syndicate-helm-green"

/obj/item/clothing/suit/space/syndicate/green
	name = "green space suit"
	icon_state = "syndicate-green"
	inhand_icon_state = "syndicate-green"

//Dark green syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/green/dark
	name = "dark green space helmet"
	icon_state = "syndicate-helm-green-dark"
	inhand_icon_state = "syndicate-helm-green-dark"

/obj/item/clothing/suit/space/syndicate/green/dark
	name = "dark green space suit"
	icon_state = "syndicate-green-dark"
	inhand_icon_state = "syndicate-green-dark"

//Orange syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/orange
	name = "orange space helmet"
	icon_state = "syndicate-helm-orange"
	inhand_icon_state = "helm-orange"

/obj/item/clothing/suit/space/syndicate/orange
	name = "orange space suit"
	icon_state = "syndicate-orange"
	inhand_icon_state = "syndicate-orange"

//Blue syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/blue
	name = "blue space helmet"
	icon_state = "syndicate-helm-blue"
	inhand_icon_state = "helm-command"

/obj/item/clothing/suit/space/syndicate/blue
	name = "blue space suit"
	icon_state = "syndicate-blue"
	inhand_icon_state = "syndicate-blue"

//Black syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black
	name = "black space helmet"
	icon_state = "syndicate-helm-black"
	inhand_icon_state = "syndicate-helm-black"

/obj/item/clothing/head/helmet/space/syndicate/black/strike
	name = "Syndicate Strike Team commando helmet"
	desc = "A heavily armored black helmet that is only given to high-ranking Syndicate operatives."
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2

/obj/item/clothing/suit/space/syndicate/black
	name = "black space suit"
	icon_state = "syndicate-black"
	inhand_icon_state = "syndicate-black"

/obj/item/clothing/suit/space/syndicate/black/strike
	name = "Syndicate Strike Team commando space suit"
	desc = "A heavily armored, black space suit that is only given to high-ranking Syndicate operatives."
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2

//Black-green syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/green
	icon_state = "syndicate-helm-black-green"
	inhand_icon_state = "syndicate-helm-black-green"

/obj/item/clothing/suit/space/syndicate/black/green
	name = "black and green space suit"
	icon_state = "syndicate-black-green"
	inhand_icon_state = "syndicate-black-green"

//Black-blue syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/blue
	icon_state = "syndicate-helm-black-blue"
	inhand_icon_state = "syndicate-helm-black-blue"

/obj/item/clothing/suit/space/syndicate/black/blue
	name = "black and blue space suit"
	icon_state = "syndicate-black-blue"
	inhand_icon_state = "syndicate-black-blue"

//Black medical syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/med
	icon_state = "syndicate-helm-black-med"

/obj/item/clothing/suit/space/syndicate/black/med
	name = "green space suit"
	icon_state = "syndicate-black-med"

//Black-orange syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/orange
	icon_state = "syndicate-helm-black-orange"

/obj/item/clothing/suit/space/syndicate/black/orange
	name = "black and orange space suit"
	icon_state = "syndicate-black-orange"

//Black-red syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/red
	icon_state = "syndicate-helm-black-red"
	inhand_icon_state = "syndicate-helm-black-red"

/obj/item/clothing/head/helmet/space/syndicate/black/red/strike
	name = "Syndicate Strike Team leader helmet"
	desc = "A heavily armored, black and red space helmet that is only given to elite Syndicate operatives, it looks particularly menacing."
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2

/obj/item/clothing/suit/space/syndicate/black/red
	name = "black and red space suit"
	icon_state = "syndicate-black-red"
	inhand_icon_state = "syndicate-black-red"

/obj/item/clothing/suit/space/syndicate/black/red/strike
	name = "Syndicate Strike Team leader space suit"
	desc = "A heavily armored, black and red space suit that is only given to elite Syndicate operatives, it looks particularly menacing."
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2

//Black with yellow/red engineering syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/engie
	icon_state = "syndicate-helm-black-engie"

/obj/item/clothing/suit/space/syndicate/black/engie
	name = "black engineering space suit"
	icon_state = "syndicate-black-engie"

/obj/item/clothing/head/helmet/space/syndicate/contractor
	name = "contractor helmet"
	desc = "A specialised black and gold helmet that's more compact than its standard Syndicate counterpart. It is made of an exotic military-grade fabric for added protection, and can be ultra-compressed into even the tightest of spaces."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "syndicate-helm-contractor"
	inhand_icon_state = "syndicate-helm-contractor"

/obj/item/clothing/suit/space/syndicate/contractor
	name = "contractor space suit"
	desc = "A specialised black and gold space suit that's easier to move around in than its standard Syndicate counterpart. It is made of an exotic military-grade fabric for added protection, and can be ultra-compressed into even the tightest of spaces."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "syndicate-contractor"
	inhand_icon_state = "syndicate-contractor"
