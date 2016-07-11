//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	use_me = 0 //Can't use the me verb, it's a freaking immobile brain
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain1"

	New()
		var/datum/reagents/R = new/datum/reagents(330)
		reagents = R
		R.my_atom = src
		..()

	Destroy()
		if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
			if(stat!=DEAD)	//If not dead.
				death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
			ghostize()		//Ghostize checks for key so nothing else is necessary.
		return ..()

	say_understands(var/other)//Goddamn is this hackish, but this say code is so odd
		if(istype(other, /mob/living/silicon/ai))
			if(!(container && istype(container, /obj/item/device/mmi)))
				return 0
			else
				return 1
		if(istype(other, /mob/living/silicon/decoy))
			if(!(container && istype(container, /obj/item/device/mmi)))
				return 0
			else
				return 1
		if(istype(other, /mob/living/silicon/pai))
			if(!(container && istype(container, /obj/item/device/mmi)))
				return 0
			else
				return 1
		if(istype(other, /mob/living/silicon/robot))
			if(!(container && istype(container, /obj/item/device/mmi)))
				return 0
			else
				return 1
		if(istype(other, /mob/living/carbon/human))
			return 1
		if(istype(other, /mob/living/carbon/slime))
			return 1
		return ..()


/mob/living/carbon/brain/update_canmove()
	if(in_contents_of(/obj/mecha))
		canmove = 1
		use_me = 1 //If it can move, let it emote
	else if(istype(loc, /obj/item/device/mmi))	canmove = 1 //mmi won't move anyways so whatever
	else							canmove = 0
	return canmove

/mob/living/carbon/brain/ex_act() //you cant blow up brainmobs because it makes transfer_to() freak out when borgs blow up.
	return

/mob/living/carbon/brain/blob_act()
	return

/mob/living/carbon/brain/on_forcemove(atom/newloc)
	if(container)
		container.loc = newloc
	else //something went very wrong.
		CRASH("Brainmob without container.")
	loc = container

/*
This will return true if the brain has a container that leaves it less helpless than a naked brain

I'm using this for Stat to give it a more nifty interface to work with
*/
/mob/living/carbon/brain/proc/has_synthetic_assistance()
	return (container && istype(container, /obj/item/device/mmi)) || in_contents_of(/obj/mecha)

/mob/living/carbon/brain/Stat()
	..()
	if(has_synthetic_assistance())
		statpanel("Status")
		show_stat_station_time()
		show_stat_emergency_shuttle_eta()

		if(client.statpanel == "Status")
			//Knowing how well-off your mech is doing is really important as an MMI
			if(istype(src.loc, /obj/mecha))
				var/obj/mecha/M = src.loc
				stat("Exosuit Charge:", "[istype(M.cell) ? "[M.cell.charge] / [M.cell.maxcharge]" : "No cell detected"]")
				stat("Exosuit Integrity", "[!M.health ? "0" : "[(M.health / initial(M.health)) * 100]"]%")

/mob/living/carbon/brain/can_safely_leave_loc()
	return 0 //You're not supposed to be ethereal jaunting, brains