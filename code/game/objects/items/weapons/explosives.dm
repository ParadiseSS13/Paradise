/obj/item/weapon/c4
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = NOBLUDGEON
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/datum/wires/explosive/plastic/wires = null
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0

/obj/item/weapon/c4/New()
	wires = new(src)
	..()

/obj/item/weapon/c4/suicide_act(var/mob/user)
	. = (BRUTELOSS)
	viewers(user) << "<span class='suicide'>[user] activates the C4 and holds it above his head! It looks like \he's going out with a bang!</span>"
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == "traitor" || role == "syndicate" || role == "syndicate commando")
				message_say = "FOR THE SYNDICATE!"
			else if(role == "changeling")
				message_say = "FOR THE HIVE!"
			else if(role == "cultist")
				message_say = "FOR NARSIE!"
			else if(role == "ninja")
				message_say = "FOR THE CLAN!"
			else if(role == "wizard")
				message_say = "FOR THE FEDERATION!"
			else if(role =="revolutionary" || role == "head revolutionary")
				message_say = "FOR THE REVOLOUTION!"
			else if(role == "death commando" || role == "emergency response team")
				message_say = "FOR NANOTRASEN!"

	user.say(message_say)
	target = user
	message_admins("[key_name_admin(user)] suicided with [src.name] at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	message_admins("[key_name(user)] suicided with [src.name] at ([x],[y],[z])")
	explode(get_turf(user))
	return .

/obj/item/weapon/c4/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"
	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		wires.Interact(user)
	else
		..()

/obj/item/weapon/c4/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	if(newtime > 60000)
		newtime = 60000
	timer = newtime
	user << "Timer set for [timer] seconds."


/obj/item/weapon/c4/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (ismob(target) || istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage) || istype(target, /obj/item/clothing/accessory/storage) || istype(target, /obj/item/clothing/under))
		return
	user << "Planting explosives..."

	if(do_after(user, 50, target = target) && in_range(user, target))
		user.drop_item()
		src.target = target
		loc = null

		if (ismob(target))
			add_logs(target, user, "planted [name] on")
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
			message_admins("[key_name_admin(user)] planted [src.name] on [key_name_admin(target)] with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [key_name(target)] with [timer] second fuse")

		else
			message_admins("[key_name_admin(user)] planted [src.name] on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			explode(get_turf(target))

/obj/item/weapon/c4/proc/explode(var/location)

	if(!target)
		target = get_atom_on_turf(src)
	if(!target)
		target = src
	if(location)
		explosion(location, -1, -1, 4, 4)

	if(target)
		if (istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			target.ex_act(1)
		if (isobj(target))
			if (target)
				qdel(target)
	qdel(src)

/obj/item/weapon/c4/attack(mob/M as mob, mob/user as mob, def_zone)
	return