/obj/item/weapon/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	origin_tech = "materials=1;biotech=3;programming=2"
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implanter/New()
	..()
	update()

/obj/item/weapon/implanter/proc/update()


/obj/item/weapon/implanter/update()
	if (src.imp)
		src.icon_state = "implanter1"
		src.origin_tech = src.imp.origin_tech
	else
		src.icon_state = "implanter0"
		src.origin_tech = initial(src.origin_tech)
	return


/obj/item/weapon/implanter/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob/living/carbon))
		return
	if (user && src.imp)
		for (var/mob/O in viewers(M, null))
			O.show_message("\red [user] is attemping to implant [M].", 1)

		var/turf/T1 = get_turf(M)
		if (T1 && ((M == user) || do_after(user, 50, target = M)))
			if(user && M && (get_turf(M) == T1) && src && src.imp)
				for (var/mob/O in viewers(M, null))
					O.show_message("\red [M] has been implanted by [user].", 1)

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [src.name] ([src.imp.name]) by [key_name(user)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] ([src.imp.name]) to implant [key_name(M)]</font>")
				msg_admin_attack("[key_name_admin(user)] implanted [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])")

				user.show_message("\red You implanted the implant into [M].")
				if(src.imp.implanted(M, user))
					src.imp.loc = M
					src.imp.imp_in = M
					src.imp.implanted = 1
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
						affected.implants += src.imp
						imp.part = affected
						H.hud_updateflag |= 1 << IMPLOYAL_HUD
				M:implanting = 0
				src.imp = null
				update()



/obj/item/weapon/implanter/traitor
	name = "implanter (Mindslave)"
	desc = "Divide and Conquer."

	New()
		src.imp = new /obj/item/weapon/implant/traitor(src)
		..()
		update()
		return

/obj/item/weapon/implanter/loyalty
	name = "implanter (Loyalty)"

/obj/item/weapon/implanter/loyalty/New()
	src.imp = new /obj/item/weapon/implant/loyalty( src )
	..()
	update()
	return

/obj/item/weapon/implanter/dexplosive
	name = "implanter (Microbomb)"

/obj/item/weapon/implanter/dexplosive/New()
	src.imp = new /obj/item/weapon/implant/dexplosive( src )
	..()
	update()
	return

/obj/item/weapon/implanter/explosive
	name = "implanter (Explosive)"

/obj/item/weapon/implanter/explosive/New()
	src.imp = new /obj/item/weapon/implant/explosive( src )
	..()
	update()
	return

/obj/item/weapon/implanter/adrenalin
	name = "implanter (Adrenaline)"

/obj/item/weapon/implanter/adrenalin/New()
	src.imp = new /obj/item/weapon/implant/adrenalin(src)
	..()
	update()
	return

/obj/item/weapon/implanter/compressed
	name = "implanter (Compressed)"
	icon_state = "cimplanter1"

	var/list/forbidden_types=list(
		// /obj/item/weapon/storage/bible // VG #11 - Recursion.
	)

/obj/item/weapon/implanter/compressed/New()
	imp = new /obj/item/weapon/implant/compressed( src )
	..()
	update()
	return

/obj/item/weapon/implanter/compressed/update()
	if (imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"
	return

/obj/item/weapon/implanter/compressed/attack(mob/M as mob, mob/user as mob)
	// Attacking things in your hands tends to make this fuck up.
	if(!istype(M))
		return
	var/obj/item/weapon/implant/compressed/c = imp
	if (!c)	return
	if (c.scanned == null)
		user << "Please scan an object with the implanter first."
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(var/obj/item/I, mob/user as mob)
	if(is_type_in_list(I,forbidden_types))
		user << "\red A red light flickers on the implanter."
		return
	if(istype(I) && imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if (c.scanned)
			user << "\red Something is already scanned inside the implant!"
			return
		if(user)
			user.unEquip(I)
			user.update_icons()	//update our overlays
		c.scanned = I
		c.scanned.loc = c
		update()

/obj/item/weapon/implanter/deadman
	name = "implanter (Deadman)"
	desc = "Switch it."

	New()
		src.imp = new /obj/item/weapon/implant/deadman(src)
		..()
		update()
		return

/obj/item/weapon/implanter/death_alarm
	name = "implanter (Death Alarm)"
	desc = "Announces the death of the implanted person over radio"

	New()
		src.imp = new /obj/item/weapon/implant/death_alarm(src)
		..()
		update()
		return

/obj/item/weapon/implanter/emp
	name = "implanter (EMP)"

	New()
		src.imp = new /obj/item/weapon/implant/emp(src)
		..()
		update()
		return

/obj/item/weapon/implanter/freedom
	name = "implanter (Freedom)"

	New()
		src.imp = new /obj/item/weapon/implant/freedom(src)
		..()
		update()
		return

/obj/item/weapon/implanter/uplink
	name = "implanter (Uplink)"

	New()
		src.imp = new /obj/item/weapon/implant/uplink(src)
		..()
		update()
		return