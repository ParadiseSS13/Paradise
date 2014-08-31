//Engine component object

var/list/ship_engines = list()
/datum/ship_engine
	var/name = "ship engine"
	var/obj/machinery/engine	//actual engine object
	var/zlevel = 0

/datum/ship_engine/New(var/obj/machinery/holder)
	engine = holder
	zlevel = holder.z
	for(var/obj/machinery/computer/engines/E in machines)
		if (E.z == zlevel && !(src in E.engines))
			E.engines += src
			break

//Tries to fire the engine. If successfull, returns 1
/datum/ship_engine/proc/burn()
	if(!engine)
		die()
	return 1

//Returns status string for this engine
/datum/ship_engine/proc/get_status()
	if(!engine)
		die()
	return "All systems nominal"

/datum/ship_engine/proc/get_thrust()
	if(!engine)
		die()
	return 100

//Sets thrust limiter, a number between 0 and 1
/datum/ship_engine/proc/set_thrust_limit(var/new_limit)
	if(!engine)
		die()
	return 1

/datum/ship_engine/proc/get_thrust_limit()
	if(!engine)
		die()
	return 1

/datum/ship_engine/proc/is_on()
	if(!engine)
		die()
	return 1

/datum/ship_engine/proc/toggle()
	if(!engine)
		die()
	return 1

/datum/ship_engine/proc/die()
	for(var/obj/machinery/computer/engines/E in machines)
		if (E.z == zlevel)
			E.engines -= src
			break
	del(src)