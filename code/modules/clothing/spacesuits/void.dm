
//Voidsuits
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in red."
	icon_state = "void-red"
	item_state = "void"
	flags_inv = HIDEMASK|HIDEEARS

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Void Suit"
	icon_state = "void-red"
	item_state = "void"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in red."
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/multitool)

//Colors!!!
/obj/item/clothing/head/helmet/space/nasavoid/green
	icon_state = "void-green"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in green."

/obj/item/clothing/suit/space/nasavoid/green
	icon_state = "void-green"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in green."

/obj/item/clothing/head/helmet/space/nasavoid/ntblue
	icon_state = "void-ntblue"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in NT colors."

/obj/item/clothing/suit/space/nasavoid/ntblue
	icon_state = "void-ntblue"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in NT colors."

/obj/item/clothing/head/helmet/space/nasavoid/purple
	icon_state = "void-purple"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in purple."

/obj/item/clothing/suit/space/nasavoid/purple
	icon_state = "void-purple"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in purple."

/obj/item/clothing/head/helmet/space/nasavoid/yellow
	icon_state = "void-yellow"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in yellow."

/obj/item/clothing/suit/space/nasavoid/yellow
	icon_state = "void-yellow"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in yellow."

/obj/item/clothing/head/helmet/space/nasavoid/ltblue
	icon_state = "void-light_blue"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in light blue."

/obj/item/clothing/suit/space/nasavoid/ltblue
	icon_state = "void-light_blue"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in light blue."

//Captian's Suit, like the other captian's suit, but looks better, at the cost of armor

/obj/item/clothing/head/helmet/space/nasavoid/captain
	name = "Fancy Retro Void Helmet"
	icon_state = "void-captian"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is fit for a captain."

/obj/item/clothing/suit/space/nasavoid/captain
	name = "Fancy NASA Void Suit"
	icon_state = "void-captian"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is fit for a captain."

//Syndi's suit, on par with a blood red softsuit

/obj/item/clothing/head/helmet/space/nasavoid/syndi
	name = "Blood Red Retro Void Helmet"
	icon_state = "void-syndi"
	desc = "A retro space suit helmet designed by a branch at NASA Centcomm. This one is in blood red."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/nasavoid/syndi
	name = "Blood Red NASA Void Suit"
	icon_state = "void-syndi"
	desc = "A retro Space suit designed by a branch at NASA Centcomm. This one is in blood red."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)

//random spawner

/obj/effect/nasavoidsuitspawner
	name = "NASA Void Suit Spawner"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "void-red"
	desc = "You shouldn't see this, a spawner for NASA Void Suits."
	var/suits = list("red", "green", "ntblue", "purple", "yellow", "ltblue")
	var/obj/item/clothing/head/helmet/space/nasavoid/H
	var/obj/item/clothing/suit/space/nasavoid/S

/obj/effect/nasavoidsuitspawner/New()
	var/suit_pick = pick(suits)
	switch(suit_pick)
		if("red")
			H = new /obj/item/clothing/head/helmet/space/nasavoid
			S = new /obj/item/clothing/suit/space/nasavoid
		if("green")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/green
			S = new /obj/item/clothing/suit/space/nasavoid/green
		if("ntblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ntblue
			S = new /obj/item/clothing/suit/space/nasavoid/ntblue
		if("purple")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/purple
			S = new /obj/item/clothing/suit/space/nasavoid/purple
		if("yellow")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/yellow
			S = new /obj/item/clothing/suit/space/nasavoid/yellow
		if("ltblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ltblue
			S = new /obj/item/clothing/suit/space/nasavoid/ltblue
	S.loc = get_turf(src)
	H.loc = get_turf(src)
	qdel(src)