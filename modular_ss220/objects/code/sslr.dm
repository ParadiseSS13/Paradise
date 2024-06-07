/obj/item/gun/projectile/automatic/sslr
	name = "SSLR"
	desc = "Стандартная лазерная винтовка производства Warp-Tac Industries, использующая лазерные картриджи вместо аккумулятора. Одно из самых популярных решений для службы безопасности Nanotrasen"
	icon = 'modular_ss220/objects/icons/guns.dmi'
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	icon_state = "sslr"
	item_state = "sslr"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=1;materials=1"
	mag_type = /obj/item/ammo_box/magazine/sslr
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()

/obj/item/gun/projectile/automatic/sslr/update_icon_state()
	icon_state = "sslr[magazine ? "-[CEILING(get_ammo(0) / 4, 1) * 4]" : ""]"
	item_state = "sslr[magazine ? "" : "_empty"]"

/obj/item/ammo_box/magazine/sslr
	name = "SSLR magazine"
	desc = "Стандартный магазин для винтовки SSLR производства Warp-Tac Industries"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "sslr"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	origin_tech = "combat=1"
	caliber = "laser"
	max_ammo = 8
	multi_sprite_step = 4
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/small_laser
	name = "small ammo box (laser)"
	desc = "Упаковка на 8 лазерных патронов для лазерных винтовок с магазинным способом заряжания"
	icon_state = "laserbox"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	max_ammo = 8
	w_class = WEIGHT_CLASS_NORMAL

/datum/design/sslr_magazine
	name = "SSLR magazine"
	desc = "Стандратный магазин на 8 патронов для SSLR"
	id = "mag_sslr"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600, MAT_PLASMA = 240)
	build_path = /obj/item/ammo_box/magazine/sslr
	category = list("Weapons")

/datum/design/laser_rifle_small_ammo_box
	name = "small ammo box (laser)"
	desc = "Упаковка на 8 лазерных патронов для лазерных винтовок с магазинным способом заряжания"
	id = "small_box_laser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1600, MAT_PLASMA = 240)
	build_path = /obj/item/ammo_box/small_laser
	category = list("Weapons")

/datum/supply_packs/security/armory/sslr_ammo
	name = "SSLR Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/sslr,
					/obj/item/ammo_box/magazine/sslr,
					/obj/item/ammo_box/magazine/sslr,
					/obj/item/ammo_box/magazine/sslr)
	cost = 150
	containername = "SSLR ammo crate"
