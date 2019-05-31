/obj/item/gun/projectile/automatic/toy
	name = "foam force SMG"
	desc = "A prototype three-round burst toy submachine gun. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "saber"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/toy/smg
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	force = 0
	throwforce = 0
	burst_size = 3
	can_suppress = 0
	clumsy_check = 0
	needs_permit = 0

/obj/item/gun/projectile/automatic/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/toy/pistol
	name = "foam force pistol"
	desc = "A small, easily concealable toy handgun. Ages 8 and up."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/toy/pistol
	fire_sound = 'sound/weapons/gunshots/gunshot.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/toy/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/toy/pistol/riot
	name = "foam force riot pistol"
	desc = "RIOT! Ages 8 and up."
	mag_type = /obj/item/ammo_box/magazine/toy/pistol/riot

/obj/item/gun/projectile/automatic/toy/pistol/riot/New()
	magazine = new /obj/item/ammo_box/magazine/toy/pistol/riot(src)
	..()

/obj/item/gun/projectile/automatic/toy/pistol/enforcer
	name = "Foam Enforcer"
	desc = "A foam shooting version of the Enforcer meant to be used for training new caddets who can't be trusted with rubber bullets."
	icon_state = "enforcer"
	mag_type = /obj/item/ammo_box/magazine/toy/enforcer
	can_flashlight = TRUE

/obj/item/gun/projectile/automatic/toy/pistol/enforcer/update_icon()
	..()
	overlays.Cut()
	if(gun_light)
		var/iconF = "Enforcer_light"
		if(gun_light.on)
			iconF = "Enforcer_light-on"
		overlays += image(icon = 'icons/obj/guns/projectile.dmi', icon_state = iconF, pixel_x = 0)

/obj/item/gun/projectile/automatic/toy/pistol/enforcer/ui_action_click()
	toggle_gunlight()

/obj/item/gun/projectile/shotgun/toy
	name = "foam force shotgun"
	desc = "A toy shotgun with wood furniture and a four-shell capacity underneath. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	force = 0
	throwforce = 0
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy
	clumsy_check = 0
	needs_permit = 0

/obj/item/gun/projectile/shotgun/toy/process_chamber()
	..()
	if(chambered && !chambered.BB)
		qdel(chambered)

/obj/item/gun/projectile/shotgun/toy/crossbow
	name = "foam force crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon_state = "crossbow"
	item_state = "crossbow"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	fire_sound = 'sound/items/syringeproj.ogg'
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gun/projectile/automatic/c20r/toy
	name = "donksoft SMG"
	desc = "A bullpup two-round burst toy SMG, designated 'C-20r'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = /obj/item/ammo_box/magazine/toy/smgm45

/obj/item/gun/projectile/automatic/c20r/toy/riot
	mag_type = /obj/item/ammo_box/magazine/toy/smgm45/riot

/obj/item/gun/projectile/automatic/c20r/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/l6_saw/toy
	name = "donksoft LMG"
	desc = "A heavily modified toy light machine gun, designated 'L6 SAW'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = /obj/item/ammo_box/magazine/toy/m762

/obj/item/gun/projectile/automatic/l6_saw/toy/riot
	mag_type = /obj/item/ammo_box/magazine/toy/m762/riot

/obj/item/gun/projectile/automatic/l6_saw/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/shotgun/toy/tommygun
	name = "tommy gun"
	desc = "Looks almost like the real thing! Great for practicing Drive-bys. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "tommygun"
	item_state = "shotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/tommygun
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gun/projectile/automatic/sniper_rifle/toy
	name = "donksoft sniper rifle"
	desc = "A recoil-operated, semi-automatic donksoft sniper rifle. Perfect to annoy/kill the neighbour’s cat! Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = FALSE
	needs_permit = FALSE
	zoomable = FALSE
	mag_type = /obj/item/ammo_box/magazine/toy/sniper_rounds

/obj/item/gun/projectile/automatic/sniper_rifle/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()