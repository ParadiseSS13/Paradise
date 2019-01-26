/obj/item/grenade/plastic
	name = "plastic explosive"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon_state = "plastic-explosive0"
	item_state = "plastic-explosive"
	flags = NOBLUDGEON
	det_time = 10
	display_timer = 0
	origin_tech = "syndicate=1"
	toolspeed = 1
	var/atom/target = null
	var/image_overlay = null
	var/obj/item/assembly_holder/nadeassembly = null
	var/assemblyattacher

/obj/item/grenade/plastic/New()
	image_overlay = image('icons/obj/grenade.dmi', "[item_state]2")
	..()

/obj/item/grenade/plastic/Destroy()
	QDEL_NULL(nadeassembly)
	target = null
	return ..()

/obj/item/grenade/plastic/attackby(obj/item/I, mob/user, params)
	if(!nadeassembly && istype(I, /obj/item/assembly_holder))
		var/obj/item/assembly_holder/A = I
		if(!user.unEquip(I))
			return ..()
		nadeassembly = A
		A.master = src
		A.loc = src
		assemblyattacher = user.ckey
		to_chat(user, "<span class='notice'>You add [A] to the [name].</span>")
		playsound(src, 'sound/weapons/tap.ogg', 20, 1)
		update_icon()
		return
	if(nadeassembly && istype(I, /obj/item/wirecutters))
		playsound(src, I.usesound, 20, 1)
		nadeassembly.loc = get_turf(src)
		nadeassembly.master = null
		nadeassembly = null
		update_icon()
		return
	..()

//assembly stuff
/obj/item/grenade/plastic/receive_signal()
	prime()

/obj/item/grenade/plastic/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/grenade/plastic/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/grenade/plastic/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)
		return
	var/newtime = input(usr, "Please set the timer.", "Timer", det_time) as num
	if(user.is_in_active_hand(src))
		newtime = Clamp(newtime, 10, 60000)
		det_time = newtime
		to_chat(user, "Timer set for [det_time] seconds.")

/obj/item/grenade/plastic/afterattack(atom/movable/AM, mob/user, flag)
	if (!flag)
		return
	if (istype(AM, /mob/living/carbon))
		return
	to_chat(user, "<span class='notice'>You start planting the [src]. The timer is set to [det_time]...</span>")

	if(do_after(user, 50 * toolspeed, target = AM))
		if(!user.unEquip(src))
			return
		src.target = AM
		loc = null

		message_admins("[key_name_admin(user)]([ADMIN_QUE(user,"?")]) ([ADMIN_FLW(user,"FLW")]) planted [src.name] on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [det_time] second fuse",0,1)
		log_game("[key_name(user)] planted [name] on [target.name] at ([target.x],[target.y],[target.z]) with [det_time] second fuse")

		target.overlays += image_overlay
		if(!nadeassembly)
			to_chat(user, "<span class='notice'>You plant the bomb. Timer counting down from [det_time].</span>")
			addtimer(CALLBACK(src, .proc/prime), det_time*10)

/obj/item/grenade/plastic/suicide_act(mob/user)
	message_admins("[key_name_admin(user)]([ADMIN_QUE(user,"?")]) ([ADMIN_FLW(user,"FLW")]) suicided with [src.name] at ([user.x],[user.y],[user.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)",0,1)
	log_game("[key_name(user)] suicided with [name] at ([user.x],[user.y],[user.z])")
	user.visible_message("<span class='suicide'>[user] activates the [name] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!</span>")
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == ROLE_TRAITOR || role == "syndicate" || role == "syndicate commando")
				message_say = "FOR THE SYNDICATE!"
			else if(role == ROLE_CHANGELING)
				message_say = "FOR THE HIVE!"
			else if(role == ROLE_CULTIST)
				message_say = "FOR NARSIE!"
			else if(role == ROLE_NINJA)
				message_say = "FOR THE CLAN!"
			else if(role == ROLE_WIZARD)
				message_say = "FOR THE FEDERATION!"
			else if(role == ROLE_REV || role == "head revolutionary")
				message_say = "FOR THE REVOLOUTION!"
			else if(role == "death commando" || role == ROLE_ERT)
				message_say = "FOR NANOTRASEN!"
			else if(role == ROLE_DEVIL)
				message_say = "FOR INFERNO!"
	user.say(message_say)
	target = user
	sleep(10)
	prime()
	user.gib()

/obj/item/grenade/plastic/update_icon()
	if(nadeassembly)
		icon_state = "[item_state]1"
	else
		icon_state = "[item_state]0"

//////////////////////////
///// The Explosives /////
//////////////////////////

/obj/item/grenade/plastic/c4
	name = "C4"
	desc = "Used to put holes in specific areas without too much extra hole. A saboteurs favourite."

/obj/item/grenade/plastic/c4/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(istype(target, /turf/))
				location = get_turf(target)	// Set the explosion location to turf if planted directly on a wall or floor
			else
				location = get_atom_on_turf(target)	// Otherwise, make sure we're blowing up what's on top of the turf
			target.overlays -= image_overlay
	else
		location = get_atom_on_turf(src)
	if(location)
		explosion(location,0,0,3)
		location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

// X4 is an upgraded directional variant of c4 which is relatively safe to be standing next to. And much less safe to be standing on the other side of.
// C4 is intended to be used for infiltration, and destroying tech. X4 is intended to be used for heavy breaching and tight spaces.
// Intended to replace C4 for nukeops, and to be a randomdrop in surplus/random traitor purchases.

/obj/item/grenade/plastic/x4
	name = "X4"
	desc = "A specialized shaped high explosive breaching charge. Designed to be safer for the user, and less so, for the wall."
	var/aim_dir = NORTH
	icon_state = "plasticx40"
	item_state = "plasticx4"

/obj/item/grenade/plastic/x4/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(istype(target, /turf/))
				location = get_turf(target)
			else
				location = get_atom_on_turf(target)
			target.overlays -= image_overlay
	else
		location = get_atom_on_turf(src)
	if(location)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			explosion(get_step(T, aim_dir),0,0,3)
			explosion(T,0,2,0)
			location.ex_act(2, target)
		else
			explosion(location, 0, 2, 3)
			location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

/obj/item/grenade/plastic/x4/afterattack(atom/movable/AM, mob/user, flag)
	aim_dir = get_dir(user,AM)
	..()

// Shaped charge
// Same blasting power as C4, but with the same idea as the X4 -- Everyone on one side of the wall is safe.

/obj/item/grenade/plastic/c4_shaped
	name = "C4 (shaped)"
	desc = "A brick of C4 shaped to allow more precise breaching."
	var/aim_dir = NORTH

/obj/item/grenade/plastic/c4_shaped/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target.overlays -= image_overlay
	else
		location = get_turf(src)
	if(location)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			explosion(get_step(T, aim_dir),0,0,3)
			location.ex_act(2, target)
		else
			explosion(location, 0, 0, 3)
			location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

/obj/item/grenade/plastic/c4_shaped/afterattack(atom/movable/AM, mob/user, flag)
	aim_dir = get_dir(user,AM)
	..()

/obj/item/grenade/plastic/c4_shaped/flash
	name = "C4 (flash)"
	desc = "A C4 charge with an altered chemical composition, designed to blind and deafen the occupants of a room before breaching."

/obj/item/grenade/plastic/c4_shaped/flash/prime()
	if(target && target.density)
		T = get_step(get_turf(target), aim_dir)
	else if(target)
		T = get_turf(target)
	else
		T = get_turf(src)

	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(T)
	CB.prime()

	..()

/obj/item/grenade/plastic/x4/thermite
	name = "T4"
	desc = "A wall breaching charge, containing fuel, metal oxide and metal powder mixed in just the right way. One hell of a combination. Effective against walls, ineffective against airlocks..."
	det_time = 2
	icon_state = "t4breach0"
	item_state = "t4breach"

/obj/item/grenade/plastic/x4/thermite/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			target.overlays -= image_overlay
	else
		location = get_turf(src)
	if(location)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(8,0, location, aim_dir)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			for(var/turf/simulated/wall/W in range(1, location))
				W.thermitemelt(speed = 30)
			addtimer(CALLBACK(null, .proc/explosion, T, 0, 0, 2), 3)
			addtimer(CALLBACK(smoke, /datum/effect_system/smoke_spread/.proc/start), 3)
		else
			addtimer(CALLBACK(null, .proc/explosion, T, 0, 0, 2), 3)
			addtimer(CALLBACK(smoke, /datum/effect_system/smoke_spread/.proc/start), 3)


	if(isliving(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(2)
		M.IgniteMob()
	qdel(src)
