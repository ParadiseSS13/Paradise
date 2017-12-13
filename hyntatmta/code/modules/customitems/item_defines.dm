/obj/item/weapon/lighter/zippo/robust
    name = "robust zippo"
    desc = "All craftsspacemanship is of the highest quality. It is encrusted with gold sheets and rubies. There is etched R on the back."
    icon = 'hyntatmta/icons/obj/custom_items.dmi'
    icon_state = "robustzippo"
    icon_on = "robustzippoon"
    icon_off = "robustzippo"

/obj/item/weapon/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity"
	max_matter = 300
	matter = 300
	canRwall = 1
	icon_state = "arcd"

/obj/item/weapon/rcd/arcd/afterattack(atom/A, mob/user)
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0
	if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window)))
		return 0
	user.Beam(A,icon_state="rped_upgrade",time=30)
	switch(mode)
		if(1)
			if(istype(A, /turf/space))
				if(useResource(1, user))
					to_chat(user, "Building Floor...")
					activate()
					var/turf/AT = A
					AT.ChangeTurf(/turf/simulated/floor/plating)
					return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				if(checkResource(3, user))
					to_chat(user, "Building Wall ...")
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 20 * toolspeed, target = A))
						if(!useResource(3, user)) return 0
						activate()
						var/turf/AT = A
						AT.ChangeTurf(/turf/simulated/wall)
						return 1
				return 0

		if(2)
			if(istype(A, /turf/simulated/floor))
				if(checkResource(10, user))
					to_chat(user, "Building Airlock...")
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50 * toolspeed, target = A))
						if(!useResource(10, user)) return 0
						activate()
						var/obj/machinery/door/airlock/T = new door_type(A)
						T.name = door_name
						T.autoclose = 1
						if(one_access)
							T.req_one_access = door_accesses.Copy()
						else
							T.req_access = door_accesses.Copy()
						return 1
					return 0
				return 0

		if(3)
			if(istype(A, /turf/simulated/wall))
				if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				if(checkResource(5, user))
					to_chat(user, "Deconstructing Wall...")
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40 * toolspeed, target = A))
						if(!useResource(5, user)) return 0
						activate()
						var/turf/AT = A
						AT.ChangeTurf(/turf/simulated/floor/plating)
						return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				if(checkResource(5, user))
					to_chat(user, "Deconstructing Floor...")
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50 * toolspeed, target = A))
						if(!useResource(5, user)) return 0
						activate()
						var/turf/AT = A
						AT.ChangeTurf(/turf/space)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource(20, user))
					to_chat(user, "Deconstructing Airlock...")
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50 * toolspeed, target = A))
						if(!useResource(20, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/window)) // You mean the grille of course, do you?
				A = locate(/obj/structure/grille) in A.loc

			if(istype(A, /obj/structure/grille))
				if(!checkResource(2, user))
					return 0
				to_chat(user, "Deconstructing window...")
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				if(!do_after(user, 20 * toolspeed, target = A))
					return 0
				if(locate(/obj/structure/window/full/shuttle) in A.contents)
					return 0 // Let's not give shuttle-griefers an easy time.
				if(!useResource(2, user))
					return 0
				activate()
				var/turf/T1 = get_turf(A)
				qdel(A)
				A = null
				for(var/obj/structure/window/W in T1.contents)
					W.disassembled = 1
					W.density = 0
					qdel(W)
				for(var/cdir in cardinal)
					var/turf/T2 = get_step(T1, cdir)
					if(locate(/obj/structure/window/full/shuttle) in T2.contents)
						continue // Shuttle windows? Nah. We don't need extra windows there.
					if(!(locate(/obj/structure/grille) in T2.contents))
						continue
					for(var/obj/structure/window/W in T2.contents)
						if(W.dir == turn(cdir, 180))
							W.disassembled = 1
							W.density = 0
							qdel(W)
					var/obj/structure/window/reinforced/W = new(T2)
					W.dir = turn(cdir, 180)
				return 1
			return 0
		if(4)
			if(istype(A, /turf/simulated/floor))
				if(locate(/obj/structure/grille) in contents)
					return 0 // We already have window
				if(!checkResource(2, user))
					return 0
				to_chat(user, "Constructing window...")
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				if(!do_after(user, 20 * toolspeed, target = A))
					return 0
				if(locate(/obj/structure/grille) in A.contents)
					return 0 // We already have window
				if(!useResource(2, user))
					return 0
				activate()
				new /obj/structure/grille(A)
				for(var/obj/structure/window/W in contents)
					W.disassembled = 1 // Prevent that annoying glass breaking sound
					W.density = 0
					qdel(W)
				for(var/cdir in cardinal)
					var/turf/T = get_step(A, cdir)
					if(locate(/obj/structure/grille) in T.contents)
						for(var/obj/structure/window/W in T.contents)
							if(W.dir == turn(cdir, 180))
								W.disassembled = 1
								W.density = 0
								qdel(W)
					else // Build a window!
						var/obj/structure/window/reinforced/W = new(A)
						W.dir = cdir
				var/turf/AT = A
				AT.ChangeTurf(/turf/simulated/floor/plating) // Platings go under windows.
				return 1
		else
			to_chat(user, "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin.")
			return 0

	nanomanager.update_uis(src)
