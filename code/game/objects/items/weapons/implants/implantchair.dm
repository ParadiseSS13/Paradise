/obj/machinery/implantchair
	name = "mindshield implanter"
	desc = "Used to implant occupants with mindshield implants."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = TRUE
	opacity = FALSE
	anchored = TRUE

	var/ready = TRUE
	var/malfunction = 0
	var/list/obj/item/implant/mindshield/implant_list = list()
	var/max_implants = 5
	var/injection_cooldown = 600
	var/replenish_cooldown = 6000
	var/replenishing = 0
	var/mob/living/carbon/occupant
	var/injecting = FALSE

/obj/machinery/implantchair/Initialize(mapload)
	. = ..()
	add_implants()


/obj/machinery/implantchair/attack_hand(mob/user)
	user.set_machine(src)
	var/health_text = ""
	if(occupant)
		if(occupant.health <= -100)
			health_text = "<FONT color=red>Dead</FONT>"
		else if(occupant.health < 0)
			health_text = "<FONT color=red>[round(occupant.health, 0.1)]</FONT>"
		else
			health_text = "[round(occupant.health,0.1)]"

	var/dat ="<B>Implanter Status</B><BR>"

	dat +="<B>Current occupant:</B> [occupant ? "<BR>Name: [occupant]<BR>Health: [health_text]<BR>" : "<FONT color=red>None</FONT>"]<BR>"
	dat += "<B>Implants:</B> [length(implant_list) ? "[length(implant_list)]" : "<A href='?src=[UID()];replenish=1'>Replenish</A>"]<BR>"
	if(occupant)
		dat += "[ready ? "<A href='?src=[UID()];implant=1'>Implant</A>" : "Recharging"]<BR>"
	user.set_machine(src)
	user << browse(dat, "window=implant")
	onclose(user, "implant")


/obj/machinery/implantchair/Topic(href, href_list)
	if(..())
		return
	if(href_list["implant"])
		if(occupant)
			injecting = TRUE
			go_out()
			ready = FALSE
			spawn(injection_cooldown)
				ready = TRUE

	if(href_list["replenish"])
		ready = FALSE
		spawn(replenish_cooldown)
			add_implants()
			ready = TRUE

	updateUsrDialog()
	return


/obj/machinery/implantchair/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ismob(G.affecting))
			return
		var/mob/M = G.affecting
		if(M.has_buckled_mobs())
			to_chat(user, "[M] will not fit into [src] because [M.p_they()] [M.p_have()] a slime latched onto [M.p_their()] head.")
			return
		if(put_mob(M))
			qdel(G)
	updateUsrDialog()
	return


/obj/machinery/implantchair/proc/go_out(mob/M)
	if(!(occupant))
		return
	if(M == occupant) // so that the guy inside can't eject himself -Agouri
		return
	occupant.forceMove(loc)
	if(injecting)
		implant(occupant)
		injecting = FALSE
	occupant = null
	icon_state = "implantchair"
	return


/obj/machinery/implantchair/proc/put_mob(mob/living/carbon/M)
	if(!iscarbon(M))
		to_chat(usr, "<span class='warning'>[src] cannot hold this!</span>")
		return
	if(occupant)
		to_chat(usr, "<span class='warning'>[src] is already occupied!</span>")
		return
	M.stop_pulling()
	M.forceMove(src)
	occupant = M
	add_fingerprint(usr)
	icon_state = "implantchair_on"
	return TRUE


/obj/machinery/implantchair/proc/implant(mob/M)
	if(!iscarbon(M))
		return
	if(!length(implant_list))
		return
	for(var/obj/item/implant/mindshield/imp in implant_list)
		if(!imp)
			continue
		if(istype(imp, /obj/item/implant/mindshield))
			visible_message("<span class='warning'>[src] implants [M].</span>")

			if(imp.implant(M))
				implant_list -= imp
			break


/obj/machinery/implantchair/proc/add_implants()
	for(var/i in 1 to max_implants)
		var/obj/item/implant/mindshield/new_implant = new /obj/item/implant/mindshield(src)
		implant_list += new_implant

/obj/machinery/implantchair/verb/get_out()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	go_out(usr)
	add_fingerprint(usr)
	return

/obj/machinery/implantchair/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || stat & (NOPOWER|BROKEN))
		return
	put_mob(usr)
	return
