/obj/item/melee/energy/sword/examine(mob/user)
	. = ..()
	recently_charged = TRUE
	update_icon()

/obj/item/melee/energy/sword/update_icon()
	overlays.Cut()

	if(ismob(loc) && recently_charged)
		recently_charged = FALSE
		var/image/overlay_dot_reflect = image(icon,"deflect[deflect_dots]")
		overlays += overlay_dot_reflect // animacion de overlay, algun dia
		deltimer(deflect_dots_timerid)
		deflect_dots_timerid = addtimer(CALLBACK(src, .proc/update_icon), 3 SECONDS, TIMER_STOPPABLE)

/obj/item/melee/energy/sword/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/melee/energy/sword/dropped(mob/user)
	. = ..()
	update_icon()

/obj/item/melee/energy/sword/proc/attempt_reload()
	if(deflect_dots <= 0)
		return
	deflect_dots--
	recently_charged = TRUE
	update_icon()

	var/recharge_time = 45 SECONDS

	addtimer(CALLBACK(src, .proc/reload), recharge_time)

/obj/item/melee/energy/sword/proc/reload()
	recently_charged = TRUE
	deflect_dots++
	update_icon()
