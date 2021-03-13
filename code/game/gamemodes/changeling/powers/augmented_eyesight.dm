//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/datum/action/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates more light sensing rods in our eyes, allowing our vision to penetrate most blocking objects. Protects our vision from flashes while inactive."
	helptext = "Grants us x-ray vision or flash protection. We will become a lot more vulnerable to flash-based devices while x-ray vision is active."
	button_icon_state = "augmented_eyesight"
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	active = FALSE

/datum/action/changeling/augmented_eyesight/on_purchase(mob/user) //The ability starts inactive, so we should be protected from flashes.
	if(!istype(user))
		return
	..()
	var/obj/item/organ/internal/eyes/E = user.get_organ_slot("eyes")
	if(E)
		E.flash_protect = FLASH_PROTECTION_WELDER //Adjust the user's eyes' flash protection
		to_chat(user, "<span class='notice'>We adjust our eyes to protect them from bright lights.</span>")
	else
		to_chat(user, "<span class='warning'>We can't adjust our eyes if we don't have any!</span>")

/datum/action/changeling/augmented_eyesight/sting_action(mob/living/carbon/user)
	if(!istype(user))
		return
	..()
	var/obj/item/organ/internal/eyes/E = user.get_organ_slot("eyes")
	if(E)
		if(!active)
			E.vision_flags |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
			E.flash_protect = FLASH_PROTECTION_SENSITIVE //Adjust the user's eyes' flash protection
			to_chat(user, "<span class='notice'>We adjust our eyes to sense prey through walls.</span>")
			active = TRUE
		else
			E.vision_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
			E.flash_protect = FLASH_PROTECTION_WELDER //Adjust the user's eyes' flash protection
			to_chat(user, "<span class='notice'>We adjust our eyes to protect them from bright lights.</span>")
			active = FALSE
		user.update_sight()
	else
		to_chat(user, "<span class='warning'>We can't adjust our eyes if we don't have any!</span>")
	return TRUE


/datum/action/changeling/augmented_eyesight/Remove(mob/user) //Get rid of x-ray vision and flash protection when the user refunds this ability
	if(!istype(user))
		return
	var/obj/item/organ/internal/eyes/E = user.get_organ_slot("eyes")
	if(E)
		if(active)
			E.vision_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS
		else
			E.flash_protect = FLASH_PROTECTION_NONE
		user.update_sight()
	..()
