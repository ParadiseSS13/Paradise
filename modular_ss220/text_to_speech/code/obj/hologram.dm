/obj/machinery/hologram/holopad/activate_holo(mob/living/user, force)
	. = ..()
	var/obj/effect/overlay/holo_pad_hologram/hologram = .
	var/datum/component/tts_component/user_tts = user.GetComponent(/datum/component/tts_component)
	hologram.AddComponent(/datum/component/tts_component, user_tts.type)
