// Airlock painter

/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on a completed airlock to change its paintjob."
	icon = 'icons/obj/device.dmi'
	icon_state = "airlock_painter"
	item_state = "airlock_painter"
	flags = CONDUCT | NOBLUDGEON
	usesound = 'sound/effects/spray2.ogg'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	var/paint_setting

	// All the different paint jobs that an airlock painter can apply.
	// If the airlock you're using it on is glass, the new paint job will also be glass
	var/list/available_paint_jobs = list(
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Command" = /obj/machinery/door/airlock/command,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Public" = /obj/machinery/door/airlock/public,
		"Research" = /obj/machinery/door/airlock/research,
		"Science" = /obj/machinery/door/airlock/science,
		"Security" = /obj/machinery/door/airlock/security,
		"Standard" = /obj/machinery/door/airlock,
	)

//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/paint(mob/user)
	playsound(loc, usesound, 30, TRUE)
	return TRUE

/obj/item/airlock_painter/attack_self(mob/user)
	paint_setting = input(user, "Please select a paintjob for this airlock.") as null|anything in available_paint_jobs
	if(!paint_setting)
		return
	to_chat(user, "<span class='notice'>The [paint_setting] paint setting has been selected.</span>")

/obj/item/airlock_painter/suicide_act(mob/user)

	var/obj/item/organ/internal/lungs/L = user.get_organ_slot("lungs")
	var/lungs_name = "\improper[L.name]"

	if(L)
		user.visible_message("<span class='suicide'>[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// they managed to lose their lungs between then and now. Good job.
		if(!L)
			return FALSE

		L.remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent("colorful_reagent", 10)
		L.reagents.reaction(L, REAGENT_TOUCH, 1)

		user.emote("scream")
		user.visible_message("<span class='suicide'>[user] vomits out [user.p_their()] [lungs_name]!</span>")
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		// make some vomit under the player, and apply colorful reagent
		var/obj/effect/decal/cleanable/vomit/V = new(get_turf(user))
		V.create_reagents(10)
		V.reagents.add_reagent("colorful_reagent", 10)
		V.reagents.reaction(V, REAGENT_TOUCH, 1)

		L.forceMove(get_turf(user))

		return OXYLOSS
	else
		return SHAME
