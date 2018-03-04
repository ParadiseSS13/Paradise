
//Voidsuits
/obj/item/clothing/head/helmet/space/voidsuit
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in red."
	icon_state = "void-red"
	item_state = "void"
	flags_inv = HIDEMASK|HIDEEARS

/obj/item/clothing/suit/space/voidsuit
	name = "NASA Void Suit"
	icon_state = "void-red"
	item_state = "void"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in red."
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/multitool)

//Colors!!!
/obj/item/clothing/head/helmet/space/voidsuit/green
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in green."
	icon_state = "void-green"

/obj/item/clothing/suit/space/voidsuit/green
	name = "NASA Void Suit"
	icon_state = "void-green"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in green."

/obj/item/clothing/head/helmet/space/voidsuit/ntblue
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in NT colors."
	icon_state = "void-ntblue"

/obj/item/clothing/suit/space/voidsuit/ntblue
	name = "NASA Void Suit"
	icon_state = "void-ntblue"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in NT colors."

/obj/item/clothing/head/helmet/space/voidsuit/purple
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in purple."
	icon_state = "void-purple"

/obj/item/clothing/suit/space/voidsuit/purple
	name = "NASA Void Suit"
	icon_state = "void-purple"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in purple."

/obj/item/clothing/head/helmet/space/voidsuit/yellow
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in yellow."
	icon_state = "void-yellow"

/obj/item/clothing/suit/space/voidsuit/yellow
	name = "NASA Void Suit"
	icon_state = "void-yellow"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in yellow."

/obj/item/clothing/head/helmet/space/voidsuit/ltblue
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in light blue."
	icon_state = "void-light_blue"

/obj/item/clothing/suit/space/voidsuit/ltblue
	name = "NASA Void Suit"
	icon_state = "void-light_blue"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in light blue."

//Captian's Suit, like the other captian's suit, but looks better, at the cost of armor

/obj/item/clothing/head/helmet/space/voidsuit/captian
	name = "Fancy Retro Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is fit for a captian."
	icon_state = "void-captian"

/obj/item/clothing/suit/space/voidsuit/captain
	name = "Fancy NASA Void Suit"
	icon_state = "void-captian"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is fit for a captian."

//Syndi's suit, on par with a blood red softsuit

/obj/item/clothing/head/helmet/space/voidsuit/syndi
	name = "Blood Red Retro Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcom. This one is in blood red."
	icon_state = "void-syndi"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/voidsuit/syndi
	name = "Blood Red NASA Void Suit"
	icon_state = "void-syndi"
	desc = "A retro Space suit designed by a branch at NASA Centcom. This one is in blood red."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

//random spawner

/obj/item/device/voidsuitspawner
	name = "NASA Void Suit Spawner"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "void-red"
	desc = "You shouldn't see this, a spawner for NASE Void Suits."
	var/suits = list("red", "green", "ntblue", "purple", "yellow", "ltblue")
	var/obj/item/clothing/head/helmet/space/voidsuit/H
	var/obj/item/clothing/suit/space/voidsuit/S

/obj/item/device/voidsuitspawner/New()
	var/suit_pick = pick(suits)
	switch(suit_pick)
		if("red")
			H = new /obj/item/clothing/head/helmet/space/voidsuit
			S = new /obj/item/clothing/suit/space/voidsuit
		if("green")
			H = new /obj/item/clothing/head/helmet/space/voidsuit/green
			S = new /obj/item/clothing/suit/space/voidsuit/green
		if("ntblue")
			H = new /obj/item/clothing/head/helmet/space/voidsuit/ntblue
			S = new /obj/item/clothing/suit/space/voidsuit/ntblue
		if("purple")
			H = new /obj/item/clothing/head/helmet/space/voidsuit/purple
			S = new /obj/item/clothing/suit/space/voidsuit/purple
		if("yellow")
			H = new /obj/item/clothing/head/helmet/space/voidsuit/yellow
			S = new /obj/item/clothing/suit/space/voidsuit/yellow
		if("ltblue")
			H = new /obj/item/clothing/head/helmet/space/voidsuit/ltblue
			S = new /obj/item/clothing/suit/space/voidsuit/ltblue
	H.loc = get_turf(src)
	S.loc = get_turf(src)
	qdel(src)