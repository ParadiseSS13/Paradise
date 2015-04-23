/obj/structure/trashcan
	name = "trash can"
	desc = "It's like a disposals unit, but shit."
	icon = 'icons/obj/trashcan.dmi'
	icon_state = "trashcan"
	anchored = 1
	density = 1
	var/welded = 0

	attackby(var/obj/item/I, var/mob/user, params)
		if(!I || !user || (I.flags & NODROP))
			return

		if(isrobot(user) && !istype(I, /obj/item/weapon/storage/bag/trash))
			return

		src.add_fingerprint(user)

		if(istype(I, /obj/item/weapon/wrench))
			if(anchored)
				anchored = 0
				user << "You unwrench the [src] from the floor."
			else
				anchored = 1
				user << "You wrench the [src] to the floor."

		if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = I

			if(W.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				if(!W.isOn()) return
				if(welded)
					user << "You unweld the trash can."
					welded = 0
				else
					user << "You weld the trash can shut."
					welded = 1
			else
				user << "You need more welding fuel to do that."
				return


		if(istype(I, /obj/item/weapon/melee/energy/blade))
			user << "You can't place that item inside the disposal unit."
			return

		if(welded)
			user.visible_message("<span class='notice'>The [src] is welded shut.</span>")
			return

		if(istype(I, /obj/item/weapon/storage/bag/trash))
			var/obj/item/weapon/storage/bag/trash/T = I
			if(T.contents.len)
				user << "\blue You empty the bag."
				for(var/obj/item/O in T.contents)
					T.remove_from_storage(O,src)
				T.update_icon()
				return

		if(istype(I, /obj/item/weapon/storage/part_replacer))
			var/obj/item/weapon/storage/part_replacer/P = I
			if(P.contents.len)
				user << "\blue You empty the RPED's contents."
				for(var/obj/item/O in P.contents)
					P.remove_from_storage(O,src)
				return

		var/obj/item/weapon/grab/G = I
		if(istype(G))	// handle grabbed mob
			if(ismob(G.affecting))
				var/mob/GM = G.affecting
				for (var/mob/V in viewers(usr))
					V.show_message("[user] starts putting [GM.name] into the [src].", 3)
				if(do_after(usr, 20))
					if (GM.client)
						GM.client.perspective = EYE_PERSPECTIVE
						GM.client.eye = src
					GM.loc = src
					for (var/mob/C in viewers(src))
						C.show_message("\red [GM.name] has been placed in the [src] by [user].", 3)
					del(G)
					usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has placed [GM.name] ([GM.ckey]) in a trash can.</font>")
					GM.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been placed in a trash can by [usr.name] ([usr.ckey])</font>")
					if(GM.ckey)
						msg_admin_attack("[usr] ([usr.ckey])[isAntag(usr) ? "(ANTAG)" : ""] placed [GM] ([GM.ckey]) in a trash can. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>)")
			return

		if(!I)	return

		user.drop_item()
		if(I)
			I.loc = src

		user << "You place \the [I] into the [src]."
		for(var/mob/M in viewers(src))
			if(M == user)
				continue
			M.show_message("[user.name] places \the [I] into the [src].", 3)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (istype(mover,/obj/item) && mover.throwing)
			var/obj/item/I = mover
			if(istype(I, /obj/item/projectile))
				return
			if(prob(75) && !welded)
				I.loc = src
				for(var/mob/M in viewers(src))
					M.show_message("\the [I] lands in \the [src].", 3)
			else
				for(var/mob/M in viewers(src))
					M.show_message("\the [I] bounces off of \the [src]'s rim!.", 3)
			return 0
		else
			return ..(mover, target, height, air_group)

	verb/empty()
		set name = "Empty Trash Can"
		set desc = "Empties the contents of a Trash Can"
		set category = null
		set src in oview(1)

		if (!can_touch(usr) || ismouse(usr))
			return

		if(do_empty())
			usr.visible_message("<span class='notice'>[usr] empties \the [src].</span>")
		else if(welded)
			usr << "<span class='notice'>The [src] is welded shut.</span>"
		return

	proc/do_empty()
		if(!(contents.len > 0))
			return 0
		if(welded)
			return 0
		for(var/atom/movable/AM in src)
			AM.loc = src.loc

	// attempt to move while inside
	relaymove(mob/user as mob)
		if(user.stat)
			return
		if(welded)
			user.visible_message("<span class='notice'>You can't get out. The [src] is welded shut!</span>")
			return
		src.go_out(user)
		return

	// leave the disposal
	proc/go_out(mob/user)

		if (user.client)
			user.client.eye = user.client.mob
			user.client.perspective = MOB_PERSPECTIVE
		user.loc = src.loc
		return

	MouseDrop_T(mob/target, mob/user)
		if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai))
			return
		if(isanimal(user) && target != user) return //animals cannot put mobs other than themselves into disposal
		src.add_fingerprint(user)
		var/target_loc = target.loc
		var/msg

		if(welded)
			user.visible_message("<span class='notice'>The [src] is welded shut!</span>")
			return

		for (var/mob/V in viewers(usr))
			if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
				V.show_message("[usr] starts climbing into the [src].", 3)
			if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
				if(target.anchored) return
				V.show_message("[usr] starts stuffing [target.name] into the [src].", 3)
		if(!do_after(usr, 20))
			return
		if(target_loc != target.loc)
			return
		if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)	// if drop self, then climbed in
												// must be awake, not stunned or whatever
			msg = "[user.name] climbs into the [src]."
			user << "You climb into the [src]."
		else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
			msg = "[user.name] stuffs [target.name] into the [src]!"
			user << "You stuff [target.name] into the [src]!"

			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has placed [target.name] ([target.ckey]) in a trash can.</font>")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been placed in a trash can by [user.name] ([user.ckey])</font>")
			if(target.ckey)
				msg_admin_attack("[user] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] placed [target] ([target.ckey]) in a trash can. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		else
			return
		if (target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = src
		target.loc = src

		for (var/mob/C in viewers(src))
			if(C == user)
				continue
			C.show_message(msg, 3)