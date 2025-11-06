//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
/obj/item/gun/projectile/revolver/grenadelauncher
	name = "grenade launcher"
	desc = "A break-action grenade launcher."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "dbshotgun_sawn"
	inhand_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	can_holster = FALSE  // Not your normal revolver

/obj/item/gun/projectile/revolver/grenadelauncher/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()

/obj/item/gun/projectile/revolver/grenadelauncher/multi
	desc = "A revolving 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon_state = "bulldog"
	inhand_icon_state = "bulldog"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg
	desc = "A 15-shot grenade launcher."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi/fifteen

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg/attack_self__legacy__attackchain()
	return

/obj/item/gun/projectile/automatic/gyropistol
	name = "\improper MX2000 gyrojet pistol"
	desc = "A prototype pistol designed by Sunburst Heavy Industries, intended to fire self-propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/explosion1.ogg'
	origin_tech = "combat=5"
	mag_type = /obj/item/ammo_box/magazine/m75
	can_holster = TRUE // Override default automatic setting since it is a handgun sized gun
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/gyropistol/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/gyropistol/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"

/obj/item/gun/projectile/automatic/speargun
	name = "kinetic speargun"
	desc = "A weapon favored by carp hunters. Fires specialized spears using kinetic energy."
	icon_state = "speargun"
	worn_icon_state = "speargun"
	inhand_icon_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	origin_tech = "combat=4;engineering=4"
	force = 10
	can_suppress = FALSE
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/speargun/update_icon_state()
	return

/obj/item/gun/projectile/automatic/speargun/attack_self__legacy__attackchain()
	return

/obj/item/gun/projectile/automatic/speargun/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/speargun/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby__legacy__attackchain(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] spear\s into \the [src].</span>")
		update_icon()
		chamber_round()
