/obj/machinery/ai_slipper
	name = "\improper AI liquid dispenser"
	icon = 'icons/obj/device.dmi'
	icon_state = "liquid_dispenser"
	layer = 3
	plane = FLOOR_PLANE
	anchored = TRUE
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	var/uses = 20
	var/cooldown_time = 10 SECONDS
	var/cooldown_on = FALSE
	req_access = list(ACCESS_AI_UPLOAD)

/obj/machinery/ai_slipper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A small counter shows it has: [uses] use\s remaining.</span>"

/obj/machinery/ai_slipper/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_slipper/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/ai_slipper/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		Activate(user)

/obj/machinery/ai_slipper/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>[src] has no power or is broken!</span>")
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	Activate(user)

/obj/machinery/ai_slipper/proc/Activate(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!uses)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(cooldown_on)
		to_chat(user, "<span class='warning'>[src] is still recharging!</span>")
		return
	else
		new /obj/effect/particle_effect/foam(loc)
		uses--
		cooldown_on = TRUE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(recharge)), cooldown_time)

/obj/machinery/ai_slipper/update_icon_state()
	if(stat & (NOPOWER|BROKEN) || cooldown_on || !uses)
		icon_state = "liquid_dispenser"
	else
		icon_state = "liquid_dispenser_on"

/obj/machinery/ai_slipper/proc/recharge()
	if(!uses)
		return
	cooldown_on = FALSE
	update_icon(UPDATE_ICON_STATE)
