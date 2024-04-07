/mob/camera/eye/ai
  name = "Inactive AI Eye"
  icon = "icons/mob/ai.dmi"
  icon_state = "eye"
  var/mob/living/silicon/ai/ai = null

/mob/camera/eye/ai/New(loc, name, origin, user)
  . = ..()
  ai = origin
  if(isAIEye(ai.eyeobj))
    qdel(src)
    return
  ai.eyeobj = src
  name = "[name] (AI Eye)"

/mob/camera/eye/ai/setLoc(T)
  ..()
  user.reset_perspective(src)
  update_parallax_contents()

/mob/camera/eye/ai/relaymove(mob/user, direct)
  ..()
  if(!ai.tracking)
    ai.cameraFollow = null
  if(ai.camera_light_on)
    ai.light_cameras()

/mob/camera/eye/ai/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
  if(relay_speech)
    ai.relay_speech(speaker, message_pieces, verb)
