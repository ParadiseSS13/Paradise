/datum/action/cooldown/flock/gatecrash
	name = "Gatecrash"
	desc = "Transmit an override signal to open every door within range."
	button_icon_state = "open_door"

	cooldown_time = 40 SECONDS

/datum/action/cooldown/flock/gatecrash/Activate(atom/target)
	var/list/targets = list()
	for(var/obj/machinery/door/airlock/airlock in INSTANCES_OF(/obj/machinery/door))
		if(airlock.z != owner.z)
			continue

		if(get_dist(airlock, owner) <= 10 && airlock.canAIControl())
			targets += airlock


	if(!length(targets))
		to_chat(owner, span_notice("No targets in range that can be opened via radio."))
		return FALSE

	..()

	to_chat(owner, span_notice("You force open all powered doors around you."))
	playsound(owner, 'goon/sounds/flockmind/flockmind_cast.ogg', 50)

	addtimer(CALLBACK(src, PROC_REF(async_open_doors), targets), 1.5 SECONDS)
	return TRUE

/datum/action/cooldown/flock/gatecrash/proc/async_open_doors(list/doors)
	for(var/obj/machinery/door/airlock/airlock in doors)
		if(QDELETED(airlock))
			continue

		// Stagger openins a little randomly
		if(prob(20))
			sleep(0.2 SECONDS)

		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, open))
