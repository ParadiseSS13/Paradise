/obj/item/ammo_casing/a357
	name = ".357 magnum round"
	desc = "A .357 magnum cartridge, often used in revolvers. Very deadly."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/rubber9mm
	name = "9mm rubber round"
	desc = "A 9mm pistol cartridge. This one has a rubber tip for less-lethal takedowns."
	caliber = "9mm"
	icon_state = "r-casing"
	projectile_type = /obj/item/projectile/bullet/weakbullet4

/obj/item/ammo_casing/a762
	name = "7.62mm round"
	desc = "A 7.62mm rifle cartridge, often used in Soviet rifles."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/a762/enchanted
	name = "enchanted 7.62 round"
	desc = "A 7.62mm rifle cartridge. It sparkles with magic."
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/item/ammo_casing/a50
	name = ".50 AE round"
	desc = "A .50AE pistol cartridge, used in large caliber handguns."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/c38/invisible
	projectile_type = /obj/item/projectile/bullet/mime
	muzzle_flash_effect = null // invisible eh

/obj/item/ammo_casing/c38/invisible/fake
	projectile_type = /obj/item/projectile/bullet/mime/fake

/obj/item/ammo_casing/c10mm
	name = "10mm round"
	desc = "A 10mm pistol cartridge, commonly used in Syndicate sidearms."
	caliber = "10mm"
	projectile_type = /obj/item/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c10mm/ap
	name = "10mm armor piercing round"
	desc = "A 10mm pistol cartridge, with a Teflon coating to increase armor penetration, at the cost of damage."
	projectile_type = /obj/item/projectile/bullet/midbullet3/ap

/obj/item/ammo_casing/c10mm/fire
	name = "10mm incendiary round"
	desc = "A 10mm pistol cartridge, containing a payload of flammable chemicals."
	projectile_type = /obj/item/projectile/bullet/midbullet3/fire
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/c10mm/hp
	name = "10mm hollow point round"
	desc = "A 10mm pistol cartridge, with an expanding tip that greatly increases stopping power, at the cost of armor penetration."
	projectile_type = /obj/item/projectile/bullet/midbullet3/hp

/obj/item/ammo_casing/overgrown
	name = "overgrown round"
	desc = "A pistol cartridge... probably. Why does it resemble a pea?"
	projectile_type = /obj/item/projectile/bullet/midbullet3/overgrown
	icon_state = "peashooter_bullet"

/obj/item/ammo_casing/c9mm
	name = "9mm round"
	desc = "A 9mm pistol cartridge, commonly used in handguns and submachine guns."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c9mm/ap
	name = "9mm armor piercing round"
	desc = "A 9mm pistol cartridge, with a Teflon coating to increase armor penetration, at the cost of stopping power."
	projectile_type = /obj/item/projectile/bullet/armourpiercing

/obj/item/ammo_casing/c9mm/tox
	name = "9mm toxic round"
	desc = "A 9mm pistol cartridge, tipped with lethal toxins. Likely a war crime."
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c9mm/inc
	name = "9mm incendiary round"
	desc = "A 9mm pistol cartridge, tipped with an incendiary chemical payload."
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/c46x30mm
	name = "4.6x30mm round"
	desc = "A 4.6x30mm PDW cartridge, commonly used in submachine guns and small-caliber rifles."
	caliber = "4.6x30mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c46x30mm/ap
	name = "4.6x30mm armor piercing round"
	desc = "A 4.6x30mm PDW cartridge, with a tungsten core to increase armor penetration, at the cost of stopping power."
	projectile_type = /obj/item/projectile/bullet/armourpiercing/wt550

/obj/item/ammo_casing/c46x30mm/tox
	name = "4.6x30mm toxic round"
	desc = "A 4.6x30mm PDW cartridge, tipped with lethal toxins. Probably a war crime."
	projectile_type = /obj/item/projectile/bullet/toxinbullet

/obj/item/ammo_casing/c46x30mm/inc
	name = "4.6x30 incendiary round"
	desc = "a 4.6x30mm PDW cartridge, tipped with an incendiary chemical payload."
	projectile_type = /obj/item/projectile/bullet/incendiary/firebullet
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/rubber45
	name = ".45 rubber round"
	desc = "A .45 caliber pistol cartridge. Features a rubber bullet for less-lethal takedowns."
	caliber = ".45"
	icon_state = "r-casing"
	projectile_type = /obj/item/projectile/bullet/midbullet_r
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c45
	name = ".45 round"
	desc = "A .45 caliber pistol cartridge, commonly used in pistols and submachine guns."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/midbullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/c45/nostamina
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/n762
	name = "7.62x38mmR round"
	desc = "A 7.62x38mmR pistol cartridge, commonly used by antique revolvers."
	caliber = "n762"
	projectile_type = /obj/item/projectile/bullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/caseless/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	projectile_type = /obj/item/projectile/bullet/reusable/magspear
	caliber = "speargun"
	icon_state = "magspear"
	throwforce = 15 //still deadly when thrown
	throw_speed = 3
	muzzle_flash_color = null

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug. Fires a single solid projectile."
	icon_state = "blshell"
	caliber = "shotgun"
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	projectile_type = /obj/item/projectile/bullet
	materials = list(MAT_METAL=4000)
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell. Fires a spread of lethal shot."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A 12 gauge shell filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/pellet/rubber
	pellets = 6
	variance = 35
	materials = list(MAT_METAL=4000)


/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A 12 gauge shell loaded with a beanbag slug for less-lethal takedowns."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	materials = list(MAT_METAL=250)
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A 12 gauge shell loaded with a taser cartridge, somehow."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunshot
	materials = list(MAT_METAL=250)
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = "#FFFF00"


/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteorslug shell"
	desc = "A 12 gauge shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/meteorshot

/obj/item/ammo_casing/shotgun/pulseslug
	name = "proto pulse slug"
	desc = "A 12 gauge shell loaded with a powerful energy emitter, firing a devastating pulse blast."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shot
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "A 12 gauge slug shell containing an incendiary chemical payload."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/frag12
	name = "\improper FRAG-12 slug"
	desc = "A 12 gauge shell, loaded with a high-explosive slug."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/frag12

/obj/item/ammo_casing/shotgun/incendiary/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A 12 gauge shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	pellets = 4
	variance = 35
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced 12 gauge shell that fires a spread of ion bolts."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 6
	variance = 40
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE

/obj/item/ammo_casing/shotgun/lasershot
	name = "lasershot"
	desc = "An advanced 12 gauge shell that uses a multitude of lenses to split a high-powered laser into eight small beams."
	icon_state = "lshell"
	projectile_type = /obj/item/projectile/beam/scatter
	pellets = 8
	variance = 35
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_DARKRED

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "An empty 12 gauge shell, ready to be loaded with all manner of projectiles."
	icon_state = "cshell"
	projectile_type = null

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A 12 gauge shell loaded with a hypodermic needle. Can be injected with up to 30 units of any chemical."
	icon_state = "cshell"
	container_type = OPENCONTAINER
	projectile_type = /obj/item/projectile/bullet/dart
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/dart/New()
	..()
	create_reagents(30)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "A shotgun dart filled with deadly toxins."

/obj/item/ammo_casing/shotgun/dart/bioterror/New()
	..()
	reagents.add_reagent("neurotoxin", 6)
	reagents.add_reagent("spore", 6)
	reagents.add_reagent("capulettium_plus", 6) //;HELP OPS IN MAINT
	reagents.add_reagent("coniine", 6)
	reagents.add_reagent("sodium_thiopental", 6)

/obj/item/ammo_casing/shotgun/tranquilizer
	name = "tranquilizer darts"
	desc = "A 12 gauge dart shell loaded with powerful tranquilizers."
	icon_state = "nshell"
	projectile_type = /obj/item/projectile/bullet/dart/syringe/tranquilizer
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	materials = list(MAT_METAL=250)

/obj/item/ammo_casing/shotgun/confetti
	name = "confettishot"
	desc = "A 12 gauge shell loaded with... confetti?"
	icon_state = "partyshell"
	projectile_type = /obj/item/projectile/bullet/confetti

/obj/item/ammo_casing/a556
	name = "5.56mm round"
	desc = "A 5.56mm rifle round, produced in incredible quantities by the Trans-Solar Federation."
	caliber = "a556"
	projectile_type = /obj/item/projectile/bullet/heavybullet
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/a545
	name = "5.45x39mm round"
	desc = "A 5.45x39mm rifle round, used by the elite marines of the USSP."
	caliber = "a545"
	projectile_type = /obj/item/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A 12 gauge beanbag slug. Smells strongly of alcohol."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet/booze
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/rocket
	name = "rocket propelled grenade"
	desc = "A high explosive rocket meant to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/projectile/missile
	caliber = "rocket"
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."

/obj/item/ammo_casing/caseless/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, distro, quiet, zone_override = "", spread, atom/firer_source_atom)
	if(..())
		qdel(src)
		return TRUE
	return FALSE

/obj/item/ammo_casing/caseless/a75
	name = ".75 gyrojet round"
	desc = "A .75 caliber gyrojet cartridge, for use in experimental weaponry. There's a Sunburst Heavy Industries logo on the side."
	caliber = "75"
	projectile_type = /obj/item/projectile/bullet/gyro
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/a40mm
	name = "40mm HE grenade"
	desc = "A 40mm high-explosive grenade round, meant to be fired from a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = /obj/item/projectile/bullet/a40mm
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart
	muzzle_flash_effect = null
	caliber = "foam_force"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	var/modified = FALSE
	harmful = FALSE

/obj/item/ammo_casing/caseless/foam_dart/update_desc()
	. = ..()
	if(modified)
		desc = "Its nerf or nothing! ... Although, this one doesn't look too safe."

/obj/item/ammo_casing/caseless/foam_dart/update_icon_state()
	if(modified)
		icon_state = "foamdart_empty"
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)

/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/A, mob/user, params)
	..()
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if((is_pen(A)) && modified && !FD.pen)
		if(!user.unEquip(A))
			return
		add_pen(A)
		to_chat(user, "<span class='notice'>You insert [A] into [src].</span>")

/obj/item/ammo_casing/caseless/foam_dart/screwdriver_act(mob/living/user, obj/item/I)
	if(modified)
		return

	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	I.play_tool_sound(src)
	modified = TRUE
	FD.damage_type = BRUTE
	update_icon()
	return TRUE

/obj/item/ammo_casing/caseless/foam_dart/proc/add_pen(obj/item/pen/P)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	harmful = TRUE
	P.forceMove(FD)
	FD.log_override = FALSE
	FD.pen = P
	FD.damage = 5
	FD.nodamage = FALSE

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

/obj/item/ammo_casing/caseless/foam_dart/sniper
	name = "foam sniper dart"
	desc = "For the big nerf! Ages 8 and up."
	caliber = "foam_force_sniper"
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/sniper
	icon_state = "foamdartsniper"


/obj/item/ammo_casing/caseless/foam_dart/sniper/update_desc()
	. = ..()
	if(modified)
		desc = "Its nerf or nothing! ... Although, this one doesn't look too safe."

/obj/item/ammo_casing/caseless/foam_dart/sniper/update_icon_state()
	if(modified)
		icon_state = "foamdartsniper_empty"
		if(BB)
			BB.icon_state = "foamdartsniper_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)

/obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	name = "riot foam sniper dart"
	desc = "For the bigger brother of the crowd control toy. Ages 18 and up."
	caliber = "foam_force_sniper"
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/sniper/riot
	icon_state = "foamdartsniper_riot"

/obj/item/ammo_casing/shotgun/assassination
	name = "assassination shell"
	desc = "A 12 gauge buckshot shell containing a powerful silencing toxin."
	projectile_type = /obj/item/projectile/bullet/pellet/assassination
	muzzle_flash_effect = null
	icon_state = "gshell"
	pellets = 6
	variance = 25

/obj/item/ammo_casing/cap
	name = "cap"
	desc = "A cap for children toys."
	caliber = "cap"
	projectile_type = /obj/item/projectile/bullet/cap
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	harmful = FALSE

/obj/item/ammo_casing/caseless/laser
	name = "caseless laser round"
	desc = "An experimental laser casing, designed to vaporize when fired."
	caliber = "laser"
	projectile_type = /obj/item/projectile/beam/laser/ik //Subtype that breaks on firing if emp'd
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/energy
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
	muzzle_flash_color = LIGHT_COLOR_DARKRED
	icon_state = "lasercasing"
