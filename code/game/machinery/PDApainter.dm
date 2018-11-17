/obj/machinery/pdapainter
	name = "PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	var/obj/item/pda/storedpda = null
	var/list/colorlist = list()


/obj/machinery/pdapainter/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda)
		overlays += "[initial(icon_state)]-closed"

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/New()
	..()
	var/blocked = list(/obj/item/pda/silicon/ai, /obj/item/pda/silicon/robot, /obj/item/pda/silicon/pai, /obj/item/pda/heads,
						/obj/item/pda/clear, /obj/item/pda/syndicate)

	for(var/P in typesof(/obj/item/pda)-blocked)
		var/obj/item/pda/D = new P

		//D.name = "PDA Style [colorlist.len+1]" //Gotta set the name, otherwise it all comes up as "PDA"
		D.name = D.icon_state //PDAs don't have unique names, but using the sprite names works.

		src.colorlist += D

/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(storedpda)
	return ..()

/obj/machinery/pdapainter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	if(istype(I, /obj/item/pda))
		if(storedpda)
			to_chat(user, "There is already a PDA inside.")
			return
		else
			var/obj/item/pda/P = user.get_active_hand()
			if(istype(P))
				if(user.drop_item())
					storedpda = P
					P.forceMove(src)
					P.add_fingerprint(user)
					update_icon()
	else
		return ..()


/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	if(..())
		return 1

	src.add_fingerprint(user)

	if(storedpda)
		var/obj/item/pda/P
		P = input(user, "Select your color!", "PDA Painting") as null|anything in colorlist
		if(!P)
			return
		if(!in_range(src, user))
			return

		storedpda.icon_state = P.icon_state
		storedpda.desc = P.desc

	else
		to_chat(user, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Eject PDA"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/pdapainter/power_change()
	..()
	update_icon()