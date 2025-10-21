/*
 * The C-Foam launcher from GTFO
 * Shoots a blob of goo. If it hits an airlock, it will get closed shut, and you will have to either destroy the goo by force, or weld it off. The RnD foam is instant, and the traitor version has a `do_after`
 * RnD printed needs canisters, while the traitor variant will slowly regenerate foam.
 * The traitor variant also slows down mobs if they are hit by the foam.
 * Overall, a good support tool designed to
 */

/obj/item/gun/projectile/c_foam_launcher
	name = "\improper C-Foam launcher"
	desc = "The C-Foam launcher. Shoots blobs of quickly hardening and growing foam. Can be used to slow down humanoids or block airlocks"
	icon_state = "c_foam_launcher"
	inhand_icon_state = "c_foam_launcher"
	origin_tech = "combat=4;syndicate=1;materials=3"
	needs_permit = FALSE
	fire_sound = 'sound/effects/bamf.ogg'
	fire_sound_text = "thunk"
	mag_type = /obj/item/ammo_box/magazine/c_foam

/obj/item/gun/projectile/c_foam_launcher/update_icon_state()
	icon_state = "c_foam_launcher[magazine ? "_loaded" : ""]"

/obj/item/projectile/c_foam
	name = "blob of foam"
	icon_state = "foam_blob"
	damage = 0

/obj/item/projectile/c_foam/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(isairlock(target))
		var/obj/machinery/door/airlock = target
		airlock.foam_up()
		return

	if(istype(target, /obj/structure/mineral_door))
		var/obj/structure/mineral_door/door = target
		door.foam_up()
		return

	if(iscarbon(target)) // For that funny xeno foam action
		var/mob/living/carbon/sticky = target
		sticky.foam_up()
		return
