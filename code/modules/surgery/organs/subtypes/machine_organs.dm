// IPC limbs.
/obj/item/organ/external/head/ipc
	can_intake_reagents = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/head/ipc/New(mob/living/carbon/holder, datum/species/species_override = null)
	..(holder, /datum/species/machine) // IPC heads need to be explicitly set to this since you can print them
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/chest/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/chest/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/groin/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/groin/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/arm/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/arm/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/arm/right/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/arm/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/leg/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/leg/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/leg/right/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/leg/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/foot/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/foot/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/foot/right/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/foot/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/hand/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/hand/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/external/hand/right/ipc
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/hand/right/ipc/New()
	..()
	robotize("Morpheus Cyberkinetics")

/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon_state = "cell"
	organ_tag = "heart"
	parent_organ = "chest"
	dead_icon = "cell_bork"
	slot = "heart"
	vital = TRUE
	status = ORGAN_ROBOT
	requires_robotic_bodypart = TRUE
	organ_datums = list(/datum/organ/battery)

/obj/item/organ/internal/cell/overvoltageproof
	name = "overvoltage-proofed microbattery"
	desc = "A variant of microbattery fitted with an overvoltage protection system, designed to mitigate damage caused by electrical shocks to the connected chassis. \
	It is even capable of shielding the chassis from EMP effects, however this triggers a failsafe and forces the system to reboot."
	icon_state = "extracell"
	dead_icon = "extracell_bork"
	var/protection_inactive = FALSE

/obj/item/organ/internal/cell/overvoltageproof/insert(mob/living/carbon/M, special, dont_remove_slot)
	..()
	if(emagged)
		ADD_TRAIT(M, TRAIT_SHOCKIMMUNE, "overvoltageproof_emagged[UID()]")
	ADD_TRAIT(M, TRAIT_EMP_IMMUNE, "overvoltageproof[UID()]")

	RegisterSignal(M, COMSIG_SPECIES_SPEC_ELECTROCUTE_POST_ACT, PROC_REF(shock_effects))
	RegisterSignal(M, COMSIG_HUMAN_EMP_IMMUNE_SIGNAL, PROC_REF(emp_effects))

/obj/item/organ/internal/cell/overvoltageproof/remove(mob/living/carbon/M, special)
	if(emagged)
		REMOVE_TRAIT(M, TRAIT_SHOCKIMMUNE, "overvoltageproof_emagged[UID()]")
	REMOVE_TRAIT(M, TRAIT_EMP_IMMUNE, "overvoltageproof[UID()]")

	UnregisterSignal(M, COMSIG_SPECIES_SPEC_ELECTROCUTE_POST_ACT)
	UnregisterSignal(M, COMSIG_HUMAN_EMP_IMMUNE_SIGNAL)
	return ..()

/obj/item/organ/internal/cell/overvoltageproof/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You disable the overvoltage protection failsafe on [src]</span>")
		emagged = TRUE
		return TRUE
	else
		to_chat(user, "<span class='warning'>You re-enable the overvoltage protection failsafe on [src]</span>")
		emagged = FALSE

/obj/item/organ/internal/cell/overvoltageproof/proc/shock_effects(bloob, mob/living/carbon/human/H, shock_damage, source, siemens_coeff, flags)
	// Bloob is a dummy value to properly offset var placement so shock damage isn't the same as H, because the vars from the signal for some reason have been supremely fucky
	SIGNAL_HANDLER

	if(!owner && owner.stat == DEAD)
		return

	if(protection_inactive)
		return

	if(emagged)
		to_chat(H, "<span class='warning'>You feel drained of energy!</span>")
		H.adjust_nutrition(shock_damage / 2) // In exchange for shock immunity, nutrition is siphoned

	else
		// Real jank ways to prevent the IPC brain damage caused by shocks and reduce the damage recieved
		H.adjustFireLoss(-shock_damage / 2)
		H.adjustBrainLoss(-shock_damage)

/obj/item/organ/internal/cell/overvoltageproof/proc/emp_effects(severity)
	SIGNAL_HANDLER

	if(!owner && owner.stat == DEAD)
		return

	if(protection_inactive)
		return

	if(emagged)
		to_chat(owner, "<span class='warning'>You feel drained of energy!</span>")
		owner.adjust_nutrition(severity / 2) // In exchange for EMP immunity, nutrition is siphoned

	else
		to_chat(owner, "<span class='warning'>You recieve a diagnostics notice that your overvoltage protection system has rebooted itself and is now inactive!</span>")
		protection_inactive = TRUE
		REMOVE_TRAIT(owner, TRAIT_EMP_IMMUNE, "overvoltageproof[UID()]")
		addtimer(CALLBACK(src, PROC_REF(protection_reenable)), 30 SECONDS)

/obj/item/organ/internal/cell/overvoltageproof/proc/protection_reenable()
	if(!owner)
		return

	to_chat(owner, "<span class='notice'>You recieve a diagnostics notice that your overvoltage protection system has finished rebooting and is now active!</span>")
	protection_inactive = FALSE
	ADD_TRAIT(owner, TRAIT_EMP_IMMUNE, "overvoltageproof[UID()]")

/obj/item/organ/internal/eyes/optical_sensor
	name = "optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	status = ORGAN_ROBOT
	weld_proof = TRUE
	requires_robotic_bodypart = TRUE

/obj/item/organ/internal/eyes/optical_sensor/remove(mob/living/user,special = 0)
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
	icon_state = "voicebox"
	status = ORGAN_ROBOT
	dead_icon = "taperecorder_empty"
	requires_robotic_bodypart = TRUE

/obj/item/organ/internal/ears/microphone/remove(mob/living/user, special = FALSE)
	if(!special)
		to_chat(owner, "<span class='userdanger'>BZZZZZZZZZZZZZZT! Microphone error!</span>")
	. = ..()
