//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika


/obj/item/weapon/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/Explosion1.ogg'
	origin_tech = "combat=3"
	mag_type = "/obj/item/ammo_box/magazine/m75"
	burst_size = 1
	fire_delay = 0
	
/obj/item/weapon/gun/projectile/automatic/gyropistol/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/gyropistol/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/weapon/gun/projectile/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun-sawn"
	item_state = "gun"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	w_class = 3

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/attackby(var/obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/multi
	desc = "A revolving 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon_state = "bulldog"
	item_state = "bulldog"
	mag_type = "/obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi"

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/multi/cyborg
	desc = "A 6-shot grenade launcher."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"

/obj/item/weapon/gun/projectile/revolver/grenadelauncher/multi/cyborg/attack_self()
	return