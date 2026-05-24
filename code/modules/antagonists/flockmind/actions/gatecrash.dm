/datum/action/cooldown/flock/gatecrash
	name = "Gatecrash"
	desc = "Transmit an override signal to open every door within range."
	button_icon_state = "open_door"

	cooldown_time = 40 SECONDS

/datum/action/cooldown/flock/gatecrash/Activate(atom/target)
	var/list/targets = list()
	for(var/obj/machinery/door/airlock/airlock in range(10, get_turf(owner)))
		if(airlock.canAIControl())
			targets += airlock

	for(var/obj/mecha/mech in range(10, get_turf(owner)))
		if(mech.occupant)
			targets += mech

	if(!length(targets))
		to_chat(owner, SPAN_NOTICE("No targets in range that can be opened via radio."))
		return FALSE

	..()

	to_chat(owner, SPAN_NOTICE("You force open all powered doors around you."))
	playsound(owner, 'sound/goonstation/flockmind/flockmind_cast.ogg', 50)

	addtimer(CALLBACK(src, PROC_REF(async_open_doors), targets), 1.5 SECONDS)
	return TRUE

/datum/action/cooldown/flock/gatecrash/proc/async_open_doors(list/doors)
	for(var/obj/target in doors)
		if(QDELETED(target))
			continue

		// Stagger openins a little randomly
		if(prob(20))
			sleep(0.2 SECONDS)

		if(isairlock(target))
			var/obj/machinery/door/airlock/airlock = target
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, open))
		if(ismecha(target))
			var/obj/mecha/mech = target
			INVOKE_ASYNC(mech, TYPE_PROC_REF(/obj/mecha, go_out), TRUE)
