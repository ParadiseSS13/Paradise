/obj/item/ammo_box/a357
	name = "speed loader (.357)"
	desc = "A small device designed to quickly reload revolvers. Seven round capacity."
	materials = list()
	ammo_type = /obj/item/ammo_casing/a357
	multi_sprite_step = 1 // see: /obj/item/ammo_box/update_icon()
	icon_state = "357"

/obj/item/ammo_box/b357
	name = "ammo box (.357)"
	desc = "An ammunition box filled with .357 magnum rounds, commonly used in high-caliber revolvers."
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/a357
	multi_sprite_step = 1
	icon_state = "357_box"

/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	desc = "An ammunition box filled with 9mm pistol cartridges, commonly used in handguns and submachine guns."
	icon_state = "9mmbox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	desc = "An ammunition box filled with 10mm pistol cartridges, commonly used in Syndicate handguns."
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	desc = "An ammunition box filled with .45 caliber pistol cartridges, commonly used in high-power pistols and submachine guns."
	icon_state = "45box"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/rubber45
	name = "ammo box (.45 rubber)"
	desc = "An ammunition box filled with .45 caliber rubber bullets for less-lethal actions."
	icon_state = "45box-r"
	ammo_type = /obj/item/ammo_casing/rubber45
	max_ammo = 16

/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	desc = "An ammunition box containing four 40mm grenades, for use with a launcher. Dropping them is ill-advised."
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multi_sprite_step = 1

/obj/item/ammo_box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip for 7.62mm cartridges, used in Mosin-Nagant rifles. Five round capacity."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multi_sprite_step = 1

/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mmR)"
	desc = "An ammunition box full of 7.62x38mmR pistol cartridges, for use in antique revolvers."
	icon_state = "riflebox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box/wt550
	name = "ammo box (4.6x30mm)"
	desc = "An ammunition box containing 4.6x30mm PDW cartridges, for use in submachine guns and low-caliber rifles."
	icon_state = "riflebox"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 20
	multiload = 0

/obj/item/ammo_box/wt550/wtap
	name = "ammo box (Armor Piercing 4.6x30mm)"
	desc = "An ammunition box containing 4.6x30mm PDW cartridges. These are AP rounds, sacrificing damage for armor penetration."
	icon_state = "wtbox_AP"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/wt550/wtic
	name = "ammo box (Incendiary 4.6x30mm)"
	desc = "An ammunition box containing 4.6x30mm PDW ammunition, tipped with an incendiary chemical payload."
	icon_state = "wtbox_inc"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc

/obj/item/ammo_box/wt550/wttx
	name = "ammo box (Toxin Tipped 4.6x30mm)"
	desc = "An ammunition box containing 4.6x30mm cartridges, tipped with lethal toxins. Possibly a war crime."
	icon_state = "wtbox_tox"
	ammo_type = /obj/item/ammo_casing/c46x30mm/tox

/obj/item/ammo_box/laser
	name = "ammo box (laser)"
	desc = "An ammunition box containing caseless laser cartridges, for use in IK-series laser rifles."
	icon_state = "laserbox"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	max_ammo = 20
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/shotgun
	name = "shotgun speedloader (Slug)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Slugs."
	icon_state = "slugloader"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/shotgun
	materials = list(MAT_METAL=28000)
	multi_sprite_step = 1

/obj/item/ammo_box/shotgun/buck
	name = "shotgun speedloader (Buckshot)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Buckshot."
	icon_state = "buckloader"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/shotgun/confetti
	name = "shotgun speedloader (Confetti)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Confetti shot."
	icon_state = "partyloader"
	ammo_type = /obj/item/ammo_casing/shotgun/confetti

/obj/item/ammo_box/shotgun/dragonsbreath
	name = "shotgun speedloader (Dragonsbreath)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Dragonsbreath rounds."
	icon_state = "dragonsbreathloader"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary/dragonsbreath

/obj/item/ammo_box/shotgun/stun
	name = "shotgun speedloader (Stun shells)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Stun slugs."
	icon_state = "stunloader"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/shotgun/beanbag
	name = "shotgun speedloader (Beanbag shells)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Beanbag slugs."
	icon_state = "beanbagloader"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	materials = list(MAT_METAL=1750)

/obj/item/ammo_box/shotgun/rubbershot
	name = "shotgun speedloader (Rubbershot shells)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Rubbershot shells."
	icon_state = "rubbershotloader"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	materials = list(MAT_METAL=1750)

/obj/item/ammo_box/shotgun/tranquilizer
	name = "shotgun speedloader (Tranquilizer darts)"
	desc = "A specialized speedloader for swiftly reloading shotguns. This one is meant for Tranquilizer dart shells."
	icon_state = "tranqloader"
	ammo_type = /obj/item/ammo_casing/shotgun/tranquilizer
	materials = list(MAT_METAL=1750)


//FOAM DARTS
/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	desc = "An ammunition box, filled with foam darts for use in toy weapons."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40
	materials = list(MAT_METAL = 500)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	desc = "An ammunition box, filled with riot darts for use in toy weapons. Not safe for children."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	materials = list(MAT_METAL = 50000)

/obj/item/ammo_box/foambox/sniper
	name = "ammo box (Foam Sniper Darts)"
	desc = "An ammunition box full of sniper darts for toy weapons."
	icon_state = "foambox_sniper"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper
	materials = list(MAT_METAL = 900)

/obj/item/ammo_box/foambox/sniper/riot
	icon_state = "foambox_sniper_riot"
	desc = "An ammunition box full of powerful sniper riot darts."
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	materials = list(MAT_METAL = 90000)

/obj/item/ammo_box/caps
	name = "speed loader (caps)"
	desc = "A revolver speedloader for a cap gun. Cannot chamber live ammunition."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/cap
	multi_sprite_step = 1
