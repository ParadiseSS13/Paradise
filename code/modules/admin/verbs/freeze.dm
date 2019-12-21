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

	if(M in GLOB.frozen_mob_list)
		M.admin_unFreeze(src)
	else
		M.admin_Freeze(src)

///mob freeze procs

/mob/living/var/frozen = null //used for preventing attacks on admin-frozen mobs
/mob/living/var/admin_prev_sleeping = 0 //used for keeping track of previous sleeping value with admin freeze

/mob/living/proc/admin_Freeze(client/admin, skip_overlays = FALSE, mech = null)
	if(istype(admin))
		to_chat(src, "<b><font color= red>You have been frozen by [admin]</b></font>")
		message_admins("<span class='notice'>[key_name_admin(admin)] froze [key_name_admin(src)] [mech ? "in a [mech]" : ""]</span>")
		log_admin("[key_name(admin)] froze [key_name(src)] [mech ? "in a [mech]" : ""]")

	var/obj/effect/overlay/adminoverlay/AO = new
	if(skip_overlays)
		overlays += AO

	anchored = TRUE
	canmove = FALSE
	admin_prev_sleeping = sleeping
	AdjustSleeping(20000)
	frozen = AO
	if(!(src in GLOB.frozen_mob_list))
		GLOB.frozen_mob_list += src

/mob/living/proc/admin_unFreeze(client/admin, skip_overlays = FALSE, mech = null)
	if(istype(admin))
		to_chat(src, "<b><font color= red>You have been unfrozen by [admin]</b></font>")
		message_admins("<span class='notice'>[key_name_admin(admin)] unfroze [key_name_admin(src)] [mech ? "in a [mech]" : ""]</span>")
		log_admin("[key_name(admin)] unfroze [key_name(src)] [mech ? "in a [mech]" : ""]")

	if(skip_overlays)
		overlays -= frozen

	anchored = FALSE
	canmove = TRUE
	frozen = null
	SetSleeping(admin_prev_sleeping)
	admin_prev_sleeping = null
	if(src in GLOB.frozen_mob_list)
		GLOB.frozen_mob_list -= src

	update_icons()


/mob/living/simple_animal/slime/admin_Freeze(admin)
	..(admin)
	adjustHealth(1000) //arbitrary large value

/mob/living/simple_animal/slime/admin_unFreeze(admin)
	..(admin)
	revive()


/mob/living/simple_animal/var/admin_prev_health = null

/mob/living/simple_animal/admin_Freeze(admin)
	..(admin)
	admin_prev_health = health
	health = 0

/mob/living/simple_animal/admin_unFreeze(admin)
	..(admin)
	revive()
	overlays.Cut()

//////////////////////////Freeze Mech

/client/proc/freezemecha(obj/mecha/O in GLOB.mechas_list)
	set name = "Freeze Mech"
	set category = null

	if(!check_rights(R_ADMIN))
		return

	var/obj/mecha/M = O
	if(!istype(M,/obj/mecha))
		to_chat(src, "<span class='danger'>This can only be used on mechs!</span>")
		return

	else if(usr?.client?.holder)
		var/adminomaly = new/obj/effect/overlay/adminoverlay
		if(M.frozen)
			M.frozen = FALSE
			M.overlays -= adminomaly
		else
			M.frozen = TRUE
			M.overlays += adminomaly

		if(M.occupant)
			if(M.occupant.frozen)
				M.occupant.admin_unFreeze(src, mech = M.name)
			else
				M.occupant.admin_Freeze(src, mech = M.name)
		else
			message_admins("<span class='notice'>[key_name_admin(usr)] [M.frozen ? "froze" : "unfroze"] an empty [M.name]</span>")
			log_admin("[key_name(usr)] [M.frozen ? "froze" : "unfroze"] an empty [M.name]")
