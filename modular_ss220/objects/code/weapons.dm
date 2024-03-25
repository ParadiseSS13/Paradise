// Base heavy revolver
/obj/item/gun/projectile/revolver/reclinable
	var/snapback_sound = 'modular_ss220/objects/sound/weapons/cylinder/snapback_rsh12.ogg'
	var/reclined_sound = 'modular_ss220/objects/sound/weapons/cylinder/reclined_rsh12.ogg'
	var/dry_fire_sound = 'sound/weapons/empty.ogg'
	var/reclined = FALSE

/obj/item/gun/projectile/revolver/reclinable/attack_self(mob/living/user)
	reclined = !reclined
	playsound(user, reclined ? reclined_sound : snapback_sound, 50, 1)
	update_icon()

	if(reclined)
		return ..()

/obj/item/gun/projectile/revolver/reclinable/update_icon_state()
	icon_state = initial(icon_state) + (reclined ? "_reclined" : "")

/obj/item/gun/projectile/revolver/reclinable/attackby(obj/item/A, mob/user, params)
	if(!reclined)
		return
	return ..()

/obj/item/gun/projectile/revolver/reclinable/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(!reclined)
		return ..()

	to_chat(user, "<span class='danger'>*click*</span>")
	playsound(user, dry_fire_sound, 100, 1)

// Colt Anaconda .44
/obj/item/gun/projectile/revolver/reclinable/anaconda
	name = "Анаконда"
	desc = "Крупнокалиберный револьвер двадцатого века. Несмотря на то, что оружие хранилось в хороших условиях, старина даёт о себе знать."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/d44
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "anaconda"
	item_state = "anaconda"
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/gunshot_anaconda.ogg'

/obj/item/gun/projectile/revolver/reclinable/anaconda/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/box_d44))
		return
	return ..()

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
	spread = 20

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
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "44_box"

// RSH-12 12.7
/obj/item/gun/projectile/revolver/reclinable/rsh12
	name = "РШ-12"
	desc = "Тяжёлый револьвер винтовочного калибра с откидным стволом. По слухам, всё ещё находится на вооружении у СССП."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rsh12
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "rsh12"
	item_state = "rsh12"
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/gunshot_rsh12.ogg'

/obj/item/gun/projectile/revolver/reclinable/rsh12/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/box_mm127))
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

// Горохострел
/obj/item/gun/projectile/revolver/peas_shooter
	name = "Peas shooter"
	desc = "Живой горох! Может стрелять горошинами, которые наносят слабый урон самооценке."
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "peas_shooter"
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/peas_shooter_gunshot.ogg'
	drop_sound = 'modular_ss220/objects/sound/weapons/drop/peas_shooter_drop.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/peas_shooter

/obj/item/ammo_box/magazine/peas_shooter
	name = "peacock shooter magazine"
	desc = "хранилище горошин для горохострела, вмещает до 6 горошин за раз."
	ammo_type = /obj/item/ammo_casing/peas_shooter
	max_ammo = 6

/obj/item/ammo_casing/peas_shooter
	name = "pea bullet"
	desc = "Пуля из гороха, не может нанести какого-либо ощутимого урона."
	projectile_type = /obj/item/projectile/bullet/midbullet_r/peas_shooter
	icon_state = "peashooter_bullet"

// Пуля горохострела
/obj/item/projectile/bullet/midbullet_r/peas_shooter
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	item_state = "peashooter_bullet"
	stamina = 5
	damage_type = STAMINA

/obj/item/projectile/bullet/midbullet_r/peas_shooter/on_hit(mob/H)
	. = ..()
	if(prob(15))
		H.emote("moan")

// Тактическая бита Флота Nanotrasen
/obj/item/melee/baseball_bat/homerun/central_command
	name = "тактическая бита Флота Nanotrasen"
	desc = "Выдвижная тактическая бита Центрального Командования Nanotrasen. \
	В официальных документах эта бита проходит под элегантным названием \"Высокоскоростная система доставки СРП\". \
	Выдаваясь только самым верным и эффективным офицерам Nanotrasen, это оружие является одновременно символом статуса \
	и инструментом высшего правосудия."
	slot_flags = SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_SMALL

	var/on = FALSE
	/// Force when concealed
	force = 5
	/// Force when extended
	var/force_on = 20

	lefthand_file = 'modular_ss220/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/melee_righthand.dmi'
	icon = 'modular_ss220/objects/icons/melee.dmi'
	/// Item state when concealed
	item_state = "centcom_bat_0"
	/// Item state when extended
	var/item_state_on = "centcom_bat_1"
	/// Icon state when concealed
	icon_state = "centcom_bat_0"
	/// Icon state when extended
	var/icon_state_on = "centcom_bat_1"
	/// Sound to play when concealing or extending
	var/extend_sound = 'sound/weapons/batonextend.ogg'
	/// Attack verbs when concealed (created on Initialize)
	attack_verb = list("hit", "poked")
	/// Attack verbs when extended (created on Initialize)
	var/list/attack_verb_on = list("smacked", "struck", "cracked", "beaten")

/obj/item/melee/baseball_bat/homerun/central_command/pickup(mob/living/user)
	. = ..()
	if(!(user.mind.offstation_role))
		user.Weaken(10 SECONDS)
		user.unEquip(src, force, silent = FALSE)
		to_chat(user, span_userdanger("Это - оружие истинного правосудия. Тебе не дано обуздать его мощь."))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			user.adjustBruteLoss(rand(force/2, force))

/obj/item/melee/baseball_bat/homerun/central_command/attack_self(mob/user)
	on = !on

	if(on)
		to_chat(user, span_userdanger("Вы активировали [src.name] - время для правосудия!"))
		item_state = item_state_on
		icon_state = icon_state_on
		w_class = WEIGHT_CLASS_HUGE
		force = force_on
		attack_verb = attack_verb_on
	else
		to_chat(user, span_notice("Вы деактивировали [src.name]."))
		item_state = initial(item_state)
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		force = initial(force)
		attack_verb = initial(attack_verb)

	homerun_able = on
	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(loc, extend_sound, 50, TRUE)
	add_fingerprint(user)

/obj/item/melee/baseball_bat/homerun/central_command/attack(mob/living/target, mob/living/user)
	if(on)
		homerun_ready = TRUE
	. = ..()

//Pneumagun
/obj/item/gun/projectile/automatic/pneumaticgun
	name = "Пневморужье"
	desc = "Стандартное пневморужье"
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
	name = "магазин пневморужья"
	desc = "Наполняется шариками с реагентом."
	caliber = "pneumatic"
	var/col = "_g"  // Цвет магазина (необходим для выбора скина)
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "pneumamag_g"
	ammo_type = /obj/item/ammo_casing/pneuma
	max_ammo = 12
	multiload = 0

/obj/item/ammo_casing/pneuma
	name = "пневматический шарик"
	desc = "Пустой пневматический шарик."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "pneumaball_g"
	caliber = "pneumatic"
	casing_drop_sound = null
	projectile_type = /obj/item/projectile/bullet/pneumaball
	muzzle_flash_strength = null
	harmful = FALSE

/obj/item/projectile/bullet/pneumaball
	name = "пневматический шарик"
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

/obj/item/melee/stylet
	name = "выкидной нож"
	desc = "Маленький складной нож скрытого ношения. \
	Нож в итальянском стиле, который исторически стал предметом споров и даже запретов \
	Его лезвие практически мгновенно выбрасывается при нажатии кнопки-качельки."
	slot_flags = SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_TINY

	var/on = FALSE
	force = 2
	var/force_on = 8

	lefthand_file = 'modular_ss220/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/melee_righthand.dmi'
	icon = 'modular_ss220/objects/icons/melee.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	item_state = "stylet_0"
	var/item_state_on = "stylet_1"
	icon_state = "stylet_0"
	var/icon_state_on = "stylet_1"
	var/extend_sound = 'modular_ss220/objects/sound/weapons/styletext.ogg'
	attack_verb = list("hit", "poked")
	sharp = TRUE
	var/list/attack_verb_on = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/melee/stylet/update_icon_state()
	. = ..()
	if(on)
		icon_state = "stylet_1"
	else
		icon_state = "stylet_0"

/obj/item/melee/stylet/attack_self(mob/user)
	on = !on

	if(on)
		to_chat(user, span_userdanger("Вы разложили [src]"))
		item_state = item_state_on
		update_icon(UPDATE_ICON_STATE)
		w_class = WEIGHT_CLASS_SMALL
		force = force_on
		attack_verb = attack_verb_on
	else
		to_chat(user, span_notice("Вы сложили [src]."))
		item_state = initial(item_state)
		update_icon(UPDATE_ICON_STATE)
		w_class = initial(w_class)
		force = initial(force)
		attack_verb = initial(attack_verb)

	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(loc, extend_sound, 50, TRUE)
	add_fingerprint(user)

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	loot += list(/obj/item/melee/stylet = 5)
	return ..()
