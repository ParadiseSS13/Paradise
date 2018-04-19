/obj/item/gun/rocketlauncher
	var/projectile
	name = "rocket launcher"
	desc = "Say hello to my little friend"
	icon_state = "rocket"
	item_state = "rocket"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	force = 5.0
	flags = CONDUCT
	origin_tech = "combat=6"
	var/missile_speed = 2
	var/missile_range = 30
	var/max_rockets = 1
	var/list/rockets = new/list()

/obj/item/gun/rocketlauncher/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")

/obj/item/gun/rocketlauncher/Destroy()
	QDEL_LIST(rockets)
	rockets = null
	return ..()

/obj/item/gun/rocketlauncher/update_icon()
	return

/obj/item/gun/rocketlauncher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_casing/rocket))
		if(rockets.len < max_rockets)
			user.drop_item()
			I.loc = src
			rockets += I
			to_chat(user, "<span class='notice'>You put the rocket in [src].</span>")
			to_chat(user, "<span class='notice'>[rockets.len] / [max_rockets] rockets.</span>")
		else
			to_chat(usr, "<span class='notice'>[src] cannot hold more rockets.</span>")

/obj/item/gun/rocketlauncher/can_shoot()
	return rockets.len

/obj/item/gun/rocketlauncher/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override = "")
	if(rockets.len)
		var/obj/item/ammo_casing/rocket/I = rockets[1]
		var/obj/item/missile/M = new /obj/item/missile(user.loc)
		playsound(user.loc, 'sound/effects/bang.ogg', 50, 1)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed, user, 1)
		message_admins("[key_name_admin(user)] fired a rocket from a rocket launcher ([name]).")
		log_game("[key_name_admin(user)] used a rocket launcher ([name]).")
		rockets -= I
		qdel(I)
	else
		to_chat(usr, "<span class='warning'>[src] is empty.</span>")
