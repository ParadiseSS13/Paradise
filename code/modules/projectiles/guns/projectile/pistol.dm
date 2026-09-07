//Stetchkin//
/obj/item/gun/projectile/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon = 'icons/tgmc/objects/guns.dmi'
	icon_state = "pistol"
	inhand_icon_state = "pistol"
	lefthand_file = 'icons/tgmc/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/tgmc/mob/inhands/guns_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=3;materials=2;syndicate=3"
	can_holster = TRUE
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	magin_sound = 'sound/weapons/gun_interactions/pistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/pistol_magout.ogg'
	can_flashlight = TRUE
	burst_size = 1
	fire_delay = 0
	execution_speed = 4 SECONDS
	actions_types = list()

/obj/item/gun/projectile/automatic/pistol/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/update_overlays()
	. = list()
	if(suppressed)
		. += image(icon = 'icons/tgmc/objects/attachments.dmi', icon_state = "suppressor_attached", pixel_x = 15, pixel_y = 5)
	if(gun_light)
		var/flashlight = "uflashlight_attached"
		if(gun_light.on)
			flashlight = "uflashlight_attached-on"
		. += image(icon = 'icons/tgmc/objects/attachments.dmi', icon_state = flashlight, pixel_x = 5, pixel_y = -2)

/obj/item/gun/projectile/automatic/pistol/ui_action_click()
	toggle_gunlight()

//M1911//
/obj/item/gun/projectile/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	inhand_icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/gun/projectile/automatic/pistol/m1911/update_overlays()
	. = list()
	if(gun_light)
		var/flashlight = "uflashlight_attached"
		if(gun_light.on)
			flashlight = "uflashlight_attached-on"
		. += image(icon = 'icons/tgmc/objects/attachments.dmi', icon_state = flashlight, pixel_x = 5, pixel_y = -1)

//Enforcer//
/obj/item/gun/projectile/automatic/pistol/enforcer
	name = "\improper NF10 'Enforcer' pistol"
	desc = "A 9mm sidearm commonly used by Nanotrasen Asset Protection."
	icon_state = "enforcer_grey"
	inhand_icon_state = "enforcer_grey"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/enforcer
	unique_reskin = TRUE

/obj/item/gun/projectile/automatic/pistol/enforcer/Initialize(mapload)
	. = ..()
	options["Grey"] = "enforcer_grey"
	options["Red"] = "enforcer_red"
	options["Green"] = "enforcer_green"
	options["Tan"] = "enforcer_tan"
	options["Black"] = "enforcer_black"
	options["Blue"] = "enforcer_blue"
	options["Brown"] = "enforcer_brown"

/obj/item/gun/projectile/automatic/pistol/enforcer/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/enforcer/update_overlays()
	. = list()
	if(suppressed)
		. += image(icon = 'icons/tgmc/objects/attachments.dmi', icon_state = "suppressor_attached", pixel_x = 15, pixel_y = 5)
	if(gun_light)
		var/flashlight = "uflashlight_attached"
		if(gun_light.on)
			flashlight = "uflashlight_attached-on"
		. += image(icon = 'icons/tgmc/objects/attachments.dmi', icon_state = flashlight, pixel_x = 5, pixel_y = -2)

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal
	mag_type = /obj/item/ammo_box/magazine/enforcer/lethal

//Desert Eagle//
/obj/item/gun/projectile/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "deagle"
	inhand_icon_state = "deagleg"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	force = 14.0
	mag_type = /obj/item/ammo_box/magazine/m50
	fire_sound = 'sound/weapons/gunshots/gunshot_pistolH.ogg'
	magin_sound = 'sound/weapons/gun_interactions/hpistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/hpistol_magout.ogg'
	can_suppress = FALSE

/obj/item/gun/projectile/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"

/obj/item/gun/projectile/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"

//Type 230 Machine Pistol//
/obj/item/gun/projectile/automatic/pistol/type_230
	name = "\improper Type 230 Machine Pistol"
	desc = "A compact submachine gun produced by the USSP-based Rocino Armaments Collective. Chambered in 10mm."
	icon_state = "type_230"
	inhand_icon_state = "type_230"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/apsm10mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
