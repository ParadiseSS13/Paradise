/datum/event/short_circuit
	name = "Short Circuit"
	nominal_severity = EVENT_LEVEL_MODERATE
	endWhen = 20 // In process ticks

/datum/event/short_circuit/start()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(short))

/datum/event/proc/short()
	var/list/skipped_areas_machines = list(
		/area/station/turret_protected/ai,
		/area/station/hallway/secondary/entry,
		/area/shuttle/arrival
		)
	skipped_areas_machines += subtypesof(/area/station/engineering/engine)
	skipped_areas_machines += subtypesof(/area/station/telecomms)
	skipped_areas_machines += subtypesof(/area/shuttle/arrival)
	skipped_areas_machines += subtypesof(/area/station/hallway/secondary/entry)
	var/list/machines = SSmachines.get_by_type(/obj/machinery)

	while(length(machines))
		var/obj/machinery/machine = pick_n_take(machines)
		var/area/current_area = get_area(machine)
		if((current_area.type in skipped_areas_machines) || !is_station_level(machine.z))
			continue
		if(machine.short_circuit())
			return
