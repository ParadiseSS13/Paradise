#define BASE_MOVE_DELAY	8
#define MAX_SPEED		2

/obj/machinery/power/treadmill
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "treadmill"
	desc = "A power-generating treadmill."
	layer = 2.2
	use_power = NO_POWER_USE

	var/speed = 0
	var/friction = 0.15		// lose this much speed every ptick
	var/inertia = 0.25		// multiplier to mob speed, when increasing treadmill speed
	var/throw_dist = 2		// distance to throw the person, worst case
	var/power_gen = 4000	// amount of power output at max speed
	var/list/mobs_running[0]
	var/id = null			// for linking to monitor

/obj/machinery/power/treadmill/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

/obj/machinery/power/treadmill/update_icon()
	icon_state = speed ? "conveyor-1" : "conveyor0"

/obj/machinery/power/treadmill/Crossed(mob/living/M, oldloc)
	if(anchored && !M.anchored)
		if(!istype(M) || M.dir != dir)
			throw_off(M)
		else
			mobs_running[M] = M.last_movement
	. = ..()

/obj/machinery/power/treadmill/Uncrossed(mob/living/M)
	if(anchored && istype(M))
		mobs_running -= M
	. = ..()

/obj/machinery/power/treadmill/proc/throw_off(atom/movable/A)
	// if 2fast, throw the person, otherwise they just slide off, if there's reasonable speed at all
	if(speed)
		var/dist = max(throw_dist * speed / MAX_SPEED, 1)
		A.throw_at(get_distant_turf(get_turf(src), reverse_direction(dir), dist), A.throw_range, A.throw_speed, src, 1)

/obj/machinery/power/treadmill/process()
	if(!anchored)
		speed = 0
		update_icon()
		return

	speed = Clamp(speed - friction, 0, MAX_SPEED)
	for(var/A in (loc.contents - src))
		var/atom/movable/AM = A
		if(AM.anchored)
			continue
		if(istype(A, /mob/living))
			var/mob/living/M = A
			var/last_move
			// get/update old step count
			if(mobs_running[M])
				last_move = mobs_running[M]
			else
				last_move = M.last_movement
			mobs_running[M] = M.last_movement
			// if we "stepped" in right direction, add to speed, else throw the person off like a common obj
			if(last_move != M.last_movement && dir == M.dir)
				// a reasonable approximation of movement speed
				var/mob_speed = M.movement_delay()
				switch(M.m_intent)
					if(MOVE_INTENT_RUN)
						if(M.drowsyness > 0)
							mob_speed += 6
						mob_speed += config.run_speed - 1
					if(MOVE_INTENT_WALK)
						mob_speed += config.walk_speed - 1
				mob_speed = BASE_MOVE_DELAY / max(1, BASE_MOVE_DELAY + mob_speed)
				speed = min(speed + inertia * mob_speed, mob_speed)
				continue
		throw_off(A)

	var/output = get_power_output()
	if(output)
		add_avail(output)
	update_icon()

/obj/machinery/power/treadmill/proc/get_power_output()
	if(speed && !stat && anchored && powernet)
		return power_gen * speed / MAX_SPEED
	return 0

/obj/machinery/power/treadmill/emp_act(severity)
	..()
	if(!(stat & BROKEN))
		stat |= BROKEN
		spawn(100)
			stat &= ~BROKEN

/obj/machinery/power/treadmill/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user, W, time = 60))
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		speed = 0
		update_icon()
		return
	return ..()

#undef BASE_MOVE_DELAY
#undef MAX_SPEED

#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Small Fonts"

/obj/machinery/treadmill_monitor
	name = "Treadmill Monitor"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "Monitors treadmill use."
	anchored = 1
	density = 0
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

	var/on = 0					// if we should be metering or not
	var/id = null				// id of treadmill
	var/obj/machinery/power/treadmill/treadmill = null
	var/total_joules = 0		// total power from prisoner
	var/J_per_ticket = 45000	// amt of power charged for a ticket
	var/line1 = ""
	var/line2 = ""
	var/frame = 0				// on 0, show labels, on 1 show numbers
	var/redeem_immediately = 0	// redeem immediately for holding cell

/obj/machinery/treadmill_monitor/Initialize(mapload)
	. = ..()
	if(id)
		for(var/obj/machinery/power/treadmill/T in GLOB.machines)
			if(T.id == id)
				treadmill = T
				break
	if(!treadmill)
		// also simply check if treadmill at loc
		for(var/obj/machinery/power/treadmill/T in loc)
			treadmill = T
			break

/obj/machinery/treadmill_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(treadmill && on)
		var/output = treadmill.get_power_output()
		if(output)
			total_joules += output
		if(redeem_immediately && total_joules > J_per_ticket)
			redeem()
			total_joules = 1
	update_icon()
	frame = !frame

/obj/machinery/treadmill_monitor/power_change()
	..()
	update_icon()

/obj/machinery/treadmill_monitor/examine(mob/user)
	. = ..()
	. += "The display reads:<div style='text-align: center'>[line1]<br>[line2]</div>"

/obj/machinery/treadmill_monitor/update_icon()
	overlays.Cut()
	if(stat & NOPOWER || !total_joules || !on)
		line1 = ""
		line2 = ""
	else if(stat & BROKEN)
		overlays += image('icons/obj/status_display.dmi', icon_state = "ai_bsod")
		line1 = "A@#$A"
		line2 = "729%!"
	else
		if(!frame)
			line1 = "-W/S-"
			line2 = "-TIX-"
		else
			if(!treadmill || treadmill.stat)
				line1 = "???"
			else
				line1 = "[add_zero(num2text(round(treadmill.get_power_output())), 4)]"
			if(length(line1) > CHARS_PER_LINE)
				line1 = "Error"
			if(J_per_ticket)
				line2 = "[round(total_joules / J_per_ticket)]"
			if(length(line2) > CHARS_PER_LINE)
				line2 = "Error"
	update_display(line1, line2)

//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/treadmill_monitor/proc/update_display(var/line1, var/line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

// called by brig timer when prisoner released
/obj/machinery/treadmill_monitor/proc/redeem()
	if(total_joules >= J_per_ticket && J_per_ticket)
		playsound(loc, 'sound/machines/chime.ogg', 50, 1)
		new /obj/item/stack/tickets(get_turf(src), round(total_joules / J_per_ticket))
		total_joules = 0

/obj/machinery/treadmill_monitor/emp_act(severity)
	..()
	if(!(stat & BROKEN))
		stat |= BROKEN
		update_icon()
		spawn(100)
			stat &= ~BROKEN
			update_icon()

#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE
