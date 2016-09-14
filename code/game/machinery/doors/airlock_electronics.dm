//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/weapon/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2 //It should be tiny! -Agouri
	materials = list(MAT_METAL=50, MAT_GLASS=50)

	req_access = list(access_engine)

	var/list/conf_access = null
	var/one_access = 0 //if set to 1, door would receive req_one_access instead of req_access
	var/last_configurator = null
	var/locked = 1

	attack_self(mob/user as mob)
		if(!ishuman(user) && !istype(user,/mob/living/silicon/robot))
			return ..(user)

		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			return

		var/t1 = text("<B>Access control</B><br>\n")


		if(last_configurator)
			t1 += "Operator: [last_configurator]<br>"

		if(locked)
			t1 += "<a href='?src=[UID()];login=1'>Swipe ID</a><hr>"
		else
			t1 += "<a href='?src=[UID()];logout=1'>Block</a><hr>"

			t1 += "Access requirement is set to "
			t1 += one_access ? "<a style='color: green' href='?src=[UID()];one_access=1'>ONE</a><hr>" : "<a style='color: red' href='?src=[UID()];one_access=1'>ALL</a><hr>"

			t1 += conf_access == null ? "<font color=red>All</font><br>" : "<a href='?src=[UID()];access=all'>All</a><br>"

			t1 += "<br>"

			var/list/accesses = get_all_accesses()
			for(var/acc in accesses)
				var/aname = get_access_desc(acc)

				if(!conf_access || !conf_access.len || !(acc in conf_access))
					t1 += "<a href='?src=[UID()];access=[acc]'>[aname]</a><br>"
				else if(one_access)
					t1 += "<a style='color: green' href='?src=[UID()];access=[acc]'>[aname]</a><br>"
				else
					t1 += "<a style='color: red' href='?src=[UID()];access=[acc]'>[aname]</a><br>"

		t1 += "<p><a href='?src=[UID()];close=1'>Close</a></p>\n"

		var/datum/browser/popup = new(user, "airlock_electronics", name, 400, 400)
		popup.set_content(t1)
		popup.open(0)
		onclose(user, "airlock")

	Topic(href, href_list)
		..()
		if(usr.stat || usr.restrained() || (!ishuman(usr) && !istype(usr,/mob/living/silicon)))
			return
		if(href_list["close"])
			usr << browse(null, "window=airlock")
			return

		if(href_list["login"])
			if(istype(usr,/mob/living/silicon))
				src.locked = 0
				src.last_configurator = usr.name
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/device/pda))
					var/obj/item/device/pda/pda = I
					I = pda.id
				if(I && src.check_access(I))
					src.locked = 0
					src.last_configurator = I:registered_name

		if(locked)
			return

		if(href_list["logout"])
			locked = 1

		if(href_list["one_access"])
			one_access = !one_access

		if(href_list["access"])
			toggle_access(href_list["access"])

		attack_self(usr)

	proc
		toggle_access(var/acc)
			if(acc == "all")
				conf_access = null
			else
				var/req = text2num(acc)

				if(conf_access == null)
					conf_access = list()

				if(!(req in conf_access))
					conf_access += req
				else
					conf_access -= req
					if(!conf_access.len)
						conf_access = null

