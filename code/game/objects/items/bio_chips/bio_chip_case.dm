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
	new_attack_chain = TRUE
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

/obj/item/bio_chip_case/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_pen(used) && !istype(used, /obj/item/bio_chip_implanter))
		return ..()

	if(is_pen(used))
		rename_interactive(user, used)
		return ITEM_INTERACT_COMPLETE

	var/obj/item/bio_chip_implanter/implanter = used
	if(implanter.imp)
		if(imp)
			to_chat(user, SPAN_WARNING("There's already an implant in [src]!"))
			return ITEM_INTERACT_COMPLETE

		if(implanter.imp.implanted)
			to_chat(user, SPAN_WARNING("[imp] is currently inside someone, which is likely a bug if you're getting this message."))
			return ITEM_INTERACT_COMPLETE

		implanter.imp.forceMove(src)
		imp = implanter.imp
		implanter.imp = null
		update_state()

		to_chat(user, SPAN_NOTICE("You move [imp] from [implanter] to [src]."))
	else
		if(imp)
			if(implanter.imp)
				to_chat(user, SPAN_WARNING("[implanter] already has an implant inside!"))
				return ITEM_INTERACT_COMPLETE
			imp.forceMove(implanter)
			implanter.imp = imp
			imp = null
			update_state()
			to_chat(user, SPAN_NOTICE("You move [implanter.imp] from [src] to [implanter]."))

	add_fingerprint(user)
	implanter.add_fingerprint(user)
	implanter.update_icon(UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE
