/obj/item/clothing/head/atmta/helmet/space/doom
	name = "Praetor Helmet"
	icon_state = "doomhelmet"
	item_state = "doomhelmet"
	desc = "That's a FUCKING HUGE helmet. The small painting on it reads 'WJ Armor'."
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	siemens_coefficient = 0.8

/obj/item/clothing/suit/atmta/space/doom
	name = "Praetor Suit"
	icon_state = "doomarmor"
	item_state = "doomarmor"
	desc = "An old, badly damaged armor. The small painting on it reads 'WJ Armor'."
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 80, bullet = 80, laser = 50,energy = 50, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0.8

/obj/item/clothing/head/atmta/helmet/space/invisible
	name = "Invisible helmet"
	icon_state = "invisible"
	item_state = "invisible"
	desc = "Space helmets club is 2 files down."
	flags = ABSTRACT | NODROP
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	siemens_coefficient = 0.8

/obj/item/clothing/suit/atmta/space/bane
	name = "Bane Jacket"
	icon_state = "bomber_open"
	item_state = "bomber_open"
	desc = "For big guys, don't put that off."
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 80, bullet = 80, laser = 50,energy = 50, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0.8