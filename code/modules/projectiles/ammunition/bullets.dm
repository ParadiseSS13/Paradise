/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/a418
	desc = "A .418 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/suffocationbullet"


/obj/item/ammo_casing/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	projectile_type = "/obj/item/projectile/bullet/gyro"


/obj/item/ammo_casing/a666
	desc = "A .666 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/cyanideround"


/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = "/obj/item/projectile/bullet/rubberbullet"


/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet9"


/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = "/obj/item/projectile/bullet/midbullet45"

/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet10"

/obj/item/ammo_casing/a12mm
	desc = "A 12mm bullet casing."
	caliber = "12mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet12"


/obj/item/ammo_casing/shotgun
	name = "shotgun shell"
	desc = "A 12 gauge shell."
	icon_state = "slshell"
	caliber = "shotgun"
	projectile_type = "/obj/item/projectile/bullet/slug"
	m_amt = 12500

/obj/item/ammo_casing/shotgun/buck
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/buck
	buck = 4
	deviation = 1

/obj/item/ammo_casing/shotgun/birdshot
	name = "birdshot shell"
	desc = "A shotgun shell full of birdshot."
	icon_state = "blshell"
	projectile_type = "/obj/item/projectile/bullet/rubberbullet"
	buck = 4
	deviation = 1
	m_amt = 6000


/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/rubberbullet"
	m_amt = 500

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/rubberbullet/booze"
	m_amt = 12500

/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"
	desc = "A stunning shell."
	icon_state = "stunshell"
	projectile_type = "/obj/item/projectile/bullet/stunshot"
	m_amt = 2500


/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary shell"
	desc = "An incendiary shell"
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell
	m_amt = 12500


/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/dart
	m_amt = 12500

obj/item/ammo_casing/shotgun/dart/New()
	..()
	flags |= NOREACT
	create_reagents(30)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return


/obj/item/ammo_casing/a762
	desc = "A 7.62 bullet casing."
	caliber = "a762"
	projectile_type = "/obj/item/projectile/bullet/a762"

/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = "/obj/item/missile"
	caliber = "rocket"

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/bullet
	//select_name = "kinetic"
	//e_cost = 500
	//fire_sound = 'sound/weapons/Gunshot4.ogg'