/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	projectile_type = /obj/item/projectile/energy
	var/e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	fire_sound = 'sound/weapons/laser.ogg'
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/energy

/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/item/projectile/beam/laser
	muzzle_flash_color = LIGHT_COLOR_DARKRED
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/cyborg //to balance cyborg energy cost seperately
	e_cost = 250

/obj/item/ammo_casing/energy/lasergun
	projectile_type = /obj/item/projectile/beam/laser
	muzzle_flash_color = LIGHT_COLOR_DARKRED
	e_cost = 83
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/hos
	e_cost = 120

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/item/projectile/beam/practice
	select_name = "practice"
	harmful = FALSE

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
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE
	e_cost = 200
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/scatter/pulse
	projectile_type = /obj/item/projectile/beam/pulse
	e_cost = 200
	select_name = "ANNIHILATE"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/item/projectile/beam/lasertag/bluetag
	muzzle_flash_color = LIGHT_COLOR_BLUE
	select_name = "bluetag"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/item/projectile/beam/lasertag/redtag
	select_name = "redtag"
	harmful = FALSE

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/item/projectile/beam/xray
	muzzle_flash_color = LIGHT_COLOR_GREEN
	e_cost = 100
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/immolator
	projectile_type = /obj/item/projectile/beam/immolator
	fire_sound = 'sound/weapons/laser3.ogg'
	e_cost = 125

/obj/item/ammo_casing/energy/immolator/strong
	projectile_type = /obj/item/projectile/beam/immolator/strong
	e_cost = 125
	select_name = "precise"

/obj/item/ammo_casing/energy/immolator/strong/cyborg
	// Used by gamma ERT borgs
	e_cost = 1000 // 5x that of the standard laser, for 2.25x the damage (if 1/1 shots hit) plus ignite. Not energy-efficient, but can be used for sniping.

/obj/item/ammo_casing/energy/immolator/scatter
	projectile_type = /obj/item/projectile/beam/immolator/weak
	e_cost = 125
	pellets = 6
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/immolator/scatter/cyborg
	// Used by gamma ERT borgs
	e_cost = 1000 // 5x that of the standard laser, for 7.5x the damage (if 6/6 shots hit) plus ignite. Efficient only if you hit with at least 4/6 of the shots.

/obj/item/ammo_casing/energy/electrode
	projectile_type = /obj/item/projectile/energy/electrode
	muzzle_flash_color = "#FFFF00"
	select_name = "stun"
	fire_sound = 'sound/weapons/taser.ogg'
	e_cost = 200
	harmful = FALSE

/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/item/projectile/ion
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	select_name = "ion"
	fire_sound = 'sound/weapons/ionrifle.ogg'

/obj/item/ammo_casing/energy/ion/hos
	projectile_type = /obj/item/projectile/ion/weak
	e_cost = 300

/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/item/projectile/energy/declone
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name = "declone"
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/item/projectile/energy/mindflayer
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	select_name = "mindflayer"
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'
	muzzle_flash_color = LIGHT_COLOR_GREEN
	harmful = FALSE

/obj/item/ammo_casing/energy/flora/yield
	projectile_type = /obj/item/projectile/energy/florayield
	select_name = "yield"

/obj/item/ammo_casing/energy/flora/mut
	projectile_type = /obj/item/projectile/energy/floramut
	select_name = "mutation"

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/item/projectile/temp
	fire_sound = 'sound/weapons/pulse3.ogg'
	var/temp = 300

/obj/item/ammo_casing/energy/temp/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/temp/newshot()
	..(temp)

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/item/projectile/meteor
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	muzzle_flash_color = null
	select_name = "goddamn meteor"

/obj/item/ammo_casing/energy/disabler
	projectile_type = /obj/item/projectile/beam/disabler
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	select_name  = "disable"
	e_cost = 50
	fire_sound = 'sound/weapons/taser2.ogg'
	harmful = FALSE
	delay = 0.6 SECONDS

/obj/item/ammo_casing/energy/disabler/cyborg //seperate balancing for cyborg, again
	e_cost = 250

/obj/item/ammo_casing/energy/disabler/hos
	e_cost = 60

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/item/projectile/plasma
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	delay = 15
	e_cost = 25

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/item/projectile/plasma/adv
	delay = 10
	e_cost = 10

/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/item/projectile/beam/wormhole
	muzzle_flash_color = "#33CCFF"
	delay = 10
	e_cost = 100
	fire_sound = 'sound/weapons/pulse3.ogg'
	var/obj/item/gun/energy/wormhole_projector/gun = null
	select_name = "blue"
	harmful = FALSE

/obj/item/ammo_casing/energy/wormhole/New(obj/item/gun/energy/wormhole_projector/wh)
	. = ..()
	gun = wh

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/item/projectile/beam/wormhole/orange
	muzzle_flash_color = "#FF6600"
	select_name = "orange"

/obj/item/ammo_casing/energy/bolt
	projectile_type = /obj/item/projectile/energy/bolt
	muzzle_flash_color = null
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	select_name = "bolt"
	e_cost = 500
	fire_sound = 'sound/weapons/genhit.ogg'

/obj/item/ammo_casing/energy/bolt/large
	projectile_type = /obj/item/projectile/energy/bolt/large
	select_name = "heavy bolt"

/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/item/projectile/beam/instakill
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	e_cost = 0
	select_name = "DESTROY"

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/item/projectile/beam/instakill/blue
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/item/projectile/beam/instakill/red
	muzzle_flash_color = LIGHT_COLOR_DARKRED

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/item/projectile/plasma
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/item/projectile/plasma/adv

/obj/item/ammo_casing/energy/tesla_bolt
	fire_sound = 'sound/magic/lightningbolt.ogg'
	e_cost = 200
	select_name = "lightning beam"
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	projectile_type = /obj/item/projectile/energy/tesla_bolt

/obj/item/ammo_casing/energy/arc_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg' //New sound
	e_cost = 125 //8 shots?
	select_name = "lightning beam" //I guess
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE // Depends on sprite
	projectile_type = /obj/item/projectile/energy/arc_revolver
	///This number is randomly generated when the arc revolver is made. This ensures the beams only link to beams from the gun, one lower or higher than the number on the boosted object.
	var/random_link_number

/obj/item/ammo_casing/energy/arc_revolver/Initialize()
	. = ..()
	random_link_number = rand(1, 9999999)

/obj/item/ammo_casing/energy/arc_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/arc_revolver/P = BB
	P.charge_number = random_link_number
	random_link_number++

/obj/item/ammo_casing/energy/weak_plasma
	projectile_type = /obj/item/projectile/energy/weak_plasma
	e_cost = 75 // With no charging, 162.5 damage from 13 shots.
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	fire_sound = 'sound/weapons/taser2.ogg'
	select_name = null //If the select name is null, it does not send a message of switching modes to the user, important on the pistol.

/obj/item/ammo_casing/energy/charged_plasma
	projectile_type = /obj/item/projectile/energy/charged_plasma
	e_cost = 0 //Charge is used when you charge the gun. Prevents issues.
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	fire_sound = 'sound/weapons/marauder.ogg' //Should be different enough to get attention
	select_name = null

/obj/item/ammo_casing/energy/clown
	projectile_type = /obj/item/projectile/clown
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	select_name = "clown"

/obj/item/ammo_casing/energy/emitter
	projectile_type = /obj/item/projectile/beam/emitter
	muzzle_flash_color = LIGHT_COLOR_GREEN
	fire_sound = 'sound/weapons/emitter.ogg'
	e_cost = 100
	delay = 2 SECONDS // Lasers fire twice every second for 40 dps, this fires every 2 seconds for 15 dps. Seems fair, since every cyborg will have this with more shots?
	select_name = "emitter"

/obj/item/ammo_casing/energy/emitter/cyborg
	e_cost = 350 // about 42 shots on an engineering borg from a borging machine, Reads a lot better than it actually is because people miss shots and often your better abilities require charge as well
	delay = 1 SECONDS

/obj/item/ammo_casing/energy/bsg
	projectile_type = /obj/item/projectile/energy/bsg
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 10000
	select_name = null //No one is sticking this into another gun / so I don't have to rename 20 icon states
	delay = 4 SECONDS //Looooooong cooldown // Used to be 10 seconds, has been rebalanced to be normal firing rate now

/obj/item/ammo_casing/energy/teleport
	projectile_type = /obj/item/projectile/energy/teleport
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 250
	select_name = "teleport beam"
	var/teleport_target

/obj/item/ammo_casing/energy/teleport/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/teleport/newshot()
	..(teleport_target)

/obj/item/ammo_casing/energy/mimic
	projectile_type = /obj/item/projectile/mimic
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/bite.ogg'
	select_name = "gun mimic"
	var/mimic_type

/obj/item/ammo_casing/energy/mimic/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/mimic/newshot()
	..(mimic_type)

/obj/item/ammo_casing/energy/detective
	projectile_type = /obj/item/projectile/beam/laser/detective
	fire_sound = 'sound/weapons/gunshots/gunshot_det_energy.ogg'
	select_name = "disabler"

/obj/item/ammo_casing/energy/detective/tracker_warrant
	projectile_type = /obj/item/projectile/beam/laser/detective/tracker_warrant_shot
	e_cost = 50
	select_name = "tracker and warrant generator"

/obj/item/ammo_casing/energy/detective/overcharge
	projectile_type = /obj/item/projectile/beam/laser/detective/overcharged
	e_cost = 200
	select_name = "overcharged"

/obj/item/ammo_casing/energy/silencer_ammo
	projectile_type = /obj/item/projectile/beam/silencer
	muzzle_flash_effect = null
	select_name = "silencing dissidents"
	e_cost = 62.5 // 16 shots
	fire_sound = 'sound/weapons/silencer_laser.ogg'
