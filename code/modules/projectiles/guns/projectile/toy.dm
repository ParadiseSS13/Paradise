/obj/item/weapon/gun/projectile/automatic/toy
	name = "foam force SMG"
	desc = "A prototype three-round burst toy submachine gun. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "saber"
	item_state = "gun"
	mag_type = "/obj/item/ammo_box/magazine/toy/smg"
	fire_sound = 'sound/items/syringeproj.ogg'
	force = 0
	throwforce = 0
	burst_size = 3
	can_suppress = 0
	clumsy_check = 0
	needs_permit = 0

/obj/item/weapon/gun/projectile/automatic/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
	if(empty_chamber)
		chambered = null
	chamber_round()
	if(AC.BB)
		if(AC.reagents && AC.BB.reagents)
			var/datum/reagents/casting_reagents = AC.reagents
			casting_reagents.trans_to(AC.BB, casting_reagents.total_volume) //For chemical darts/bullets
			qdel(casting_reagents)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/automatic/toy/pistol
	name = "foam force pistol"
	desc = "A small, easily concealable toy handgun. Ages 8 and up."
	icon_state = "pistol"
	w_class = 2
	mag_type = "/obj/item/ammo_box/magazine/toy/pistol"
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/toy/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/toy/pistol/riot
	name = "foam force riot pistol"
	desc = "RIOT! Ages 8 and up."

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
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
	if(empty_chamber)
		chambered = null
	chamber_round()
	if(AC.BB)
		if(AC.reagents && AC.BB.reagents)
			var/datum/reagents/casting_reagents = AC.reagents
			casting_reagents.trans_to(AC.BB, casting_reagents.total_volume) //For chemical darts/bullets
			qdel(casting_reagents)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/automatic/l6_saw/toy
	name = "donksoft LMG"
	desc = "A heavily modified toy light machine gun, designated 'L6 SAW'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = 0
	needs_permit = 0
	mag_type = "/obj/item/ammo_box/magazine/toy/m762"

/obj/item/weapon/gun/projectile/automatic/l6_saw/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
	if(empty_chamber)
		chambered = null
	chamber_round()
	if(AC.BB)
		if(AC.reagents && AC.BB.reagents)
			var/datum/reagents/casting_reagents = AC.reagents
			casting_reagents.trans_to(AC.BB, casting_reagents.total_volume) //For chemical darts/bullets
			qdel(casting_reagents)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/automatic/tommygun/toy
	name = "tommy gun"
	desc = "Looks almost like the real thing! Great for practicing Drive-bys. Ages 8 and up."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = 2
	mag_type = "/obj/item/ammo_box/magazine/toy/tommygunm45"
	fire_sound = 'sound/items/syringeproj.ogg'

/obj/item/weapon/gun/projectile/automatic/tommygun/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
	if(empty_chamber)
		chambered = null
	chamber_round()
	if(AC.BB)
		if(AC.reagents && AC.BB.reagents)
			var/datum/reagents/casting_reagents = AC.reagents
			casting_reagents.trans_to(AC.BB, casting_reagents.total_volume) //For chemical darts/bullets
			qdel(casting_reagents)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.update_icon()
		return 1
	return 0

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

/obj/item/weapon/gun/projectile/shotgun/toy/process_chambered(var/eject_casing = 0, var/empty_chamber = 1)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
	if(empty_chamber)
		chambered = null
	chamber_round()
	if(AC.BB)
		if(AC.reagents && AC.BB.reagents)
			var/datum/reagents/casting_reagents = AC.reagents
			casting_reagents.trans_to(AC.BB, casting_reagents.total_volume) //For chemical darts/bullets
			qdel(casting_reagents)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/shotgun/toy/crossbow
	name = "foam force crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamcrossbow"
	item_state = "crossbow"
	mag_type = "/obj/item/ammo_box/magazine/internal/shot/toy/crossbow"
	slot_flags = SLOT_BELT
	w_class = 2