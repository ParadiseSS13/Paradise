/obj/item/implantcase
	name = "implant case"
	desc = "A glass case containing an implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=2"
	container_type = OPENCONTAINER | INJECTABLE | DRAWABLE
	materials = list(MAT_GLASS=500)
	var/obj/item/implant/imp = null


/obj/item/implantcase/update_icon()
	if(imp)
		icon_state = "implantcase-[imp.item_color]"
		origin_tech = imp.origin_tech
		flags = imp.flags & ~DROPDEL
		reagents = imp.reagents
	else
		icon_state = "implantcase-0"
		origin_tech = initial(origin_tech)
		flags = initial(flags)
		reagents = null


/obj/item/implantcase/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_hand() != W)
			return
		if(!in_range(src, user) && loc != user)
			return
		if(t)
			name = "implant case - '[t]'"
		else
			name = "implant case"
	else if(istype(W, /obj/item/implanter))
		var/obj/item/implanter/I = W
		if(I.imp)
			if(imp || I.imp.implanted)
				return
			I.imp.loc = src
			imp = I.imp
			I.imp = null
			update_icon()
			I.update_icon()
		else
			if(imp)
				if(I.imp)
					return
				imp.loc = I
				I.imp = imp
				imp = null
				update_icon()
			I.update_icon()

	/*else if(istype(W, /obj/item/ammo_casing/shotgun/implanter))
		var/obj/item/ammo_casing/shotgun/implanter/I = W
		if(I.implanter)
			src.attackby(I.implanter, user, params) */ // COMING SOON -- c0

/obj/item/implantcase/New()
	..()
	update_icon()


/obj/item/implantcase/tracking
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."

/obj/item/implantcase/tracking/New()
	imp = new /obj/item/implant/tracking(src)
	..()


/obj/item/implantcase/weapons_auth
	name = "implant case - 'Firearms Authentication'"
	desc = "A glass case containing a firearms authentication implant."

/obj/item/implantcase/weapons_auth/New()
	imp = new /obj/item/implant/weapons_auth(src)
	..()

/obj/item/implantcase/adrenaline
	name = "implant case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline implant."

/obj/item/implantcase/adrenaline/New()
	imp = new /obj/item/implant/adrenalin(src)
	..()

/obj/item/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."

/obj/item/implantcase/death_alarm/New()
	imp = new /obj/item/implant/death_alarm(src)
	..()
