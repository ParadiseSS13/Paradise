//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls and floors."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	materials = list(MAT_METAL=100000)
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/system/spark_spread/spark_system
	var/max_matter = 100
	var/matter = 0
	var/working = 0
	var/mode = 1
	var/canRwall = 0

	New()
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
		src.spark_system = new /datum/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		rcd_list += src
		return

	Destroy()
		qdel(spark_system)
		spark_system = null
		rcd_list -= src
		return ..()

	attackby(obj/item/weapon/W, mob/user, params)
		..()
		if(istype(W, /obj/item/weapon/rcd_ammo))
			var/obj/item/weapon/rcd_ammo/R = W
			if((matter + R.ammoamt) > max_matter)
				to_chat(user, "<span class='notice'>The RCD cant hold any more matter-units.</span>")
				return
			matter += R.ammoamt
			user.drop_item()
			qdel(W)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
			desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return


	attack_self(mob/user)
		//Change the mode
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		switch(mode)
			if(1)
				mode = 2
				to_chat(user, "<span class='notice'>Changed mode to 'Airlock'</span>")
				if(prob(20))
					src.spark_system.start()
				return
			if(2)
				mode = 3
				to_chat(user, "<span class='notice'>Changed mode to 'Deconstruct'</span>")
				if(prob(20))
					src.spark_system.start()
				return
			if(3)
				mode = 4
				to_chat(user, "<span class='notice'>Changed mode to 'Windows'</span>")
				if(prob(20))
					src.spark_system.start()
				return
			if(4)
				mode = 1
				to_chat(user, "<span class='notice'>Changed mode to 'Floor & Walls'</span>")
				if(prob(20))
					src.spark_system.start()
				return

	proc/activate()
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


	afterattack(atom/A, mob/user, proximity)
		if(!proximity) return
		if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
			return 0
		if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window)))
			return 0

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
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 20, target = A))
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
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50, target = A))
							if(!useResource(10, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
							T.autoclose = 1
							return 1
						return 0
					return 0

			if(3)
				if(istype(A, /turf/simulated/wall))
					if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
						return 0
					if(checkResource(5, user))
						to_chat(user, "Deconstructing Wall...")
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 40, target = A))
							if(!useResource(5, user)) return 0
							activate()
							var/turf/AT = A
							AT.ChangeTurf(/turf/simulated/floor/plating)
							return 1
					return 0

				if(istype(A, /turf/simulated/floor))
					if(checkResource(5, user))
						to_chat(user, "Deconstructing Floor...")
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50, target = A))
							if(!useResource(5, user)) return 0
							activate()
							var/turf/AT = A
							AT.ChangeTurf(/turf/space)
							return 1
					return 0

				if(istype(A, /obj/machinery/door/airlock))
					if(checkResource(20, user))
						to_chat(user, "Deconstructing Airlock...")
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50, target = A))
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
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(!do_after(user, 20, target = A))
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
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(!do_after(user, 20, target = A))
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

/obj/item/weapon/rcd/proc/useResource(var/amount, var/mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	return 1

/obj/item/weapon/rcd/proc/checkResource(var/amount, var/mob/user)
	return matter >= amount
/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 160)

/obj/item/weapon/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 160)

/obj/item/weapon/rcd/borg/New()
	..()
	desc = "A device used to rapidly build and deconstruct walls and floors."
	canRwall = 1

/obj/item/weapon/rcd/combat
	name = "combat RCD"
	max_matter = 500
	matter = 500
	canRwall = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	materials = list(MAT_METAL=16000, MAT_GLASS=8000)
	var/ammoamt = 20

/obj/item/weapon/rcd_ammo/large
	ammoamt = 100
