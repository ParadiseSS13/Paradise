/obj/item/organ/internal/cyberimp/arm/badass
	name = "badassery implant"
	contents = newlist(/obj/item/gun/projectile/automatic/badass_shotgun, /obj/item/gun/energy/plasmagun, /obj/item/gun/projectile/automatic/chain_gun, /obj/item/gun/projectile/automatic/rocket_launcher, /obj/item/gun/energy/bsg/prebuilt/admin/mk9000)

/obj/item/organ/internal/cyberimp/arm/badass/New()
	. = ..()
	var/obj/item/twohanded/required/chainsaw/doomslayer/badass/B = new(src)
	B.forceMove(src)
	items_list += B // this is needed to have the direct ref to the implant on the chainsaw. probably a better way of doing this but oh well

/obj/item/twohanded/required/chainsaw/doomslayer/badass
	on = TRUE
	icon_state = "OOOHBABY_off"
	icon_base = "OOOHBABY_"
	force = 30
	hitsound = 'sound/weapons/chainsaw.ogg'
	var/obj/item/organ/internal/cyberimp/arm/badass/implant

/obj/item/twohanded/required/chainsaw/doomslayer/badass/New(obj/item/organ/internal/cyberimp/arm/badass/B)
	. = ..()
	implant = B

/obj/item/twohanded/required/chainsaw/doomslayer/badass/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity)
		return

	for(var/obj/item/gun/G in implant)
		if(istype(G, /obj/item/gun/projectile/automatic))
			var/obj/item/gun/projectile/automatic/A = G
			qdel(A.magazine)
			A.magazine = new A.mag_type(src)
			A.chamber_round()
			A.update_icon()
		else
			var/obj/item/gun/energy/E = G
			E.cell.charge = E.cell.maxcharge

/obj/item/gun/projectile/automatic/badass_shotgun
	name = "Extremely badass shotgun"
	desc = "You feel extremely badass holding this."
	icon_state = "badass_shotgun"
	item_state = "badass_shotgun"
	lefthand_file = 'icons/mob/inhands/64x64_guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/badass_shotgun_shells
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	burst_size = 2
	inhand_x_dimension = 64
	inhand_y_dimension = 64

/obj/item/gun/projectile/automatic/badass_shotgun/attack_self(mob/living/user)
	return

/obj/item/gun/projectile/automatic/badass_shotgun/update_icon()
	return

/obj/item/ammo_box/magazine/badass_shotgun_shells
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 12

/obj/item/gun/energy/plasmagun
	name = "plasma rifle"
	desc = "An extremely high tech piece of technology which fires self containing balls of plasma."
	icon_state = "plasma_rifle"
	item_state = "plasma_rifle"
	cell_type = /obj/item/stock_parts/cell/pulse/carbine
	ammo_type = list(/obj/item/ammo_casing/energy/plasma_rifle)
	burst_size = 5
	fire_delay = 8
	spread = 15

/obj/item/gun/energy/plasmagun/update_icon()
	return

/obj/item/ammo_casing/energy/plasma_rifle
	e_cost = 50
	delay = 0.1 SECONDS
	projectile_type = /obj/item/projectile/energy/plasma_rifle
	muzzle_flash_color = "#33CCFF"

/obj/item/projectile/energy/plasma_rifle
	name = "plasma bolt"
	damage = 15
	speed = 0.5
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	icon_state = "spark"
	color = "#33CCFF"

/obj/item/gun/projectile/automatic/chain_gun
	name = "chaingun"
	desc = "A high rate of fire murder machine."
	icon_state = "chaingun"
	item_state = "chaingun"
	burst_size = 10
	fire_delay = 2
	spread = 2
	mag_type = /obj/item/ammo_box/magazine/chaingun

/obj/item/gun/projectile/automatic/chain_gun/attack_self(mob/living/user)
	return

/obj/item/gun/projectile/automatic/chain_gun/update_icon()
	return

/obj/item/gun/projectile/automatic/chain_gun/shoot_live_shot(mob/living/user, atom/target, pointblank, message)
	. = ..()
	flick("chaingun_on", src)

/obj/item/ammo_box/magazine/chaingun
	max_ammo = 60
	ammo_type = /obj/item/ammo_casing/mm556x45/chaingun

/obj/item/ammo_casing/mm556x45/chaingun
	projectile_type = /obj/item/projectile/bullet/chaingun

/obj/item/projectile/bullet/chaingun
	damage = 15
	armour_penetration = -20
	forcedodge = TRUE //this variable name is stupid

/obj/item/projectile/bullet/chaingun/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!isliving(target))
		forcedodge = FALSE
	else if(range > 3)
		range = 3 //goes 4 tiles through someone

/obj/item/gun/projectile/automatic/rocket_launcher
	name = "Rocket launcher"
	desc = "point it at something, it goes boom. now with 99% less shitcode"
	icon_state = "rocket_launcher"
	item_state = "rocket_launcher"
	fire_sound = 'sound/effects/bang.ogg'
	fire_delay = 10
	burst_size = 1
	mag_type = /obj/item/ammo_box/magazine/rockets

/obj/item/gun/projectile/automatic/rocket_launcher/attack_self(mob/living/user)
	return

/obj/item/gun/projectile/automatic/rocket_launcher/update_icon()
	return

/obj/item/ammo_box/magazine/rockets
	max_ammo = 4
	ammo_type = /obj/item/ammo_casing/rocket_but_not_shitcode

/obj/item/ammo_casing/rocket_but_not_shitcode
	icon_state = null
	projectile_type = /obj/item/projectile/bullet/rocket
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/projectile/bullet/rocket
	icon = 'icons/obj/grenade.dmi'
	icon_state = "missile"

/obj/item/projectile/bullet/rocket/on_hit(atom/target, blocked, hit_zone)
	target.ex_act(EXPLODE_HEAVY) //boom times two
	explosion(target, 0, 0, 3, 5, 4)
	..()

/obj/item/gun/energy/bsg/prebuilt/admin/mk9000
	name = "BSG mk-9000"
	item_state = "BFG"
	icon_state = "BFG"
	desc = "The somehow more advanced BSG."
	ammo_type = list(/obj/item/ammo_casing/energy/bsg/badass)
	burst_size = 4

/obj/item/gun/energy/bsg/prebuilt/admin/mk9000/update_icon()
	return // STOP STEALING MY SPRITE

/obj/item/ammo_casing/energy/bsg/badass
	delay = 0.5 SECONDS //shoooooooooooooooort cooldown

/obj/item/clothing/head/helmet/space/badass
	name = "badass helm"
	desc = "A highly advanced and badass looking helmet."
	icon_state = "badass_helm"
	item_state = "badass_helm"
	w_class = WEIGHT_CLASS_SMALL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flags = THICKMATERIAL
	armor = list(MELEE = 70, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | LAVA_PROOF

/obj/item/clothing/suit/space/badass
	name = "badass suit"
	desc = "A highly advanced and badass looking suit."
	icon_state = "badass_suit"
	item_state = "badass_suit"
	slowdown = 0
	w_class = WEIGHT_CLASS_SMALL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flags = THICKMATERIAL
	armor = list(MELEE = 70, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | LAVA_PROOF
