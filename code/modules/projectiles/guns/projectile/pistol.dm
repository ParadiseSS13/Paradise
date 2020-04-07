//Stetchkin//
/obj/item/gun/projectile/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=3;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/m10mm
	fire_sound = 'sound/weapons/gunshots/gunshot_pistol.ogg'
	magin_sound = 'sound/weapons/gun_interactions/pistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/pistol_magout.ogg'
	can_suppress = 1
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/pistol/isHandgun()
	return 1

/obj/item/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return

//M1911//
/obj/item/gun/projectile/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = 0

//Enforcer//
/obj/item/gun/projectile/automatic/pistol/enforcer
	name = "Enforcer"
	desc = "A pistol of modern design."
	icon_state = "enforcer_grey"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/enforcer
	can_suppress = TRUE
	unique_reskin = TRUE
	can_flashlight = TRUE

/obj/item/gun/projectile/automatic/pistol/enforcer/New()
	..()
	options["Grey slide"] = "enforcer_grey"
	options["Red slide"] = "enforcer_red"
	options["Green slide"] = "enforcer_green"
	options["Tan slide"] = "enforcer_tan"
	options["Black slide"] = "enforcer_black"
	options["Green Handle"] = "enforcer_greengrip"
	options["Tan Handle"] = "enforcer_tangrip"
	options["Red Handle"] = "enforcer_redgrip"
	options["Cancel"] = null

/obj/item/gun/projectile/automatic/pistol/enforcer/update_icon()
	..()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	overlays.Cut()
	if(suppressed)
		overlays += image(icon = icon, icon_state = "enforcer_supp", pixel_x = 4)
	if(gun_light)
		var/iconF = "Enforcer_light"
		if(gun_light.on)
			iconF = "Enforcer_light-on"
		overlays += image(icon = icon, icon_state = iconF, pixel_x = 0)

/obj/item/gun/projectile/automatic/pistol/enforcer/ui_action_click()
	toggle_gunlight()

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal/New()
	magazine = new/obj/item/ammo_box/magazine/enforcer/lethal
	..()

//Desert Eagle//
/obj/item/gun/projectile/automatic/pistol/deagle
	name = "desert eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14.0
	mag_type = /obj/item/ammo_box/magazine/m50
	fire_sound = 'sound/weapons/gunshots/gunshot_pistolH.ogg'
	magin_sound = 'sound/weapons/gun_interactions/hpistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/hpistol_magout.ogg'
	can_suppress = 0

/obj/item/gun/projectile/automatic/pistol/deagle/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/gun/projectile/automatic/pistol/deagle/gold
	desc = "A gold plated desert eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/projectile/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

//APS Pistol//
/obj/item/gun/projectile/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "The original russian version of a widely used Syndicate sidearm. Uses 9mm ammo."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=3;materials=2;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = 0
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
