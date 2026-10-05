/obj/item/bio_chip_implanter
	name = "bio-chip implanter"
	desc = "A sterile automatic bio-chip injector."
	icon = 'icons/obj/bio_chips.dmi'
	icon_state = "implanter0"
	inhand_icon_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	new_attack_chain = TRUE
	var/obj/item/bio_chip/imp
	var/obj/item/bio_chip/implant_type

/obj/item/bio_chip_implanter/update_icon_state()
	if(imp)
		icon_state = "implanter1"
		origin_tech = imp.origin_tech
	else
		icon_state = "implanter0"
		origin_tech = initial(origin_tech)

/obj/item/bio_chip_implanter/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!iscarbon(target))
		return NONE

	if(!imp)
		to_chat(user, SPAN_WARNING("There's no implant inside [src]!"))
		return ITEM_INTERACT_COMPLETE

	if(target != user)
		target.visible_message(SPAN_WARNING("[user] is attempting to bio-chip [target]."))

	var/turf/T = get_turf(target)
	if(!(T && (target == user || do_after_once(user, 50 * toolspeed, target = target))))
		return ITEM_INTERACT_COMPLETE

	if(QDELETED(user) || !imp)
		return ITEM_INTERACT_COMPLETE

	if(!imp.implant(target, user))
		to_chat(user, SPAN_WARNING("You fail to insert the bio-chip."))
		return ITEM_INTERACT_COMPLETE

	if(target == user)
		to_chat(user, SPAN_NOTICE("You bio-chip yourself."))
	else
		target.visible_message("[user] has implanted [target].", SPAN_NOTICE("[user] bio-chips you."))
	imp = null
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/bio_chip_implanter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		rename_interactive(user, used)
		return ITEM_INTERACT_COMPLETE

/obj/item/bio_chip_implanter/Initialize(mapload)
	. = ..()
	if(!implant_type)
		return
	imp = new implant_type()
	update_icon(UPDATE_ICON_STATE)

/obj/item/bio_chip_implanter/Destroy()
	QDEL_NULL(imp)
	. = ..()
