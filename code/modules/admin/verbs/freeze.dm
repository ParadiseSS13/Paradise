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
	set category = null

	if(!check_rights(R_ADMIN))
		return

	M.admin_Freeze(src)

/// Created here as a base proc. Override as needed for any type of object or mob you want able to be frozen.
/atom/movable/proc/admin_Freeze(client/admin)
	to_chat(admin, "<span class='warning'>Freeze is not able to be called on this type of object.</span")
	return

///mob freeze procs

/mob/living
	/// Used for preventing attacks on admin-frozen mobs.
	var/frozen = null
	/// Used for keeping track of previous sleeping value with admin freeze.
	var/admin_prev_sleeping = 0

/mob/living/admin_Freeze(client/admin, skip_overlays = FALSE, mech = null)
	if(!istype(admin))
		return

	if(!(src in GLOB.frozen_atom_list))
		GLOB.frozen_atom_list += src

		var/obj/effect/overlay/adminoverlay/AO = new
		if(skip_overlays)
			overlays += AO

		anchored = TRUE
		canmove = FALSE
		admin_prev_sleeping = sleeping
		AdjustSleeping(20000)
		frozen = AO

	else
		GLOB.frozen_atom_list -= src

		if(skip_overlays)
			overlays -= frozen

		anchored = FALSE
		canmove = TRUE
		frozen = null
		SetSleeping(admin_prev_sleeping)
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

/mob/living/simple_animal/var/admin_prev_health = null

/mob/living/simple_animal/admin_Freeze(admin)
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
