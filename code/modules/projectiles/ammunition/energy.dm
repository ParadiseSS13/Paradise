/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	projectile_type = /obj/item/projectile/energy
	var/e_cost = 1000 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/item/projectile/beam/laser
	select_name = "kill"

/obj/item/ammo_casing/energy/lasergun
	projectile_type = /obj/item/projectile/beam/laser
	e_cost = 830
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/hos //allows balancing of HoS and blueshit guns seperately from other energy weapons

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/item/projectile/beam/practice
	select_name = "practice"

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/item/projectile/beam/scatter
	pellets = 5
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/item/projectile/beam/laser/heavylaser
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/item/projectile/beam/pulse
	e_cost = 200
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/scatter/pulse
	projectile_type = /obj/item/projectile/beam/pulse
	e_cost = 2000
	select_name = "ANNIHILATE"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/item/projectile/beam/lasertag/bluetag
	select_name = "bluetag"

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/item/projectile/beam/lasertag/redtag
	select_name = "redtag"

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/item/projectile/beam/xray
	e_cost = 500
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/immolator
	projectile_type = /obj/item/projectile/beam/immolator
	fire_sound = 'sound/weapons/laser3.ogg'
	e_cost = 1250

/obj/item/ammo_casing/energy/electrode
	projectile_type = /obj/item/projectile/energy/electrode
	select_name = "stun"
	fire_sound = 'sound/weapons/taser.ogg'
	e_cost = 2000
	delay = 15

/obj/item/ammo_casing/energy/electrode/gun
	fire_sound = 'sound/weapons/gunshot.ogg'
	e_cost = 1000

/obj/item/ammo_casing/energy/electrode/hos //allows balancing of HoS and blueshit guns seperately from other energy weapons

/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/item/projectile/ion
	select_name = "ion"
	fire_sound = 'sound/weapons/IonRifle.ogg'

/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/item/projectile/energy/declone
	select_name = "declone"
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/item/projectile/beam/mindflayer
	select_name = "MINDFUCK"
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'

/obj/item/ammo_casing/energy/flora/yield
	projectile_type = /obj/item/projectile/energy/florayield
	select_name = "yield"

/obj/item/ammo_casing/energy/flora/mut
	projectile_type = /obj/item/projectile/energy/floramut
	select_name = "mutation"

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/item/projectile/temp
	e_cost = 100
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/temp/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/temp/newshot(shot_temp, shot_cost)
	e_cost = shot_cost
	..(shot_temp)

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/item/projectile/meteor
	select_name = "goddamn meteor"

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	select_name = "kinetic"
	e_cost = 5000
	fire_sound = 'sound/weapons/Kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/super
	projectile_type = /obj/item/projectile/kinetic/super

/obj/item/ammo_casing/energy/kinetic/hyper
	projectile_type = /obj/item/projectile/kinetic/hyper

/obj/item/ammo_casing/energy/disabler
	projectile_type = /obj/item/projectile/beam/disabler
	select_name  = "disable"
	e_cost = 500
	fire_sound = "sound/weapons/taser2.ogg"

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/item/projectile/plasma
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	delay = 15
	e_cost = 250

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/item/projectile/plasma/adv
	delay = 10
	e_cost = 100

/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/item/projectile/beam/wormhole
	e_cost = 0
	fire_sound = "sound/weapons/pulse3.ogg"
	var/obj/item/weapon/gun/energy/wormhole_projector/gun = null
	select_name = "blue"

/obj/item/ammo_casing/energy/wormhole/New(var/obj/item/weapon/gun/energy/wormhole_projector/wh)
	gun = wh

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/item/projectile/beam/wormhole/orange
	select_name = "orange"

/obj/item/ammo_casing/energy/bolt
	projectile_type = /obj/item/projectile/energy/bolt
	select_name = "bolt"
	e_cost = 5000
	fire_sound = 'sound/weapons/Genhit.ogg'

/obj/item/ammo_casing/energy/bolt/large
	projectile_type = /obj/item/projectile/energy/bolt/large
	select_name = "heavy bolt"

/obj/item/ammo_casing/energy/dart
	projectile_type = /obj/item/projectile/energy/dart
	fire_sound = 'sound/weapons/Genhit.ogg'
	e_cost = 5000
	select_name = "toxic dart"

/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/item/projectile/beam/instakill
	e_cost = 0
	select_name = "DESTROY"

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/item/projectile/beam/instakill/blue

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/item/projectile/beam/instakill/red

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/item/projectile/plasma
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/item/projectile/plasma/adv

/obj/item/ammo_casing/energy/shock_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg'
	e_cost = 2000
	select_name = "lightning beam"
	projectile_type = /obj/item/projectile/energy/shock_revolver

/obj/item/ammo_casing/energy/toxplasma
	projectile_type = /obj/item/projectile/energy/toxplasma
	fire_sound = "sound/weapons/taser2.ogg"
	select_name = "plasma dart"

/obj/item/ammo_casing/energy/clown
	projectile_type = /obj/item/projectile/clown
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	select_name = "clown"

/obj/item/ammo_casing/energy/sniper
	projectile_type = /obj/item/projectile/beam/sniper
	fire_sound = 'sound/weapons/marauder.ogg'
	delay = 50
	select_name = "snipe"

/obj/item/ammo_casing/energy/teleport
	projectile_type = /obj/item/projectile/energy/teleport
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 1250
	select_name = "teleport beam"
	var/teleport_target

/obj/item/ammo_casing/energy/teleport/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/teleport/newshot(teleport_target)
	..()

/obj/item/ammo_casing/energy/mimic
	projectile_type = /obj/item/projectile/mimic
	fire_sound = 'sound/weapons/bite.ogg'
	select_name = "gun mimic"

/obj/item/ammo_casing/energy/mimic/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/mimic/newshot(mimic_type)
	..()
