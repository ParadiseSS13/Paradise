/obj/item/implanter
	name = "bio-chip implanter"
	desc = "A sterile automatic bio-chip injector."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	toolspeed = 1
	var/obj/item/implant/imp
	var/obj/item/implant/implant_type

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
			M.visible_message("<span class='warning'>[user] is attempting to bio-chip [M].</span>")

		var/turf/T = get_turf(M)
		if(T && (M == user || do_after(user, 50 * toolspeed, target = M)))
			if(user && M && (get_turf(M) == T) && src && imp)
				if(imp.implant(M, user))
					if(M == user)
						to_chat(user, "<span class='notice'>You bio-chip yourself.</span>")
					else
						M.visible_message("[user] has implanted [M].", "<span class='notice'>[user] bio-chips you.</span>")
					imp = null
					update_icon(UPDATE_ICON_STATE)

/obj/item/implanter/attackby(obj/item/W, mob/user, params)
	..()
	if(is_pen(W))
		rename_interactive(user, W)

/obj/item/implanter/Initialize(mapload)
	. = ..()
	if(!implant_type)
		return
	imp = new implant_type()
	update_icon(UPDATE_ICON_STATE)

/obj/item/implanter/Destroy()
	QDEL_NULL(imp)
	. = ..()
