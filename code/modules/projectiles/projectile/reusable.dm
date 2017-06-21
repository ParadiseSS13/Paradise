/obj/item/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/ammo_type = /obj/item/ammo_casing/caseless/
	var/dropped = 0

/obj/item/projectile/bullet/reusable/on_hit(atom/target, blocked = 0)
	. = ..()
	handle_drop()

/obj/item/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/item/projectile/bullet/reusable/proc/handle_drop()
	if(!dropped)
		new ammo_type(loc)
		dropped = 1

/obj/item/projectile/bullet/reusable/magspear
	name = "magnetic spear"
	desc = "WHITE WHALE, HOLY GRAIL"
	damage = 30 //takes 3 spears to kill a mega carp, one to kill a normal carp
	icon_state = "magspear"
	ammo_type = /obj/item/ammo_casing/caseless/magspear

/obj/item/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	nodamage = 1
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	var/obj/item/weapon/pen/pen = null
	edge = 0
	embed = 0
	log_override = TRUE//it won't log even when there's a pen inside, but since the damage will be so low, I don't think there's any point in making it any more complex

/obj/item/projectile/bullet/reusable/foam_dart/handle_drop()
	if(dropped)
		return
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newdart = new ammo_type(loc)
	var/obj/item/ammo_casing/caseless/foam_dart/old_dart = ammo_casing
	newdart.modified = old_dart.modified
	if(pen)
		var/obj/item/projectile/bullet/reusable/foam_dart/newdart_FD = newdart.BB
		newdart_FD.pen = pen
		pen.loc = newdart_FD
		pen = null
	newdart.BB.damage = damage
	newdart.BB.nodamage = nodamage
	newdart.BB.damage_type = damage_type
	newdart.update_icon()

/obj/item/projectile/bullet/reusable/foam_dart/Destroy()
	QDEL_NULL(pen)
	return ..()

/obj/item/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 25
	log_override = FALSE

////////////// 25mm grenades


/obj/item/projectile/bullet/reusable/flash25
	name = " 25mm grenade"
	desc = "GET DOWN."
	damage = 10
	nodamage = FALSE
	icon_state= "25mmflash"
	ammo_type = /obj/item/weapon/grenade/flashbang
	range = 10
	edge = FALSE
	embed = FALSE
	var/det_time = 0

/obj/item/projectile/bullet/reusable/flash25/handle_drop()
	if(!dropped)
		var/obj/item/weapon/grenade/flashbang/F = new ammo_type(loc)
		dropped = TRUE
		spawn(det_time)
			F.prime()

/obj/item/projectile/bullet/reusable/flash25/tear
	ammo_type = /obj/item/weapon/grenade/chem_grenade/teargas
	icon_state= "25mmtear"

/obj/item/projectile/bullet/reusable/flash25/tear/handle_drop()
	if(!dropped)
		var/obj/item/weapon/grenade/chem_grenade/teargas/F = new ammo_type(loc)
		dropped = TRUE
		spawn(det_time)
			F.prime()


/obj/item/projectile/bullet/reusable/flash25/thud
	name = " 25mm grenade"
	desc = "GET DOWN."
	damage = 10
	stamina = 65
	nodamage = FALSE
	icon_state= "25mmthud"
	ammo_type = null
	range = 10

/obj/item/projectile/bullet/reusable/flash25/thud/handle_drop()
	return
