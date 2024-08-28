/obj/item/gun/throw/biogun
	name = "biogun"
	desc = "Метатель живых био-ядер."
	icon = 'modular_ss220/antagonists/icons/guns/vox_guns.dmi'
	lefthand_file = 'modular_ss220/antagonists/icons/guns/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/antagonists/icons/guns/inhands/guns_righthand.dmi'
	icon_state = "biogun"
	item_state = "spike_long"
	var/inhand_charge_sections = 3
	w_class = WEIGHT_CLASS_HUGE
	max_capacity = 3
	projectile_speed = 2
	projectile_range = 30
	valid_projectile_type = /obj/item/biocore
	var/is_vox_private = FALSE

/obj/item/gun/throw/biogun/pickup(mob/user)
	. = ..()
	if(!is_vox_private)
		is_vox_private = TRUE
		to_chat(user, span_notice("Оружие инициализировало вас, более никто кроме Воксов не сможет им воспользоваться."))

/obj/item/gun/throw/biogun/afterattack(atom/target, mob/living/user, flag, params)
	if(is_vox_private && !isvox(user))
		if(prob(20))
			to_chat(user, span_notice("Оружие отказывается с вами работать и не активируется."))
		return FALSE
	. = ..()

/obj/item/gun/throw/biogun/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/throw/biogun/process_chamber()
	. = ..()
	update_icon()

/obj/item/gun/throw/biogun/update_icon_state()
	. = ..()
	var/num = length(loaded_projectiles) + (to_launch ? 1 : 0)
	var/inhand_ratio = CEILING((num / max_capacity) * inhand_charge_sections, 1)
	var/new_item_state = "[initial(item_state)][inhand_ratio]"
	item_state = new_item_state

/obj/item/gun/throw/biogun/update_overlays()
	. = ..()
	var/num = length(loaded_projectiles) + (to_launch ? 1 : 0)
	if(num)
		num = min(num, max_capacity)
		. += "[icon_state]_charge[num]"

/obj/item/gun/throw/biogun/notify_ammo_count()
	update_icon()
	var/amount = get_ammocount()
	if(get_ammocount() >= 1)
		return span_notice("[src] заряжен [amount]/[max_capacity].")
	return span_notice("[src] разряжен.")


// ============== Существа ==============

/mob/living/simple_animal/hostile/viscerator/vox
	name = "vox viscerator"
	icon = 'modular_ss220/antagonists/icons/objects/critter.dmi'
	faction = list("Vox")
	mob_biotypes = MOB_ROBOTIC
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = -1, CLONE = -1, STAMINA = 0, OXY = 0)
	can_be_on_fire = FALSE
	fire_damage = 1
	unsuitable_atmos_damage = 0
	mob_size = MOB_SIZE_TINY
	flying = FALSE
	melee_damage_lower = 10
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/viscerator/vox/Process_Spacemove(movement_dir)
	return TRUE

/mob/living/simple_animal/hostile/viscerator/vox/stamina
	name = "stakikamka"
	desc = "Небольшое биомеханическое проворное существо на высоких ножках, мешающее и изматывающее тех, кому оно не понравилось."
	icon_state = "stamina"
	icon_living = "stamina"
	density = FALSE
	obj_damage = 0
	speed = 0.25
	melee_damage_type = STAMINA
	melee_damage_lower = 5
	melee_damage_upper = 20
	attacktext = "утомляет"

/mob/living/simple_animal/hostile/viscerator/vox/stamina/death(gibbed)
	if(prob(30))
		xgibs(loc)
	. = ..()

/mob/living/simple_animal/hostile/viscerator/vox/acid
	name = "acikikid"
	desc = "Небольшое биомеханическое крабоподобное существо из пасти которого стекает кислота, которую тот наматывает на свои маленькие острые клешни."
	icon_state = "acid"
	icon_living = "acid"
	health = 50
	maxHealth = 50
	obj_damage = 20
	melee_damage_type = BURN
	melee_damage_lower = 10
	melee_damage_upper = 30
	attacktext = "выжигает"
	mob_size = MOB_SIZE_SMALL

/mob/living/simple_animal/hostile/viscerator/vox/acid/death(gibbed)
	xgibs(loc)
	. = ..()

/mob/living/simple_animal/hostile/viscerator/vox/kusaka
	name = "kusakika"
	desc = "Маленькое биомеханическое существо с острыми клыкам с половину его тела."
	icon_state = "kusaka"
	icon_living = "kusaka"
	density = FALSE
	speed = 0.5
	obj_damage = 0
	melee_damage_lower = 5
	melee_damage_upper = 10
	armour_penetration_flat = 30
	attacktext = "кусает"

/mob/living/simple_animal/hostile/viscerator/vox/kusaka/death(gibbed)
	if(prob(20))
		robogibs(loc)
	. = ..()

/mob/living/simple_animal/hostile/viscerator/vox/taran
	name = "tarakikan"
	desc = "Весомое пластинчатое биомеханическое существо."
	icon_state = "taran"
	icon_living = "taran"
	speed = 2
	health = 100
	maxHealth = 100
	obj_damage = 50
	melee_damage_lower = 10
	melee_damage_upper = 20
	armour_penetration_flat = 20
	attacktext = "таранит"
	mob_size = MOB_SIZE_HUMAN

/mob/living/simple_animal/hostile/viscerator/vox/taran/death(gibbed)
	robogibs(loc)
	. = ..()

/mob/living/simple_animal/hostile/viscerator/vox/tox
	name = "toxikikic"
	desc = "Маленькое биомеханическое иглоподобное существо."
	icon_state = "tox"
	icon_living = "tox"
	density = FALSE
	melee_damage_type = TOX
	melee_damage_lower = 5
	melee_damage_upper = 15
	armour_penetration_flat = 80
	attacktext = "вонзается"

/mob/living/simple_animal/hostile/viscerator/vox/tox/death(gibbed)
	xgibs(loc)
	. = ..()
