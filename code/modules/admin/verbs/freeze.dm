////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//////Freeze Mob/Mech Verb -- Ported from NSS Pheonix (Unbound Travels)/////////
////////////////////////////////////////////////////////////////////////////////
//////Allows admin's to right click on any mob/mech and freeze them in place.///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

GLOBAL_LIST_EMPTY(frozen_atom_list) // A list of admin-frozen atoms.

/client/proc/freeze(atom/movable/M)
	set name = "\[Admin\] Freeze"

	if(!check_rights(R_ADMIN))
		return

	M.admin_Freeze(src)

/// Created here as a base proc. Override as needed for any type of object or mob you want able to be frozen.
/atom/movable/proc/admin_Freeze(client/admin)
	to_chat(admin, "<span class='warning'>Freeze is not able to be called on this type of object.</span")
	return

///mob freeze procs
/mob/living/admin_Freeze(client/admin, skip_overlays = FALSE, mech = null)
	if(!istype(admin))
		return

	if(!(src in GLOB.frozen_atom_list))
		GLOB.frozen_atom_list += src

		var/obj/effect/overlay/adminoverlay/AO = new
		if(skip_overlays)
			overlays += AO

		anchored = TRUE
		admin_prev_sleeping = AmountSleeping()
		frozen = AO
		PermaSleeping()

	else
		GLOB.frozen_atom_list -= src

		if(skip_overlays)
			overlays -= frozen

		anchored = FALSE
		frozen = null
		SetSleeping(admin_prev_sleeping, TRUE)
		admin_prev_sleeping = null

	to_chat(src, "<b><font color= red>You have been [frozen ? "frozen" : "unfrozen"] by [admin]</b></font>")
	message_admins("<span class='notice'>[key_name_admin(admin)] [frozen ? "froze" : "unfroze"] [key_name_admin(src)] [mech ? "in a [mech]" : ""]</span>")
	log_admin("[key_name(admin)] [frozen ? "froze" : "unfroze"] [key_name(src)] [mech ? "in a [mech]" : ""]")
	update_icons()

	return frozen


/mob/living/simple_animal/slime/admin_Freeze(admin)
	if(..()) // The result of the parent call here will be the value of the mob's `frozen` variable after they get (un)frozen.
		adjustHealth(1000) //arbitrary large value
	else
		revive()

/mob/living/simple_animal/admin_Freeze(admin)
	// If we were frozen before this call, make sure we
	// reset our health before attempting a rejuvenate,
	// as removing status effects can perform stat calls.
	if(frozen && del_on_death)
		health = admin_prev_health

	if(..()) // The result of the parent call here will be the value of the mob's `frozen` variable after they get (un)frozen.
		admin_prev_health = health
		health = 0
	else
		revive()
		overlays.Cut()

//////////////////////////Freeze Mech

/obj/mecha/admin_Freeze(client/admin)
	var/obj/effect/overlay/adminoverlay/freeze_overlay = new
	if(!frozen)
		GLOB.frozen_atom_list += src
		frozen = TRUE
		overlays += freeze_overlay
	else
		GLOB.frozen_atom_list -= src
		frozen = FALSE
		overlays -= freeze_overlay

	if(occupant)
		occupant.admin_Freeze(admin, mech = name) // We also want to freeze the driver of the mech.
	else
		message_admins("<span class='notice'>[key_name_admin(admin)] [frozen ? "froze" : "unfroze"] an empty [name]</span>")
		log_admin("[key_name(admin)] [frozen ? "froze" : "unfroze"] an empty [name]")

/obj/machinery/atmospherics/supermatter_crystal/admin_Freeze(client/admin)
	var/obj/effect/overlay/adminoverlay/freeze_overlay = new
	if(processes)
		radio.autosay("Alert: Unknown intervention has frozen causality around the crystal. It is not progressing in local timespace.", name, "Engineering")
		GLOB.frozen_atom_list += src
		processes = FALSE
		add_overlay(freeze_overlay)
	else
		radio.autosay("Alert: Unknown intervention has ceased around the crystal. It has returned to the regular flow of time.", name, "Engineering")
		GLOB.frozen_atom_list -= src
		processes = TRUE
		cut_overlay(freeze_overlay)
	message_admins("<span class='notice'>[key_name_admin(admin)] [processes ? "unfroze" : "froze"] a supermatter crystal</span>")
	log_admin("[key_name(admin)] [processes ? "unfroze" : "froze"] a supermatter crystal")
