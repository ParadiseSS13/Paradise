// IPC limbs.
/obj/item/organ/external/head/ipc
	can_intake_reagents = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/head/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/chest/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/chest/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/groin/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/groin/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/arm/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/arm/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/arm/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/arm/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()
/obj/item/organ/external/leg/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/leg/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/leg/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/leg/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/foot/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/foot/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/foot/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/foot/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/hand/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/hand/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/hand/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/hand/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/internal/eyes/optical_sensor
	name = "optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	status = ORGAN_ROBOT
	species = "Machine"
//	dead_icon = "camera_broken"
	weld_proof = 1

/obj/item/organ/internal/eyes/optical_sensor/New()
	robotize()
	..()


/obj/item/organ/internal/eyes/optical_sensor/remove(var/mob/living/user,special = 0)
	if(!special)
		to_chat(owner, "Error 404:Optical Sensors not found.")

	. = ..()

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	stored_mmi = new /obj/item/mmi/robotic_brain/positronic(src)
	..()
	spawn(1)
		if(!QDELETED(src))
			if(owner)
				stored_mmi.name = "positronic brain ([owner.real_name])"
				stored_mmi.brainmob.real_name = owner.real_name
				stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
				stored_mmi.icon_state = "posibrain-occupied"
				update_from_mmi()
			else
				stored_mmi.loc = get_turf(src)
				qdel(src)