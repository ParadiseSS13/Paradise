/mob/camera/eye/hologram
  name = "Inactive Hologram Eye"
  ai_detector_visible = FALSE
  relay_speech = TRUE
  var/obj/machinery/hologram/holopad/holopad = null

/mob/camera/eye/hologram/New(loc, name, origin, user)
  . = ..()
  holopad = origin
  name = "Hologram ([user.name])"
  give_control(user)

/mob/camera/eye/hologram/validate_active_cameranet()
  ..(TRUE)

/mob/camera/eye/hologram/setLoc(T)
  ..()
  holopad.move_hologram(user, loc)
