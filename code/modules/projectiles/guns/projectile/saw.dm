/obj/item/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 5.56 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/mm556x45
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	magin_sound = 'sound/weapons/gun_interactions/lmg_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/lmg_magout.ogg'
	var/cover_open = FALSE
	actions_types = list()
	can_suppress = FALSE
	burst_size = 1
	spread = 7
	fire_delay = 0

/obj/item/gun/projectile/automatic/l6_saw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	playsound(src, cover_open ? 'sound/weapons/gun_interactions/sawopen.ogg' : 'sound/weapons/gun_interactions/sawclose.ogg', 50, 1)
	update_icon()

/obj/item/gun/projectile/automatic/l6_saw/update_icon_state()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? CEILING(get_ammo(0)/12.5, 1)*25 : "-empty"][suppressed ? "-suppressed" : ""]"
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"

/obj/item/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
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
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")


/obj/item/gun/projectile/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
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
	armour_penetration_flat = 5

/obj/item/projectile/bullet/saw/bleeding
	damage = 20
	armour_penetration_flat = 0

/obj/item/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(35)

/obj/item/projectile/bullet/saw/hollow
	damage = 60
	armour_penetration_flat = -30

/obj/item/projectile/bullet/saw/ap
	damage = 40
	armour_penetration_percentage = 100

/obj/item/projectile/bullet/saw/incen
	damage = 7
	armour_penetration_flat = 0
	immolate = 3

/obj/item/projectile/bullet/saw/incen/Move()
	..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

//magazines//

/obj/item/ammo_box/magazine/mm556x45
	name = "box magazine (5.56x45mm)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/mm556x45
	caliber = "mm55645"
	max_ammo = 50
	multi_sprite_step = 10

/obj/item/ammo_box/magazine/mm556x45/bleeding
	name = "box magazine (Bleeding 5.56x45mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/mm556x45/bleeding

/obj/item/ammo_box/magazine/mm556x45/hollow
	name = "box magazine (Hollow-Point 5.56x45mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/mm556x45/hollow

/obj/item/ammo_box/magazine/mm556x45/ap
	name = "box magazine (Armor Penetrating 5.56x45mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/mm556x45/ap

/obj/item/ammo_box/magazine/mm556x45/incen
	name = "box magazine (Incendiary 5.56x45mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/mm556x45/incen

//casings//

/obj/item/ammo_casing/mm556x45
	name = "5.56x45mm round"
	desc = "A 5.56x45mm rifle cartridge, commonly used in light machine guns."
	icon_state = "762-casing"
	caliber = "mm55645"
	projectile_type = /obj/item/projectile/bullet/saw
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/mm556x45/bleeding
	name = "5.56x45mm 'Shredder' round"
	desc = "A 5.56x45mm 'Shredder' cartridge, with a heavily serrated tip intended to cause massive bleeding."
	icon_state = "762-casing"
	projectile_type = /obj/item/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/mm556x45/hollow
	name = "5.56x45mm hollow point round"
	desc = "A 5.56x45mm rifle cartridge designed to cause more damage to unarmored targets."
	projectile_type = /obj/item/projectile/bullet/saw/hollow

/obj/item/ammo_casing/mm556x45/ap
	name = "5.56x45mm armor piercing round"
	desc = "A 5.56x45mm rifle cartridge with a hardened tungsten core to increase armor penetration."
	projectile_type = /obj/item/projectile/bullet/saw/ap

/obj/item/ammo_casing/mm556x45/incen
	name = "5.56x45mm incendiary round"
	desc = "A 5.56x45mm rifle cartridge with an incendiary chemical payload."
	projectile_type = /obj/item/projectile/bullet/saw/incen
	muzzle_flash_color = LIGHT_COLOR_FIRE
