/datum/map_generator

	//Map information
	var/list/map = list()

	//mapGeneratorModule information
	var/list/modules = list()

/datum/map_generator/New()
	..()
	initialiseModules()

//Defines the region the map represents, sets map
//Returns the map
/datum/map_generator/proc/defineRegion(turf/Start, turf/End, replace = 0)
	if(!checkRegion(Start, End))
		return 0

	if(replace)
		undefineRegion()

	map |= block(Start,End)
	return map


//Defines the region the map represents, as a CIRCLE!, sets map
//Returns the map
/datum/map_generator/proc/defineCircularRegion(turf/Start, turf/End, replace = 0)
	if(!checkRegion(Start, End))
		return 0

	var/centerX = max(abs((End.x+Start.x)/2),1)
	var/centerY = max(abs((End.y+Start.y)/2),1)

	var/lilZ = min(Start.z,End.z)
	var/bigZ = max(Start.z,End.z)

	var/sphereMagic = max(abs(bigZ-(lilZ/2)),1) //Spherical maps! woo!

	var/radius = abs(max(centerX,centerY)) //take the biggest displacement as the radius

	if(replace)
		undefineRegion()

	//Even sphere correction engage
	var/offByOneOffset = 1
	if(ISEVEN(bigZ))
		offByOneOffset = 0

	for(var/i = lilZ, i <= bigZ+offByOneOffset, i++)
		var/theRadius = radius
		if(i != sphereMagic)
			theRadius = max(radius/max((2*abs(sphereMagic-i)),1),1)


		map |= circlerange(locate(centerX,centerY,i),theRadius)


	return map


//Empties the map list, he's dead jim.
/datum/map_generator/proc/undefineRegion()
	map = list() //bai bai


//Checks for and Rejects bad region coordinates
//Returns 1/0
/datum/map_generator/proc/checkRegion(turf/Start, turf/End)
	. = 1

	if(!Start || !End)
		return 0 //Just bail

	if(Start.x > world.maxx || End.x > world.maxx)
		. = 0
	if(Start.y > world.maxy || End.y > world.maxy)
		. = 0
	if(Start.z > world.maxz || End.z > world.maxz)
		. = 0


//Requests the mapGeneratorModule(s) to (re)generate
/datum/map_generator/proc/generate()
	syncModules()
	if(!modules || !length(modules))
		return
	for(var/datum/map_generator_module/mod in modules)
		spawn(0)
			mod.generate()


//Requests the mapGeneratorModule(s) to (re)generate this one turf
/datum/map_generator/proc/generateOneTurf(turf/T)
	if(!T)
		return
	syncModules()
	if(!modules || !length(modules))
		return
	for(var/datum/map_generator_module/mod in modules)
		spawn(0)
			mod.place(T)


//Replaces all paths in the module list with actual module datums
/datum/map_generator/proc/initialiseModules()
	for(var/path in modules)
		if(ispath(path))
			modules.Remove(path)
			modules |= new path
	syncModules()


//Sync mapGeneratorModule(s) to mapGenerator
/datum/map_generator/proc/syncModules()
	for(var/datum/map_generator_module/mod in modules)
		mod.sync(src)



///////////////////////////
// HERE BE DEBUG DRAGONS //
///////////////////////////

/client/proc/debugNatureMapGenerator()
	set name = "Test Nature Map Generator"
	set category = "Debug"

	if(!check_rights(R_MAINTAINER))
		return

	var/datum/map_generator/nature/N = new()
	var/startInput = clean_input("Start turf of Map, (X;Y;Z)", "Map Gen Settings", "1;1;1")
	var/endInput = clean_input("End turf of Map (X;Y;Z)", "Map Gen Settings", "[world.maxx];[world.maxy];[mob ? mob.z : 1]")
	//maxx maxy and current z so that if you fuck up, you only fuck up one entire z level instead of the entire universe
	if(!startInput || !endInput)
		to_chat(src, "Missing Input")
		return

	var/list/startCoords = splittext(startInput, ";")
	var/list/endCoords = splittext(endInput, ";")
	if(!startCoords || !endCoords)
		to_chat(src, "Invalid Coords")
		to_chat(src, "Start Input: [startInput]")
		to_chat(src, "End Input: [endInput]")
		return

	var/turf/Start = locate(text2num(startCoords[1]),text2num(startCoords[2]),text2num(startCoords[3]))
	var/turf/End = locate(text2num(endCoords[1]),text2num(endCoords[2]),text2num(endCoords[3]))
	if(!Start || !End)
		to_chat(src, "Invalid Turfs")
		to_chat(src, "Start Coords: [startCoords[1]] - [startCoords[2]] - [startCoords[3]]")
		to_chat(src, "End Coords: [endCoords[1]] - [endCoords[2]] - [endCoords[3]]")
		return

	var/list/clusters = list("None"=MAP_GENERATOR_CLUSTER_CHECK_NONE,"All"=MAP_GENERATOR_CLUSTER_CHECK_ALL,"Sames"=MAP_GENERATOR_CLUSTER_CHECK_SAMES,"Differents"=MAP_GENERATOR_CLUSTER_CHECK_DIFFERENTS, \
	"Same turfs"=MAP_GENERATOR_CLUSTER_CHECK_SAME_TURFS, "Same atoms"=MAP_GENERATOR_CLUSTER_CHECK_SAME_ATOMS, "Different turfs"=MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_TURFS, \
	"Different atoms"=MAP_GENERATOR_CLUSTER_CHECK_DIFFERENT_ATOMS, "All turfs"=MAP_GENERATOR_CLUSTER_CHECK_ALL_TURFS,"All atoms"=MAP_GENERATOR_CLUSTER_CHECK_ALL_ATOMS)

	var/moduleClusters = input("Cluster Flags (Cancel to leave unchanged from defaults)","Map Gen Settings") as null|anything in clusters
	//null for default

	var/theCluster = 0
	if(moduleClusters != "None")
		if(!clusters[moduleClusters])
			to_chat(src, "Invalid Cluster Flags")
			return
		theCluster = clusters[moduleClusters]
	else
		theCluster =  MAP_GENERATOR_CLUSTER_CHECK_NONE

	if(theCluster)
		for(var/datum/map_generator_module/M in N.modules)
			M.clusterCheckFlags = theCluster


	to_chat(src, "Defining Region")
	N.defineRegion(Start, End)
	to_chat(src, "Region Defined")
	to_chat(src, "Generating Region")
	N.generate()
	to_chat(src, "Generated Region")
