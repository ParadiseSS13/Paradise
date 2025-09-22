/obj/item/gun/projectile/automatic/sniper_rifle
	name = "\improper SR-31C sniper rifle"
	desc = "A powerful anti-materiel rifle produced by Aussec Armory, chambered in devastating .50 BMG."
	icon_state = "sniper"
	worn_icon_state = "sniper"
	inhand_icon_state = "sniper"
	recoil = 2
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_sound = 'sound/weapons/gunshots/gunshot_sniper.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 40
	burst_size = 1
	origin_tech = "combat=7"
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	execution_speed = 4 SECONDS
	var/zoomable = TRUE

/obj/item/gun/projectile/automatic/sniper_rifle/Initialize(mapload)
	. = ..()
	if(zoomable)
		AddComponent(/datum/component/scope, range_modifier = 2, flags = SCOPE_TURF_ONLY | SCOPE_NEED_ACTIVE_HAND)

/obj/item/gun/projectile/automatic/sniper_rifle/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(istype(chambered.BB, /obj/item/projectile/bullet/sniper) && !HAS_TRAIT(user, TRAIT_SCOPED))
		var/obj/item/projectile/bullet/sniper/S = chambered.BB
		if(S.non_zoom_spread)
			to_chat(user, "<span class='warning'>[src] must be zoomed in to fire this ammunition accurately!</span>")
			bonus_spread += S.non_zoom_spread
	return ..()

/obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	name = "\improper SR-31C (S) Sniper Rifle"
	desc = "A powerful anti-materiel rifle by Aussec Armory, chambered in devastating .50 BMG. This model is engraved with superficial Syndicate iconography."
	origin_tech = "combat=7;syndicate=6"

/obj/item/gun/projectile/automatic/sniper_rifle/update_icon_state()
	if(magazine)
		icon_state = "sniper-mag"
	else
		icon_state = "sniper"

//Normal Boolets
/obj/item/ammo_box/magazine/sniper_rounds
	name = "sniper rounds (.50)"
	icon_state = ".50mag"
	origin_tech = "combat=6;syndicate=2"
	ammo_type = /obj/item/ammo_casing/point50
	max_ammo = 6
	caliber = ".50"

/obj/item/ammo_box/magazine/sniper_rounds/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_casing/point50
	name = ".50 BMG round"
	desc = "A .50 BMG rifle cartridge, commonly used in anti-materiel rifles and heavy machine guns."
	icon_state = "heavy_steel"
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/projectile/bullet/sniper
	damage = 70
	weaken = 10 SECONDS
	armor_penetration_flat = 70
	forced_accuracy = TRUE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSGIRDER
	speed = 0.5
	var/non_zoom_spread = 0

/obj/item/ammo_box/magazine/sniper_rounds/antimatter
	name = "sniper rounds (Antimatter)"
	desc = "Antimatter sniper rounds, for when you really don't like something. Requires zooming in to fire accurately."
	icon_state = "antimatter"
	ammo_type = /obj/item/ammo_casing/antimatter

/obj/item/ammo_casing/antimatter
	name = ".50 BMG anti-matter round"
	desc = "A .50 BMG high-explosive cartridge. Does not actually contain antimatter."
	icon_state = "heavy_steel_incin"
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/antimatter

/obj/item/projectile/bullet/sniper/antimatter
	name = "antimatter bullet"
	dismemberment = 50
	non_zoom_spread = 60

/obj/item/projectile/bullet/sniper/antimatter/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target)))
		target.ex_act(rand(1,2))

	return ..()

//Sleepy ammo
/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = "sniper rounds (Zzzzz)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	origin_tech = "combat=6;syndicate=3"
	ammo_type = /obj/item/ammo_casing/soporific
	max_ammo = 3

/obj/item/ammo_casing/soporific
	name = ".50 BMG soporific round"
	desc = "A .50 BMG hypodermic cartridge, loaded with sedatives for instant incapacitation."
	icon_state = "heavy_steel_rubber"
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/soporific
	harmful = FALSE

/obj/item/projectile/bullet/sniper/soporific
	armor_penetration_flat = 0
	nodamage = 1
	weaken = 0

/obj/item/projectile/bullet/sniper/soporific/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.SetSleeping(40 SECONDS)

	return ..()

//hemorrhage ammo
/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage
	name = "sniper rounds (Bleed)"
	desc = "Haemorrhage sniper rounds, leaves your target in a pool of crimson pain."
	icon_state = "haemorrhage"
	ammo_type = /obj/item/ammo_casing/haemorrhage
	max_ammo = 5

/obj/item/ammo_casing/haemorrhage
	name = ".50 BMG shredder round"
	desc = "A .50 BMG 'Shredder' cartridge, with a heavily serrated bullet intended to cause massive blood loss."
	icon_state = "heavy_steel_hollow"
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/haemorrhage

/obj/item/projectile/bullet/sniper/haemorrhage
	armor_penetration_flat = 25
	damage = 45
	weaken = 6 SECONDS

/obj/item/projectile/bullet/sniper/haemorrhage/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(150)

	return ..()

//penetrator ammo
/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "sniper rounds (penetrator)"
	desc = "An extremely powerful round capable of passing straight through cover and anyone unfortunate enough to be behind it."
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/penetrator
	origin_tech = "combat=6;syndicate=3"
	max_ammo = 5

/obj/item/ammo_casing/penetrator
	name = ".50 BMG sabot round"
	desc = "A .50 BMG Sabot Penetrator cartridge, capable of punching through just about anything."
	icon_state = "heavy_steel_ap"
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet/sniper/penetrator

/obj/item/projectile/bullet/sniper/penetrator
	icon_state = "gauss"
	name = "penetrator round"
	damage = 60
	forcedodge = -1
	weaken = 0
	speed = 0.75
	pass_flags = PASSTABLE //damage glass

//toy magazine
/obj/item/ammo_box/magazine/toy/sniper_rounds
	name = "donksoft Sniper magazine"
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	max_ammo = 6
	caliber = "foam_force_sniper"

/obj/item/ammo_box/magazine/toy/sniper_rounds/update_icon_state()
	return

/obj/item/ammo_box/magazine/toy/sniper_rounds/update_overlays()
	. = ..()
	var/ammo = ammo_count()
	if(ammo && istype(contents[length(contents)], /obj/item/ammo_casing/caseless/foam_dart/sniper/riot))
		. += ".50mag-r"
	else if(ammo)
		. += ".50mag-f"
