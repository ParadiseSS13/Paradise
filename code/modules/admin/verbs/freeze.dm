////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//////Freeze Mob/Mech Verb -- Ported from NSS Pheonix (Unbound Travels)/////////
////////////////////////////////////////////////////////////////////////////////
//////Allows admin's to right click on any mob/mech and freeze them in place.///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
var/global/list/frozen_mob_list = list()
/client/proc/freeze(var/mob/living/M as mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Freeze"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(M))
		return

	if(M in frozen_mob_list)
		M.admin_unFreeze(src)
	else
		M.admin_Freeze(src)

///mob freeze procs

/mob/living/var/frozen = null //used for preventing attacks on admin-frozen mobs
/mob/living/var/admin_prev_sleeping = 0 //used for keeping track of previous sleeping value with admin freeze

/mob/living/proc/admin_Freeze(var/client/admin, skip_overlays = FALSE)
	if(istype(admin))
		to_chat(src, "<b><font color= red>You have been frozen by [key_name(admin)]</b></font>")
		message_admins("<span class='notice'>[key_name_admin(admin)]</span> froze [key_name_admin(src)]")
		log_admin("[key_name(admin)] froze [key_name(src)]")

	var/obj/effect/overlay/adminoverlay/AO = new
	if(skip_overlays)
		src.overlays += AO

	anchored = 1
	frozen = AO
	admin_prev_sleeping = sleeping
	AdjustSleeping(20000)
	if(!(src in frozen_mob_list))
		frozen_mob_list += src

/mob/living/proc/admin_unFreeze(var/client/admin, skip_overlays = FALSE)
	if(istype(admin))
		to_chat(src, "<b><font color= red>You have been unfrozen by [key_name(admin)]</b></font>")
		message_admins("<span class='notice'>[key_name_admin(admin)] unfroze [key_name_admin(src)]</span>")
		log_admin("[key_name(admin)] unfroze [key_name(src)]")

	anchored = 0
	if(skip_overlays)
		overlays -= frozen
	frozen = null
	SetSleeping(admin_prev_sleeping)
	admin_prev_sleeping = null
	if(src in frozen_mob_list)
		frozen_mob_list -= src

	update_icons()


/mob/living/carbon/slime/admin_Freeze(admin)
	..(admin)
	adjustToxLoss(1010101010) //arbitrary large value

/mob/living/carbon/slime/admin_unFreeze(admin)
	..(admin)
	adjustToxLoss(-1010101010)
	stat = 0
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

/client/proc/freezemecha(var/obj/mecha/O as obj in GLOB.mechas_list)
	set category = "Admin"
	set name = "Freeze Mech"

	if(!check_rights(R_ADMIN))
		return

	var/obj/mecha/M = O
	if(!istype(M,/obj/mecha))
		to_chat(src, "<span class='danger'>This can only be used on mechs!</span>")
		return
	else
		if(usr)
			if(usr.client)
				if(usr.client.holder)
					var/adminomaly = new/obj/effect/overlay/adminoverlay
					if(M.can_move == 1)
						M.can_move = 0
						M.overlays += adminomaly
						if(M.occupant)
							to_chat(M.occupant, "<b><font color= red>You have been frozen by <a href='?priv_msg=[usr.client.UID()]'>[key]</a></b></font>")
							message_admins("<span class='notice'>[key_name_admin(usr)] froze [key_name(M.occupant)] in a [M.name]</span>")
							log_admin("[key_name(usr)] froze [key_name(M.occupant)] in a [M.name]")
						else
							message_admins("<span class='notice'>[key_name_admin(usr)] froze an empty [M.name]</span>")
							log_admin("[key_name(usr)] froze an empty [M.name]")
					else if(M.can_move == 0)
						M.can_move = 1
						M.overlays -= adminomaly
						if(M.occupant)
							to_chat(M.occupant, "<b><font color= red>You have been unfrozen by <a href='?priv_msg=[usr.client.UID()]'>[key]</a></b></font>")
							message_admins("<span class='notice'>[key_name_admin(usr)] unfroze [key_name(M.occupant)] in a [M.name]</span>")
							log_admin("[key_name(usr)] unfroze [key_name(M.occupant)] in a [M.name]")
						else
							message_admins("<span class='notice'>[key_name_admin(usr)] unfroze an empty [M.name]</span>")
							log_admin("[key_name(usr)] unfroze an empty [M.name]")
