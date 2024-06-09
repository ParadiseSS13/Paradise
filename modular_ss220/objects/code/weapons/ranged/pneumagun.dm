//Pneumagun
/obj/item/gun/projectile/automatic/pneumaticgun
	name = "pneumatic rifle"
	desc = "Стандартное пневморужье с магазинным заряжанием."
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "pneumagun"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/pneuma
	magazine = new /obj/item/ammo_box/magazine/pneuma/pepper
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/gunshot_pneumatic.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 2
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()

/obj/item/gun/projectile/automatic/pneumaticgun/process_chamber(eject_casing = 0, empty_chamber = 1)
	..(eject_casing, empty_chamber)

/obj/item/gun/projectile/automatic/pneumaticgun/update_icon_state()
	var/obj/item/ammo_box/magazine/pneuma/M = magazine
	icon_state = "pneumagun[M ? "[M.col]" : ""]"
	item_state = icon_state

// Базовые боеприпасы для пневморужья
/obj/item/ammo_box/magazine/pneuma
	name = "pneumatic rifle magazine"
	desc = "Наполняется шариками с реагентом."
	caliber = "pneumatic"
	var/col = "_g"  // Цвет магазина (необходим для выбора скина)
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "pneumamag_g"
	ammo_type = /obj/item/ammo_casing/pneuma
	max_ammo = 12
	multiload = 0

/obj/item/ammo_casing/pneuma
	name = "pneumatic ball"
	desc = "Пустой пневматический шарик."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "pneumaball_g"
	caliber = "pneumatic"
	casing_drop_sound = null
	projectile_type = /obj/item/projectile/bullet/pneumaball
	muzzle_flash_strength = null
	harmful = FALSE

/obj/item/projectile/bullet/pneumaball
	name = "pneumatic ball"
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "pneumaball_g"
	stamina = 7
	damage = 1

/obj/item/projectile/bullet/pneumaball/New()
	..()
	create_reagents(15)
	reagents.set_reacting(FALSE)

/obj/item/projectile/bullet/pneumaball/on_hit(atom/target, blocked = 0)
	..(target, blocked)
	if(!iscarbon(target))
		return
	var/mob/living/carbon/H = target
	reagents.reaction(H)
	reagents.set_reacting(TRUE)
	reagents.handle_reactions()

// Боеприпасы для перцового типа пневморужья
/obj/item/ammo_box/magazine/pneuma/pepper
	ammo_type = /obj/item/ammo_casing/pneuma/pepper
	col = "_r"
	icon_state = "pneumamag_r"

/obj/item/ammo_casing/pneuma/pepper
	desc = "Шарик с капсаицином. Эффективно подходит для задержания преступников, не носящих очки."
	projectile_type = /obj/item/projectile/bullet/pneumaball/pepper
	icon_state = "pneumaball_r"

/obj/item/projectile/bullet/pneumaball/pepper
	icon_state = "pneumaball_r"

/obj/item/projectile/bullet/pneumaball/pepper/New()
	..()
	reagents.add_reagent("condensedcapsaicin", 15)

/datum/supply_packs/security/armory/pneumagun
	name = "Pneumatic Pepper Rifles Crate"
	contains = list(/obj/item/gun/projectile/automatic/pneumaticgun,
					/obj/item/gun/projectile/automatic/pneumaticgun,
					/obj/item/ammo_box/magazine/pneuma/pepper,
					/obj/item/ammo_box/magazine/pneuma/pepper)
	cost = 500
	containername = "pneumatic pepper rifles pack"

/datum/supply_packs/security/armory/pneumapepperballs
	name = "Pneumatic Pepper Rifle Ammunition Crate"
	contains = list(/obj/item/ammo_box/magazine/pneuma/pepper,
					/obj/item/ammo_box/magazine/pneuma/pepper,
					/obj/item/ammo_box/magazine/pneuma/pepper)
	cost = 250
	containername = "pneumatic pepper ammunition pack"
