/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "I didn't even know magic needed ammo..."
	projectile_type = /obj/item/projectile/magic
	muzzle_flash_color = COLOR_BLUE_GRAY
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/magic

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/item/projectile/magic/change

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/item/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/item/projectile/magic/resurrection
	harmful = FALSE

/obj/item/ammo_casing/magic/death
	projectile_type = /obj/item/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/item/projectile/magic/teleport
	harmful = FALSE

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/item/projectile/magic/door
	harmful = FALSE

/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/item/projectile/magic/fireball

/obj/item/ammo_casing/magic/chaos
	projectile_type = /obj/item/projectile/magic/chaos

/obj/item/ammo_casing/magic/slipping
	projectile_type = /obj/item/projectile/magic/slipping

/obj/item/ammo_casing/magic/arcane_barrage
	projectile_type = /obj/item/projectile/magic/arcane_barrage

/obj/item/ammo_casing/magic/forcebolt
	projectile_type = /obj/item/projectile/forcebolt

/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = null
	muzzle_flash_effect = null

/obj/item/ammo_casing/energy/c3dbullet
	projectile_type = /obj/item/projectile/bullet/midbullet3
	select_name = "spraydown"
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	e_cost = 20
