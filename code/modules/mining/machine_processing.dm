/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
		if(machine)
			machine.CONSOLE = src
		else
			qdel(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(user as mob)

	var/dat = "<b>Smelter control console</b><br><br>"
	//iron
	if(machine.ore_iron || machine.ore_glass || machine.ore_plasma || machine.ore_uranium || machine.ore_gold || machine.ore_silver || machine.ore_diamond || machine.ore_clown || machine.ore_mime || machine.ore_adamantine)
		if(machine.ore_iron)
			if(machine.selected_iron==1)
				dat += text("<A href='?src=[UID()];sel_iron=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_iron=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Iron: [machine.ore_iron]<br>")
		else
			machine.selected_iron = 0

		//sand - glass
		if(machine.ore_glass)
			if(machine.selected_glass==1)
				dat += text("<A href='?src=[UID()];sel_glass=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_glass=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Sand: [machine.ore_glass]<br>")
		else
			machine.selected_glass = 0

		//plasma
		if(machine.ore_plasma)
			if(machine.selected_plasma==1)
				dat += text("<A href='?src=[UID()];sel_plasma=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_plasma=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Plasma: [machine.ore_plasma]<br>")
		else
			machine.selected_plasma = 0

		//uranium
		if(machine.ore_uranium)
			if(machine.selected_uranium==1)
				dat += text("<A href='?src=[UID()];sel_uranium=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_uranium=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Uranium: [machine.ore_uranium]<br>")
		else
			machine.selected_uranium = 0

		//gold
		if(machine.ore_gold)
			if(machine.selected_gold==1)
				dat += text("<A href='?src=[UID()];sel_gold=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_gold=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Gold: [machine.ore_gold]<br>")
		else
			machine.selected_gold = 0

		//silver
		if(machine.ore_silver)
			if(machine.selected_silver==1)
				dat += text("<A href='?src=[UID()];sel_silver=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_silver=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Silver: [machine.ore_silver]<br>")
		else
			machine.selected_silver = 0

		//diamond
		if(machine.ore_diamond)
			if(machine.selected_diamond==1)
				dat += text("<A href='?src=[UID()];sel_diamond=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_diamond=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Diamond: [machine.ore_diamond]<br>")
		else
			machine.selected_diamond = 0

		//bananium
		if(machine.ore_clown)
			if(machine.selected_clown==1)
				dat += text("<A href='?src=[UID()];sel_clown=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_clown=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Bananium: [machine.ore_clown]<br>")
		else
			machine.selected_clown = 0

		//tranquillite
		if(machine.ore_mime)
			if(machine.selected_mime==1)
				dat += text("<A href='?src=[UID()];sel_mime=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=[UID()];sel_mime=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Tranquillite: [machine.ore_mime]<br>")
		else
			machine.selected_mime = 0


		//On or off
		dat += text("Machine is currently ")
		if(machine.on==1)
			dat += text("<A href='?src=[UID()];set_on=off'>On</A> ")
		else
			dat += text("<A href='?src=[UID()];set_on=on'>Off</A> ")
	else
		dat+="---No Materials Loaded---"


	user << browse("[dat]", "window=console_processing_unit")

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["sel_iron"])
		if(href_list["sel_iron"] == "yes")
			machine.selected_iron = 1
		else
			machine.selected_iron = 0
	if(href_list["sel_glass"])
		if(href_list["sel_glass"] == "yes")
			machine.selected_glass = 1
		else
			machine.selected_glass = 0
	if(href_list["sel_plasma"])
		if(href_list["sel_plasma"] == "yes")
			machine.selected_plasma = 1
		else
			machine.selected_plasma = 0
	if(href_list["sel_uranium"])
		if(href_list["sel_uranium"] == "yes")
			machine.selected_uranium = 1
		else
			machine.selected_uranium = 0
	if(href_list["sel_gold"])
		if(href_list["sel_gold"] == "yes")
			machine.selected_gold = 1
		else
			machine.selected_gold = 0
	if(href_list["sel_silver"])
		if(href_list["sel_silver"] == "yes")
			machine.selected_silver = 1
		else
			machine.selected_silver = 0
	if(href_list["sel_diamond"])
		if(href_list["sel_diamond"] == "yes")
			machine.selected_diamond = 1
		else
			machine.selected_diamond = 0
	if(href_list["sel_clown"])
		if(href_list["sel_clown"] == "yes")
			machine.selected_clown = 1
		else
			machine.selected_clown = 0
	if(href_list["sel_mime"])
		if(href_list["sel_mime"] == "yes")
			machine.selected_mime = 1
		else
			machine.selected_mime = 0
	if(href_list["set_on"])
		if(href_list["set_on"] == "on")
			machine.on = 1
		else
			machine.on = 0
	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/CONSOLE = null
	var/ore_gold = 0
	var/ore_silver = 0
	var/ore_diamond = 0
	var/ore_glass = 0
	var/ore_plasma = 0
	var/ore_uranium = 0
	var/ore_iron = 0
	var/ore_clown = 0
	var/ore_mime = 0
	var/ore_adamantine = 0
	var/selected_gold = 0
	var/selected_silver = 0
	var/selected_diamond = 0
	var/selected_glass = 0
	var/selected_plasma = 0
	var/selected_uranium = 0
	var/selected_iron = 0
	var/selected_clown = 0
	var/selected_mime = 0
	var/on = 0 //0 = off, 1 =... oh you know!

/obj/machinery/mineral/processing_unit/process()
	var/i
	for(i = 0; i < 10; i++)
		if(on)
			if(selected_glass == 1 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_mime == 0)
				if(ore_glass > 0)
					ore_glass--;
					generate_mineral(/obj/item/stack/sheet/glass)
				else
					on = 0
				continue
			if(selected_glass == 1 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0 && selected_mime == 0)
				if(ore_glass > 0 && ore_iron > 0)
					ore_glass--;
					ore_iron--;
					generate_mineral(/obj/item/stack/sheet/rglass)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 1 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_mime == 0)
				if(ore_gold > 0)
					ore_gold--;
					generate_mineral(/obj/item/stack/sheet/mineral/gold)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 1 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_mime == 0)
				if(ore_silver > 0)
					ore_silver--;
					generate_mineral(/obj/item/stack/sheet/mineral/silver)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 1 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_mime == 0)
				if(ore_diamond > 0)
					ore_diamond--;
					generate_mineral(/obj/item/stack/sheet/mineral/diamond)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_mime == 0)
				if(ore_plasma > 0)
					ore_plasma--;
					generate_mineral(/obj/item/stack/sheet/mineral/plasma)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 1 && selected_iron == 0 && selected_clown == 0 && selected_mime == 0)
				if(ore_uranium > 0)
					ore_uranium--;
					generate_mineral(/obj/item/stack/sheet/mineral/uranium)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0 && selected_mime == 0)
				if(ore_iron > 0)
					ore_iron--;
					generate_mineral(/obj/item/stack/sheet/metal)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0 && selected_mime == 0)
				if(ore_iron > 0 && ore_plasma > 0)
					ore_iron--;
					ore_plasma--;
					generate_mineral(/obj/item/stack/sheet/plasteel)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 1 && selected_mime == 0)
				if(ore_clown > 0)
					ore_clown--;
					generate_mineral(/obj/item/stack/sheet/mineral/bananium)
				else
					on = 0
				continue
			if(selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0 && selected_mime == 1)
				if(ore_mime > 0)
					ore_mime--;
					generate_mineral(/obj/item/stack/sheet/mineral/tranquillite)
				else
					on = 0
				continue


			//if a non valid combination is selected

			var/b = 1 //this part checks if all required ores are available

			if(!(selected_gold || selected_silver ||selected_diamond || selected_uranium | selected_plasma || selected_iron || selected_iron))
				b = 0

			if(selected_gold == 1)
				if(ore_gold <= 0)
					b = 0
			if(selected_silver == 1)
				if(ore_silver <= 0)
					b = 0
			if(selected_diamond == 1)
				if(ore_diamond <= 0)
					b = 0
			if(selected_uranium == 1)
				if(ore_uranium <= 0)
					b = 0
			if(selected_plasma == 1)
				if(ore_plasma <= 0)
					b = 0
			if(selected_iron == 1)
				if(ore_iron <= 0)
					b = 0
			if(selected_glass == 1)
				if(ore_glass <= 0)
					b = 0
			if(selected_clown == 1)
				if(ore_clown <= 0)
					b = 0
			if(selected_mime == 1)
				if(ore_mime <= 0)
					b = 0

			if(b) //if they are, deduct one from each, produce slag and shut the machine off
				if(selected_gold == 1)
					ore_gold--
				if(selected_silver == 1)
					ore_silver--
				if(selected_diamond == 1)
					ore_diamond--
				if(selected_uranium == 1)
					ore_uranium--
				if(selected_plasma == 1)
					ore_plasma--
				if(selected_iron == 1)
					ore_iron--
				if(selected_clown == 1)
					ore_clown--
				if(selected_mime == 1)
					ore_mime--
				generate_mineral(/obj/item/weapon/ore/slag)
				on = 0
			else
				on = 0
				break
			break
		else
			break
	var/turf/T = get_step(src,input_dir)
	if(T)
		var/n = 0
		for(var/obj/item/O in T)
			n++
			if(n>10)
				break
			if(istype(O,/obj/item/weapon/ore/iron))
				ore_iron++;
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/glass))
				ore_glass++;
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/diamond))
				ore_diamond++;
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/plasma))
				ore_plasma++
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/gold))
				ore_gold++
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/silver))
				ore_silver++
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/uranium))
				ore_uranium++
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/bananium))
				ore_clown++
				O.loc = null
				continue
			if(istype(O,/obj/item/weapon/ore/tranquillite))
				ore_mime++
				O.loc = null
				continue
			unload_mineral(O)

/obj/machinery/mineral/processing_unit/proc/generate_mineral(var/P)
	var/O = new P(src)
	unload_mineral(O)
