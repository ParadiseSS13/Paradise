
/obj/machinery/computer/syndicate_depot
	name = "depot door control computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "syndishuttle"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(access_syndicate)
	var/activated = FALSE

/obj/machinery/computer/syndicate_depot/attack_ai(var/mob/user as mob)
	to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
	return 1

/obj/machinery/computer/syndicate_depot/emp_act(severity)
	return

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

	user.set_machine(src)

	var/dat = get_menu()

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/syndicate_depot/Topic(href, href_list)
	if(..())
		return 1

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	if(href_list["activate"])
		activate(usr)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/syndicate_depot/proc/summon()
	var/area/syndicate_depot/A = myArea
	if(A)
		A.call_backup(src)

/obj/machinery/computer/syndicate_depot/Destroy()
	summon()
	..()

/obj/machinery/computer/syndicate_depot/set_broken()
	summon()
	..()

/obj/machinery/computer/syndicate_depot/proc/get_menu()
	return {"<B>Syndicate Depot Door Control Computer</B><HR>
	<BR><BR><a href='?src=[UID()];activate=1'>Toggle Door Security</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/proc/activate(var/mob/user)
	var/area/syndicate_depot/D = get_area(src)
	if(D)
		D.toggle_door_locks(src)



/obj/machinery/computer/syndicate_depot/selfdestruct
	name = "reactor control computer"
	req_access = list()
	var/landmark_name = "syndi_depot_reactor"

/obj/machinery/computer/syndicate_depot/selfdestruct/get_menu()
	return {"<B>Syndicate Depot Fission Reactor Control</B><HR>
	<BR><BR><a href='?src=[UID()];activate=1'>Disable Containment Field</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/selfdestruct/activate(var/mob/user)
	if(activated)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return
	activated = TRUE

	playsound(user, 'sound/machines/click.ogg', 20, 1)

	sleep(5)

	playsound(src, 'sound/machines/Alarm.ogg', 100, 0, 0)

	sleep(5)

	var/area/syndicate_depot/D = get_area(src)
	if(D)
		D.activate_lockdown(src)

	sleep(10)

	var/turf/T = get_turf(src)
	var/area/A = get_area(T)
	bombers += "[key_name(user)] has armed a self destruct device using a [name] at [A.name] ([T.x],[T.y],[T.z]"
	log_game("[key_name(user)] has armed a self destruct device using a [name] at [A.name] ([T.x],[T.y],[T.z]")

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == landmark_name)
			explosion(get_turf(L), 20, 30, 40, 50, 1, 1, 40, 0, 1)

