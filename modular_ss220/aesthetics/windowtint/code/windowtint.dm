/obj/machinery/button/windowtint
	icon = 'modular_ss220/aesthetics/windowtint/icons/polarizer.dmi'
	icon_state = "polarizer-0"
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/button/windowtint/try_attack_hand(mob/user)
	if(..())
		return TRUE
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("polarizer-denied",src)
		playsound(src, pick('modular_ss220/aesthetics/windowtint/sound/button.ogg', 'modular_ss220/aesthetics/windowtint/sound/button_alternate.ogg', 'modular_ss220/aesthetics/windowtint/sound/button_meloboom.ogg'), 20)
		return TRUE
	return FALSE

/obj/machinery/button/windowtint/toggle_tint()
	..()
	if(range != TINT_CONTROL_RANGE_AREA)
		animate_windowtint()
		return
	for(var/obj/machinery/button/windowtint/button in button_area)
		if(button.range != TINT_CONTROL_RANGE_AREA || (button.id != id && button.id != TINT_CONTROL_GROUP_NONE))
			continue
		button.animate_windowtint()

/obj/machinery/button/windowtint/proc/animate_windowtint()
	icon_state = active ? "polarizer-turning_on" : "polarizer-turning_off"
	addtimer(CALLBACK(src, PROC_REF(update_windowtint_icon)), 0.5 SECONDS)

/obj/machinery/button/windowtint/proc/update_windowtint_icon()
	icon_state = "polarizer-[active]"
