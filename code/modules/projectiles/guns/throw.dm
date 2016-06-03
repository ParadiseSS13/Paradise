/obj/item/weapon/gun/throw
	name = "abstract item thrower"
	desc = "This shouldn't be here, yell at a coder."
	fire_sound = 'sound/weapons/punchmiss.ogg'
	fire_sound_text = "thwock"

	var/obj/item/to_launch
	var/list/valid_projectile_type
	var/max_capacity = 1
	var/list/loaded_projectiles = list()

	var/projectile_speed = 1
	var/projectile_range = 1

/obj/item/weapon/gun/throw/proc/notify_ammo_count(mob/user)
	return

/obj/item/weapon/gun/throw/proc/get_throwrange()
	return projectile_speed

/obj/item/weapon/gun/throw/proc/get_throwspeed()
	return projectile_range

/obj/item/weapon/gun/throw/proc/modify_projectile(obj/item/I, on_chamber = 0)
	return

/obj/item/weapon/gun/throw/proc/get_ammocount(include_loaded = 1)
	var/count = loaded_projectiles.len
	if(include_loaded && to_launch)
		count++
	return count

/obj/item/weapon/gun/throw/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It is [to_launch ? "loaded with \a [to_launch]" : "not loaded"].</span>")
	notify_ammo_count(user)

/obj/item/weapon/gun/throw/Destroy()
	qdel(to_launch)
	to_launch = null
	for(var/atom/A in loaded_projectiles)
		qdel(A)
	loaded_projectiles = null

	return ..()

/obj/item/weapon/gun/throw/update_icon()
	return

/obj/item/weapon/gun/throw/attackby(obj/item/I, mob/user, params)
	if(istype(I, valid_projectile_type) && !(I.flags & NODROP))
		if(get_ammocount() < max_capacity)
			user.drop_item()
			I.forceMove(src)
			loaded_projectiles += I
			to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
			if(!to_launch)
				process_chamber()
			notify_ammo_count(user)
		else
			to_chat(user, "<span class='warning'>[src] cannot hold any more projectiles.</span>")
	else
		to_chat(user, "<span class='warning'>You cannot load [I] into [src]!</span>")

/obj/item/weapon/gun/throw/process_chamber()
	if(!to_launch && loaded_projectiles.len)
		to_launch = loaded_projectiles[1]
		loaded_projectiles -= to_launch
	return

/obj/item/weapon/gun/throw/can_shoot()
	if(to_launch)
		return 1
	return 0

/obj/item/weapon/gun/throw/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	add_fingerprint(user)
	if(semicd)
		return

	var/obj/item/I = to_launch
	I.forceMove(get_turf(src))
	to_launch = null
	modify_projectile(I)
	playsound(user, fire_sound, 50, 1)
	I.throw_at(target, get_throwrange(), get_throwspeed(), user, 1)
	message_admins("[key_name_admin(user)] fired \a [I] from a [src].")
	log_game("[key_name_admin(user)] used \a [src].")
	process_chamber()

	semicd = 1
	spawn(fire_delay)
		semicd = 0
