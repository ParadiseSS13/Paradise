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

// DVORAK
/obj/machinery/camera/tracking_head
	icon_state = "camera_base"
	var/obj/effect/camera_head/camera_overlay

/obj/machinery/camera/tracking_head/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 6)
	camera_overlay = new(get_turf(src))
	switch(dir)
		if(NORTH)
			camera_overlay.pixel_x = 2
			camera_overlay.pixel_y = 6

		if(EAST)
			camera_overlay.pixel_x = 6
			camera_overlay.pixel_y = 23

		if(SOUTH)
			camera_overlay.pixel_x = 4
			camera_overlay.pixel_y = 20

		if(WEST)
			camera_overlay.pixel_x = 20
			camera_overlay.pixel_y = 23

	camera_overlay.dir = dir
	RegisterSignal(src, COMSIG_CAMERA_OFF, PROC_REF(prime_the_camera))

/obj/machinery/camera/tracking_head/Destroy()
	. = ..()
	QDEL_NULL(camera_overlay)
	UnregisterSignal(src, COMSIG_CAMERA_OFF)

/obj/machinery/camera/tracking_head/process()
	return PROCESS_KILL

/obj/machinery/camera/tracking_head/update_icon_state()
	return

/obj/machinery/camera/tracking_head/update_overlays()
	return

/obj/machinery/camera/tracking_head/HasProximity(atom/movable/AM)
	if(!isrobot(AM) && !iscarbon(AM)) // Only care about carbons and borgs.
		return
	if(camera_overlay.dir == get_dir(src, AM))
		return
	camera_overlay.dir = get_dir(src, AM)
	playsound(get_turf(src), pick('sound/effects/turret/move1.wav', 'sound/effects/turret/move2.wav'), 10, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/machinery/camera/tracking_head/proc/prime_the_camera()
	SIGNAL_HANDLER //COMSIG_CAMERA_OFF
	visible_message("<span class='danger'>[src] begins to spark violently!")
	do_sparks(4, 0, src)
	addtimer(CALLBACK(src, PROC_REF(explode_the_camera)), 2.5 SECONDS)

/obj/machinery/camera/tracking_head/proc/explode_the_camera()
	if(QDELETED(src))
		return
	explosion(loc, -1, -1, 2, flame_range = 4, cause = "Exploding DVORAK Camera")
	qdel(src)

/obj/effect/camera_head
	icon = 'icons/obj/followingcamera.dmi'
	icon_state = "camera_head"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/camera/tracking_head/dvorak
	non_chunking_camera = TRUE
	network = list("DVORAK") //Shouldn't show on any camera net, be it camera bugs or station or AI.

/obj/machinery/camera/motion/dvorak
	non_chunking_camera = TRUE
	network = list("DVORAK") //Shouldn't show on any camera net, be it camera bugs or station or AI.

// This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize(mapload)
	var/static/list/autonames_in_areas = list()

	var/area/camera_area = get_area(src)
	if(!camera_area)
		c_tag = "Unknown #[rand(1, 100)]"
		stack_trace("Camera with tag [c_tag] was spawned without an area, please report this to your nearest coder.")
		return ..()

	c_tag = "[sanitize(camera_area.name)] #[++autonames_in_areas[camera_area]]" // increase the number, then print it (this is what ++ before does)
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
	GLOB.cameranet.update_visibility(src, 0)

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	if(isMotion())
		return
	if(name == initial(name))
		name = "motion-sensitive security camera"
	assembly.upgrades.Add(new /obj/item/assembly/prox_sensor(assembly))
	proximity_monitor = new(src, CAMERA_VIEW_DISTANCE)
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
