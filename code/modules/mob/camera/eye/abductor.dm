/mob/camera/eye/abductor
  name = "Inactive Advanced Camera Eye"
  ai_detector_visible = FALSE

/mob/camera/eye/abductor/New(loc, name, origin, user)
  ..()
  setLoc(first_active_camera())
  give_control(user)

/mob/camera/eye/abductor/validate_active_cameranet()
  ..(TRUE)
