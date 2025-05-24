/client/proc/cmd_admin_offer_control(mob/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Offer Control To Ghosts"
	set category = null

	if(!check_rights(R_ADMIN))
		return

	if(!mob)
		return
	if(!istype(M))
		alert("This can only be used on instances of type /mob")
		return
	offer_control(M)
