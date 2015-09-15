/obj/item/weapon/gun/projectile/automatic/pistol
	name = "\improper FK-69 pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = 2
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = "/obj/item/ammo_box/magazine/m10mm"
	can_suppress = 1
	burst_size = 1
	fire_delay = 0
	action_button_name = null
	
/obj/item/weapon/gun/projectile/automatic/pistol/isHandgun()
	return 1

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][silenced ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol/m2411
	name = "\improper M2411 pistol"
	desc = "John Browning's classic updated for the modern day. Uses .45 rounds."
	icon_state = "m2411"
	w_class = 3.0
	origin_tech = "combat=3;materials=2"
	mag_type = "/obj/item/ammo_box/magazine/m45"
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/pistol/deagle
	name = "\improper Desert Eagle pistol"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14.0
	mag_type = "/obj/item/ammo_box/magazine/m50"
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/gold
	desc = "A gold plated desert eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"