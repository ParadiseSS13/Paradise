/obj/item/chameleon_counterfeiter
	name = "chameleon counterfeiter"
	icon = 'icons/obj/device.dmi'
	icon_state = "cham_counter"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "syndicate=3;magnets=3"
	var/can_use = TRUE
	var/saved_item
	var/saved_icon
	var/saved_icon_state
	var/saved_item_state
	var/saved_overlays
	var/saved_underlays
	var/activate_dummy = FALSE

/obj/item/chameleon_counterfeiter/examine(mob/user)
	. = ..()
	if(activate_dummy == TRUE)
		. += "<span class='warning'>It doesn't look quite right...</span>"

/obj/item/chameleon_counterfeiter/afterattack(obj/item/target, mob/user, proximity)
	if(!proximity || !check_sprite(target) || target.alpha < 255 || target.invisibility != 0)
		return
	if(activate_dummy || !isitem(target))
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
	to_chat(user, "<span class='notice'>Scanned [target].</span>")
	saved_item = target.type
	saved_icon = target.icon
	saved_icon_state = target.icon_state
	saved_item_state = target.item_state
	saved_overlays = target.overlays
	saved_underlays = target.underlays

/obj/item/chameleon_counterfeiter/proc/check_sprite(atom/target)
	return (target.icon_state in icon_states(target.icon))

/obj/item/chameleon_counterfeiter/proc/matter_toggle(mob/living/user)
	if(!can_use || !saved_item)
		return
	if(activate_dummy)
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		matter_deactivate(saved_icon, saved_icon_state, saved_item_state, saved_overlays, saved_underlays)
		to_chat(user, "<span class='notice'>You deactivate [src].</span>")
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		var/obj/O = new saved_item(src)
		to_chat(user, "<span class='notice'>You activate [src].</span>")
		matter_activate(O, saved_icon, saved_icon_state, saved_item_state, saved_overlays, saved_underlays)

/obj/item/chameleon_counterfeiter/proc/matter_activate(obj/O, new_icon, new_iconstate, new_item_state, new_overlays, new_underlays)
	name = O.name
	desc = O.desc
	icon = new_icon
	icon_state = new_iconstate
	item_state = new_item_state
	overlays = new_overlays
	underlays = new_underlays
	activate_dummy = TRUE

/obj/item/chameleon_counterfeiter/proc/matter_deactivate(new_icon, new_iconstate, new_item_state, new_overlays, new_underlays)
	name = initial(name)
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	overlays = initial(overlays)
	underlays = initial(underlays)
	activate_dummy = FALSE
	can_use = FALSE
	addtimer(VARSET_CALLBACK(src, can_use, TRUE), 3 SECONDS)

/obj/item/chameleon_counterfeiter/attack_self(mob/living/user)
	matter_toggle(user)
