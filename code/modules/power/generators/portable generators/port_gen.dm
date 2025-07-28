

//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "Placeholder Generator"	//seriously, don't use this. It can't be anchored without VV magic.
	desc = "A portable generator for emergency backup power."
	icon_state = "portgen0_0"
	density = TRUE
	anchored = FALSE

	var/active = FALSE
	var/power_gen = 5000
	var/power_output = 1
	var/base_icon = "portgen0"

/obj/machinery/power/port_gen/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		if(active)
			. += "<span class='notice'>The generator is on.</span>"
		else
			. += "<span class='notice'>The generator is off.</span>"

/obj/machinery/power/port_gen/process()
	if(anchored && powernet && active && has_fuel() && !is_broken())
		produce_direct_power(power_gen * power_output)
		use_fuel()
		return
	active = FALSE
	handle_inactive()
	update_icon()

/obj/machinery/power/port_gen/proc/is_broken()
	return (stat & (BROKEN|EMPED))

/obj/machinery/power/port_gen/proc/has_fuel() //Placeholder for fuel check.
	return TRUE

/obj/machinery/power/port_gen/proc/use_fuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/drop_fuel()
	return

/obj/machinery/power/port_gen/proc/handle_inactive()
	return

/obj/machinery/power/port_gen/update_icon_state()
	icon_state = "[base_icon]_[active]"

/obj/machinery/power/has_power()
	return TRUE //doesn't require an external power source

/obj/machinery/power/port_gen/emp_act(severity)
	var/duration = 10 MINUTES
	switch(severity)
		if(1)
			stat &= BROKEN
			if(prob(75))
				explode()
				return
		if(2)
			if(prob(25))
				stat &= BROKEN
			if(prob(10))
				explode()
				return
		if(3)
			if(prob(10))
				stat &= BROKEN
			duration = 30 SECONDS
	stat |= EMPED
	addtimer(CALLBACK(src, PROC_REF(remove_emp)), duration)

/// Callback proc for EMP status
/obj/machinery/power/port_gen/proc/remove_emp()
	stat &= ~EMPED

/obj/machinery/power/port_gen/proc/explode()
	explosion(loc, -1, 3, 5, -1, cause = "Exploding [name]")
	qdel(src)
