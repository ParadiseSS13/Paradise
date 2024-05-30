/*
 * The C-Foam launcher from GTFO
 * Shoots a blob of goo. If it hits an airlock, it will get closed shut, and you will have to either destroy the goo by force, or weld it off. The RnD foam is instant, and the traitor version has a `do_after`
 * RnD printed needs canisters, while the traitor variant will slowly regenerate foam.
 * The traitor variant also slows down mobs if they are hit by the foam.
 * Overall, a good support tool designed to
 */

/obj/item/gun/projectile/c_foam_launcher
	name = "\improper C-Foam launcher"
	desc = "The C-Foam launcher. Shoots blobs of quickly hardening and growing foam. Can be used to slow down humans or block airlocks"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver_bright"
	item_state = "riotgun"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=1"
	needs_permit = FALSE

	fire_sound = 'sound/items/syringeproj.ogg'
	fire_sound_text = "thunk"
	magin_sound = 'sound/weapons/gun_interactions/smg_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/smg_magout.ogg'
	mag_type = /obj/item/ammo_box/magazine/c_foam

/obj/item/projectile/c_foam
	name = "blob of foam"
	damage = 0

/obj/item/projectile/c_foam/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(isairlock(target))
		var/obj/machinery/door/airlock = target
		airlock.foam_up(1)
