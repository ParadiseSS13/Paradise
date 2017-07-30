/obj/item/weapon/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	req_access = list(access_engine)

	var/list/conf_access = null
	var/one_access = 0 //if set to 1, door would receive req_one_access instead of req_access
	var/last_configurator = null
	var/locked = TRUE
	var/const/max_brain_damage = 60 // Maximum brain damage a mob can have until it can't use the electronics
	toolspeed = 1
	usesound = 'sound/items/Deconstruct.ogg'

/obj/item/weapon/airlock_electronics/attack_self(mob/user)
	if(!ishuman(user) && !isrobot(user))
		return ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= max_brain_damage)
			to_chat(user, "<span class='warning'>You forget how to use \the [src].</span>")
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

/obj/item/weapon/airlock_electronics/Topic(href, href_list)
	..()

	if(usr.incapacitated() || (!ishuman(usr) && !isrobot(usr)))
		return 1

	if(href_list["close"])
		usr << browse(null, "window=airlock")
		return

	if(href_list["login"])
		if(allowed(usr))
			locked = FALSE
			last_configurator = usr.name

	if(locked)
		return

	if(href_list["logout"])
		locked = TRUE

	if(href_list["one_access"])
		one_access = !one_access

	if(href_list["access"])
		toggle_access(href_list["access"])

	attack_self(usr)

/obj/item/weapon/airlock_electronics/proc/toggle_access(var/access)
	if(access == "all")
		conf_access = null
	else
		var/req = text2num(access)

		if(conf_access == null)
			conf_access = list()

		if(!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if(!conf_access.len)
				conf_access = null
