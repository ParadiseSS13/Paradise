/obj/item/bio_chip_case
	name = "bio-chip case"
	desc = "A glass case containing a bio-chip."
	icon = 'icons/obj/bio_chips.dmi'
	icon_state = "implantcase"
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=2"
	container_type = OPENCONTAINER | INJECTABLE | DRAWABLE
	materials = list(MAT_GLASS = 500)

	var/obj/item/bio_chip/imp
	var/obj/item/bio_chip/implant_type

/obj/item/bio_chip_case/Initialize(mapload)
	. = ..()
	if(!implant_type)
		return
	imp = new implant_type(src)
	update_state()

/obj/item/bio_chip_case/Destroy()
	if(imp)
		QDEL_NULL(imp)
	return ..()

/obj/item/bio_chip_case/proc/update_state()
	if(imp)
		origin_tech = imp.origin_tech
		flags = imp.flags & ~DROPDEL
		reagents = imp.reagents
	else
		origin_tech = initial(origin_tech)
		flags = initial(flags)
		reagents = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/bio_chip_case/update_overlays()
	. = ..()
	if(imp)
		var/image/implant_overlay = image('icons/obj/bio_chips.dmi', imp.implant_state)
		. += implant_overlay

/obj/item/bio_chip_case/attackby__legacy__attackchain(obj/item/W, mob/user)
	..()

	if(is_pen(W))
		rename_interactive(user, W)
	else if(istype(W, /obj/item/bio_chip_implanter))
		var/obj/item/bio_chip_implanter/I = W
		if(I.imp)
			if(imp || I.imp.implanted)
				return
			I.imp.forceMove(src)
			imp = I.imp
			I.imp = null
			update_state()
			I.update_icon(UPDATE_ICON_STATE)
		else
			if(imp)
				if(I.imp)
					return
				imp.loc = I
				I.imp = imp
				imp = null
				update_state()
			I.update_icon(UPDATE_ICON_STATE)
