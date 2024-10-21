// MARK: Skrellian carbine
/obj/item/gun/energy/gun/skrell_carbine
	name = "\improper skrellian carbine"
	desc = "Энергетический карабин Vuu'Xqu*ix T-3, более известный в ТСФ как 'VT-3'. Это оружие редко можно увидеть где-то, помимо ОСС. \
		Имеет два режима мощности энерголуча: 'летальный' и 'штурмовой'. Второй предназначен для прорыва сквозь укрпеления противника."
	icon = 'modular_ss220/objects/icons/guns.dmi'
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	item_state = "skrell_carbine"
	icon_state = "skrell_carbine"
	cell_type = /obj/item/stock_parts/cell/skrell_carbine_cell
	ammo_type = list(/obj/item/ammo_casing/energy/laser/skrell_light, /obj/item/ammo_casing/energy/laser/skrell_assault)
	origin_tech = "combat=6;magnets=5"
	modifystate = 2
	execution_speed = 3 SECONDS
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/energy/gun/skrell_carbine/elite
	name = "\improper elite skrellian carbine"
	desc = "Энергетический карабин Vuu'Xqu*ix T-3, более известный в ТСФ как 'VT-3'. Это оружие редко можно увидеть где-то, помимо ОСС. \
		Этот экземпляр обладает батареей повышенной емкости, а так же дополнительными стабилизаторами стрельбы. \
		Имеет два режима мощности энерголуча: 'летальный' и 'штурмовой'. Второй предназначен для прорыва сквозь укрпеления противника."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/skrell_light/elite, /obj/item/ammo_casing/energy/laser/skrell_assault/elite)

/obj/item/ammo_casing/energy/laser/skrell_light
	projectile_type = /obj/item/projectile/beam/laser/skrell_light
	muzzle_flash_color = LIGHT_COLOR_LAVENDER
	select_name = "light"
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/blaster.ogg'

/obj/item/ammo_casing/energy/laser/skrell_assault
	projectile_type = /obj/item/projectile/beam/pulse/skrell_laser_assault
	muzzle_flash_color = LIGHT_COLOR_LAVENDER
	select_name = "assault"
	e_cost = 1600
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/blaster.ogg'

/obj/item/ammo_casing/energy/laser/skrell_light/elite
	e_cost = 50

/obj/item/ammo_casing/energy/laser/skrell_assault/elite
	e_cost = 200

/obj/item/projectile/beam/laser/skrell_light
	name = "laser"
	icon_state = "purple_laser"
	damage = 23
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_LAVENDER

/obj/item/projectile/beam/pulse/skrell_laser_assault
	name = "heavy laser"
	icon_state = "u_laser_alt"
	damage = 10
	stamina = 80
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARK_BLUE
	weakened_against_rwalls = TRUE

/obj/item/stock_parts/cell/skrell_carbine_cell
	name = "\improper Vuu'Xqu*ix T-3 gun power cell"
	maxcharge = 1600

// MARK: Skrellian railgun rifle
/obj/item/gun/projectile/automatic/sniper_rifle/skrell_rifle
	name = "\improper skrellian rifle"
	desc = "Винтовка Zquiv*Tzuuli-8, или ''ZT-8'' - это рельсотрон, стоящий на вооружении тяжелых штурмовых отрядов Раскинта из ОСС. \
		Имеет цилиндрический магазин заряжания, разгонный магнитный блок и стабилизаторы для точной стрельбы."
	icon = 'modular_ss220/objects/icons/guns.dmi'
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	icon_state = "sniper"
	item_state = "sniper"
	fire_sound = 'modular_ss220/objects/sound/weapons/gunshots/railgun.ogg'
	recoil = 0
	fire_delay = 25
	slot_flags = SLOT_FLAG_BELT
	zoomable = FALSE
	can_suppress = FALSE
	mag_type = /obj/item/ammo_box/magazine/skrell_magazine

/obj/item/gun/projectile/automatic/sniper_rifle/skrell_rifle/elite
	name = "\improper elite skrellian rifle"
	desc = "Винтовка Zquiv*Tzuuli-8, или ''ZT-8'' - это рельсотрон, стоящий на вооружении тяжелых штурмовых отрядов Раскинта из ОСС. \
		Имеет цилиндрический магазин заряжания, разгонный магнитный блок и стабилизаторы для точной стрельбы. \
		Этот экземпляр обладает расширенным магазинным гнездом, а так же оптическим прицелом."
	fire_delay = 20
	zoomable = TRUE
	mag_type = /obj/item/ammo_box/magazine/skrell_magazine/skrell_magazine_elite

/obj/item/ammo_box/magazine/skrell_magazine
	name = "\improper ammo cylinder"
	desc = "Цилиндровый магазин для рельсотрона."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "skrell_magazine"
	multi_sprite_step = 3
	ammo_type = /obj/item/ammo_casing/railgun
	max_ammo = 4
	caliber = "railgun"
	multiload = TRUE

/obj/item/ammo_box/magazine/skrell_magazine/skrell_magazine_elite
	icon_state = "skrell_magazine_elite"
	multi_sprite_step = 7
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/railgun/railgun_strong

/obj/item/ammo_casing/railgun
	name = "\improper railgun ammo casing"
	desc = "Снаряд для рельсотрона. Состоит из поражающего элемента и магнитного стабилизатора."
	icon = 'modular_ss220/objects/icons/ammo.dmi'
	icon_state = "railgun-casing"
	caliber = "railgun"
	projectile_type = /obj/item/projectile/bullet/railgun

/obj/item/ammo_casing/railgun/railgun_strong
	projectile_type = /obj/item/projectile/bullet/railgun/railgun_strong

/obj/item/projectile/bullet/railgun
	damage = 35
	armour_penetration_flat = 80
	pass_flags = PASSTABLE | PASSGRILLE | PASSGIRDER
	speed = 0.2
	icon_state = "gauss_silenced"
	light_color = LIGHT_COLOR_LIGHT_CYAN

/obj/item/projectile/bullet/railgun/railgun_strong
	damage = 45
	armour_penetration_flat = 30
	weaken = 0.2
	speed = 0.2

// MARK: Skrellian pistol
/obj/item/gun/energy/gun/skrell_pistol
	name = "\improper self-charge skrellian pistol"
	desc = "Энергетический пистолет Qua'l*Sarqzix-44x, известный на территориях ТСФ как QS-44. Компактный и удобный в использовании, имеет два режима мощности энерголуча: 'летальный' и 'нейтрализующий'. \
		Встроенный микрогенератор постепенно пополняет запас аккамулятора прямо в бою."
	icon = 'modular_ss220/objects/icons/guns.dmi'
	icon_state = "skrell_pistol"
	item_state = "skrell_pistol"
	lefthand_file = 'modular_ss220/objects/icons/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/laser/skrell_light, /obj/item/ammo_casing/energy/disabler)
	w_class = WEIGHT_CLASS_SMALL
	shaded_charge = FALSE
	can_holster = TRUE
	execution_speed = 4 SECONDS
	selfcharge = TRUE
