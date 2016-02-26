/obj/item/weapon/gun/projectile/automatic/toy
	name = "foam force gun"
	desc = "A toy gun. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "pistol"
	item_state = "gun"
	w_class = 2
	mag_type = "/obj/item/ammo_box/magazine/toy"
	fire_sound = 'sound/items/syringeproj.ogg'
	force = 0
	throwforce = 0
	burst_size = 1
	can_suppress = 0
	clumsy_check = 0
	needs_permit = 0

/obj/item/weapon/gun/projectile/automatic/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/toy/smg
	name = "foam force SMG"
	desc = "A prototype three-round burst toy submachine gun. Ages 8 and up."
	icon_state = "saber"
	mag_type = "/obj/item/ammo_box/magazine/toy/smg"
	burst_size = 3

/obj/item/weapon/gun/projectile/automatic/toy/pistol
	name = "foam force pistol"
	desc = "A small, easily concealable toy handgun. Ages 8 and up."
	mag_type = "/obj/item/ammo_box/magazine/toy/pistol"
	can_suppress = 0
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/toy/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/toy/pistol/riot/New()
	magazine = new /obj/item/ammo_box/magazine/toy/pistol/riot(src)
	..()

/obj/item/weapon/gun/projectile/automatic/c20r/toy
	name = "donksoft SMG"
	desc = "A bullpup two-round burst toy SMG, designated 'C-20r'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = "/obj/item/ammo_box/magazine/toy/smgm45"

/obj/item/weapon/gun/projectile/automatic/c20r/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/toy
	name = "donksoft LMG"
	desc = "A heavily modified toy light machine gun, designated 'L6 SAW'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = "/obj/item/ammo_box/magazine/toy/m762"

/obj/item/weapon/gun/projectile/automatic/l6_saw/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	..()

/obj/item/weapon/gun/projectile/automatic/tommygun/toy
	name = "tommy gun"
	desc = "Looks almost like the real thing! Great for practicing Drive-bys. Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = 2
	mag_type = "/obj/item/ammo_box/magazine/toy/tommygunm45"
	fire_sound = 'sound/items/syringeproj.ogg'

/obj/item/weapon/gun/projectile/shotgun/toy
	name = "foam force shotgun"
	desc = "A toy shotgun with wood furniture and a four-shell capacity underneath. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	force = 0
	throwforce = 0
	origin_tech = null
	mag_type = "/obj/item/ammo_box/magazine/internal/shot/toy"
	fire_sound = 'sound/items/syringeproj.ogg'
	clumsy_check = 0
	needs_permit = 0

/obj/item/weapon/gun/projectile/shotgun/toy/process_chambered()
	..()
	if(chambered && !chambered.BB)
		qdel(chambered)

/obj/item/weapon/gun/projectile/shotgun/toy/crossbow
	name = "foam force crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamcrossbow"
	item_state = "crossbow"
	mag_type = "/obj/item/ammo_box/magazine/internal/shot/toy/crossbow"
	slot_flags = SLOT_BELT
	w_class = 2
