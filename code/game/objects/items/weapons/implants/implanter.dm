/obj/item/implanter
	name = "microchip implanter"
	desc = "A sterile automatic microchip injector."
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL=600, MAT_GLASS=200)
	toolspeed = 1
	var/obj/item/implant/imp = null


/obj/item/implanter/update_icon_state()
	if(imp)
		icon_state = "implanter1"
		origin_tech = imp.origin_tech
	else
		icon_state = "implanter0"
		origin_tech = initial(origin_tech)


/obj/item/implanter/attack(mob/living/carbon/M, mob/user)
	if(!iscarbon(M))
		return
	if(user && imp)
		if(M != user)
			M.visible_message("<span class='warning'>[user] is attempting to microchip [M].</span>")

		var/turf/T = get_turf(M)
		if(T && (M == user || do_after(user, 50 * toolspeed, target = M)))
			if(user && M && (get_turf(M) == T) && src && imp)
				if(imp.implant(M, user))
					if(M == user)
						to_chat(user, "<span class='notice'>You microchip yourself.</span>")
					else
						M.visible_message("[user] has implanted [M].", "<span class='notice'>[user] microchips you.</span>")
					imp = null
					update_icon(UPDATE_ICON_STATE)

/obj/item/implanter/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/pen))
		rename_interactive(user, W)

/obj/item/implanter/New()
	..()
	spawn(1)
		update_icon(UPDATE_ICON_STATE)


/obj/item/implanter/adrenalin
	name = "microchip implanter (adrenalin)"

/obj/item/implanter/adrenalin/New()
	imp = new /obj/item/implant/adrenalin(src)
	..()


/obj/item/implanter/emp
	name = "microchip implanter (EMP)"

/obj/item/implanter/emp/New()
	imp = new /obj/item/implant/emp(src)
	..()

/obj/item/implanter/traitor
	name = "microchip implanter (Mindslave)"

/obj/item/implanter/traitor/New()
	imp = new /obj/item/implant/traitor(src)
	..()

/obj/item/implanter/death_alarm
	name = "microchip implanter (Death Alarm)"

/obj/item/implanter/death_alarm/New()
	imp = new /obj/item/implant/death_alarm(src)
	..()
