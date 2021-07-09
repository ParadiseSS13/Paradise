/obj/machinery/ai_slipper
	name = "\improper AI liquid dispenser"
	icon = 'icons/obj/device.dmi'
	icon_state = "liquid_dispenser"
	layer = 3
	plane = FLOOR_PLANE
	anchored = TRUE
	max_integrity = 200
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)
	var/uses = 20
	var/cooldown_time = 10 SECONDS
	var/cooldown_on = FALSE
	req_access = list(ACCESS_AI_UPLOAD)

/obj/machinery/ai_slipper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A small counter shows it has: [uses] use\s remaining.</span>"

/obj/machinery/ai_slipper/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

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
		power_change()
		addtimer(CALLBACK(src, .proc/recharge), cooldown_time)

/obj/machinery/ai_slipper/update_icon()
	if(stat & (NOPOWER|BROKEN) || cooldown_on || !uses)
		icon_state = "liquid_dispenser"
	else
		icon_state = "liquid_dispenser_on"

/obj/machinery/ai_slipper/proc/recharge()
	if(!uses)
		return
	cooldown_on = FALSE
	power_change()
