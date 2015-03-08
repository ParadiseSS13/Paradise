/obj/item/part/computer/networking
	name = "Computer networking component"

	/*
		This is the public-facing proc used by NETUP.
		It does additional checking before and after calling get_machines()

	*/
	proc/connect_to(var/typekey,var/atom/previous)
		if(!computer || computer.stat)
			return null

		if(istype(previous,typekey) && verify_machine(previous))
			return previous

		var/result = get_machines(typekey)

		if(!result)
			return null

		if(islist(result))
			var/list/R = result
			if(R.len == 0)
				return null
			else if(R.len == 1)
				return R[1]
			else
				var/list/atomlist = computer.format_atomlist(R)
				result = input("Select:","Multiple destination machines located",atomlist[1]) as null|anything in atomlist
				return atomlist[result]

		if(isobj(result))
			return result

		return null // ?

	/*
		This one is used to determine the candidate machines.
		It may return an object, a list of objects, or null.

		Overwite this on any networking component.
	*/
	proc/get_machines(var/typekey)
		return list()

	/*
		This is used to verify that an existing machine is within the network.
		Calling NETUP() with an object argument will run this check, and if
		the object is still accessible, it will be used.  Otherwise, another
		search will be run.

		Overwrite this on any networking component.
	*/
	proc/verify_machine(var/obj/previous)
		return 0

/*
	Provides radio/signaler functionality, and also
	network-connects to anything on the same z-level
	which is tuned to the same frequency.
*/
/obj/item/part/computer/networking/radio
	name = "Wireless networking component"
	desc = "Radio module for computers"

	var/datum/radio_frequency/radio_connection	= null
	var/frequency = 1459
	var/filter = null
	var/range = null
	var/subspace = 0

	init()
		..()
		spawn(5)
			radio_connection = radio_controller.add_object(src, src.frequency, src.filter)

	proc/set_frequency(new_frequency)
		if(radio_controller)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, filter)
		else
			frequency = new_frequency
			spawn(rand(5,10))
				set_frequency(new_frequency)

	receive_signal(var/datum/signal/signal)
		if(!signal || !computer || (computer.stat&~MAINT)) // closed laptops use maint, allow it
			return
		if(computer.program)
			computer.program.receive_signal(signal)

	proc/post_signal(var/datum/signal/signal)
		if(!computer || (computer.stat&~MAINT) || !computer.program) return
		if(!radio_connection) return

		radio_connection.post_signal(src,signal,filter,range)

	get_machines(var/typekey)
		if(!radio_connection || !radio_connection.frequency)
			return list()
		var/list/result = list()
		var/turf/T = get_turf(loc)
		var/z_level = T.z
		for(var/obj/O in radio_connection.devices)
			if(istype(O,typekey))
				T = get_turf(O)
				if(istype(O) && (subspace || (O.z == z_level)))		// radio does not work across z-levels
					result |= O
		return result

	verify_machine(var/obj/previous)
		if(!previous) return 0
		if(subspace)
			return ( radio_connection && (previous in radio_connection.devices) )
		else
			var/turf/T = get_turf(loc)
			var/turf/O = get_turf(previous)
			if(!T || !O)
				return 0
			return ( radio_connection && (previous in radio_connection.devices) && (T.z == O.z))

/*
	Subspace networking: Communicates off-station.  Allows centcom communications.
*/
/obj/item/part/computer/networking/radio/subspace
	name = "subspace networking terminal"
	desc = "Communicates long distances and through spatial anomalies."
	subspace = 1

/*
	APC (/area) networking
*/

/obj/item/part/computer/networking/area
	name = "short-wave networking terminal"
	desc = "Connects to nearby computers through the area power network"

	get_machines(var/typekey)
		var/area/A = get_area(loc)
		if(!istype(A) || A == /area)
			return list()
		if(typekey == null)
			typekey = /obj/machinery
		var/list/machines = list()
		for(var/area/area in A.related)
			for(var/obj/O in area.contents)
				if(istype(O,typekey))
					machines |= O
		return machines
	verify_machine(var/obj/previous)
		if(!previous) return 0
		var/area/A = get_area(src)
		if( A && A == get_area(previous) )
			return 1
		return 0

/*
	Proximity networking: Connects to machines or computers adjacent to this device
*/
/obj/item/part/computer/networking/prox
	name = "proximity networking terminal"
	desc = "Connects a computer to adjacent machines"

	get_machines(var/typekey)
		var/turf/T = get_turf(loc)
		if(!istype(T))
			return list()
		if(typekey == null)
			typekey = /obj/machinery
		var/list/machines = list()
		for(var/d in cardinal)
			var/turf/T2 = get_step(T,d)
			for(var/obj/O in T2)
				if(istype(O,typekey))
					machines += O
		return machines

	verify_machine(var/obj/previous)
		if(!previous)
			return 0
		if(get_dist(get_turf(previous),get_turf(loc)) == 1)
			return 1
		return 0
/*
	Cable networking: Not currently used
*/

/obj/item/part/computer/networking/cable
	name = "cable networking terminal"
	desc = "Connects to other machines on the same cable network."

	get_machines(var/typekey)
//		if(istype(computer,/obj/machinery/computer/laptop)) // laptops move, this could get breaky
//			return list()
		var/turf/T = get_turf(loc)
		var/datum/powernet/P = null
		for(var/obj/structure/cable/C in T)
			if(C.d1 == 0)
				P = C.powernet
				break
		if(!P)
			return list()
		if(!typekey)
			typekey = /obj/machinery
		else if(typekey == /datum/powernet)
			return list(P)
		var/list/candidates = list()
		for(var/atom/A in P.nodes)
			if(istype(A,typekey))
				candidates += A
			else if(istype(A,/obj/machinery/power/terminal))
				var/obj/machinery/power/terminal/PT = A
				if(istype(PT.master,typekey))
					candidates += PT.master
		return candidates

	verify_machine(var/obj/previous)
		if(!previous)
			return 0
		var/turf/T = get_turf(loc)
		var/datum/powernet/P = null
		for(var/obj/structure/cable/C in T)
			if(C.d1 == 0)
				P = C.powernet
				break
		if(istype(previous,/datum/powernet))
			if(previous == P)
				return 1
			return 0
		T = get_turf(previous.loc)
		for(var/obj/structure/cable/C in T)
			if(C.d1 == 0 && (C.powernet == P))
				return 1
		return 0

