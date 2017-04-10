//Regular syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	desc = "Top secret Spess Helmet."
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "Has a tag: Totally not property of an enemy corporation, honest."
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/syndicate
	name = "red space suit"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "Has a tag on it: Totally not property of of a hostile corporation, honest!"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)


//Green syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/green
	name = "Green Space Helmet"
	icon_state = "syndicate-helm-green"
	item_state = "syndicate-helm-green"

/obj/item/clothing/suit/space/syndicate/green
	name = "Green Space Suit"
	icon_state = "syndicate-green"
	item_state = "syndicate-green"


//Dark green syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/green/dark
	name = "Dark Green Space Helmet"
	icon_state = "syndicate-helm-green-dark"
	item_state = "syndicate-helm-green-dark"

/obj/item/clothing/suit/space/syndicate/green/dark
	name = "Dark Green Space Suit"
	icon_state = "syndicate-green-dark"
	item_state = "syndicate-green-dark"


//Orange syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/orange
	name = "Orange Space Helmet"
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"

/obj/item/clothing/suit/space/syndicate/orange
	name = "Orange Space Suit"
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"


//Blue syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/blue
	name = "Blue Space Helmet"
	icon_state = "syndicate-helm-blue"
	item_state = "syndicate-helm-blue"

/obj/item/clothing/suit/space/syndicate/blue
	name = "Blue Space Suit"
	icon_state = "syndicate-blue"
	item_state = "syndicate-blue"


//Black syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black"
	item_state = "syndicate-helm-black"

obj/item/clothing/head/helmet/space/syndicate/black/strike
	name = "Syndicate Strike Team commando helmet"
	desc = "A heavily armored black helmet that is only given to high-ranking Syndicate operatives."
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1

/obj/item/clothing/suit/space/syndicate/black
	name = "Black Space Suit"
	icon_state = "syndicate-black"
	item_state = "syndicate-black"

obj/item/clothing/suit/space/syndicate/black/strike
	name = "Syndicate Strike Team commando space suit"
	desc = "A heavily armored, black space suit that is only given to high-ranking Syndicate operatives."
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1

//Black-green syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/green
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-green"
	item_state = "syndicate-helm-black-green"

/obj/item/clothing/suit/space/syndicate/black/green
	name = "Black and Green Space Suit"
	icon_state = "syndicate-black-green"
	item_state = "syndicate-black-green"


//Black-blue syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/blue
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-blue"
	item_state = "syndicate-helm-black-blue"

/obj/item/clothing/suit/space/syndicate/black/blue
	name = "Black and Blue Space Suit"
	icon_state = "syndicate-black-blue"
	item_state = "syndicate-black-blue"


//Black medical syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/med
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-med"
	item_state = "syndicate-helm-black"

/obj/item/clothing/suit/space/syndicate/black/med
	name = "Green Space Suit"
	icon_state = "syndicate-black-med"
	item_state = "syndicate-black"


//Black-orange syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/orange
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-orange"
	item_state = "syndicate-helm-black"

/obj/item/clothing/suit/space/syndicate/black/orange
	name = "Black and Orange Space Suit"
	icon_state = "syndicate-black-orange"
	item_state = "syndicate-black"


//Black-red syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/red
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"

obj/item/clothing/head/helmet/space/syndicate/black/red/strike
	name = "Syndicate Strike Team leader helmet"
	desc = "A heavily armored, black and red space helmet that is only given to elite Syndicate operatives, it looks particularly menacing."
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1

/obj/item/clothing/suit/space/syndicate/black/red
	name = "Black and Red Space Suit"
	icon_state = "syndicate-black-red"
	item_state = "syndicate-black-red"

obj/item/clothing/suit/space/syndicate/black/red/strike
	name = "Syndicate Strike Team leader space suit"
	desc = "A heavily armored, black and red space suit that is only given to elite Syndicate operatives, it looks particularly menacing."
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100) //Matches DS gear.
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1


//Black with yellow/red engineering syndicate space suit
/obj/item/clothing/head/helmet/space/syndicate/black/engie
	name = "Black Space Helmet"
	icon_state = "syndicate-helm-black-engie"
	item_state = "syndicate-helm-black"

/obj/item/clothing/suit/space/syndicate/black/engie
	name = "Black Engineering Space Suit"
	icon_state = "syndicate-black-engie"
	item_state = "syndicate-black"