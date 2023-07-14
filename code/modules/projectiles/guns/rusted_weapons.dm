// Rusted Soviet special weapons

/obj/item/gun/projectile/automatic/rusted
	name = "\improper Rusted gun"
	desc = "An old gun, be careful using it."
	icon_state = "aksu"
	item_state = "aksu"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=5;materials=3"
	mag_type = /obj/item/ammo_box/magazine/aksu
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	can_bayonet = FALSE
	slot_flags = SLOT_BACK
	burst_size = 3
	fire_delay = 1
	recoil = 1
	rusted_weapon = TRUE
	self_shot_divisor = 3
	malf_low_bound = 60
	malf_high_bound = 90


/obj/item/gun/projectile/automatic/rusted/aksu
	name = "\improper Rusted AKSU assault rifle"
	desc = "An old AK assault rifle favored by Soviet soldiers."
	icon_state = "aksu"
	item_state = "aksu"
	mag_type = /obj/item/ammo_box/magazine/aksu
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;materials=3"
	burst_size = 3
	fire_delay = 2
	recoil = 0.8

/obj/item/gun/projectile/automatic/rusted/ppsh
	name = "\improper Rusted PPSh submachine gun"
	desc = "An old submachine gun favored by Soviet soldiers."
	icon_state = "ppsh"
	item_state = "ppsh"
	mag_type = /obj/item/ammo_box/magazine/ppsh
	w_class = WEIGHT_CLASS_HUGE
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	self_shot_divisor = 5
	malf_high_bound = 100
	burst_size = 5
	fire_delay = 1.5
	recoil = 1.2


//////////// Shotguns

/obj/item/gun/projectile/shotgun/lethal/rusted
	desc = "A traditional shotgun. It looks like it has been lying here for a very long time, rust is pouring."
	rusted_weapon = TRUE
	self_shot_divisor = 3
	malf_low_bound = 12
	malf_high_bound = 24

//////////// Revolvers

/obj/item/gun/projectile/revolver/nagant/rusted
	desc = "An old model of revolver that originated in Russia. This one is a real relic, rust is pouring."
	rusted_weapon = TRUE
	self_shot_divisor = 2
	malf_low_bound = 7
	malf_high_bound = 21
