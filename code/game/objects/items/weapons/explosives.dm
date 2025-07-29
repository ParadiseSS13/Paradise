/obj/item/grenade/plastic
	name = "plastic explosive"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon_state = "plastic-explosive0"
	base_icon_state = "plastic-explosive"
	inhand_icon_state = "plastic-explosive"
	flags = NOBLUDGEON
	det_time = 10
	display_timer = FALSE
	origin_tech = "syndicate=1"
	var/atom/target = null
	var/image_overlay = null
	var/obj/item/assembly/nadeassembly = null
	var/assemblyattacher
	var/notify_admins = TRUE
	/// C4 overlay to put on target
	var/mutable_appearance/plastic_overlay
	/// Target of the overlay, not neccicarly the thing the C4 is attached to!
	var/atom/plastic_overlay_target

/obj/item/grenade/plastic/Initialize(mapload)
	. = ..()
	plastic_overlay = mutable_appearance(icon, "[base_icon_state]2", HIGH_OBJ_LAYER)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/grenade/plastic/Destroy()
	QDEL_NULL(nadeassembly)
	target = null
	plastic_overlay_target = null
	return ..()

/obj/item/grenade/plastic/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!nadeassembly && istype(I, /obj/item/assembly))
		var/obj/item/assembly/A = I
		if(!user.transfer_item_to(A, src))
			return ..()
		nadeassembly = A
		A.master = src
		assemblyattacher = user.ckey
		to_chat(user, "<span class='notice'>You add [A] to [src].</span>")
		playsound(src, 'sound/weapons/tap.ogg', 20, 1)
		update_icon(UPDATE_ICON_STATE)
		return
	if(nadeassembly && istype(I, /obj/item/wirecutters))
		playsound(src, I.usesound, 20, 1)
		nadeassembly.loc = get_turf(src)
		nadeassembly.master = null
		nadeassembly = null
		update_icon(UPDATE_ICON_STATE)
		return
	..()

/obj/item/grenade/plastic/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(nadeassembly)
		nadeassembly.on_atom_entered(source, entered)

/obj/item/grenade/plastic/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/grenade/plastic/hear_talk(mob/living/M as mob, list/message_pieces)
	if(istype(nadeassembly, /obj/item/assembly/voice))
		var/obj/item/assembly/voice/voice_analyzer = nadeassembly
		voice_analyzer.hear_input(M, multilingual_to_message(message_pieces), 0)

/obj/item/grenade/plastic/hear_message(mob/living/M as mob, msg)
	if(istype(nadeassembly, /obj/item/assembly/voice))
		var/obj/item/assembly/voice/voice_analyzer = nadeassembly
		voice_analyzer.hear_input(M, msg, 1)

/obj/item/grenade/plastic/attack_self__legacy__attackchain(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self__legacy__attackchain(user)
		return
	var/newtime = input(usr, "Please set the timer.", "Timer", det_time) as num
	if(user.is_in_active_hand(src))
		newtime = clamp(newtime, 10, 60000)
		det_time = newtime
		to_chat(user, "Timer set for [det_time] seconds.")

/obj/item/grenade/plastic/afterattack__legacy__attackchain(mob/AM, mob/user, flag)
	if(!flag)
		return
	if(ismob(AM) && AM.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>You can't get the [src] to stick to [AM]! Perhaps if [AM] was asleep or dead you could attach it?</span>")
		return
	if(isstorage(AM) || ismodcontrol(AM))
		return ..() //Let us not have people c4 themselfs. Especially with a now 1.5 second do_after
	if(isobserver(AM))
		to_chat(user, "<span class='warning'>Your hand just phases through [AM]!</span>")
		return
	to_chat(user, "<span class='notice'>You start planting [src].[isnull(nadeassembly) ? " The timer is set to [det_time]..." : ""]</span>")

	if(do_after(user, 1.5 SECONDS * toolspeed, target = AM))
		if(!user.unequip(src))
			return

		target = AM
		loc = null

		if(notify_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at ([target.x],[target.y],[target.z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [det_time] second fuse", 0, 1)
			log_game("[key_name(user)] planted [name] on [target.name] at ([target.x],[target.y],[target.z]) with [det_time] second fuse")

		plastic_overlay.layer = HIGH_OBJ_LAYER
		if(isturf(target) || isairlock(target))
			plastic_overlay_target = new /obj/effect/plastic(get_turf(user))
		else
			plastic_overlay_target = target
		if(isliving(target))
			plastic_overlay.layer = ABOVE_ALL_MOB_LAYER
		if(plastic_overlay_target != target)
			switch(plastic_overlay_target.x - target.x)
				if(-1)
					plastic_overlay.pixel_x += 32
				if(1)
					plastic_overlay.pixel_x -= 32
			switch(plastic_overlay_target.y - target.y)
				if(-1)
					plastic_overlay.pixel_y += 32
				if(1)
					plastic_overlay.pixel_y -= 32
		plastic_overlay_target.add_overlay(plastic_overlay)

		if(!nadeassembly)
			to_chat(user, "<span class='notice'>You plant the bomb. Timer counting down from [det_time].</span>")
			addtimer(CALLBACK(src, PROC_REF(prime)), det_time SECONDS)

/obj/item/grenade/plastic/suicide_act(mob/user)
	message_admins("[key_name_admin(user)]([ADMIN_QUE(user,"?")]) ([ADMIN_FLW(user,"FLW")]) suicided with [src.name] at ([user.x],[user.y],[user.z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)",0,1)
	log_game("[key_name(user)] suicided with [name] at ([user.x],[user.y],[user.z])")
	user.visible_message("<span class='suicide'>[user] activates [src] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!</span>")
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
			else if(role == ROLE_WIZARD)
				message_say = "FOR THE FEDERATION!"
			else if(role == ROLE_REV || role == "head revolutionary")
				message_say = "FOR THE REVOLUTION!"
			else if(role == SPECIAL_ROLE_DEATHSQUAD || role == ROLE_ERT)
				message_say = "FOR NANOTRASEN!"
	user.say(message_say)
	target = user
	sleep(10)
	prime()
	user.gib()
	return OBLITERATION

/obj/item/grenade/plastic/update_icon_state()
	if(nadeassembly)
		icon_state = "[base_icon_state]1"
	else
		icon_state = "[base_icon_state]0"

//////////////////////////
///// The Explosives /////
//////////////////////////

/obj/item/grenade/plastic/c4
	name = "C4"
	desc = "Used to put holes in specific areas without too much extra hole. A saboteurs favourite."
	/// If set to true, the secondary explosion will be centered two tiles behind the wall/object it's set on for a targeted breach and entry.
	var/shaped = FALSE
	/// Set when installing the charge, to know which direction to explode to when setting up a shaped c4
	var/aim_dir
	/// Range values given to the explosion proc when primed
	var/ex_devastate = 0
	var/ex_heavy = 0
	var/ex_light = 3
	/// Will the explosion cause a breach. C4 placed on floors will always cause a breach, regardless of this value.
	var/ex_breach = FALSE

/obj/item/grenade/plastic/c4/afterattack__legacy__attackchain(atom/movable/AM, mob/user, flag)
	aim_dir = get_dir(user, AM)
	..()

/obj/item/grenade/plastic/c4/prime()
	var/turf/location
	if(plastic_overlay_target && !QDELETED(plastic_overlay_target))
		plastic_overlay_target.cut_overlay(plastic_overlay, TRUE)
		if(istype(plastic_overlay_target, /obj/effect/plastic))
			qdel(plastic_overlay_target)
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			if(!ex_breach && iswallturf(target)) //Walls get dismantled instead of destroyed to avoid making unwanted holes to space.
				var/turf/simulated/wall/W = target
				W.dismantle_wall(TRUE, TRUE)
			else
				target.ex_act(EXPLODE_DEVASTATE)
	else
		location = get_turf(src)
	if(location)
		if(shaped && aim_dir)
			location = get_step(get_step(location, aim_dir), aim_dir) //Move the explosion location two steps away from the target when using a shaped c4
		explosion(location, ex_devastate, ex_heavy, ex_light, breach = ex_breach, cause = name)

	qdel(src)

// X4 is an upgraded directional variant of c4 which is relatively safe to be standing next to. And much less safe to be standing on the other side of.
// C4 is intended to be used for infiltration, and destroying tech. X4 is intended to be used for heavy breaching and tight spaces.
// Intended to replace C4 for nukeops, and to be a randomdrop in surplus/random traitor purchases.

/obj/item/grenade/plastic/c4/x4
	name = "X4"
	desc = "A specialized shaped high explosive breaching charge. Designed to be safer for the user, and less so, for the wall."
	icon_state = "plasticx40"
	base_icon_state = "plasticx4"
	shaped = TRUE
	ex_heavy = 2
	ex_breach = TRUE

// Shaped charge
// Same blasting power as C4, but with the same idea as the X4 -- Everyone on one side of the wall is safe.

/obj/item/grenade/plastic/c4/shaped
	name = "C4 (shaped)"
	desc = "A brick of C4 shaped to allow more precise breaching."
	shaped = TRUE

/obj/item/grenade/plastic/c4/shaped/flash
	name = "C4 (flash)"
	desc = "A C4 charge with an altered chemical composition, designed to blind and deafen the occupants of a room before breaching."

/obj/item/grenade/plastic/c4/shaped/flash/prime()
	var/turf/T
	if(target && target.density)
		T = get_step(get_turf(target), aim_dir)
	else if(target)
		T = get_turf(target)
	else
		T = get_turf(src)

	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(T)
	CB.prime()

	..()

/obj/item/grenade/plastic/c4/thermite
	name = "T4"
	desc = "A wall breaching charge, containing fuel, metal oxide and metal powder mixed in just the right way. One hell of a combination. Effective against walls, ineffective against airlocks..."
	det_time = 2
	icon_state = "t4breach0"
	base_icon_state = "t4breach"

/obj/item/grenade/plastic/c4/thermite/prime()
	var/turf/location
	if(plastic_overlay_target && !QDELETED(plastic_overlay_target))
		plastic_overlay_target.cut_overlay(plastic_overlay, TRUE)
		if(istype(plastic_overlay_target, /obj/effect/plastic))
			qdel(plastic_overlay_target)
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
	else
		location = get_turf(src)
	if(location)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(8, FALSE, location, aim_dir)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			for(var/turf/simulated/wall/W in range(1, location))
				W.thermitemelt(speed = 30)
			addtimer(CALLBACK(null, GLOBAL_PROC_REF(explosion), T, 0, 0, 2), 3)
			addtimer(CALLBACK(smoke, TYPE_PROC_REF(/datum/effect_system/smoke_spread, start)), 3)
		else
			var/turf/T = get_step(location, aim_dir)
			addtimer(CALLBACK(null, GLOBAL_PROC_REF(explosion), T, 0, 0, 2), 3)
			addtimer(CALLBACK(smoke, TYPE_PROC_REF(/datum/effect_system/smoke_spread, start)), 3)

	if(isliving(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(2)
		M.IgniteMob()
	qdel(src)

//Used so the effect is visable for overlay purposes, but not show on right click with a broken sprite
/obj/effect/plastic
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
