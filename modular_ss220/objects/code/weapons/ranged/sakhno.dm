// MARK: Sakhno rifle
/obj/item/gun/projectile/shotgun/boltaction/sakhno
	name = "\improper Sakhno precision rifle"
	desc = "Высокоточная винтовка Sakhno со скользящим затвором, которая была (и, безусловно, остается) крайне популярной среди \
		покорителей фронтира, контрабандистов, ЧОП'овцев, исследователей, и прочих рисковых ребят. Эта модель \
		была разработана и производится с 2440 года."
	icon = 'modular_ss220/objects/icons/wide_guns.dmi'
	icon_state = "sakhno"
	item_state = "sakhno"
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/shot_heavy.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/sakhno
	knife_x_offset = 30
	knife_y_offset = 12

/obj/item/ammo_box/magazine/internal/boltaction/sakhno
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "310"
	ammo_type = /obj/item/ammo_casing/s310
	caliber = "s310"
	max_ammo = 5
	multiload = 1

// MARK: .310
/obj/item/ammo_box/s310
	name = "stripper clip (.310)"
	desc = "A stripper clip for .310 cartridges, used in Sakhno rifles. Five round capacity."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "310"
	ammo_type = /obj/item/ammo_casing/s310
	max_ammo = 5
	multi_sprite_step = 1

/obj/item/ammo_casing/s310
	name = ".310 round"
	desc = "A .310 rifle cartridge"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "310-casing"
	caliber = "s310"
	projectile_type = /obj/item/projectile/bullet/midbullet3/hp
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
