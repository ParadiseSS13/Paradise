/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 2
	is_reflectable = TRUE
	light_range = 2
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/beam/laser

/obj/item/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40

/obj/item/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = 1
	log_override = TRUE

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 15
	tile_dropoff = 0.75
	irradiate = 30
	forcedodge = 1
	range = 15
	light_color = LIGHT_COLOR_GREEN

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 36
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	light_color = LIGHT_COLOR_CYAN

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	light_color = LIGHT_COLOR_DARKBLUE

/obj/item/projectile/beam/pulse/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target,/turf/)||istype(target,/obj/structure/))
		target.ex_act(2)
	..()

/obj/item/projectile/beam/pulse/shot
	damage = 40

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	legacy = 1
	animate_movement = SLIDE_STEPS
	light_color = LIGHT_COLOR_GREEN

/obj/item/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/item/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = 1
	damage_type = STAMINA
	flag = "laser"
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	log_override = TRUE
	light_color = LIGHT_COLOR_DARKBLUE

/obj/item/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)
	return 1

/obj/item/projectile/beam/lasertag/omni
	name = "laser tag beam"
	icon_state = "omnilaser"

/obj/item/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "sniperlaser"
	damage = 60
	stun = 5
	weaken = 5
	stutter = 5
	light_color = LIGHT_COLOR_PINK

/obj/item/projectile/beam/immolator
	name = "immolation beam"

/obj/item/projectile/beam/immolator/strong
	name = "heavy immolation beam"
	damage = 45
	icon_state = "heavylaser"

/obj/item/projectile/beam/immolator/weak
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"

/obj/item/projectile/beam/immolator/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	light_color = LIGHT_COLOR_PURPLE

/obj/item/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	light_color = LIGHT_COLOR_DARKBLUE

/obj/item/projectile/beam/instakill/red
	icon_state = "red_laser"
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.visible_message("<span class='danger'>[L] explodes!</span>")
		L.gib()