/obj/item/chameleon_counterfeiter
	name = "chameleon counterfeiter"
	icon = 'icons/obj/device.dmi'
	icon_state = "cham_counter"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "syndicate=1;magnets=3"
	var/can_use = TRUE
	var/saved_name
	var/saved_desc
	var/saved_icon
	var/saved_icon_state
	var/saved_item_state
	var/saved_overlays
	var/saved_underlays
	var/dummy_active = FALSE

/obj/item/chameleon_counterfeiter/examine(mob/user)
	. = ..()
	if(dummy_active)
		. += "<span class='warning'>It doesn't look quite right...</span>"

/obj/item/chameleon_counterfeiter/afterattack(obj/item/target, mob/user, proximity)
	if(!proximity || !check_sprite(target) || target.alpha < 255 || target.invisibility != 0)
		return
	if(dummy_active || !isitem(target))
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
	to_chat(user, "<span class='notice'>Scanned [target].</span>")
	saved_name = target.name
	saved_desc = target.desc
	saved_icon = target.icon
	saved_icon_state = target.icon_state
	saved_item_state = target.item_state
	saved_overlays = target.overlays
	saved_underlays = target.underlays

/obj/item/chameleon_counterfeiter/proc/check_sprite(atom/target)
	return (target.icon_state in icon_states(target.icon))

/obj/item/chameleon_counterfeiter/proc/matter_toggle(mob/living/user)
	if(!can_use || !saved_name)
		return
	playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
	if(dummy_active)
		matter_deactivate()
		to_chat(user, "<span class='notice'>You deactivate [src].</span>")
	else
		to_chat(user, "<span class='notice'>You activate [src].</span>")
		matter_activate()

/obj/item/chameleon_counterfeiter/proc/matter_activate()
	name = saved_name
	desc = saved_desc
	icon = saved_icon
	icon_state = saved_icon_state
	item_state = saved_item_state
	overlays = saved_overlays
	underlays = saved_underlays
	dummy_active = TRUE

/obj/item/chameleon_counterfeiter/proc/matter_deactivate()
	name = initial(name)
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	overlays = initial(overlays)
	underlays = initial(underlays)
	dummy_active = FALSE
	can_use = FALSE
	addtimer(VARSET_CALLBACK(src, can_use, TRUE), 3 SECONDS)

/obj/item/chameleon_counterfeiter/attack_self(mob/living/user)
	matter_toggle(user)
