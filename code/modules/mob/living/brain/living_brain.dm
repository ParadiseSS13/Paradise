/mob/living/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	use_me = FALSE //Can't use the me verb, it's a freaking immobile brain
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"

/mob/living/brain/New()
	..()
	add_language("Galactic Common")

/mob/living/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		ghostize()		//Ghostize checks for key so nothing else is necessary.
	return ..()

/mob/living/brain/say_understands(other)//Goddamn is this hackish, but this say code is so odd
	if(issilicon(other))
		return istype(container, /obj/item/mmi)
	if(ishuman(other))
		return TRUE
	if(isslime(other))
		return TRUE
	if(isbrain(other))
		return TRUE

	return ..()

/mob/living/brain/ex_act() //you cant blow up brainmobs because it makes transfer_to() freak out when borgs blow up.
	return

/mob/living/brain/blob_act(obj/structure/blob/B)
	return

/mob/living/brain/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE)
	return FALSE

/mob/living/brain/on_forcemove(atom/newloc)
	if(container)
		container.forceMove(newloc)
	else //something went very wrong.
		CRASH("Brainmob without container.")
	forceMove(container)

/*
This will return true if the brain has a container that leaves it less helpless than a naked brain

I'm using this for Stat to give it a more nifty interface to work with
*/
/mob/living/brain/proc/has_synthetic_assistance()
	return (container && istype(container, /obj/item/mmi)) || in_contents_of(/obj/mecha)

/mob/living/brain/proc/get_race()
	if(container)
		var/obj/item/mmi/M = container
		if(istype(M) && M.held_brain)
			return M.held_brain.dna.species.name
		else
			return "Artificial Life"
	if(istype(loc, /obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/B = loc
		return B.dna.species.name

/mob/living/brain/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(has_synthetic_assistance() && ismecha(loc))
		var/obj/mecha/M = loc
		status_tab_data[++status_tab_data.len] = list("Exosuit Charge:", "[istype(M.cell) ? "[M.cell.charge] / [M.cell.maxcharge]" : "No cell detected"]")
		status_tab_data[++status_tab_data.len] = list("Exosuit Integrity:", "[!M.obj_integrity ? "0" : "[(M.obj_integrity / M.max_integrity) * 100]"]%")

/mob/living/brain/can_safely_leave_loc()
	return 0 //You're not supposed to be ethereal jaunting, brains

/mob/living/brain/can_hear()
	. = TRUE

/mob/living/brain/update_runechat_msg_location()
	if(ismecha(loc))
		runechat_msg_location = loc.UID()
	else if(container)
		runechat_msg_location = container.UID()
	else
		return ..()
