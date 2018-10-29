/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "point claim console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 0
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/laborstacker/machine = null
	var/machinedir = SOUTH
	var/obj/item/card/id/prisoner/inserted_id
	var/obj/machinery/door/airlock/release_door
	var/door_tag = "prisonshuttle"
	var/use_release_door = 0
	var/obj/item/radio/intercom/announcer


/obj/machinery/mineral/labor_claim_console/New()
	..()
	announcer = new /obj/item/radio/intercom(null)
	announcer.config(list("Security" = 0))

	spawn(7)
		src.machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
		var/t
		for(var/obj/machinery/door/airlock/d in range(5,src))
			t = d.id_tag
			if(t == src.door_tag)
				src.release_door = d
		if(machine && (release_door || !use_release_door))
			machine.CONSOLE = src
		else
			qdel(src)

/obj/machinery/mineral/labor_claim_console/proc/check_auth()
	if(emagged) return 1 //Shuttle is emagged, let any ol' person through
	return (istype(inserted_id) && inserted_id.points >= inserted_id.goal) //Otherwise, only let them out if the prisoner's reached his quota.


/obj/machinery/mineral/labor_claim_console/attack_hand(user as mob)
	var/dat
	dat += text("<b>Point Claim Console</b><br><br>")
	if(emagged) //Shit's broken
		dat += text("<b>QU&#t0A In%aL*D</b><br>")
	else if(istype(inserted_id)) //There's an ID in there.
		dat += text("ID: [inserted_id.registered_name] <A href='?src=[UID()];choice=eject'>Eject ID.</A><br>")
		dat += text("Points Collected:[inserted_id.points]<br>")
		dat += text("Point Quota: [inserted_id.goal] - Reach your quota to earn your release<br>")
		dat += text("Unclaimed Collection Points: [machine.points].  <A href='?src=[UID()];choice=claim'>Claim points.</A><br>")
	else	//No ID in sight.  Complain about it.
		dat += text("No ID inserted.  <A href='?src=[UID()];choice=insert'>Insert ID.</A><br>")
	if(check_auth())
		dat += text("<A href='?src=[UID()];choice=station'>Proceed to station.</A><br>")
		if(use_release_door)
			dat += text("<A href='?src=[UID()];choice=release'>Open release door.</A><br>")
	if(machine)
		dat += text("<HR><b>Mineral Value List:</b><BR>[machine.get_ore_values()]")


	user << browse("[dat]", "window=console_stacking_machine")


/obj/machinery/mineral/labor_claim_console/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/card/id))
		return attack_hand(user)
	..()

/obj/machinery/mineral/labor_claim_console/emag_act(user as mob)
	emag(user)

/obj/machinery/mineral/labor_claim_console/proc/emag(mob/user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='warning'>PZZTTPFFFT</span>")



/obj/machinery/mineral/labor_claim_console/Topic(href, href_list)
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["choice"])
		if(istype(inserted_id)) //Sanity check against href spoofs
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
			if(href_list["choice"] == "claim")
				inserted_id.points += machine.points
				machine.points = 0
				to_chat(src, "Points transferred.")
		else if(href_list["choice"] == "insert")
			var/obj/item/card/id/prisoner/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else
				to_chat(usr, "<span class='warning'>Invalid ID.</span>")
		if(check_auth()) //Sanity check against hef spoofs
			if(href_list["choice"] == "station")
				if(!alone_in_area(get_area(src), usr))
					to_chat(usr, "<span class='warning'>Prisoners are only allowed to be released while alone.</span>")
				else
					switch(SSshuttle.moveShuttle("laborcamp","laborcamp_home"))
						if(1)
							to_chat(usr, "<span class='notice'>Shuttle not found</span>")
						if(2)
							to_chat(usr, "<span class='notice'>Shuttle already at station</span>")
						if(3)
							to_chat(usr, "<span class='notice'>No permission to dock could be granted.</span>")
						else
							var/message = "[inserted_id.registered_name] has returned to the station. Minerals and Prisoner ID card ready for retrieval."
							announcer.autosay(message, "Labor Camp Controller", "Security")
							to_chat(usr, "<span class='notice'>Shuttle received message and will be sent shortly.</span>")

			if(href_list["choice"] == "release")
				if(alone_in_area(get_area(loc), usr))
					var/obj/docking_port/stationary/S = SSshuttle.getDock("laborcamp_home")
					if(S && S.get_docked())
						if(release_door && release_door.density)
							release_door.open()
					else
						to_chat(usr, "<span class='warning'>Prisoners can only be released while docked with the station.</span>")
				else
					to_chat(usr, "<span class='warning'>Prisoners are only allowed to be released while alone.</span>")

		src.updateUsrDialog()
	return


/**********************Prisoner Collection Unit**************************/


/obj/machinery/mineral/stacking_machine/laborstacker
	var/points = 0 //The unclaimed value of ore stacked.  Value for each ore loosely relative to its rarity.
	var/list/ore_values = list(("glass" = 1), ("metal" = 2), ("solid plasma" = 20), ("plasteel" = 23), ("reinforced glass" = 4), ("gold" = 20), ("silver" = 20), ("uranium" = 20), ("diamond" = 25), ("bananium" = 50), ("tranquillite" = 50))

/obj/machinery/mineral/stacking_machine/laborstacker/proc/get_ore_values()
	var/dat = "<table border='0' width='200'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/inp)
	if(istype(inp))
		var/n = inp.name
		var/a = inp.amount
		if(n in ore_values)
			points += ore_values[n] * a
	..()


/**********************Point Lookup Console**************************/
/obj/machinery/mineral/labor_points_checker
	name = "points checking console"
	desc = "A console used by prisoners to check the progress on their quotas. Simply swipe a prisoner ID."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 0
	anchored = 1

/obj/machinery/mineral/labor_points_checker/attack_hand(mob/user)
	user.examine(src)

/obj/machinery/mineral/labor_points_checker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/card/id))
		if(istype(I, /obj/item/card/id/prisoner))
			var/obj/item/card/id/prisoner/prisoner_id = I
			to_chat(user, "<span class='notice'><B>ID: [prisoner_id.registered_name]</B></span>")
			to_chat(user, "<span class='notice'>Points Collected:[prisoner_id.points]</span>")
			to_chat(user, "<span class='notice'>Point Quota: [prisoner_id.goal]</span>")
			to_chat(user, "<span class='notice'>Collect points by bringing smelted minerals to the Labor Shuttle stacking machine. Reach your quota to earn your release.</span>")
		else
			to_chat(user, "<span class='warning'>Error: Invalid ID</span>")
		return
	..()
