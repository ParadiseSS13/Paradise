//clusterCheckFlags defines
//All based on clusterMin and clusterMax as guides

//Individual defines
#define CLUSTER_CHECK_NONE				0  //No checks are done, cluster as much as possible
#define CLUSTER_CHECK_DIFFERENT_TURFS	2  //Don't let turfs of DIFFERENT types cluster
#define CLUSTER_CHECK_DIFFERENT_ATOMS	4  //Don't let atoms of DIFFERENT types cluster
#define CLUSTER_CHECK_SAME_TURFS		8  //Don't let turfs of the SAME type cluster
#define CLUSTER_CHECK_SAME_ATOMS		16 //Don't let atoms of the SAME type cluster

//Combined defines
#define CLUSTER_CHECK_SAMES				24 //Don't let any of the same type cluster
#define CLUSTER_CHECK_DIFFERENTS		6  //Don't let any of different types cluster
#define CLUSTER_CHECK_ALL_TURFS			10 //Don't let ANY turfs cluster same and different types
#define CLUSTER_CHECK_ALL_ATOMS			20 //Don't let ANY atoms cluster same and different types

//All
#define CLUSTER_CHECK_ALL				30 //Don't let anything cluster, like, at all


/datum/mapGenerator

	//Map information
	var/list/map = list()

	//mapGeneratorModule information
	var/list/modules = list()

/datum/mapGenerator/New()
	..()
	initialiseModules()

//Defines the region the map represents, sets map
//Returns the map
/datum/mapGenerator/proc/defineRegion(turf/Start, turf/End, replace = 0)
	if(!checkRegion(Start, End))
		return 0

	if(replace)
		undefineRegion()

	map |= block(Start,End)
	return map


//Defines the region the map represents, as a CIRCLE!, sets map
//Returns the map
/datum/mapGenerator/proc/defineCircularRegion(turf/Start, turf/End, replace = 0)
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
	if(bigZ % 2 == 0)
		offByOneOffset = 0

	for(var/i = lilZ, i <= bigZ+offByOneOffset, i++)
		var/theRadius = radius
		if(i != sphereMagic)
			theRadius = max(radius/max((2*abs(sphereMagic-i)),1),1)


		map |= circlerange(locate(centerX,centerY,i),theRadius)


	return map


//Empties the map list, he's dead jim.
/datum/mapGenerator/proc/undefineRegion()
	map = list() //bai bai


//Checks for and Rejects bad region coordinates
//Returns 1/0
/datum/mapGenerator/proc/checkRegion(turf/Start, turf/End)
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
/datum/mapGenerator/proc/generate()
	syncModules()
	if(!modules || !modules.len)
		return
	for(var/datum/mapGeneratorModule/mod in modules)
		spawn(0)
			mod.generate()


//Requests the mapGeneratorModule(s) to (re)generate this one turf
/datum/mapGenerator/proc/generateOneTurf(turf/T)
	if(!T)
		return
	syncModules()
	if(!modules || !modules.len)
		return
	for(var/datum/mapGeneratorModule/mod in modules)
		spawn(0)
			mod.place(T)


//Replaces all paths in the module list with actual module datums
/datum/mapGenerator/proc/initialiseModules()
	for(var/path in modules)
		if(ispath(path))
			modules.Remove(path)
			modules |= new path
	syncModules()


//Sync mapGeneratorModule(s) to mapGenerator
/datum/mapGenerator/proc/syncModules()
	for(var/datum/mapGeneratorModule/mod in modules)
		mod.sync(src)
