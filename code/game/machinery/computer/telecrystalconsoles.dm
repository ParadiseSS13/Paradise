#define NUKESCALINGMODIFIER 1

var/list/possible_uplinker_IDs = list("Alfa","Bravo","Charlie","Delta","Echo","Foxtrot","Zero", "Niner")


/obj/machinery/computer/telecrystals
	name = "\improper Telecrystal assignment station"
	desc = "A device used to manage telecrystals during group operations. You shouldn't be looking at this particular one..."

/////////////////////////////////////////////
/obj/machinery/computer/telecrystals/uplinker
	name = "\improper Telecrystal upload/recieve station"
	desc = "A device used to manage telecrystals during group operations. To use, simply insert your uplink. With your uplink installed \
	you can upload your telecrystals to the group's pool using the console, or be assigned additional telecrystals by your lieutenant."
	icon_state = "tcstation"
	icon_keyboard = "tcstation_key"
	icon_screen = "syndie"
	var/obj/item/uplinkholder = null
	var/obj/machinery/computer/telecrystals/boss/linkedboss = null

/obj/machinery/computer/telecrystals/uplinker/New()
	..()

	var/ID
	if(possible_uplinker_IDs.len)
		ID = pick(possible_uplinker_IDs)
		possible_uplinker_IDs -= ID
		name = "[name] [ID]"
	else
		name = "[name] [rand(1,999)]"


/obj/machinery/computer/telecrystals/uplinker/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item))

		if(uplinkholder)
			user << "<span class='notice'>The [src] already has an uplink in it.</span>"
			return

		if(O.hidden_uplink)
			var/obj/item/P = user.get_active_hand()
			user.drop_item()
			uplinkholder = P
			P.loc = src
			P.add_fingerprint(user)
			update_icon()
			updateUsrDialog()
		else
			user << "<span class='notice'>The [O] doesn't appear to be an uplink...</span>"



/obj/machinery/computer/telecrystals/uplinker/update_icon()
	overlays.Cut()
	..()
	if(uplinkholder)
		overlays += "[initial(icon_state)]-closed"


/obj/machinery/computer/telecrystals/uplinker/proc/ejectuplink()
	if(uplinkholder)
		uplinkholder.loc = get_turf(src.loc)
		uplinkholder = null
		update_icon()

/obj/machinery/computer/telecrystals/uplinker/proc/donateTC(var/amt, var/addLog = 1)
	if(uplinkholder && linkedboss)
		if(amt <= uplinkholder.hidden_uplink.uses)
			uplinkholder.hidden_uplink.uses -= amt
			linkedboss.storedcrystals += amt
			if(addLog)
				linkedboss.logTransfer("[src] donated [amt] telecrystals to [linkedboss].")

/obj/machinery/computer/telecrystals/uplinker/proc/giveTC(var/amt, var/addLog = 1)
	if(uplinkholder && linkedboss)
		if(amt <= linkedboss.storedcrystals)
			uplinkholder.hidden_uplink.uses += amt
			linkedboss.storedcrystals -= amt
			if(addLog)
				linkedboss.logTransfer("[src] recieved [amt] telecrystals from [linkedboss].")

///////

/obj/machinery/computer/telecrystals/uplinker/attack_hand(mob/user as mob)
	if(..())
		return
	src.add_fingerprint(user)
	user.set_machine(src)

	var/dat = ""
	if(linkedboss)
		dat += "[linkedboss] has [linkedboss.storedcrystals] telecrystals available for distribution. <BR><BR>"
	else
		dat += "No linked management consoles detected. Scan for uplink stations using the management console.<BR><BR>"

	if(uplinkholder)
		dat += "[uplinkholder.hidden_uplink.uses] telecrystals remain in this uplink.<BR>"
		if(linkedboss)
			dat += "Donate TC: <a href='byond://?src=\ref[src];donate1=1'>1</a> | <a href='byond://?src=\ref[src];donate5=1'>5</a>"
		dat += "<br><a href='byond://?src=\ref[src];eject=1'>Eject Uplink</a>"


	var/datum/browser/popup = new(user, "computer", "Telecrystal Upload/Recieve Station", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/telecrystals/uplinker/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["donate1"])
		donateTC(1)

	if(href_list["donate5"])
		donateTC(5)

	if(href_list["eject"])
		ejectuplink()

	src.updateUsrDialog()


/////////////////////////////////////////
/obj/machinery/computer/telecrystals/boss
	name = "team Telecrystal management console"
	desc = "A device used to manage telecrystals during group operations. To use, simply initialize the machine by scanning for nearby uplink stations. \
	Once the consoles are linked up, you can assign any telecrystals amongst your operatives; be they donated by your agents or rationed to the squad \
	based on the danger rating of the mission."
	icon_keyboard = "syndie_key"
	icon_screen = "tcboss"
	var/virgin = 1
	var/scanrange = 10
	var/storedcrystals = 0
	var/list/TCstations = list()
	var/list/transferlog = list()

/obj/machinery/computer/telecrystals/boss/proc/logTransfer(var/logmessage)
	transferlog += ("<b>[worldtime2text()]</b> [logmessage]")

/obj/machinery/computer/telecrystals/boss/proc/scanUplinkers()
	for(var/obj/machinery/computer/telecrystals/uplinker/A in range(scanrange, src.loc))
		if(!A.linkedboss)
			TCstations += A
			A.linkedboss = src
	if(virgin)
		getDangerous()
		virgin = 0

/obj/machinery/computer/telecrystals/boss/proc/getDangerous()//This scales the TC assigned with the round population.
	..()
	var/danger
	danger = player_list.len
	while(!IsMultiple(++danger,10))//Just round up to the nearest multiple of ten.
	scaleTC(danger)

/obj/machinery/computer/telecrystals/boss/proc/scaleTC(var/amt)//Its own proc, since it'll probably need a lot of tweaks for balance, use a fancier algorhithm, etc.
	storedcrystals += amt * NUKESCALINGMODIFIER

/////////

/obj/machinery/computer/telecrystals/boss/attack_hand(var/mob/user as mob)
	if(..())
		return
	src.add_fingerprint(user)
	user.set_machine(src)


	var/dat = ""
	dat += "<a href='byond://?src=\ref[src];scan=1'>Scan for TC stations.</a><BR>"
	dat += "This [src] has [storedcrystals] telecrystals available for distribution. <BR>"
	dat += "<BR><BR>"


	for(var/obj/machinery/computer/telecrystals/uplinker/A in TCstations)
		dat += "[A.name] | "
		if(A.uplinkholder)
			dat += "[A.uplinkholder.hidden_uplink.uses] telecrystals."
		if(storedcrystals)
			dat+= "<BR>Add TC: <a href ='?src=\ref[src];give1=\ref[A]'>1</a> | <a href ='?src=\ref[src];give5=\ref[A]'>5</a>"
		dat += "<BR>"

	if(TCstations.len)
		dat += "<BR><BR><a href='byond://?src=\ref[src];distrib=1'>Evenly distribute remaining TC.</a><BR><BR>"


	for(var/entry in transferlog)
		dat += "<small>[entry]</small><BR>"


	var/datum/browser/popup = new(user, "computer", "Team Telecrystal Management Console", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/telecrystals/boss/Topic(href, href_list)
	if(..())
		return

	if(href_list["scan"])
		scanUplinkers()

	if(href_list["give1"])
		var/obj/machinery/computer/telecrystals/uplinker/A = locate(href_list["give1"])
		A.giveTC(1)

	if(href_list["give5"])
		var/obj/machinery/computer/telecrystals/uplinker/A = locate(href_list["give5"])
		A.giveTC(5)

	if(href_list["distrib"])
		var/sanity = 0
		while(storedcrystals && sanity < 100)
			for(var/obj/machinery/computer/telecrystals/uplinker/A in TCstations)
				A.giveTC(1,0)
			sanity++
		logTransfer("[src] evenly distributed telecrystals.")

	src.updateUsrDialog()
	return

#undef NUKESCALINGMODIFIER