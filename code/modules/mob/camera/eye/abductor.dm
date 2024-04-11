/mob/camera/eye/abductor
  name = "Abductor Camera Eye"
  ai_detector_visible = FALSE

/mob/camera/eye/abductor/Initialize(mapload, name, origin, user)
  ..()
  setLoc(first_active_camera())

/mob/camera/eye/abductor/rename_camera(new_name)
  name = "Abductor Camera Eye ([new_name])"

/mob/camera/eye/abductor/validate_active_cameranet()
  ..(TRUE)
