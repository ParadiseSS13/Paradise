// APC malf status
#define APC_MALF_NOT_HACKED 1
#define APC_MALF_HACKED 2 // APC hacked by user, and user is in its core.
#define APC_MALF_SHUNTED_HERE 3 // User is shunted in this APC
#define APC_MALF_SHUNTED_OTHER 4 // User is shunted in another APC

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != APC_MALF_NOT_HACKED)
		return
	if(malf.malfhacking)
		to_chat(malf, "You are already hacking an APC.")
		return
	if(constructed)
		to_chat(malf, "<span class='warning'>This APC was only recently constructed, and is not fully linked to station systems. Hacking it would be pointless.</span>")
		return
	to_chat(malf, "Beginning override of APC systems. This takes some time, and you can only hack one APC at a time.")
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, TYPE_PROC_REF(/mob/living/silicon/ai, malfhacked), src), 600, TIMER_STOPPABLE)
	var/atom/movable/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /atom/movable/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current APC first!</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>You cannot shunt!</span>")
		return
	if(!is_station_level(z))
		return
	occupier = new /mob/living/silicon/ai(src,malf.laws,null,1)
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = TRUE
	malf.mind.transfer_to(occupier)
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	var/datum/spell/ai_spell/return_to_core/R = new
	occupier.AddSpell(R)
	occupier.cancel_camera()
	if((SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_DELTA) && malf.nuking)
		for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
			point.the_disk = src //the pinpointer will detect the shunted AI

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = FALSE
		occupier.parent.adjustOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		qdel(occupier)
		if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_DELTA)
			for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
				for(var/mob/living/silicon/ai/A in GLOB.ai_list)
					if((A.stat != DEAD) && A.nuking)
						point.the_disk = A //The pinpointer tracks the AI back into its core.
	else
		to_chat(occupier, "<span class='danger'>Primary core damaged, unable to return core processes.</span>")
		if(forced)
			occupier.loc = loc
			occupier.death()
			occupier.gib()
			for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
				point.the_disk = null //Pinpointers go back to tracking the nuke disk

/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return FALSE

	// Only if they're a traitor OR they have the malf picker from the combat module
	if(!malf.mind.has_antag_datum(/datum/antagonist/traitor) && !malf.malf_picker)
		return FALSE

	if(malfai == (malf.parent || malf))
		if(occupier == malf)
			return APC_MALF_SHUNTED_HERE
		else if(istype(malf.loc, /obj/machinery/power/apc))
			return APC_MALF_SHUNTED_OTHER
		else
			return APC_MALF_HACKED
	else
		return APC_MALF_NOT_HACKED

#undef APC_MALF_NOT_HACKED
#undef APC_MALF_HACKED
#undef APC_MALF_SHUNTED_HERE
#undef APC_MALF_SHUNTED_OTHER
