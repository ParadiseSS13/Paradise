/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = "/obj/item/projectile/bullet/weakbullet2/rubber"


/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet3"


/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = "/obj/item/projectile/bullet/weakbullet3"
	
/obj/item/ammo_casing/c9mmap
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type =/obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c9mmtox
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mminc
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet

/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = "/obj/item/projectile/bullet/midbullet"


/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = "/obj/item/projectile/bullet"
	materials = list(MAT_METAL=4000)


/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = "/obj/item/projectile/bullet/pellet"
	pellets = 5
	deviation = 30


/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/weakbullet/rubber"
	materials = list(MAT_METAL=250)


/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "gshell"
	projectile_type = "/obj/item/projectile/bullet/pellet/weak"
	materials = list(MAT_METAL=250)
	pellets = 5
	deviation = 30

/obj/item/ammo_casing/shotgun/improvised/overload
	name = "overloaded improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards. This one has been packed with even more \
	propellant. It's like playing russian roulette, with a shotgun."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/random
	materials = list(MAT_METAL=250)
	pellets = 5
	deviation = 30

/obj/item/ammo_casing/shotgun/improvised/overload/New()
	..()
	pellets = rand(3, 8)

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = "/obj/item/projectile/bullet/stunshot"
	materials = list(MAT_METAL=250)


/obj/item/ammo_casing/shotgun/meteorshot
	name = "meteorshot shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = "/obj/item/projectile/bullet/meteorshot"

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = "/obj/item/projectile/beam/pulse/shot"

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = "/obj/item/projectile/bullet/incendiary/shell"

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/frag12

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = "/obj/item/projectile/bullet/incendiary/shell/dragonsbreath"
	pellets = 4
	deviation = 30

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal splot the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 4
	deviation = 30

/obj/item/ammo_casing/shotgun/laserslug
	name = "laser slug"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/item/projectile/beam

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "cshell"
	projectile_type = "/obj/item/projectile/bullet/dart"

/obj/item/ammo_casing/shotgun/dart/New()
	..()
	flags |= NOREACT
	flags |= OPENCONTAINER
	create_reagents(30)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/tranquilizer
	name = "tranquilizer darts"
	desc = "A tranquilizer round used to subdue individuals utilizing stimulants."
	icon_state = "cshell"
	projectile_type = "/obj/item/projectile/bullet/dart/syringe/tranquilizer"
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = null

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/weakbullet/booze"

/obj/item/ammo_casing/a762
	desc = "A 7.62mm bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = "/obj/item/projectile/bullet"

/obj/item/ammo_casing/a556
	desc = "A 5.56mm bullet casing."
	caliber = "a556"
	projectile_type = "/obj/item/projectile/bullet/heavybullet"

/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = "/obj/item/missile"
	caliber = "rocket"

/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	projectile_type = "/obj/item/projectile/bullet/gyro"

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = "/obj/item/projectile/bullet/a40mm"