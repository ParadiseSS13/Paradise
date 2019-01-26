// IPC limbs.
/obj/item/organ/external/head/ipc
	can_intake_reagents = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/head/ipc/New(mob/living/carbon/holder, datum/species/species_override = null)
	..(holder, /datum/species/machine) // IPC heads need to be explicitly set to this since you can print them
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/chest/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/chest/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/groin/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/groin/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/arm/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/arm/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/arm/right/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/arm/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/leg/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/leg/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/leg/right/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/leg/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/foot/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/foot/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/foot/right/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/foot/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/hand/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/hand/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/hand/right/ipc
	encased = null
	status = ORGAN_ROBOT

/obj/item/organ/external/hand/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/obj/power.dmi'
	icon_state = "scell"
	organ_tag = "heart"
	parent_organ = "chest"
	slot = "heart"
	vital = TRUE
	status = ORGAN_ROBOT

/obj/item/organ/internal/eyes/optical_sensor
	name = "optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	status = ORGAN_ROBOT
//	dead_icon = "camera_broken"
	weld_proof = 1

/obj/item/organ/internal/eyes/optical_sensor/remove(var/mob/living/user,special = 0)
	if(!special)
		to_chat(owner, "Error 404:Optical Sensors not found.")

	. = ..()

/obj/item/organ/internal/brain/mmi_holder/posibrain
	name = "positronic brain"

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	..()
	stored_mmi = new /obj/item/mmi/robotic_brain/positronic(src)
	if(!owner)
		stored_mmi.forceMove(get_turf(src))
		qdel(src)

/obj/item/organ/internal/brain/mmi_holder/posibrain/remove(mob/living/user, special = 0)
	if(stored_mmi && dna)
		stored_mmi.name = "[initial(name)] ([dna.real_name])"
		stored_mmi.brainmob.real_name = dna.real_name
		stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
		stored_mmi.icon_state = "posibrain-occupied"
		if(!stored_mmi.brainmob.dna)
			stored_mmi.brainmob.dna = dna.Clone()
	. = ..()

/obj/item/organ/internal/ears/microphone
	name = "microphone"
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	status = ORGAN_ROBOT
	dead_icon = "taperecorder_empty"

/obj/item/organ/internal/ears/microphone/remove(mob/living/user, special = FALSE)
	if(!special)
		to_chat(owner, "<span class='userdanger'>BZZZZZZZZZZZZZZT! Microphone error!</span>")
	. = ..()