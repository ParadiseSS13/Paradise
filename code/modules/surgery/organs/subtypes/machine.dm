// IPC limbs.
/obj/item/organ/external/head/ipc
	can_intake_reagents = 0
	vital = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null

/obj/item/organ/external/head/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/chest/ipc
	encased = null

/obj/item/organ/external/chest/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/groin/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/arm/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/arm/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/leg/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/leg/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/foot/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/foot/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/hand/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/hand/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/obj/power.dmi'
	icon_state = "scell"
	organ_tag = "cell"
	parent_organ = "chest"
	slot = "heart"
	vital = 1

/obj/item/organ/internal/cell/New()
	robotize()
	..()

/obj/item/organ/internal/cell/insert()
	..()
	// This is very ghetto way of rebooting an IPC. TODO better way.
	if(owner && owner.stat == DEAD)
		owner.stat = CONSCIOUS
		owner.visible_message("<span class='danger'>\The [owner] twitches visibly!</span>")

/obj/item/organ/internal/optical_sensor
	name = "optical sensor"
	organ_tag = "optics"
	parent_organ = "head"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	slot = "eyes"
//	dead_icon = "camera_broken"

/obj/item/organ/internal/optical_sensor/New()
	robotize()
	..()

// Used for an MMI or posibrain being installed into a human.
/obj/item/organ/internal/brain/mmi_holder
	name = "brain"
	organ_tag = "brain"
	parent_organ = "chest"
	vital = 1
	max_damage = 200
	slot = "brain"
	var/obj/item/device/mmi/stored_mmi

/obj/item/organ/internal/brain/mmi_holder/proc/update_from_mmi()
	if(!stored_mmi)
		return
	name = stored_mmi.name
	desc = stored_mmi.desc
	icon = stored_mmi.icon
	icon_state = stored_mmi.icon_state

/obj/item/organ/internal/brain/mmi_holder/remove(var/mob/living/user)
	if(stored_mmi)
		stored_mmi.loc = get_turf(src)
		if(owner.mind)
			owner.mind.transfer_to(stored_mmi.brainmob)
	..()

	var/mob/living/holder_mob = loc
	if(istype(holder_mob))
		holder_mob.unEquip(src)
	qdel(src)

/obj/item/organ/internal/brain/mmi_holder/New()
	..()
	// This is very ghetto way of rebooting an IPC. TODO better way.
	spawn(1)
		if(owner && owner.stat == DEAD)
			owner.stat = CONSCIOUS
			owner.visible_message("<span class='danger'>\The [owner] twitches visibly!</span>")

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	robotize()
	stored_mmi = new /obj/item/device/mmi/posibrain(src)
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
