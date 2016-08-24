/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 100
	var/lastbang
	var/cutting_tool = /obj/item/weapon/weldingtool
	var/sound = 'sound/machines/click.ogg'
	var/cutting_sound = 'sound/items/Welder.ogg'
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/material_drop = /obj/item/stack/sheet/metal

/obj/structure/closet/New()
	..()
	spawn(1)
		if(!opened)		// if closed, any item at the crate's loc is put in the contents
			for(var/obj/item/I in src.loc)
				if(I.density || I.anchored || I == src) continue
				I.forceMove(src)

// Fix for #383 - C4 deleting fridges with corpses
/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0 || wall_mounted)) return 1
	return (!density)

/obj/structure/closet/proc/can_open()
	if(src.welded)
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && closet.anchored != 1)
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()
	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.forceMove(loc)

	for(var/obj/I in src)
		I.forceMove(loc)

	for(var/mob/M in src)
		moveMob(M, loc)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/closet/proc/moveMob(var/mob/M, var/atom/destination)
	loc.Exited(M)
	M.loc = destination
	if(isturf(loc))
		loc.Entered(M, src, ignoreRest = 1)
	else
		loc.Entered(M, src)
	for(var/atom/movable/AM in loc)
		if(istype(AM, /obj/item))
			continue
		AM.Crossed(M)

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	if(sound)
		playsound(src.loc, src.sound, 15, 1, -3)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 0
	return 1

/obj/structure/closet/proc/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	var/itemcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src.loc)
		if(itemcount >= storage_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored)
			I.forceMove(src)
			itemcount++

	for(var/mob/M in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(istype (M, /mob/dead/observer))
			continue
		if(M.buckled)
			continue

		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

		moveMob(M, src)
		itemcount++

	src.icon_state = src.icon_closed
	src.opened = 0
	if(sound)
		playsound(src.loc, src.sound, 15, 1, -3)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 1
	return 1

/obj/structure/closet/proc/toggle(mob/user as mob)
	if(!(src.opened ? src.close() : src.open()))
		to_chat(user, "<span class='notice'>It won't budge!</span>")

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A as mob|obj in src)//pulls everything out of the locker and hits it with an explosion
				A.forceMove(src.loc)
				A.ex_act(severity++)
			qdel(src)
		if(2)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					A.ex_act(severity++)
				new /obj/item/stack/sheet/metal(loc)
				qdel(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					A.ex_act(severity++)
				new /obj/item/stack/sheet/metal(loc)
				qdel(src)

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	..()
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		if(health <= 0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
			qdel(src)

/obj/structure/closet/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash)
		user.do_attack_animation(src)
		visible_message("\red [user] destroys the [src]. ")
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(loc)
		qdel(src)

// this should probably use dump_contents()
/obj/structure/closet/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(loc)
		qdel(src)

/obj/structure/closet/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/rcs) && !src.opened)
		if(user in contents) //to prevent self-teleporting.
			return
		var/obj/item/weapon/rcs/E = W
		if(E.rcell && (E.rcell.charge >= E.chargecost))
			if(!is_level_reachable(src.z))
				to_chat(user, "<span class='warning'>The rapid-crate-sender can't locate any telepads!</span>")
				return
			if(E.mode == 0)
				if(!E.teleporting)
					var/list/L = list()
					var/list/areaindex = list()
					for(var/obj/machinery/telepad_cargo/R in world)
						if(R.stage == 0)
							var/turf/T = get_turf(R)
							var/tmpname = T.loc.name
							if(areaindex[tmpname])
								tmpname = "[tmpname] ([++areaindex[tmpname]])"
							else
								areaindex[tmpname] = 1
							L[tmpname] = R
					var/desc = input("Please select a telepad.", "RCS") in L
					E.pad = L[desc]
					playsound(E.loc, 'sound/machines/click.ogg', 50, 1)
					to_chat(user, "\blue Teleporting [src.name]...")
					E.teleporting = 1
					if(!do_after(user, 50, target = src))
						E.teleporting = 0
						return
					E.teleporting = 0
					if(user in contents)
						to_chat(user, "<span class='warning'>Error: User located in container--aborting for safety.</span>")
						playsound(E.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
						return
					var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
					s.set_up(5, 1, src)
					s.start()
					do_teleport(src, E.pad, 0)
					E.rcell.use(E.chargecost)
					to_chat(user, "<span class='notice'>Teleport successful. [round(E.rcell.charge/E.chargecost)] charge\s left.</span>")
					return
			else
				E.rand_x = rand(50,200)
				E.rand_y = rand(50,200)
				var/L = locate(E.rand_x, E.rand_y, 6)
				playsound(E.loc, 'sound/machines/click.ogg', 50, 1)
				to_chat(user, "\blue Teleporting [src.name]...")
				E.teleporting = 1
				if(!do_after(user, 50, target = src))
					E.teleporting = 0
					return
				E.teleporting = 0
				if(user in contents)
					to_chat(user, "<span class='warning'>Error: User located in container--aborting for safety.</span>")
					playsound(E.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
					return
				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				do_teleport(src, L)
				E.rcell.use(E.chargecost)
				to_chat(user, "<span class='notice'>Teleport successful. [round(E.rcell.charge/E.chargecost)] charge\s left.</span>")
				return
		else
			to_chat(user, "<span class='warning'>Out of charges.</span>")
			return

	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		if(istype(W,/obj/item/tk_grab))
			return 0
		if(istype(W, cutting_tool))
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(!WT.remove_fuel(0, user))
					return
				to_chat(user, "<span class='notice'>You begin cutting \the [src] apart...</span>")
				playsound(loc, cutting_sound, 40, 1)
				if(do_after(user, 40, 1, target = src))
					if(!opened || !WT.isOn())
						return
					playsound(loc, cutting_sound, 50, 1)
					visible_message("<span class='notice'>[user] slices apart \the [src].</span>",
									"<span class='notice'>You cut \the [src] apart with \the [WT].</span>",
									"<span class='italics'>You hear welding.</span>")
					var/turf/T = get_turf(src)
					new material_drop(T)
					qdel(src)
					return
		if(isrobot(user))
			return
		if(!usr.drop_item())
			return
		if(W)
			W.forceMove(loc)
	else if(istype(W, /obj/item/stack/packageWrap))
		return
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(src == user.loc)
			to_chat(user, "<span class='notice'>You can not [welded?"unweld":"weld"] the locker from inside.</span>")
			return
		if(!WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		src.welded = !src.welded
		src.update_icon()
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>", 3, "You hear welding.", 2)
	else
		src.attack_hand(user)

/obj/structure/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	..()
	if(istype(O, /obj/screen))	//fix for HUD elements making their way into the world	-Pete
		return
	if(O.loc == user)
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.lying)
		return
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!src.opened)
		return
	if(istype(O, /obj/structure/closet))
		return
	step_towards(O, src.loc)
	if(user != O)
		user.visible_message("<span class='danger'>[user] stuffs [O] into [src]!</span>", "<span class='danger'>You stuff [O] into [src]!</span>")
	src.add_fingerprint(user)

/obj/structure/closet/attack_ai(mob/user)
	if(istype(user, /mob/living/silicon/robot) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user as mob)
	if(user.stat || !isturf(src.loc))
		return

	if(!src.open())
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		if(!lastbang)
			lastbang = 1
			for(var/mob/M in hearers(src, null))
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = 0

/obj/structure/closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	src.toggle(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user as mob)
	src.add_fingerprint(user)
	if(!src.toggle())
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = null
	set name = "Toggle Open"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += "welded"
	else
		icon_state = icon_opened

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src) return 0
	return 1

/obj/structure/closet/container_resist(var/mob/living/L)
	var/breakout_time = 2 //2 minutes by default
	if(opened)
		if(L.loc == src)
			L.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?
	if(!welded)
		open() //for cardboard boxes
		return //closed but not welded...
	//	else Meh, lets just keep it at 2 minutes for now
	//		breakout_time++ //Harder to get out of welded lockers than locked lockers

	//okay, so the closet is either welded or locked... resist!!!
	L.changeNext_move(CLICK_CD_BREAKOUT)
	L.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(L, "<span class='warning'>You lean on the back of \the [src] and start pushing the door open. (this will take about [breakout_time] minutes)</span>")
	for(var/mob/O in viewers(usr.loc))
		O.show_message("<span class='danger'>The [src] begins to shake violently!</span>", 1)


	spawn(0)
		if(do_after(L,(breakout_time*60*10), target = src)) //minutes * 60seconds * 10deciseconds
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				return

			//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
			if(!welded)
				return

			//Well then break it!
			welded = 0
			update_icon()
			to_chat(usr, "<span class='warning'>You successfully break out!</span>")
			for(var/mob/O in viewers(L.loc))
				O.show_message("<span class='danger'>\the [usr] successfully broke out of \the [src]!</span>", 1)
			if(istype(src.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
				var/obj/structure/bigDelivery/BD = src.loc
				BD.attack_hand(usr)
			open()

/obj/structure/closet/tesla_act(var/power)
	..()
	visible_message("<span class='danger'>[src] is blown apart by the bolt of electricity!</span>", "<span class='danger'>You hear a metallic screeching sound.</span>")
	qdel(src)
