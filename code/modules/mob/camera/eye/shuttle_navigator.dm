/mob/camera/eye/shuttle_docker
  name = "Shuttle Docker Camera Eye"
  ai_detector_visible = FALSE
  simulated = FALSE
  var/list/placement_images = list()
  var/list/placed_images = list()

/mob/camera/eye/shuttle_docker/Initialize(mapload, obj/machinery/computer/camera_advanced/origin)
  src.origin = origin
  return ..()

/mob/camera/eye/shuttle_docker/setLoc(T)
  if(isspaceturf(get_turf(T)) || istype(get_area(T), /area/space) || istype(get_area(T), /area/shuttle))
    ..()
    var/obj/machinery/camera_advanced/shuttle_docker/console = origin
    console.checkLandingSpot()
    return
  else
    return

/mob/camera/eye/shuttle_docker/update_remote_sight(mob/living/user)
  user.sight = SEE_TURFS
  
  ..()
  return TRUE
  