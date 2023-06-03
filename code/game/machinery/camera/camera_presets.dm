// PRESETS

// EMP

/obj/machinery/camera/emp_proof/Initialize(mapload)
	. = ..()
	upgradeEmpProof()

// X-RAY

/obj/machinery/camera/xray
	icon_state = "xraycam" // Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/Initialize(mapload)
	. = ..()
	upgradeXRay()

// MOTION
/obj/machinery/camera/motion
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

// ALL UPGRADES
/obj/machinery/camera/all
	icon_state = "xraycam" //mapping icon.

/obj/machinery/camera/all/Initialize(mapload)
	. = ..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

// This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize(mapload)
	number = 1
	var/area/A = get_area(src)
	if(!A)
		number = rand(1, 100)
		c_tag = "Unknown #[number]"
		stack_trace("Camera with tag [c_tag] was spawned without an area, please report this to your nearest coder.")
		return ..()

	for(var/obj/machinery/camera/autoname/C in A.contents)
		if(C == src)
			continue
		if(C.number)
			number = max(number, C.number + 1)

	c_tag = "[sanitize(A.name)] #[number]"

	return ..() // We do this here so the camera is not added to the cameranet until it has a name.

// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/mineral/plasma) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/analyzer) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/assembly/prox_sensor) in assembly.upgrades
	return O

// UPGRADE PROCS

/obj/machinery/camera/proc/upgradeEmpProof()
	assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(assembly))
	setPowerUsage()

/obj/machinery/camera/proc/upgradeXRay()
	assembly.upgrades.Add(new /obj/item/analyzer(assembly))
	setPowerUsage()
	//Update what it can see.
	GLOB.cameranet.updateVisibility(src, 0)

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	if(isMotion())
		return
	if(name == initial(name))
		name = "motion-sensitive security camera"
	assembly.upgrades.Add(new /obj/item/assembly/prox_sensor(assembly))
	setPowerUsage()
	// Add it to machines that process
	START_PROCESSING(SSmachines, src)

/obj/machinery/camera/proc/setPowerUsage()
	var/mult = 1
	if(isXRay())
		mult++
	if(isMotion())
		mult++
	active_power_consumption = mult * initial(active_power_consumption)
