

/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	var/ammo_name = "grenade"
	var/ammo_type = /obj/item/weapon/grenade
	var/unloaded

	m_amt = 2000

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\icon [name]:"
		usr << "\blue [grenades.len] / [max_grenades] [ammo_name]s."

	attackby(obj/item/I as obj, mob/user as mob, params)

		if((istype(I, ammo_type)))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "\blue You put the [ammo_name] in the [name]."
				user << "\blue [grenades.len] / [max_grenades] [ammo_name]s."
			else
				usr << "\red The grenade launcher cannot hold more [ammo_name]s."

	afterattack(obj/target, mob/user , flag)

		if (istype(target, /obj/item/weapon/storage/backpack ))
			return

		else if (locate (/obj/structure/table, src.loc))
			return

		else if(target == user)
			return

		if(grenades.len)
			spawn(0) fire_grenade(target,user)
		else
			usr << "\red The [name] is empty."

	proc
		fire_grenade(atom/target, mob/user)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] fired a [ammo_name]!", user), 1)
			user << "\red You fire the [name]!"
			var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
			grenades -= F
			F.loc = user.loc
			F.throw_at(target, 30, 2, user)
			message_admins("[key_name_admin(user)] fired a [ammo_name] ([F.name]) from a launcher ([name]).")
			log_game("[key_name_admin(user)] used a [ammo_name] ([name]).")
			F.active = 1
			F.icon_state = initial(icon_state) + "_active"
			playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
			spawn(15)
				F.prime()

/obj/item/weapon/gun/grenadelauncher/piecannon
	name = "pie cannon"
	icon = 'icons/obj/gun.dmi'
	icon_override = 'icons/mob/in-hand/guns.dmi'
	icon_state = "piecannon1"
	item_state = "piecannon1"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	clumsy_check = 0
	grenades = new/list()
	max_grenades = 5
	ammo_name = "cream pie"
	ammo_type = /obj/item/weapon/reagent_containers/food/snacks/pie

/obj/item/weapon/gun/grenadelauncher/piecannon/New()
	..()
	for(var/i=0, i < max_grenades, i++)
		var/obj/item/weapon/reagent_containers/food/snacks/pie/P = new /obj/item/weapon/reagent_containers/food/snacks/pie(src)
		grenades += P

/obj/item/weapon/gun/grenadelauncher/piecannon/attackby(obj/item/I as obj, mob/user as mob, params)
	if((istype(I, ammo_type)))
		if(grenades.len < max_grenades)
			user.drop_item()
			I.loc = src
			grenades += I
			user << "\blue You put the [ammo_name] in the [name]."
			user << "\blue [grenades.len] / [max_grenades] [ammo_name]s."
			icon_state = "piecannon1"
		else
			usr << "\red The grenade launcher cannot hold more [ammo_name]s."

/obj/item/weapon/gun/grenadelauncher/piecannon/fire_grenade(atom/target, mob/user)
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("\red [] fired a [ammo_name]!", user), 1)
	user << "\red You fire the [name]!"
	var/obj/item/weapon/reagent_containers/food/snacks/pie/P = grenades[1] //Now with less copypasta!
	grenades -= P
	P.loc = user.loc
	P.throw_at(target, 30, 2, user)
	if(!grenades.len)
		icon_state = "piecannon0"
