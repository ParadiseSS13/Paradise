/client/verb/listprocs()
	set category = "Debug"
	set name = "Debug Proc List"

	var/list/atomList = typesof(/atom)
	var/list/objList = typesof(/obj)
	var/list/mobList = typesof(/mob)
	var/list/turfList = typesof(/turf)
	var/list/clientList = typesof(/client)
	var/list/datumList = typesof(/datum)
	var/total = 0
	var/debuglog = file("data/logs/debug.log")

	for (var/A in atomList)
		var/list/procList = typesof("[A]/proc")
		for(var/B in procList)
			debuglog << B
		total += procList.len

	for (var/A in objList)
		var/list/procList = typesof("[A]/proc")
		for(var/B in procList)
			debuglog << B
		total += procList.len

	for (var/A in mobList)
		var/list/procList = typesof("[A]/proc")
		for(var/B in procList)
			debuglog << B
		total += procList.len

	for (var/A in turfList)
		var/list/procList = typesof("[A]/proc")
		for(var/B in procList)
			debuglog << B
		total += procList.len

	for (var/A in clientList)
		var/list/procList = typesof("[A]/proc")
		for(var/B in procList)
			debuglog << B
		total += procList.len

	for (var/A in datumList)
		var/list/procList = typesof("[A]/proc")
		for(var/B in procList)
			debuglog << B
		total += procList.len

	debuglog << total
	world << total
