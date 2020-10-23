//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/item/loaded_item = null
	var/datum/component/material_container/materials	//Store for hyper speed!
	var/efficiency_coeff = 1
	var/list/categories = list()

/obj/machinery/r_n_d/New()
	materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC), 0, TRUE, /obj/item/stack, CALLBACK(src, .proc/is_insertion_ready), CALLBACK(src, .proc/AfterMaterialInsert))
	materials.precise_insertion = TRUE
	..()
	wires["Red"] = 0
	wires["Blue"] = 0
	wires["Green"] = 0
	wires["Yellow"] = 0
	wires["Black"] = 0
	wires["White"] = 0
	var/list/w = list("Red","Blue","Green","Yellow","Black","White")
	src.hack_wire = pick(w)
	w -= src.hack_wire
	src.shock_wire = pick(w)
	w -= src.shock_wire
	src.disable_wire = pick(w)
	w -= src.disable_wire

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if(shocked)
		shock(user,50)
	if(panel_open)
		var/list/dat = list()
		dat += "[src.name] Wires:<BR>"
		for(var/wire in wires)
			dat += "[wire] Wire: <A href='?src=[UID()];wire=[wire];cut=1'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=[UID()];wire=[wire];pulse=1'>Pulse</A><BR>"

		dat += "The red light is [src.disabled ? "off" : "on"].<BR>"
		dat += "The green light is [src.shocked ? "off" : "on"].<BR>"
		dat += "The blue light is [src.hacked ? "off" : "on"].<BR>"
		user << browse({"<HTML><meta charset="UTF-8"><HEAD><TITLE>[src.name] Hacking</TITLE></HEAD><BODY>[dat.Join("")]</BODY></HTML>"},"window=hack_win")
	return


/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["pulse"])
		var/temp_wire = href_list["wire"]
		if(!istype(usr.get_active_hand(), /obj/item/multitool))
			to_chat(usr, "You need a multitool!")
		else
			if(src.wires[temp_wire])
				to_chat(usr, "You can't pulse a cut wire.")
			else
				if(src.hack_wire == href_list["wire"])
					src.hacked = !src.hacked
					spawn(100) src.hacked = !src.hacked
				if(src.disable_wire == href_list["wire"])
					src.disabled = !src.disabled
					src.shock(usr,50)
					spawn(100) src.disabled = !src.disabled
				if(src.shock_wire == href_list["wire"])
					src.shocked = !src.shocked
					src.shock(usr,50)
					spawn(100) src.shocked = !src.shocked
	if(href_list["cut"])
		if(!istype(usr.get_active_hand(), /obj/item/wirecutters))
			to_chat(usr, "You need wirecutters!")
		else
			var/temp_wire = href_list["wire"]
			wires[temp_wire] = !wires[temp_wire]
			if(src.hack_wire == temp_wire)
				src.hacked = !src.hacked
			if(src.disable_wire == temp_wire)
				src.disabled = !src.disabled
				src.shock(usr,50)
			if(src.shock_wire == temp_wire)
				src.shocked = !src.shocked
				src.shock(usr,50)
	src.updateUsrDialog()

//whether the machine can have an item inserted in its current state.
/obj/machinery/r_n_d/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(disabled)
		return FALSE
	if(!linked_console)
		to_chat(user, "<span class='warning'>[src] must be linked to an R&D console first!</span>")
		return FALSE
	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")
		return FALSE
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>[src] is broken.</span>")
		return FALSE
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] has no power.</span>")
		return FALSE
	if(loaded_item)
		to_chat(user, "<span class='warning'>[src] is already loaded.</span>")
		return FALSE
	return TRUE

/obj/machinery/r_n_d/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		stack_name = "bluespace polycrystal"
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		var/obj/item/stack/S = type_inserted
		stack_name = initial(S.name)
		use_power(min(1000, (amount_inserted / 100)))
	overlays += "[initial(name)]_[stack_name]"
	sleep(10)
	overlays -= "[initial(name)]_[stack_name]"

/obj/machinery/r_n_d/proc/check_mat(datum/design/being_built, var/M)
	return 0 // number of copies of design beign_built you can make with material M
