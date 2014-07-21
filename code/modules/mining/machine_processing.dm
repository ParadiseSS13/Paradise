/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1

	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST
	var/show_all_ores = 0

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
		if (machine)
			machine.console = src
		else
			del(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/mineral/processing_unit_console/interact(mob/user)

	if(..())
		return

	if(!allowed(user))
		user << "\red Access denied."
		return

	user.set_machine(src)

	var/dat = "<h1>Ore processor console</h1>"

	dat += "<hr><table>"

	for(var/ore in machine.ores_processing)

		if(!machine.ores_stored[ore] && !show_all_ores) continue

		dat += "<tr><td width = 40><b>[capitalize(ore)]</b></td><td width = 30>[machine.ores_stored[ore]]</td><td width = 100><font color='"
		if(machine.ores_processing[ore])
			switch(machine.ores_processing[ore])
				if(0)
					dat += "red'>not processing"
				if(1)
					dat += "orange'>smelting"
				if(2)
					dat += "blue'>compressing"
				if(3)
					dat += "gray'>alloying"
		else
			dat += "red'>not processing"
		dat += "</font>.</td><td width = 30><a href='?src=\ref[src];toggle_smelting=[ore]'>\[change\]</a></td></tr>"

	dat += "</table><hr>"
	dat += "Currently displaying [show_all_ores ? "all ore types" : "only available ore types"]. <A href='?src=\ref[src];toggle_ores=1'>\[[show_all_ores ? "show less" : "show more"]\]</a></br>"
	dat += "The ore processor is currently <A href='?src=\ref[src];toggle_power=1'>[(machine.active ? "<font color='green'>processing</font>" : "<font color='red'>disabled</font>")]</a>."
	user << browse(dat, "window=processor_console;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["toggle_smelting"])

		var/choice = input("What setting do you wish to use for processing [href_list["toggle_smelting"]]?") as null|anything in list("Smelting","Compressing","Alloying","Nothing")
		if(!choice) return

		switch(choice)
			if("Nothing") choice = 0
			if("Smelting") choice = 1
			if("Compressing") choice = 2
			if("Alloying") choice = 3

		machine.ores_processing[href_list["toggle_smelting"]] = choice

	if(href_list["toggle_power"])

		machine.active = !machine.active

	if(href_list["toggle_ores"])

		show_all_ores = !show_all_ores

	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "material processor" //This isn't actually a goddamn furnace, we're in space and it's processing platinum and flammable phoron...
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1
	luminosity = 3
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/console = null
	var/sheets_per_tick = 10
	var/list/ores_processing[0]
	var/list/ores_stored[0]
	var/list/ore_data[0]
	var/list/alloy_data[0]
	var/active = 0

/obj/machinery/mineral/processing_unit/New()

	..()

	//TODO: Ore and alloy global storage datum.
	for(var/alloytype in typesof(/datum/alloy)-/datum/alloy)
		alloy_data += new alloytype()

	for(var/oretype in typesof(/datum/ore)-/datum/ore)
		var/datum/ore/OD = new oretype()
		ore_data[OD.oretag] = OD
		ores_processing[OD.oretag] = 0
		ores_stored[OD.oretag] = 0

	//Locate our output and input machinery.
	spawn(5)
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		return
	return

/obj/machinery/mineral/processing_unit/process()

	if (!src.output || !src.input) return

	var/list/tick_alloys = list()

	//Grab some more ore to process this tick.
	for(var/i = 0,i<sheets_per_tick,i++)
		var/obj/item/weapon/ore/O = locate() in input.loc
		if(!O) break
		if(!isnull(ores_stored[O.oretag])) ores_stored[O.oretag]++
		O.loc = null

	if(!active)
		return

	//Process our stored ores and spit out sheets.
	var/sheets = 0
	for(var/metal in ores_stored)

		if(sheets >= sheets_per_tick) break

		if(ores_stored[metal] > 0 && ores_processing[metal] != 0)

			var/datum/ore/O = ore_data[metal]

			if(!O) continue

			if(ores_processing[metal] == 3 && O.alloy) //Alloying.

				for(var/datum/alloy/A in alloy_data)

					if(A.metaltag in tick_alloys)
						continue

					tick_alloys += A.metaltag
					var/enough_metal

					if(!isnull(A.requires[metal]) && ores_stored[metal] >= A.requires[metal]) //We have enough of our first metal, we're off to a good start.

						enough_metal = 1

						for(var/needs_metal in A.requires)
							//Check if we're alloying the needed metal and have it stored.
							if(ores_processing[needs_metal] != 3 || ores_stored[needs_metal] < A.requires[needs_metal])
								enough_metal = 0
								break

					if(!enough_metal)
						continue
					else
						var/total
						for(var/needs_metal in A.requires)
							ores_stored[needs_metal] -= A.requires[needs_metal]
							total += A.requires[needs_metal]
							total = max(1,round(total*A.product_mod)) //Always get at least one sheet.
							sheets += total-1

						for(var/i=0,i<total,i++)
							new A.product(output.loc)

			else if(ores_processing[metal] == 2 && O.compresses_to) //Compressing.

				var/can_make = Clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(can_make%2>0) can_make--

				if(!can_make || ores_stored[metal] < 1)
					continue

				for(var/i=0,i<can_make,i+=2)
					ores_stored[metal]-=2
					sheets+=2
					new O.compresses_to(output.loc)

			else if(ores_processing[metal] == 1 && O.smelts_to) //Smelting.

				var/can_make = Clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(!can_make || ores_stored[metal] < 1)
					continue

				for(var/i=0,i<can_make,i++)
					ores_stored[metal]--
					sheets++
					new O.smelts_to(output.loc)
			else
				ores_stored[metal]--
				sheets++
				new /obj/item/weapon/ore/slag(output.loc)
		else
			continue

	console.updateUsrDialog()
