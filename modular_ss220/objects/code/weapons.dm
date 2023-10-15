// Colt Anaconda .44

/obj/item/gun/projectile/revolver/anaconda
	name = "Анаконда"
	desc = "Крупнокалиберный револьвер двадцатого века. Несмотря на то, что оружие хранилось в хороших условиях, старина даёт о себе знать."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/d44
	lefthand_file = 'modular_ss220/objects/icons/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/guns_righthand.dmi'
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "anaconda"

/obj/item/gun/projectile/revolver/anaconda/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/box_d44))
		return
	return ..()

/obj/item/gun/projectile/revolver/anaconda/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	bonus_spread += 30
	. = ..()

/obj/item/ammo_box/magazine/internal/cylinder/d44
	name = ".44 revolver cylinder"
	ammo_type = /obj/item/ammo_casing/d44
	caliber = "44"
	max_ammo = 6

/obj/item/ammo_casing/d44
	desc = "A .44 bullet casing."
	caliber = "44"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "casing44"
	projectile_type = /obj/item/projectile/bullet/d44
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/projectile/bullet/d44
	name = ".44 bullet"
	icon_state = "bullet"
	damage = 50
	damage_type = BRUTE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/item/ammo_box/speed_loader_d44
	name = "speed loader (.44)"
	desc = "Designed to quickly reload revolvers."
	ammo_type = /obj/item/ammo_casing/d44
	max_ammo = 6
	multi_sprite_step = 1
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "44"

/obj/item/ammo_box/box_d44
	name = "ammo box (.44)"
	desc = "Contains up to 24 .44 cartridges, intended to either be inserted into a speed loader or into the gun manually."
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/d44
	max_ammo = 24
	icon_state = "44_box"

/obj/structure/displaycase/hos
	alert = TRUE
	start_showpiece_type = /obj/item/gun/projectile/revolver/anaconda
	req_access = list(ACCESS_HOS)

// RSH-12 12.7

/obj/item/gun/projectile/revolver/rsh12
	name = "РШ-12"
	desc = "Тяжёлый револьвер винтовочного калибра с, откидным вниз для более удобного заряжания, стволом. По слухам, всё ещё находится на вооружении у СССП."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rsh12
	lefthand_file = 'modular_ss220/objects/icons/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/guns_righthand.dmi'
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "rsh12"
	item_state = "rsh12"
	var/reclined = FALSE

/obj/item/gun/projectile/revolver/rsh12/attack_self(mob/living/user)
	reclined = !reclined
	update_icon()
	if(reclined)
		return ..()

/obj/item/gun/projectile/revolver/rsh12/update_icon_state()
	icon_state = initial(icon_state) + (reclined ? "_reclined" : "")

/obj/item/gun/projectile/revolver/rsh12/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/box_mm127))
		return
	if(!reclined)
		return
	return ..()

/obj/item/ammo_box/magazine/internal/cylinder/rsh12
	name = "12.7mm revolver cylinder"
	ammo_type = /obj/item/ammo_casing/mm127
	caliber = "127mm"
	max_ammo = 5

/obj/item/ammo_casing/mm127
	desc = "A 12.7mm bullet casing."
	caliber = "127mm"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "casing127mm"
	projectile_type = /obj/item/projectile/bullet/mm127
	muzzle_flash_strength = MUZZLE_FLASH_RANGE_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/projectile/bullet/mm127
	name = "127mm bullet"
	icon_state = "bullet"
	damage = 75
	damage_type = BRUTE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/item/projectile/bullet/mm127/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(L.move_resist == INFINITY)
		return
	var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, starting)))
	L.throw_at(throw_target, 2, 2)

/obj/item/ammo_box/speed_loader_mm127
	name = "speed loader (12.7mm)"
	desc = "Designed to quickly reload... is it a revolver speedloader with rifle cartidges in it?"
	ammo_type = /obj/item/ammo_casing/mm127
	max_ammo = 5
	multi_sprite_step = 1
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "mm127"

/obj/item/ammo_box/box_mm127
	name = "ammo box (12.7)"
	desc = "Contains up to 100 12.7mm cartridges."
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = /obj/item/ammo_casing/mm127
	max_ammo = 100
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "mm127_box"
