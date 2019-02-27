#define DNA_BLOCK_SIZE 3

// Buffer datatype flags.
#define DNA2_BUF_UI 1
#define DNA2_BUF_UE 2
#define DNA2_BUF_SE 4

#define NEGATE_MUTATION_THRESHOLD 30 // Occupants with over ## percent radiation threshold will not gain mutations

//list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0),
/datum/dna2/record
	var/datum/dna/dna = null
	var/types=0
	var/name="Empty"

	// Stuff for cloners
	var/id=null
	var/implant=null
	var/ckey=null
	var/mind=null
	var/languages=null

/datum/dna2/record/proc/GetData()
	var/list/ser=list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0)
	if(dna)
		ser["ue"] = (types & DNA2_BUF_UE) == DNA2_BUF_UE
		if(types & DNA2_BUF_SE)
			ser["data"] = dna.SE
		else
			ser["data"] = dna.UI
		ser["owner"] = src.dna.real_name
		ser["label"] = name
		if(types & DNA2_BUF_UI)
			ser["type"] = "ui"
		else
			ser["type"] = "se"
	return ser

/datum/dna2/record/proc/copy()
	var/datum/dna2/record/newrecord = new /datum/dna2/record
	newrecord.dna = dna.Clone()
	newrecord.types = types
	newrecord.name = name
	newrecord.mind = mind
	newrecord.ckey = ckey
	newrecord.languages = languages
	newrecord.implant = implant
	return newrecord


/////////////////////////// DNA MACHINES
/obj/machinery/dna_scannernew
	name = "\improper DNA modifier"
	desc = "It scans DNA structures."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "scanner_open"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 300
	interact_offline = 1
	var/locked = 0
	var/mob/living/carbon/occupant = null
	var/obj/item/reagent_containers/glass/beaker = null
	var/opened = 0
	var/damage_coeff
	var/scan_level
	var/precision_coeff

/obj/machinery/dna_scannernew/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/dna_scannernew/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		precision_coeff = P.rating
	for(var/obj/item/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating

/obj/machinery/dna_scannernew/AllowDrop()
	return FALSE

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if(user.stat)
		return
	src.go_out()
	return

/obj/machinery/dna_scannernew/verb/eject()
	set src in oview(1)
	set category = null
	set name = "Eject DNA Scanner"

	if(usr.stat != 0)
		return

	eject_occupant()

	add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/proc/eject_occupant()
	src.go_out()
	for(var/obj/O in src)
		if(!istype(O,/obj/item/circuitboard/clonescanner) && \
		   !istype(O,/obj/item/stock_parts) && \
		   !istype(O,/obj/item/stack/cable_coil) && \
		   O != beaker)
			O.forceMove(get_turf(src))//Ejects items that manage to get in there (exluding the components and beaker)
	if(!occupant)
		for(var/mob/M in src)//Failsafe so you can get mobs out
			M.forceMove(get_turf(src))

/obj/machinery/dna_scannernew/verb/move_inside()
	set src in oview(1)
	set category = null
	set name = "Enter DNA Scanner"

	if(usr.stat != 0)
		return
	if(usr.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(!ishuman(usr)) //Make sure they're a mob that has dna
		to_chat(usr, "<span class='notice'>Try as you might, you can not climb up into the [src].</span>")
		return
	if(src.occupant)
		to_chat(usr, "<span class='boldnotice'>The [src] is already occupied!</span>")
		return
	if(usr.abiotic())
		to_chat(usr, "<span class='boldnotice'>Subject cannot have abiotic items on.</span>")
		return
	usr.stop_pulling()
	usr.forceMove(src)
	src.occupant = usr
	src.icon_state = "scanner_occupied"
	src.add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(!istype(O))
		return
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		to_chat(user, "<span class='boldnotice'>The [src] is already occupied!</span>")
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		to_chat(user, "<span class='danger'>Subject cannot have abiotic items on.</span>")
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the [src] because [L.p_they()] [L.p_have()] a slime latched onto [L.p_their()] head.")
			return
	if(L == user)
		visible_message("[user] climbs into the [src].")
	else
		visible_message("[user] puts [L.name] into the [src].")
	put_in(L)
	if(user.pulling == L)
		user.stop_pulling()

/obj/machinery/dna_scannernew/attackby(var/obj/item/item as obj, var/mob/user as mob, params)
	if(istype(item, /obj/item/screwdriver))
		if(occupant)
			to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
			return
		default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]", item)

	if(exchange_parts(user, item))
		return

	if(istype(item, /obj/item/crowbar))
		if(panel_open)
			for(var/obj/I in contents) // in case there is something in the scanner
				I.forceMove(src.loc)
			default_deconstruction_crowbar(item)
		return
	else if(istype(item, /obj/item/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [item] is stuck to you!</span>")
			return

		beaker = item
		item.forceMove(src)
		user.visible_message("[user] adds \a [item] to \the [src]!", "You add \a [item] to \the [src]!")
		return
	else if(!istype(item, /obj/item/grab))
		return
	var/obj/item/grab/G = item
	if(!ismob(G.affecting))
		return
	if(src.occupant)
		to_chat(user, "<span class='boldnotice'>The scanner is already occupied!</span>")
		return
	if(G.affecting.abiotic())
		to_chat(user, "<span class='boldnotice'>Subject cannot have abiotic items on.</span>")
		return
	if(panel_open)
		to_chat(usr, "<span class='boldnotice'>Close the maintenance panel first.</span>")
		return
	put_in(G.affecting)
	src.add_fingerprint(user)
	qdel(G)
	return

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if(user.incapacitated())
		return 0 //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/dna_scannernew/proc/put_in(var/mob/M)
	M.forceMove(src)
	src.occupant = M
	src.icon_state = "scanner_occupied"

	// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
	if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))

		occupant.notify_ghost_cloning(source = src)
	return

/obj/machinery/dna_scannernew/proc/go_out()
	if(!src.occupant)
		to_chat(usr, "<span class='warning'>The scanner is empty!</span>")
		return

	if(src.locked)
		to_chat(usr, "<span class='warning'>The scanner is locked!</span>")
		return

	src.occupant.forceMove(src.loc)
	src.occupant = null
	src.icon_state = "scanner_open"
	return

/obj/machinery/dna_scannernew/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(src.loc)
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/dna_scannernew/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.loc)
		qdel(src)

// Checks if occupants can be irradiated/mutated - prevents exploits where wearing full rad protection would still let you gain mutations
/obj/machinery/dna_scannernew/proc/radiation_check()
	if(!occupant)
		return 1

	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(NO_DNA in H.dna.species.species_traits)
			return 1

	var/radiation_protection = occupant.run_armor_check(null, "rad", "Your clothes feel warm.", "Your clothes feel warm.")
	if(radiation_protection > NEGATE_MUTATION_THRESHOLD)
		return 1

	return 0

/obj/machinery/computer/scan_consolenew
	name = "\improper DNA Modifier access console"
	desc = "Allows you to scan and modify DNA."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = 1
	circuit = /obj/item/circuitboard/scan_consolenew
	var/selected_ui_block = 1.0
	var/selected_ui_subblock = 1.0
	var/selected_se_block = 1.0
	var/selected_se_subblock = 1.0
	var/selected_ui_target = 1
	var/selected_ui_target_hex = 1
	var/radiation_duration = 2.0
	var/radiation_intensity = 1.0
	var/list/datum/dna2/record/buffers[3]
	var/irradiating = 0
	var/injector_ready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/disk/data/disk = null
	var/selected_menu_key = null
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400
	var/waiting_for_user_input=0 // Fix for #274 (Mash create block injector without answering dialog to make unlimited injectors) - N3X

/obj/machinery/computer/scan_consolenew/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/disk/data)) //INSERT SOME diskS
		if(!src.disk)
			user.drop_item()
			I.forceMove(src)
			src.disk = I
			to_chat(user, "You insert [I].")
			SSnanoui.update_uis(src) // update all UIs attached to src()
			return
	else
		..()
	return

/obj/machinery/computer/scan_consolenew/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/computer/scan_consolenew/blob_act()
	if(prob(75))
		qdel(src)

/obj/machinery/computer/scan_consolenew/New()
	..()
	for(var/i=0;i<3;i++)
		buffers[i+1]=new /datum/dna2/record
	spawn(5)
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
			if(!isnull(connected))
				break
		spawn(250)
			src.injector_ready = 1
		return
	return

/obj/machinery/computer/scan_consolenew/proc/all_dna_blocks(var/list/buffer)
	var/list/arr = list()
	for(var/i = 1, i <= buffer.len, i++)
		arr += "[i]:[EncodeDNABlock(buffer[i])]"
	return arr

/obj/machinery/computer/scan_consolenew/proc/setInjectorBlock(var/obj/item/dnainjector/I, var/blk, var/datum/dna2/record/buffer)
	var/pos = findtext(blk,":")
	if(!pos) return 0
	var/id = text2num(copytext(blk,1,pos))
	if(!id) return 0
	I.block = id
	I.buf = buffer
	return 1

/*
/obj/machinery/computer/scan_consolenew/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	if(!( src.status )) //remove this
		return
	return
*/

/obj/machinery/computer/scan_consolenew/attack_ai(user as mob)
	src.add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/computer/scan_consolenew/attack_hand(user as mob)
	if(isnull(connected))
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
			if(!isnull(connected))
				attack_hand(user)
				break
	else
		if(..(user))
			return

		if(stat & (NOPOWER|BROKEN))
			return

		ui_interact(user)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(user == connected.occupant)
		return

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "dna_modifier.tmpl", "DNA Modifier Console", 660, 700)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/computer/scan_consolenew/ui_data(mob/user, datum/topic_state/state)
	var/data[0]
	data["selectedMenuKey"] = selected_menu_key
	data["locked"] = src.connected.locked
	data["hasOccupant"] = connected.occupant ? 1 : 0

	data["isInjectorReady"] = injector_ready

	data["hasDisk"] = disk ? 1 : 0

	var/diskData[0]
	if(!disk || !disk.buf)
		diskData["data"] = null
		diskData["owner"] = null
		diskData["label"] = null
		diskData["type"] = null
		diskData["ue"] = null
	else
		diskData = disk.buf.GetData()
	data["disk"] = diskData

	var/list/new_buffers = list()
	for(var/datum/dna2/record/buf in src.buffers)
		new_buffers += list(buf.GetData())
	data["buffers"]=new_buffers

	data["radiationIntensity"] = radiation_intensity
	data["radiationDuration"] = radiation_duration
	data["irradiating"] = irradiating

	data["dnaBlockSize"] = DNA_BLOCK_SIZE
	data["selectedUIBlock"] = selected_ui_block
	data["selectedUISubBlock"] = selected_ui_subblock
	data["selectedSEBlock"] = selected_se_block
	data["selectedSESubBlock"] = selected_se_subblock
	data["selectedUITarget"] = selected_ui_target
	data["selectedUITargetHex"] = selected_ui_target_hex

	var/occupantData[0]
	if(!src.connected.occupant || !src.connected.occupant.dna)
		occupantData["name"] = null
		occupantData["stat"] = null
		occupantData["isViableSubject"] = null
		occupantData["health"] = null
		occupantData["maxHealth"] = null
		occupantData["minHealth"] = null
		occupantData["uniqueEnzymes"] = null
		occupantData["uniqueIdentity"] = null
		occupantData["structuralEnzymes"] = null
		occupantData["radiationLevel"] = null
	else
		occupantData["name"] = connected.occupant.dna.real_name
		occupantData["stat"] = connected.occupant.stat
		occupantData["isViableSubject"] = 1
		if((NOCLONE in connected.occupant.mutations && connected.scan_level < 3) || !src.connected.occupant.dna || (NO_DNA in connected.occupant.dna.species.species_traits))
			occupantData["isViableSubject"] = 0
		occupantData["health"] = connected.occupant.health
		occupantData["maxHealth"] = connected.occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["uniqueEnzymes"] = connected.occupant.dna.unique_enzymes
		occupantData["uniqueIdentity"] = connected.occupant.dna.uni_identity
		occupantData["structuralEnzymes"] = connected.occupant.dna.struc_enzymes
		occupantData["radiationLevel"] = connected.occupant.radiation
	data["occupant"] = occupantData;

	data["isBeakerLoaded"] = connected.beaker ? 1 : 0
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(connected.beaker)
		data["beakerLabel"] = connected.beaker.label_text ? connected.beaker.label_text : null
		if(connected.beaker.reagents && connected.beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in connected.beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	return data

/obj/machinery/computer/scan_consolenew/Topic(href, href_list)
	if(..())
		return 0 // don't update uis
	if(!istype(usr.loc, /turf))
		return 0 // don't update uis
	if(!src || !src.connected)
		return 0 // don't update uis
	if(irradiating) // Make sure that it isn't already irradiating someone...
		return 0 // don't update uis

	add_fingerprint(usr)

	if(href_list["selectMenuKey"])
		selected_menu_key = href_list["selectMenuKey"]
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["toggleLock"])
		if((src.connected && src.connected.occupant))
			src.connected.locked = !( src.connected.locked )
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["pulseRadiation"])
		irradiating = src.radiation_duration
		var/lock_state = src.connected.locked
		src.connected.locked = 1//lock it
		SSnanoui.update_uis(src) // update all UIs attached to src

		sleep(10*src.radiation_duration) // sleep for radiation_duration seconds

		irradiating = 0
		src.connected.locked = lock_state

		if(!src.connected.occupant)
			return 1 // return 1 forces an update to all Nano uis attached to src

		var/radiation = (((src.radiation_intensity*3)+src.radiation_duration*3) / connected.damage_coeff)
		src.connected.occupant.apply_effect(radiation,IRRADIATE,0)
		if(src.connected.radiation_check())
			return 1

		if(prob(95))
			if(prob(75))
				randmutb(src.connected.occupant)
			else
				randmuti(src.connected.occupant)
		else
			if(prob(95))
				randmutg(src.connected.occupant)
			else
				randmuti(src.connected.occupant)

		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["radiationDuration"])
		if(text2num(href_list["radiationDuration"]) > 0)
			if(src.radiation_duration < 20)
				src.radiation_duration += 2
		else
			if(src.radiation_duration > 2)
				src.radiation_duration -= 2
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["radiationIntensity"])
		if(text2num(href_list["radiationIntensity"]) > 0)
			if(src.radiation_intensity < 10)
				src.radiation_intensity++
		else
			if(src.radiation_intensity > 1)
				src.radiation_intensity--
		return 1 // return 1 forces an update to all Nano uis attached to src

	////////////////////////////////////////////////////////

	if(href_list["changeUITarget"] && text2num(href_list["changeUITarget"]) > 0)
		if(src.selected_ui_target < 15)
			src.selected_ui_target++
			src.selected_ui_target_hex = src.selected_ui_target
			switch(selected_ui_target)
				if(10)
					src.selected_ui_target_hex = "A"
				if(11)
					src.selected_ui_target_hex = "B"
				if(12)
					src.selected_ui_target_hex = "C"
				if(13)
					src.selected_ui_target_hex = "D"
				if(14)
					src.selected_ui_target_hex = "E"
				if(15)
					src.selected_ui_target_hex = "F"
		else
			src.selected_ui_target = 0
			src.selected_ui_target_hex = 0
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["changeUITarget"] && text2num(href_list["changeUITarget"]) < 1)
		if(src.selected_ui_target > 0)
			src.selected_ui_target--
			src.selected_ui_target_hex = src.selected_ui_target
			switch(selected_ui_target)
				if(10)
					src.selected_ui_target_hex = "A"
				if(11)
					src.selected_ui_target_hex = "B"
				if(12)
					src.selected_ui_target_hex = "C"
				if(13)
					src.selected_ui_target_hex = "D"
				if(14)
					src.selected_ui_target_hex = "E"
		else
			src.selected_ui_target = 15
			src.selected_ui_target_hex = "F"
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["selectUIBlock"] && href_list["selectUISubblock"]) // This chunk of code updates selected block / sub-block based on click
		var/select_block = text2num(href_list["selectUIBlock"])
		var/select_subblock = text2num(href_list["selectUISubblock"])
		if((select_block <= DNA_UI_LENGTH) && (select_block >= 1))
			src.selected_ui_block = select_block
		if((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
			src.selected_ui_subblock = select_subblock
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["pulseUIRadiation"])
		var/block = src.connected.occupant.dna.GetUISubBlock(src.selected_ui_block,src.selected_ui_subblock)

		irradiating = src.radiation_duration
		var/lock_state = src.connected.locked
		src.connected.locked = 1//lock it
		SSnanoui.update_uis(src) // update all UIs attached to src

		sleep(10*src.radiation_duration) // sleep for radiation_duration seconds

		irradiating = 0
		src.connected.locked = lock_state

		if(!src.connected.occupant)
			return 1

		if(prob((80 + (src.radiation_duration / 2))))
			var/radiation = (src.radiation_intensity+src.radiation_duration)
			src.connected.occupant.apply_effect(radiation,IRRADIATE,0)

			if(src.connected.radiation_check())
				return 1

			block = miniscrambletarget(num2text(selected_ui_target), src.radiation_intensity, src.radiation_duration)
			src.connected.occupant.dna.SetUISubBlock(src.selected_ui_block,src.selected_ui_subblock,block)
			src.connected.occupant.UpdateAppearance()
		else
			var/radiation = ((src.radiation_intensity*2)+src.radiation_duration)
			src.connected.occupant.apply_effect(radiation,IRRADIATE,0)
			if(src.connected.radiation_check())
				return 1

			if(prob(20+src.radiation_intensity))
				randmutb(src.connected.occupant)
				domutcheck(src.connected.occupant,src.connected)
			else
				randmuti(src.connected.occupant)
				src.connected.occupant.UpdateAppearance()
		return 1 // return 1 forces an update to all Nano uis attached to src

	////////////////////////////////////////////////////////

	if(href_list["injectRejuvenators"])
		if(!connected.occupant)
			return 0
		var/inject_amount = round(text2num(href_list["injectRejuvenators"]), 5) // round to nearest 5
		if(inject_amount < 0) // Since the user can actually type the commands himself, some sanity checking
			inject_amount = 0
		if(inject_amount > 50)
			inject_amount = 50
		connected.beaker.reagents.trans_to(connected.occupant, inject_amount)
		connected.beaker.reagents.reaction(connected.occupant)
		return 1 // return 1 forces an update to all Nano uis attached to src

	////////////////////////////////////////////////////////

	if(href_list["selectSEBlock"] && href_list["selectSESubblock"]) // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
		var/select_block = text2num(href_list["selectSEBlock"])
		var/select_subblock = text2num(href_list["selectSESubblock"])
		if((select_block <= DNA_SE_LENGTH) && (select_block >= 1))
			src.selected_se_block = select_block
		if((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
			src.selected_se_subblock = select_subblock
		//testing("User selected block [selected_se_block] (sent [select_block]), subblock [selected_se_subblock] (sent [select_block]).")
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["pulseSERadiation"])
		var/block = src.connected.occupant.dna.GetSESubBlock(src.selected_se_block,src.selected_se_subblock)
		//var/original_block=block
		//testing("Irradiating SE block [src.selected_se_block]:[src.selected_se_subblock] ([block])...")

		irradiating = src.radiation_duration
		var/lock_state = src.connected.locked
		src.connected.locked = 1 //lock it
		SSnanoui.update_uis(src) // update all UIs attached to src

		sleep(10*src.radiation_duration) // sleep for radiation_duration seconds

		irradiating = 0
		src.connected.locked = lock_state

		if(src.connected.occupant)
			if(prob((80 + ((src.radiation_duration / 2) + (connected.precision_coeff ** 3)))))
				var/radiation = ((src.radiation_intensity+src.radiation_duration) / connected.damage_coeff)
				src.connected.occupant.apply_effect(radiation,IRRADIATE,0)

				if(src.connected.radiation_check())
					return 1

				var/real_SE_block=selected_se_block
				block = miniscramble(block, src.radiation_intensity, src.radiation_duration)
				if(prob(20))
					if(src.selected_se_block > 1 && src.selected_se_block < DNA_SE_LENGTH/2)
						real_SE_block++
					else if(src.selected_se_block > DNA_SE_LENGTH/2 && src.selected_se_block < DNA_SE_LENGTH)
						real_SE_block--

				//testing("Irradiated SE block [real_SE_block]:[src.selected_se_subblock] ([original_block] now [block]) [(real_SE_block!=selected_se_block) ? "(SHIFTED)":""]!")
				connected.occupant.dna.SetSESubBlock(real_SE_block,selected_se_subblock,block)
				domutcheck(src.connected.occupant,src.connected)
			else
				var/radiation = (((src.radiation_intensity*2)+src.radiation_duration) / connected.damage_coeff)
				src.connected.occupant.apply_effect(radiation,IRRADIATE,0)

				if(src.connected.radiation_check())
					return 1

				if(prob(80-src.radiation_duration))
					//testing("Random bad mut!")
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					//testing("Random identity mut!")
					src.connected.occupant.UpdateAppearance()
		return 1 // return 1 forces an update to all Nano uis attached to src

	if(href_list["ejectBeaker"])
		if(connected.beaker)
			var/obj/item/reagent_containers/glass/B = connected.beaker
			B.forceMove(connected.loc)
			connected.beaker = null
		return 1

	if(href_list["ejectOccupant"])
		connected.eject_occupant()
		return 1

	// Transfer Buffer Management
	if(href_list["bufferOption"])
		var/bufferOption = href_list["bufferOption"]

		// These bufferOptions do not require a bufferId
		if(bufferOption == "wipeDisk")
			if((isnull(src.disk)) || (src.disk.read_only))
				//src.temphtml = "Invalid disk. Please try again."
				return 0

			src.disk.buf=null
			//src.temphtml = "Data saved."
			return 1

		if(bufferOption == "ejectDisk")
			if(!src.disk)
				return
			src.disk.forceMove(get_turf(src))
			src.disk = null
			return 1

		// All bufferOptions from here on require a bufferId
		if(!href_list["bufferId"])
			return 0

		var/bufferId = text2num(href_list["bufferId"])

		if(bufferId < 1 || bufferId > 3)
			return 0 // Not a valid buffer id

		if(bufferOption == "saveUI")
			if(src.connected.occupant && src.connected.occupant.dna)
				var/datum/dna2/record/databuf=new
				databuf.types = DNA2_BUF_UI // DNA2_BUF_UE
				databuf.dna = src.connected.occupant.dna.Clone()
				if(ishuman(connected.occupant))
					databuf.dna.real_name=connected.occupant.name
				databuf.name = "Unique Identifier"
				src.buffers[bufferId] = databuf
			return 1

		if(bufferOption == "saveUIAndUE")
			if(src.connected.occupant && src.connected.occupant.dna)
				var/datum/dna2/record/databuf=new
				databuf.types = DNA2_BUF_UI|DNA2_BUF_UE
				databuf.dna = src.connected.occupant.dna.Clone()
				if(ishuman(connected.occupant))
					databuf.dna.real_name=connected.occupant.dna.real_name
				databuf.name = "Unique Identifier + Unique Enzymes"
				src.buffers[bufferId] = databuf
			return 1

		if(bufferOption == "saveSE")
			if(src.connected.occupant && src.connected.occupant.dna)
				var/datum/dna2/record/databuf=new
				databuf.types = DNA2_BUF_SE
				databuf.dna = src.connected.occupant.dna.Clone()
				if(ishuman(connected.occupant))
					databuf.dna.real_name=connected.occupant.dna.real_name
				databuf.name = "Structural Enzymes"
				src.buffers[bufferId] = databuf
			return 1

		if(bufferOption == "clear")
			src.buffers[bufferId]=new /datum/dna2/record()
			return 1

		if(bufferOption == "changeLabel")
			var/datum/dna2/record/buf = src.buffers[bufferId]
			var/text = sanitize(input(usr, "New Label:", "Edit Label", buf.name) as text|null)
			buf.name = text
			src.buffers[bufferId] = buf
			return 1

		if(bufferOption == "transfer")
			if(!src.connected.occupant || (NOCLONE in src.connected.occupant.mutations && connected.scan_level < 3) || !src.connected.occupant.dna)
				return 1

			irradiating = 2
			var/lock_state = src.connected.locked
			src.connected.locked = 1//lock it
			SSnanoui.update_uis(src) // update all UIs attached to src

			sleep(2 SECONDS)

			irradiating = 0
			src.connected.locked = lock_state

			var/radiation = (rand(20,50) / connected.damage_coeff)
			src.connected.occupant.apply_effect(radiation,IRRADIATE,0)

			if(src.connected.radiation_check())
				return 1

			var/datum/dna2/record/buf = src.buffers[bufferId]

			if((buf.types & DNA2_BUF_UI))
				if((buf.types & DNA2_BUF_UE))
					src.connected.occupant.real_name = buf.dna.real_name
					src.connected.occupant.name = buf.dna.real_name
				src.connected.occupant.UpdateAppearance(buf.dna.UI.Copy())
			else if(buf.types & DNA2_BUF_SE)
				src.connected.occupant.dna.SE = buf.dna.SE.Copy()
				src.connected.occupant.dna.UpdateSE()
				domutcheck(src.connected.occupant,src.connected)
			return 1

		if(bufferOption == "createInjector")
			if(injector_ready && !waiting_for_user_input)

				var/success = 1
				var/obj/item/dnainjector/I = new /obj/item/dnainjector
				var/datum/dna2/record/buf = src.buffers[bufferId]
				buf = buf.copy()
				if(href_list["createBlockInjector"])
					waiting_for_user_input=1
					var/list/selectedbuf
					if(buf.types & DNA2_BUF_SE)
						selectedbuf=buf.dna.SE
					else
						selectedbuf=buf.dna.UI
					var/blk = input(usr,"Select Block","Block") as null|anything in all_dna_blocks(selectedbuf)
					success = setInjectorBlock(I,blk,buf)
				else
					I.buf = buf
				waiting_for_user_input = 0
				if(success)
					I.forceMove(src.loc)
					I.name += " ([buf.name])"
					if(connected)
						I.damage_coeff = connected.damage_coeff
					src.injector_ready = 0
					spawn(300)
						src.injector_ready = 1
			return 1

		if(bufferOption == "loadDisk")
			if((isnull(src.disk)) || (!src.disk.buf))
				//src.temphtml = "Invalid disk. Please try again."
				return 0

			src.buffers[bufferId]=src.disk.buf.copy()
			//src.temphtml = "Data loaded."
			return 1

		if(bufferOption == "saveDisk")
			if((isnull(src.disk)) || (src.disk.read_only))
				//src.temphtml = "Invalid disk. Please try again."
				return 0

			var/datum/dna2/record/buf = src.buffers[bufferId]

			src.disk.buf = buf.copy()
			src.disk.name = "data disk - '[buf.dna.real_name]'"
			//src.temphtml = "Data saved."
			return 1


/////////////////////////// DNA MACHINES
