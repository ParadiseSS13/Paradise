/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Piping"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Piping") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(alert("WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", "No", "Yes") == "No")
		return

	to_chat(usr, "Checking for disconnected pipes...")

	//Manifolds
	for(var/obj/machinery/atmospherics/pipe/manifold/pipe in SSair.atmos_machinery)
		if(!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(usr, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

	//Pipes
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in SSair.atmos_machinery)
		if(!pipe.node1 || !pipe.node2)
			to_chat(usr, "Unconnected [pipe.name] located at [pipe.x],[pipe.y],[pipe.z] ([get_area(pipe.loc)])")

	to_chat(usr, "Checking for overlapping pipes...")
	for(var/turf/T in world)
		for(var/dir in GLOB.cardinal)
			var/list/check = list(0, 0, 0)
			var/done = 0
			for(var/obj/machinery/atmospherics/pipe in T)
				if(dir & pipe.initialize_directions)
					for(var/ct in pipe.connect_types)
						check[ct]++
						if(check[ct] > 1)
							to_chat(usr, "Overlapping pipe ([pipe.name]) located at [T.x],[T.y],[T.z] ([get_area(T)])")
							done = 1
							break
				if(done)
					break
	to_chat(usr, "Done")
