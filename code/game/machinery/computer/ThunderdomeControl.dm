/obj/machinery/computer/HolodeckControl
	name = "thunderdome control computer"
	desc = "A computer used to control the thunderdome."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"
	var/area/linkedthunderdome = null
	var/area/targettdome = null
	var/active = 0
	var/damaged = 0
	var/last_change = 0

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

	dat += "<A href='?src=[UID()];emptycourt=1'>((Empty Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];boxingcourt=1'>((Boxing Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];basketball=1'>((Basketball Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];thunderdomecourt=1'>((Thunderdome Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];beach=1'>((Beach)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];desert=1'>((Desert)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];space=1'>((Space)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];picnicarea=1'>((Picnic Area)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];snowfield=1'>((Snow Field)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];theatre=1'>((Theatre)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];meetinghall=1'>((Meeting Hall)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];knightarena=1'>((Knight Arena)</font>)</A><BR>"
//		dat += "<A href='?src=[UID()];turnoff=1'>((Shutdown System)</font>)</A><BR>"

	dat += "Weapons are live and can kill. Well not the weapons but the morons using them.<BR>"

	var/datum/browser/popup = new(user, "thunderdome_computer", name, 400, 500)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "computer")
	return

/obj/machinery/computer/ThunderdomeControl/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["emptycourt"])
		target = locate(/area/holodeck/source_emptycourt)
		if(target)
			loadProgram(target)

	else if(href_list["boxingcourt"])
		target = locate(/area/holodeck/source_boxingcourt)
		if(target)
			loadProgram(target)

	else if(href_list["basketball"])
		target = locate(/area/holodeck/source_basketball)
		if(target)
			loadProgram(target)

	else if(href_list["thunderdomecourt"])
		target = locate(/area/holodeck/source_thunderdomecourt)
		if(target)
			loadProgram(target)

	else if(href_list["beach"])
		target = locate(/area/holodeck/source_beach)
		if(target)
			loadProgram(target)

	else if(href_list["desert"])
		target = locate(/area/holodeck/source_desert)
		if(target)
			loadProgram(target)

	else if(href_list["space"])
		target = locate(/area/holodeck/source_space)
		if(target)
			loadProgram(target)

	else if(href_list["picnicarea"])
		target = locate(/area/holodeck/source_picnicarea)
		if(target)
			loadProgram(target)

	else if(href_list["snowfield"])
		target = locate(/area/holodeck/source_snowfield)
		if(target)
			loadProgram(target)

	else if(href_list["theatre"])
		target = locate(/area/holodeck/source_theatre)
		if(target)
			loadProgram(target)

	else if(href_list["meetinghall"])
		target = locate(/area/holodeck/source_meetinghall)
		if(target)
			loadProgram(target)

	else if(href_list["knightarena"])
		target = locate(/area/holodeck/source_knightarena)
		if(target)
			loadProgram(target)

	else if(href_list["turnoff"])
		target = locate(/area/holodeck/source_plating)
		if(target)
			loadProgram(target)
/*
	else if(href_list["burntest"])
		if(!emagged)	return
		target = locate(/area/holodeck/source_burntest)
		if(target)
			loadProgram(target)
*/
	else if(href_list["wildlifecarp"])
		if(!emagged)	return
		target = locate(/area/holodeck/source_wildlife)
		if(target)
			loadProgram(target)

	else if(href_list["AIoverride"])
		if(!issilicon(usr))	return
		emagged = !emagged
		if(emagged)
			message_admins("[key_name_admin(usr)] overrode the holodeck's safeties")
			log_game("[key_name(usr)] overrode the holodeck's safeties")
		else
			message_admins("[key_name_admin(usr)] restored the holodeck's safeties")
			log_game("[key_name(usr)] restored the holodeck's safeties")

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/ThunderdomeControl/attackby(var/obj/item/D as obj, var/mob/user as mob, params)
	return

/obj/machinery/computer/ThunderdomeControl/emag_act(user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You vastly increase projector power and override the safety and security protocols.</span>")
		to_chat(user, "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator.")
		log_game("[key_name(usr)] emagged the Holodeck Control Computer")
		src.updateUsrDialog()

/obj/machinery/computer/ThunderdomeControl/New()
	..()
	linkedholodeck = locate(/area/holodeck/alphadeck)
	//if(linkedholodeck)
	//	target = locate(/area/holodeck/source_emptycourt)
	//	if(target)
	//		loadProgram(target)

//This could all be done better, but it works for now.
/obj/machinery/computer/ThunderdomeControl/Destroy()
	emergencyShutdown()
	return ..()

/obj/machinery/computer/ThunderdomeControl/emp_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/ThunderdomeControl/ex_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/ThunderdomeControl/blob_act()
	emergencyShutdown()
	..()

/obj/machinery/computer/ThunderdomeControl/process()
	for(var/item in holographic_items) // do this first, to make sure people don't take items out when power is down.
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if(!..())
		return

	if(active)
		if(!checkInteg(linkedholodeck))
			damaged = 1
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = 0
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(2, 1, T)
					s.start()
				T.ex_act(3)
				T.hotspot_expose(1000,500,1)

/obj/machinery/computer/ThunderdomeControl/proc/derez(var/obj/obj , var/silent = 1)
	holographic_items.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.unEquip(obj, 1) //Holoweapons should always drop.

	if(!silent)
		var/obj/oldobj = obj
		visible_message("The [oldobj.name] fades away!")
	qdel(obj)

/obj/machinery/computer/ThunderdomeControl/proc/checkInteg(var/area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

/obj/machinery/computer/ThunderdomeControl/proc/togglePower(var/toggleOn = 0)

	if(toggleOn)
		var/area/targetsource = locate(/area/holodeck/source_emptycourt)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

/*		spawn(30)
			for(var/obj/effect/landmark/L in linkedholodeck)
				if(L.name=="Atmospheric Test Start")
					spawn(20)
						var/turf/T = get_turf(L)
						var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
						s.set_up(2, 1, T)
						s.start()
						if(T)
							T.temperature = 5000
							T.hotspot_expose(50000,50000,1)*/

		active = 1
	else
		for(var/item in holographic_items)
			derez(item)
		var/area/targetsource = locate(/area/holodeck/source_plating)
		targetsource.copy_contents_to(linkedholodeck , 1)
		active = 0


/obj/machinery/computer/ThunderdomeControl/proc/loadProgram(var/area/A)

	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("<b>ERROR. Recalibrating projection apparatus.</b>")
			last_change = world.time
			return

	last_change = world.time
	active = 1

	for(var/item in holographic_items)
		derez(item)

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		qdel(B)

	for(var/mob/living/simple_animal/hostile/carp/C in linkedholodeck)
		qdel(C)

	holographic_items = A.copy_contents_to(linkedholodeck , 1)

	if(emagged)
		for(var/obj/item/holo/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
/*			if(L.name=="Atmospheric Test Start")
				spawn(20)
					var/turf/T = get_turf(L)
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(2, 1, T)
					s.start()
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1)*/
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)


/obj/machinery/computer/ThunderdomeControl/proc/emergencyShutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	//Turn it back to the regular non-holographic room
	target = locate(/area/holodeck/source_plating)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holodeck/source_plating)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = 0

// Holographic Items!
/turf/simulated/floor/holofloor/
	thermal_conductivity = 0
	icon_state = "plating"
/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass

/turf/simulated/floor/holofloor/grass/New()
	..()
	spawn(1)
		update_icon()

/turf/simulated/floor/holofloor/grass/update_icon()
	..()
	if(!(icon_state in list("grass1", "grass2", "grass3", "grass4", "sand")))
		icon_state = "grass[pick("1","2","3","4")]"

/turf/simulated/floor/holofloor/attackby(obj/item/W as obj, mob/user as mob, params)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK

/obj/structure/table/holotable
	can_deconstruct = FALSE
	canSmoothWith = list(/obj/structure/table/holotable)

/obj/structure/table/holotable/wood
	name = "wooden table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	canSmoothWith = list(/obj/structure/table/holotable/wood)

/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER

/obj/structure/rack/holorack
	can_deconstruct = FALSE

/obj/item/holo
	damtype = STAMINA

/obj/item/holo/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50

/obj/item/holo/claymore/blue
	icon_state = "claymoreblue"
	item_state = "claymoreblue"

/obj/item/holo/claymore/red
	icon_state = "claymorered"
	item_state = "claymorered"

/obj/item/holo/esword
	name = "Holographic Energy Sword"
	desc = "This looks like a real energy sword!"
	icon_state = "sword0"
	hitsound = "swing_hit"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 50
	block_chance = 50
	var/activetdome = 0

/obj/item/holo/esword/green/New()
	item_color = "green"

/obj/item/holo/esword/red/New()
	item_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/New()
	item_color = pick("red","blue","green","purple")

/obj/item/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if(active)
		force = 30
		icon_state = "sword[item_color]"
		hitsound = "sound/weapons/blade1.ogg"
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		hitsound = "swing_hit"
		w_class = WEIGHT_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return