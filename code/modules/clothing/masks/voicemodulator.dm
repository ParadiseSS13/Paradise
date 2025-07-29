/obj/item/clothing/mask/gas/voice_modulator
	name = "modified gas mask"
	desc = "A gas mask modified with a sound modulator that disguises the user's voice when active."
	icon_state = "voice_modulator"
	var/obj/item/voice_changer/voice_modulator/voice_modulator

/obj/item/clothing/mask/gas/voice_modulator/Initialize(mapload)
	. = ..()
	voice_modulator = new(src)

/obj/item/clothing/mask/gas/voice_modulator/Destroy()
	QDEL_NULL(voice_modulator)
	return ..()

/obj/item/clothing/mask/gas/voice_modulator/chameleon
	name = "chameleon voice modulator mask"
	desc = "A tactical mask equipped with chameleon technology and a sound modulator that disguises the user's voice when active."
	icon_state = "swat"
	var/datum/action/item_action/chameleon_change/chameleon_action

/obj/item/clothing/mask/gas/voice_modulator/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.chameleon_blacklist = list()
	chameleon_action.initialize_disguises()

/obj/item/clothing/mask/gas/voice_modulator/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/mask/gas/voice_modulator/chameleon/emp_act(severity)
	. = ..()
	chameleon_action.emp_randomise()

/obj/item/clothing/mask/gas/voice_modulator/change_speech_verb()
	if(voice_modulator.active)
		return pick("modulates", "drones", "hums", "buzzes")
