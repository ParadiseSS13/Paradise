
//Voidsuits
/obj/item/clothing/head/helmet/space/void
	name = "\improper Antique Void Helmet"
	desc = "An old space helmet with a wide plexiglass visor. It lacks any modern HUD systems and provides negligible armor protection. The interior smells like mothballs."
	icon_state = "void-red"
	flags_inv = HIDEMASK|HIDEEARS
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_VOID_HELMET
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi')

/obj/item/clothing/suit/space/void
	name = "\improper Antique Void Suit"
	icon_state = "void-red"
	desc = "An antique space suit commonly used for extravehicular repairs many years ago. Painfully outdated, it provides next to nothing beyond protection from the vaccuum of space."
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_VOID_SUIT
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/multitool)
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

//Colors!!!
/obj/item/clothing/head/helmet/space/void/green
	icon_state = "void-green"

/obj/item/clothing/suit/space/void/green
	icon_state = "void-green"

/obj/item/clothing/head/helmet/space/void/ntblue
	icon_state = "void-ntblue"

/obj/item/clothing/suit/space/void/ntblue
	icon_state = "void-ntblue"

/obj/item/clothing/head/helmet/space/void/purple
	icon_state = "void-purple"

/obj/item/clothing/suit/space/void/purple
	icon_state = "void-purple"

/obj/item/clothing/head/helmet/space/void/yellow
	icon_state = "void-yellow"

/obj/item/clothing/suit/space/void/yellow
	icon_state = "void-yellow"

/obj/item/clothing/head/helmet/space/void/ltblue
	icon_state = "void-light_blue"

/obj/item/clothing/suit/space/void/ltblue
	icon_state = "void-light_blue"

//Captian's Suit, like the other captian's suit, but looks better, at the cost of armor
/obj/item/clothing/head/helmet/space/void/captain
	name = "\improper Antique Captain's Void Helmet"
	icon_state = "void-captian"
	desc = "An old space helmet with a plexiglass visor and golden rank insignia. It lacks any modern HUD systems and provides nothing in the way of armor protection. The interior smells like cheap air freshener."

/obj/item/clothing/suit/space/void/captain
	name = "\improper Antique Captain's Void Suit"
	icon_state = "void-captian"
	desc = "An antique space suit used by command staff many years ago. Painfully outdated, it provides next to nothing beyond protection from the vaccuum of space."

//Syndi's suit, on par with a blood red softsuit

/obj/item/clothing/head/helmet/space/void/syndi
	name = "blood-red antique void helmet"
	icon_state = "void-syndi"
	desc = "A hastily-modified void helmet reinforced with metal plates and kevlar scraps. It's covered in a strange coating that seems to repel acidic substances."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 200, ACID = 285)

/obj/item/clothing/suit/space/void/syndi
	name = "blood-red antique void suit"
	icon_state = "void-syndi"
	desc = "A hastily-modified void suit reinforced with metal plates and kevlar scraps. It's covered in a strange coating that seems to repel acidic substances."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs,/obj/item/tank/internals)
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 200, ACID = 285)

//random spawner

/obj/effect/voidsuitspawner
	name = "\improper Antique void suit spawner"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "void-red"
	desc = "You shouldn't see this, it's a spawner for Antique Void Suits."
	var/suits = list("red", "green", "ntblue", "purple", "yellow", "ltblue")

/obj/effect/voidsuitspawner/New()
	. = ..()
	var/obj/item/clothing/head/helmet/space/void/H
	var/obj/item/clothing/suit/space/void/S
	switch(pick(suits))
		if("red")
			H = new /obj/item/clothing/head/helmet/space/void
			S = new /obj/item/clothing/suit/space/void
		if("green")
			H = new /obj/item/clothing/head/helmet/space/void/green
			S = new /obj/item/clothing/suit/space/void/green
		if("ntblue")
			H = new /obj/item/clothing/head/helmet/space/void/ntblue
			S = new /obj/item/clothing/suit/space/void/ntblue
		if("purple")
			H = new /obj/item/clothing/head/helmet/space/void/purple
			S = new /obj/item/clothing/suit/space/void/purple
		if("yellow")
			H = new /obj/item/clothing/head/helmet/space/void/yellow
			S = new /obj/item/clothing/suit/space/void/yellow
		if("ltblue")
			H = new /obj/item/clothing/head/helmet/space/void/ltblue
			S = new /obj/item/clothing/suit/space/void/ltblue
	var/turf/T = get_turf(src)
	if(H)
		H.forceMove(T)
	if(S)
		S.forceMove(T)
	qdel(src)
