/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a762
	desc = "A 7.62mm bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/weakbullet2/rubber

/obj/item/ammo_casing/c10mm
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/c9mmap
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c9mmtox
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mminc
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet

/obj/item/ammo_casing/c46x30mm
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/c46x30mmap
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c46x30mmtox
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c46x30mminc
	desc = "A 4.6x30mm bullet casing."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet

/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet

/obj/item/ammo_casing/c45nostamina
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/n762
	desc = "A 7.62x38mmR bullet casing."
	caliber = "n762"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/caseless/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	projectile_type = /obj/item/projectile/bullet/reusable/magspear
	caliber = "speargun"
	icon_state = "magspear"
	throwforce = 15 //still deadly when thrown
	throw_speed = 3

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet
	materials = list(MAT_METAL=4000)

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/rpellet
	pellets = 6
	variance = 25
	materials = list(MAT_METAL=4000)

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet/rubber
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet/weak
	materials = list(MAT_METAL=250)
	pellets = 5
	variance = 25

/obj/item/ammo_casing/shotgun/improvised/overload
	name = "overloaded improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards. This one has been packed with even more \
	propellant. It's like playing russian roulette, with a shotgun."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/overload
	materials = list(MAT_METAL=250)
	pellets = 5
	variance = 40

/obj/item/ammo_casing/shotgun/improvised/overload/New()
	..()
	pellets = rand(3, 8)

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunshot
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/shotgun/meteorshot
	name = "meteorshot shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot

/obj/item/ammo_casing/shotgun/breaching
	name = "breaching shell"
	desc = "An economic version of the meteorshot, utilizing similar technologies. Great for busting down doors."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot/weak

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shot

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/frag12

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal splot the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 4
	variance = 35

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
	projectile_type = /obj/item/projectile/bullet/dart

/obj/item/ammo_casing/shotgun/dart/New()
	..()
	flags |= NOREACT
	flags |= OPENCONTAINER
	create_reagents(30)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "A shotgun dart filled with deadly toxins."

/obj/item/ammo_casing/shotgun/dart/bioterror/New()
	..()
	reagents.add_reagent("neurotoxin", 6)
	reagents.add_reagent("spore", 6)
	reagents.add_reagent("mutetoxin", 6) //;HELP OPS IN MAINT
	reagents.add_reagent("coniine", 6)
	reagents.add_reagent("sodium_thiopental", 6)

/obj/item/ammo_casing/shotgun/tranquilizer
	name = "tranquilizer darts"
	desc = "A tranquilizer round used to subdue individuals utilizing stimulants."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/dart/syringe/tranquilizer
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/a556
	desc = "A 5.56mm bullet casing."
	caliber = "a556"
	projectile_type = /obj/item/projectile/bullet/heavybullet

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet/booze

/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/missile
	caliber = "rocket"

/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."

/obj/item/ammo_casing/caseless/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, distro, quiet)
	if(..())
		loc = null
		return 1
	else
		return 0

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	projectile_type = /obj/item/projectile/bullet/gyro

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = /obj/item/projectile/bullet/a40mm

/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart
	caliber = "foam_force"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	var/modified = 0

/obj/item/ammo_casing/caseless/foam_dart/update_icon()
	..()
	if(modified)
		icon_state = "foamdart_empty"
		desc = "Its nerf or nothing! ... Although, this one doesn't look too safe."
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = "foamdart"
		desc = "Its nerf or nothing! Ages 8 and up."
		if(BB)
			BB.icon_state = "foamdart_empty"

/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/A, mob/user, params)
	..()
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if(istype(A, /obj/item/weapon/screwdriver) && !modified)
		modified = 1
		FD.damage_type = BRUTE
		update_icon()
	else if((istype(A, /obj/item/weapon/pen)) && modified && !FD.pen)
		if(!user.unEquip(A))
			return
		A.loc = FD
		FD.pen = A
		FD.damage = 5
		FD.nodamage = 0
		to_chat(user, "<span class='notice'>You insert [A] into [src].</span>")
	return

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		to_chat(user, "<span class='notice'>You remove [FD.pen] from [src].</span>")
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/riot
	icon_state = "foamdart_riot"

/obj/item/ammo_casing/shotgun/dart/assassination
	desc = "A specialist shotgun dart designed to inncapacitate and kill the target over time, so you can get very far away from your target"

/obj/item/ammo_casing/shotgun/dart/assassination/New()
	..()
	reagents.add_reagent("neurotoxin", 6)

/obj/item/ammo_casing/cap
	desc = "A cap for children toys."
	caliber = "caps"
	projectile_type = /obj/item/projectile/bullet/cap
