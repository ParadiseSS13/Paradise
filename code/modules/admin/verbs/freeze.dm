////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//////Freeze Mob/Mech Verb -- Ported from NSS Pheonix (Unbound Travels)/////////
////////////////////////////////////////////////////////////////////////////////
//////Allows admin's to right click on any mob/mech and freeze them in place.///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
GLOBAL_LIST_EMPTY(frozen_atom_list)

/client/proc/freeze(atom/movable/M)
	set name = "Freeze"
	set category = null

	if(!check_rights(R_ADMIN))
		return

	if(!istype(M))
		return

	if(M in GLOB.frozen_atom_list)
		M.admin_unFreeze(src)
	else
		to_chat(src, "<span class='warning'>This can only be used on mobs or mechs.</span")
		return

///mob freeze procs

/mob/living/var/frozen = null //used for preventing attacks on admin-frozen mobs
/mob/living/var/admin_prev_sleeping = 0 //used for keeping track of previous sleeping value with admin freeze

/mob/living/proc/admin_Freeze(client/admin, skip_overlays = FALSE, mech = null)
	if(istype(admin))
		if(!(src in frozen_atom_list))
			frozen_atom_list += src

			var/obj/effect/overlay/adminoverlay/AO = new
			if(skip_overlays)
				overlays += AO

			anchored = TRUE
			canmove = FALSE
			admin_prev_sleeping = sleeping
			AdjustSleeping(20000)
			frozen = AO

		else
			frozen_atom_list -= src

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
	. = ..(admin)
	if(.)
		adjustHealth(1000) //arbitrary large value
	else
		revive()

/mob/living/simple_animal/var/admin_prev_health = null

/mob/living/simple_animal/admin_Freeze(admin)
	. = ..(admin)
	if(.)
		admin_prev_health = health
		health = 0
	else
		revive()
		overlays.Cut()

//////////////////////////Freeze Mech

/obj/mecha/proc/admin_Freeze(client/admin)
	var/adminomaly = new/obj/effect/overlay/adminoverlay
	if(!frozen)
		frozen = TRUE
		overlays += adminomaly
	else
		frozen = FALSE
		overlays -= adminomaly

	if(occupant)
		occupant.admin_Freeze(admin, mech = name)
	else
		message_admins("<span class='notice'>[key_name_admin(admin)] [frozen ? "froze" : "unfroze"] an empty [name]</span>")
		log_admin("[key_name(admin)] [frozen ? "froze" : "unfroze"] an empty [name]")
