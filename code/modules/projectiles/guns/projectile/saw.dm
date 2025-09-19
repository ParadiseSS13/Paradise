/obj/item/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A next-generation medium machine gun designed by Aussec Armory for CQB use aboard ships and stations. Chambered in 7.62x51mm Federal."
	icon_state = "l6closed100"
	inhand_icon_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/mm762x51
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	magin_sound = 'sound/weapons/gun_interactions/lmg_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/lmg_magout.ogg'
	actions_types = list()
	can_suppress = FALSE
	burst_size = 1
	spread = 7
	fire_delay = 0
	var/cover_open = FALSE

/obj/item/gun/projectile/automatic/l6_saw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/projectile/automatic/l6_saw/attack_self__legacy__attackchain(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	playsound(src, cover_open ? 'sound/weapons/gun_interactions/sawopen.ogg' : 'sound/weapons/gun_interactions/sawclose.ogg', 50, 1)
	update_icon()

/obj/item/gun/projectile/automatic/l6_saw/update_icon_state()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? CEILING(get_ammo(FALSE) / 12.5, 1) * 25 : "-empty"][suppressed ? "-suppressed" : ""]"
	inhand_icon_state = "l6[cover_open ? "open" : "closed"][magazine ? "mag" : ""]"

/obj/item/gun/projectile/automatic/l6_saw/afterattack__legacy__attackchain(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is open! Close it before firing!</span>")
	else
		..()
		update_icon()

/obj/item/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(loc)
		user.put_in_hands(magazine)
		magazine = null
		playsound(src, magout_sound, 50, 1)
		update_icon()
		if(user.hand)
			user.update_inv_r_hand()
		else
			user.update_inv_l_hand()
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")

/obj/item/gun/projectile/automatic/l6_saw/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			if(!cover_open)
				to_chat(user, "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>")
				return
	return ..()

//ammo//

/obj/item/projectile/bullet/saw
	damage = 45
	armor_penetration_flat = 5

/obj/item/projectile/bullet/saw/bleeding
	damage = 20
	armor_penetration_flat = 0

/obj/item/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(35)

/obj/item/projectile/bullet/saw/hollow
	damage = 60
	armor_penetration_flat = -30

/obj/item/projectile/bullet/saw/ap
	damage = 40
	armor_penetration_percentage = 100

/obj/item/projectile/bullet/saw/incen
	damage = 7
	armor_penetration_flat = 0
	immolate = 3

/obj/item/projectile/bullet/saw/incen/Move()
	..()
	var/turf/location = get_turf(src)
	if(location)
		var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
		hotspot.temperature = 1000
		hotspot.recolor()
		location.hotspot_expose(700, 50)

//magazines//

/obj/item/ammo_box/magazine/mm762x51
	name = "box magazine (7.62x51mm FMJ)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/mm762x51
	caliber = "mm762x51"
	max_ammo = 50
	multi_sprite_step = 10

/obj/item/ammo_box/magazine/mm762x51/bleeding
	name = "box magazine (7.62x51mm Shredder)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/mm762x51/bleeding

/obj/item/ammo_box/magazine/mm762x51/hollow
	name = "box magazine (7.62x51mm Hollowpoint)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/mm762x51/hollow

/obj/item/ammo_box/magazine/mm762x51/ap
	name = "box magazine (7.62x51mm Armor-Piercing)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/mm762x51/ap

/obj/item/ammo_box/magazine/mm762x51/incen
	name = "box magazine (7.62x51mm Incendiary)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/mm762x51/incen

//casings//

/obj/item/ammo_casing/mm762x51
	name = "7.62x51mm round"
	desc = "A 7.62x51mm full-metal jacket rifle cartridge, commonly used in general-purpose machine guns."
	icon_state = "rifle_brass"
	caliber = "mm762x51"
	projectile_type = /obj/item/projectile/bullet/saw
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/mm762x51/bleeding
	name = "7.62x51mm 'Shredder' round"
	desc = "A 7.62x51mm 'Shredder' cartridge, with a heavily serrated tip intended to cause massive bleeding."
	icon_state = "rifle_brass_surplus"
	projectile_type = /obj/item/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/mm762x51/hollow
	name = "7.62x51mm hollow point round"
	desc = "A 7.62x51mm rifle cartridge designed to cause more damage to unarmored targets."
	icon_state = "rifle_brass_hollow"
	projectile_type = /obj/item/projectile/bullet/saw/hollow

/obj/item/ammo_casing/mm762x51/ap
	name = "7.62x51mm armor-piercing round"
	desc = "A 7.62x51mm rifle cartridge with a hardened tungsten core to increase armor penetration."
	icon_state = "rifle_brass_ap"
	projectile_type = /obj/item/projectile/bullet/saw/ap

/obj/item/ammo_casing/mm762x51/incen
	name = "7.62x51mm incendiary round"
	desc = "A 7.62x51mm rifle cartridge with an incendiary chemical payload."
	icon_state = "rifle_brass_incin"
	projectile_type = /obj/item/projectile/bullet/saw/incen
	muzzle_flash_color = LIGHT_COLOR_FIRE
