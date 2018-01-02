
/obj/machinery/computer/syndicate_depot
	name = "depot control computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "syndishuttle"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(access_syndicate)

/obj/machinery/computer/syndicate_depot/attack_ai(var/mob/user as mob)
	to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
	return 1

/obj/machinery/computer/syndicate_depot/attackby(I as obj, user as mob, params)
	if(istype(I,/obj/item/weapon/card/emag))
		to_chat(user, "<span class='notice'>The electronic systems in this console is far too advanced for your primitive hacking peripherals.</span>")
	else
		return attack_hand(user)

/obj/machinery/computer/syndicate_depot/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return

	if(..())
		return

	// functions here
	return

/obj/machinery/computer/syndicate_depot/proc/summon()
	myArea.call_backup(src)

/obj/machinery/computer/syndicate_depot/Destroy()
	summon()
	..()

/obj/machinery/computer/syndicate_depot/set_broken()
	summon()
	..()