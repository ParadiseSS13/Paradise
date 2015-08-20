/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	var/energy = 0

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200)
		var/admin_message = "New singularity made"
		if(fingerprintshidden && length(fingerprintshidden))
			admin_message +=  "touched by: "
			if(islist(fingerprintshidden))
				for(var/fp in fingerprintshidden)
					admin_message += "[fp], "
				admin_message += " - Last touched by [fingerprintslast]. at [x],[y],[z]"
			else
				admin_message += fingerprintshidden

			log_admin(admin_message)
		message_admins("[admin_message] at [x],[y],[z]",1)
		investigate_log("[admin_message] at [x],[y],[z]","singulo")

		new /obj/singularity/(T, 50)
		if(src) qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet")
			src.add_hiddenprint(user)



		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet")
		return
	return ..()
