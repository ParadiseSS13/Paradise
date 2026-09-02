USER_VERB_VISIBILITY(debug_check_piping, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(debug_check_piping, R_ADMIN, "Check Piping", "Check Piping", VERB_CATEGORY_MAPPING)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Piping") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(alert(client, "WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", "No", "Yes") == "No")
		return

	to_chat(client, "Checking for disconnected pipes...")

	//Manifolds
	for(var/obj/machinery/atmospherics/pipe/manifold/pipe in SSair.atmos_machinery)
		if(!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(client, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

	//Pipes
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in SSair.atmos_machinery)
		if(!pipe.node1 || !pipe.node2)
			to_chat(client, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

	to_chat(client, "Checking for overlapping pipes...")
	for(var/turf/T in world)
		for(var/dir in GLOB.cardinal)
			var/list/check = list(0, 0, 0)
			var/done = 0
			for(var/obj/machinery/atmospherics/pipe in T)
				if(dir & pipe.initialize_directions)
					for(var/ct in pipe.connect_types)
						check[ct]++
						if(check[ct] > 1)
							to_chat(client, "Overlapping pipe ([pipe.name]) located at [T.x],[T.y],[T.z] ([get_area(T)])")
							done = 1
							break
				if(done)
					break
	to_chat(client, "Done")

USER_VERB_VISIBILITY(debug_power, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(debug_power, R_ADMIN, "Check Power", "Check Power", VERB_CATEGORY_MAPPING)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Power") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for(var/datum/regional_powernet/PN in SSmachines.powernets)
		if(!PN.nodes || !length(PN.nodes))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(client, "Powernet with no nodes! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")

		if(!PN.cables || (length(PN.cables) < 10))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(client, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [C.x], [C.y], [C.z] in area [get_area(C.loc)]")
