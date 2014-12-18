
/proc/power_failure(var/announce = 1)
	if(announce)
		command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
		for(var/mob/M in player_list)
			M << sound('sound/AI/poweroff.ogg')

	var/list/skipped_areas = list(/area/turret_protected/ai)
	var/list/skipped_areas_apc = list(/area/engine/engineering)

	for(var/obj/machinery/power/smes/S in machines)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.updateicon()
		S.power_change()


	for(var/obj/machinery/power/apc/C in world)
		var/area/current_area = get_area(C)
		if(current_area.type in skipped_areas_apc || C.z != 1)
			continue
		if(C.cell)
			C.cell.charge = 0

/proc/power_restore(var/announce = 1)
	var/list/skipped_areas = list(/area/turret_protected/ai)
	var/list/skipped_areas_apc = list(/area/engine/engineering)

	if(announce)
		command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
		for(var/mob/M in player_list)
			M << sound('sound/AI/poweron.ogg')
	for(var/obj/machinery/power/apc/C in machines)
		var/area/current_area = get_area(C)
		if(current_area.type in skipped_areas_apc || C.z != 1)
			continue
		if(C.cell)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in machines)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()

/proc/power_restore_quick(var/announce = 1)

	if(announce)
		command_alert("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal")
		for(var/mob/M in player_list)
			M << sound('sound/AI/poweron.ogg')
	for(var/obj/machinery/power/smes/S in machines)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()
