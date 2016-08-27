// IPC limbs.
/obj/item/organ/external/head/ipc
	can_intake_reagents = 0
	vital = 0
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

/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/obj/power.dmi'
	icon_state = "scell"
	organ_tag = "heart"
	parent_organ = "chest"
	slot = "heart"
	vital = 1
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/internal/cell/New()
	robotize()
	..()

/obj/item/organ/internal/optical_sensor
	name = "optical sensor"
	organ_tag = "eyes"
	parent_organ = "head"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	slot = "eyes"
	status = ORGAN_ROBOT
	species = "Machine"
//	dead_icon = "camera_broken"

/obj/item/organ/internal/optical_sensor/New()
	robotize()
	..()


/obj/item/organ/internal/optical_sensor/remove(var/mob/living/user,special = 0)
	if(!special)
		to_chat(owner, "Error 404:Optical Sensors not found.")

	. = ..()

/obj/item/organ/internal/optical_sensor/surgeryize()
	if(!owner)
		return
	owner.disabilities &= ~NEARSIGHTED
	owner.disabilities &= ~BLIND
	owner.eye_blurry = 0
	owner.eye_blind = 0


// Used for an MMI or posibrain being installed into a human.
/obj/item/organ/internal/brain/mmi_holder
	name = "brain"
	organ_tag = "brain"
	parent_organ = "chest"
	vital = 1
	max_damage = 200
	slot = "brain"
	status = ORGAN_ROBOT
	species = "Machine"
	var/obj/item/device/mmi/stored_mmi


/obj/item/organ/internal/brain/mmi_holder/Destroy()
	if(stored_mmi)
		qdel(stored_mmi)
	return ..()

/obj/item/organ/internal/brain/mmi_holder/insert(var/mob/living/target,special = 0)
	..()
	// To supersede the over-writing of the MMI's name from `insert`
	update_from_mmi()

/obj/item/organ/internal/brain/mmi_holder/remove(var/mob/living/user,special = 0)
	if(!special)
		if(stored_mmi)
			. = stored_mmi
			if(owner.mind)
				owner.mind.transfer_to(stored_mmi.brainmob)
			stored_mmi.forceMove(get_turf(src))
			stored_mmi = null
	..()
	qdel(src)

/obj/item/organ/internal/brain/mmi_holder/proc/update_from_mmi()
	if(!stored_mmi)
		return
	name = stored_mmi.name
	desc = stored_mmi.desc
	icon = stored_mmi.icon
	icon_state = stored_mmi.icon_state
	set_dna(stored_mmi.brainmob.dna)

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	robotize()
	stored_mmi = new /obj/item/device/mmi/posibrain/ipc(src)
	..()
	spawn(1)
		if(owner)
			stored_mmi.name = "positronic brain ([owner.real_name])"
			stored_mmi.brainmob.real_name = owner.real_name
			stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
			stored_mmi.icon_state = "posibrain-occupied"
			update_from_mmi()
		else
			stored_mmi.loc = get_turf(src)
			qdel(src)
