/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 150.0 //If you change this, consider changing ../door/window/brigdoor/ health at the bottom of this .dm file
	visible = 0.0
	flags = ON_BORDER
	opacity = 0
	var/obj/item/weapon/airlock_electronics/electronics = null

/obj/machinery/door/window/New()
	..()

	if(req_access && req_access.len)
		icon_state = "[icon_state]"
		base_state = icon_state

	if(!color)
		color = color_windows(src)
	return

/obj/machinery/door/window/Destroy()
	density = 0
	if(health == 0)
		playsound(src, "shatter", 70, 1)
	QDEL_NULL(electronics)
	return ..()


/obj/machinery/door/window/proc/open_and_close()
	open()
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if(operating || !density)
		return
	if(!ismob(AM))
		if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && allowed(mecha.occupant))
				open_and_close()
			else
				flick(text("[]deny", base_state), src)
		return
	if(!ticker)
		return
	var/mob/living/M = AM
	if(!M.restrained() && M.mob_size > MOB_SIZE_SMALL)
		bumpopen(M)
	return

/obj/machinery/door/window/bumpopen(mob/user as mob)
	if( operating || !density )
		return
	add_fingerprint(user)
	if(!requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		flick(text("[]deny", base_state), src)
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/machinery/door/window/CanAtmosPass(var/turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(var/obj/item/weapon/card/id/ID, var/to_dir)
	return !density || (dir != to_dir) || (check_access(ID) && !(stat & NOPOWER))

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open(var/forced=0)
	if(operating) //doors can still open when emag-disabled
		return 0
	if(!ticker)
		return 0
	if(!forced)
		if(stat & NOPOWER)
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	if(!operating) //in case of emag
		operating = 1
	flick(text("[]opening", base_state), src)
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state = text("[]open", base_state)
	sleep(10)

	density = 0
//	sd_set_opacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()

	if(operating) //emag again
		operating = 0
	return 1

/obj/machinery/door/window/close(var/forced=0)
	if(operating)
		return 0
	if(!forced)
		if(stat & NOPOWER)
			return 0
	if(forced < 2)
		if(emagged)
			return 0
	operating = 1
	flick(text("[]closing", base_state), src)
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	icon_state = base_state

	density = 1
//	if(visible)
//		set_opacity(1)	//TODO: why is this here? Opaque windoors? ~Carn
	air_update_turf(1)
	update_freelook_sight()
	sleep(10)

	operating = 0
	return 1

/obj/machinery/door/window/proc/take_damage(var/damage)
	health = max(0, health - damage)
	if(health <= 0)
		var/debris = list(
			new /obj/item/weapon/shard(loc),
			new /obj/item/weapon/shard(loc),
			new /obj/item/stack/rods(loc, 2),
			new /obj/item/stack/cable_coil(loc, 2)
			)
		for(var/obj/fragment in debris)
			transfer_fingerprints_to(fragment)
		density = 0
		qdel(src)
		return

/obj/machinery/door/window/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			take_damage(round(Proj.damage / 2))
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(AM as mob|obj)

	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	take_damage(tforce)
	//..() //Does this really need to be here twice? The parent proc doesn't even do anything yet. - Nodrak
	return

/obj/machinery/door/window/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>")
		take_damage(M.force)
	return

/obj/machinery/door/window/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/window/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/window/proc/attack_generic(mob/user as mob, damage = 0)
	if(operating)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	user.visible_message("<span class='danger'>[user] smashes against the [name].</span>", \
				"<span class='userdanger'>[user] smashes against the [name].</span>")
	take_damage(damage)

/obj/machinery/door/window/attack_alien(mob/living/user as mob)
	if(islarva(user))
		return
	attack_generic(user, 25)

/obj/machinery/door/window/attack_animal(mob/living/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper > 0 && (M.melee_damage_type == BRUTE || M.melee_damage_type == BURN))
		attack_generic(M, M.melee_damage_upper)

/obj/machinery/door/window/attack_slime(mob/living/carbon/slime/user as mob)
	if(!user.is_adult)
		return
	attack_generic(user, 25)

/obj/machinery/door/window/attack_hand(mob/user as mob)
	return attackby(user, user)

/obj/machinery/door/window/emag_act(mob/user, obj/weapon)
	if(!operating && density && !emagged)
		operating = 1
		flick("[base_state]spark", src)
		sleep(6)
		operating = 0
		desc += "<BR><span class='warning'>Its access panel is smoking slightly.</span>"
		if(istype(weapon, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/B
			var/datum/effect/system/spark_spread/spark_system = new /datum/effect/system/spark_spread()
			spark_system.set_up(5, 0, loc)
			spark_system.start()
			playsound(loc, "sparks", 50, 1)
			playsound(loc, B.usesound, 50, 1)
			visible_message("<span class='warning'> The glass door was sliced open by [user]!</span>")
			open(2)
			emagged = 1
			return 1
		open()
		emagged = 1
		return 1

/obj/machinery/door/window/attackby(obj/item/weapon/I as obj, mob/living/user as mob, params)

	//If it's in the process of opening/closing, ignore the click
	if(operating)
		return

	add_fingerprint(user)

	//Ninja swords? You may pass.
	if(density && (istype(I, /obj/item/weapon/card/emag) || istype(I, /obj/item/weapon/melee/energy/blade)))
		emag_act(user,I)
		return 1

	if(istype(I, /obj/item/weapon/screwdriver))
		if(density || operating)
			to_chat(user, "<span class='warning'>You need to open the door to access the maintenance panel.</span>")
			return
		playsound(loc, I.usesound, 50, 1)
		p_open = !( p_open )
		to_chat(user, "<span class='notice'>You [p_open ? "open":"close"] the maintenance panel of the [name].</span>")
		return

	if(istype(I, /obj/item/weapon/crowbar))
		if(p_open && !density && !operating)
			playsound(loc, I.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] removes the electronics from the [name].</span>", \
								 "You start to remove electronics from the [name].")
			if(do_after(user, 40 * I.toolspeed, target = src))
				if(p_open && !density && !operating && loc)
					var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(loc)
					switch(base_state)
						if("left")
							WA.facing = "l"
						if("right")
							WA.facing = "r"
						if("leftsecure")
							WA.facing = "l"
							WA.secure = 1
						if("rightsecure")
							WA.facing = "r"
							WA.secure = 1
					WA.anchored = 1
					WA.state= "02"
					WA.dir = dir
					WA.ini_dir = dir
					WA.update_icon()
					WA.created_name = name

					if(emagged)
						to_chat(user, "<span class='warning'>You discard the damaged electronics.</span>")
						qdel(src)
						return

					to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")

					var/obj/item/weapon/airlock_electronics/ae
					if(!electronics)
						ae = new/obj/item/weapon/airlock_electronics( loc )
						if(!req_access)
							check_access()
						if(req_access.len)
							ae.conf_access = req_access
						else if(req_one_access.len)
							ae.conf_access = req_one_access
							ae.one_access = 1
					else
						ae = electronics
						electronics = null
						ae.loc = loc

					qdel(src)
			return


	//If windoor is unpowered, crowbar, fireaxe and armblade can force it.
	if(istype(I, /obj/item/weapon/crowbar) || istype(I, /obj/item/weapon/twohanded/fireaxe))
		if(stat & NOPOWER)
			if(density)
				open(2)
			else
				close(2)
			return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card) )
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if( (I.flags&NOBLUDGEON) || !I.force )
			return
		var/aforce = I.force
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("<span class='danger'>\The [src] has been hit by [user] with [I].</span>")
		if(I.damtype == BURN || I.damtype == BRUTE)
			take_damage(aforce)
		return

	if(!requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null

	if(allowed(user) || user.can_advanced_admin_interact())
		if(density)
			open()
		else
			close()

	else if(density)
		flick(text("[]deny", base_state), src)

	return



/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	health = 300.0 //Stronger doors for prison (regular window door health is 200)


/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
