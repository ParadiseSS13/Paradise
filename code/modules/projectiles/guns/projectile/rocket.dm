/obj/item/weapon/gun/rocketlauncher
	var/projectile
	name = "rocket launcher"
	desc = "Say hello to my little friend"
	icon_state = "rocket"
	item_state = "rocket"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	origin_tech = "combat=8;materials=5"
	projectile = /obj/item/missile
	var/missile_speed = 2
	var/missile_range = 30
	var/max_rockets = 1
	var/list/rockets = new/list()

/obj/item/weapon/gun/rocketlauncher/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return
	usr << "\blue [rockets.len] / [max_rockets] rockets."

/obj/item/weapon/gun/rocketlauncher/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/rocket))
		if(rockets.len < max_rockets)
			user.drop_item()
			I.loc = src
			rockets += I
			user << "\blue You put the rocket in [src]."
			user << "\blue [rockets.len] / [max_rockets] rockets."
		else
			usr << "\red [src] cannot hold more rockets."

/obj/item/weapon/gun/rocketlauncher/can_fire()
	return rockets.len

/obj/item/weapon/gun/rocketlauncher/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(rockets.len)
		var/obj/item/ammo_casing/rocket/I = rockets[1]
		var/obj/item/missile/M = new projectile(user.loc)
		playsound(user.loc, 'sound/effects/bang.ogg', 50, 1)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed,user)
		message_admins("[key_name_admin(user)] fired a rocket from a rocket launcher ([src.name]).")
		log_game("[key_name_admin(user)] used a rocket launcher ([src.name]).")
		rockets -= I
		del(I)
		return
	else
		usr << "\red [src] is empty."