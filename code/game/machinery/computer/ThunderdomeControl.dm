/obj/machinery/computer/ThunderdomeControl
	name = "thunderdome control computer"
	desc = "A computer used to control the thunderdome."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"
	var/area/linkedthunderdome = null
	var/area/tdometarget = null
	var/activetdome = 0
	var/damagedtdome = 0
	var/last_changetdome = 0
	var/thunderdomearea = /area/tdome/arena

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/ThunderdomeControl/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/ThunderdomeControl/attack_hand(var/mob/user as mob)
	if(..())
		return 1

	user.set_machine(src)
	var/dat

	dat += "<B>Thunderdome Control System</B><BR>"
	dat += "<HR>Loaded Programs:<BR>"

	dat += "<A href='?src=[UID()];snowfield=1'>((Snow Field)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];technohell=1'>((Techno Hell)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];placeholder=1'>((Placeholder)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];placeholder2=1'>((Placeholder 2)</font>)</A><BR>"

	dat += "Weapons are live and can kill. Well not the weapons but the morons using them.<BR>"

	var/datum/browser/popup = new(user, "thunderdome_computer", name, 400, 500)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "computer")
	return

/obj/machinery/computer/ThunderdomeControl/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["snowfield"])
		tdometarget = locate(/area/tdome/arena_source)
		if(tdometarget)
			for(var/obj/obj in thunderdomearea)
				qdel(obj) //Clear objects
			tdometarget.copy_contents_to(thunderdomearea)

	else if(href_list["technohell"])
		tdometarget = locate(/area/tdome/arena_source2)
		if(tdometarget)
			for(var/obj/obj in thunderdomearea)
				qdel(obj)
			tdometarget.copy_contents_to(thunderdomearea)

	else if(href_list["placeholder"])
		tdometarget = locate(/area/tdome/arena_source3)
		if(tdometarget)
			for(var/obj/obj in thunderdomearea)
				qdel(obj)
			tdometarget.copy_contents_to(thunderdomearea)

	else if(href_list["placeholder2"])
		tdometarget = locate(/area/tdome/arena_source4)
		if(tdometarget)
			for(var/obj/obj in thunderdomearea)
				qdel(obj)
			tdometarget.copy_contents_to(thunderdomearea)


	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/ThunderdomeControl/attackby(var/obj/item/D as obj, var/mob/user as mob, params)
	return

/obj/machinery/computer/ThunderdomeControl/New()
	..()
	linkedthunderdome = locate(/area/tdome/arena)


/obj/machinery/computer/ThunderdomeControl/proc/checkInteg(var/area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

/obj/machinery/computer/ThunderdomeControl/proc/togglePower(var/toggleOn = 0)

	if(toggleOn)
		activetdome = 1
	else
		activetdome = 0


/obj/machinery/computer/ThunderdomeControl/proc/loadProgram(var/area/A)

	if(world.time < (last_changetdome + 25))
		if(world.time < (last_changetdome + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("<b>ERROR. Recalibrating projection apparatus.</b>")
			last_changetdome = world.time
			return

	last_changetdome = world.time
	activetdome = 1
