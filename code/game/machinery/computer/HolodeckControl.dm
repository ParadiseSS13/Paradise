/obj/machinery/computer/HolodeckControl
	name = "holodeck control computer"
	desc = "A computer used to control a nearby holodeck."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = 0
	var/list/holographic_items = list()
	var/damaged = 0
	var/last_change = 0

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/HolodeckControl/attack_ai(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/HolodeckControl/attack_hand(var/mob/user as mob)
	if(..())
		return 1

	user.set_machine(src)
	var/dat

	dat += "<B>Holodeck Control System</B><BR>"
	dat += "<HR>Current Loaded Programs:<BR>"

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

	dat += "Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.<BR>"

	if(emagged)
/*			dat += "<A href='?src=[UID()];burntest=1'>(<font color=red>Begin Atmospheric Burn Simulation</font>)</A><BR>"
		dat += "Ensure the holodeck is empty before testing.<BR>"
		dat += "<BR>"*/
		dat += "<A href='?src=[UID()];wildlifecarp=1'>(<font color=red>Begin Wildlife Simulation</font>)</A><BR>"
		dat += "Ensure the holodeck is empty before testing.<BR>"
		dat += "<BR>"
		if(issilicon(user))
			dat += "<A href='?src=[UID()];AIoverride=1'>(<font color=green>Re-Enable Safety Protocols?</font>)</A><BR>"
		dat += "Safety Protocols are <font color=red> DISABLED </font><BR>"
	else
		if(issilicon(user))
			dat += "<A href='?src=[UID()];AIoverride=1'>(<font color=red>Override Safety Protocols?</font>)</A><BR>"
		dat += "<BR>"
		dat += "Safety Protocols are <font color=green> ENABLED </font><BR>"

	var/datum/browser/popup = new(user, "holodeck_computer", name, 400, 500)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "computer")
	return

/obj/machinery/computer/HolodeckControl/Topic(href, href_list)
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

/obj/machinery/computer/HolodeckControl/attackby(var/obj/item/D as obj, var/mob/user as mob, params)
	return

/obj/machinery/computer/HolodeckControl/emag_act(user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You vastly increase projector power and override the safety and security protocols.</span>")
		to_chat(user, "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator.")
		log_game("[key_name(usr)] emagged the Holodeck Control Computer")
		src.updateUsrDialog()

/obj/machinery/computer/HolodeckControl/New()
	..()
	linkedholodeck = locate(/area/holodeck/alphadeck)
	//if(linkedholodeck)
	//	target = locate(/area/holodeck/source_emptycourt)
	//	if(target)
	//		loadProgram(target)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Destroy()
	emergencyShutdown()
	return ..()

/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/blob_act(obj/structure/blob/B)
	emergencyShutdown()
	return ..()

/obj/machinery/computer/HolodeckControl/process()
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
					do_sparks(2, 1, T)
				T.ex_act(3)
				T.hotspot_expose(1000,500,1)

/obj/machinery/computer/HolodeckControl/proc/derez(var/obj/obj , var/silent = 1)
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

/obj/machinery/computer/HolodeckControl/proc/checkInteg(var/area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

/obj/machinery/computer/HolodeckControl/proc/togglePower(var/toggleOn = 0)

	if(toggleOn)
		var/area/targetsource = locate(/area/holodeck/source_emptycourt)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

/*		spawn(30)
			for(var/obj/effect/landmark/L in linkedholodeck)
				if(L.name=="Atmospheric Test Start")
					spawn(20)
						var/turf/T = get_turf(L)
						do_sparks(2, 1, T)
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


/obj/machinery/computer/HolodeckControl/proc/loadProgram(var/area/A)

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
					do_sparks(2, 1, T)
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1)*/
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)


/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
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
	flags = NODECONSTRUCT
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
	flags = NODECONSTRUCT

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
	var/active = 0

/obj/item/holo/esword/green/New()
	..()
	item_color = "green"

/obj/item/holo/esword/red/New()
	..()
	item_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/New()
	..()
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

//BASKETBALL OBJECTS
/obj/item/beach_ball/holoball
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	name = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/beach_ball/holoball/baseball
	icon_state = "baseball"
	name = "baseball"
	item_state = "baseball"
	desc = "Take me out to the ball game."

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = 1
	density = 1
	pass_flags = LETPASSTHROW

/obj/structure/holohoop/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/grab) && get_dist(src,user)<2)
		var/obj/item/grab/G = W
		if(G.state<2)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		visible_message("<span class='warning'>[G.assailant] dunks [G.affecting] into the [src]!</span>")
		qdel(W)
		return
	else if(istype(W, /obj/item) && get_dist(src,user)<2)
		user.drop_item(src)
		visible_message("<span class='notice'>[user] dunks [W] into the [src]!</span>")
		return

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.loc = src.loc
			visible_message("<span class='notice'>Swish! \the [I] lands in \the [src].</span>")
		else
			visible_message("<span class='alert'>\The [I] bounces off of \the [src]'s rim!</span>")
		return 0
	else
		return ..(mover, target, height)

/obj/structure/holohoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && !istype(AM,/obj/item/projectile))
		if(prob(50))
			AM.forceMove(get_turf(src))
			visible_message("<span class='warning'>Swish! [AM] lands in [src].</span>")
			return
		else
			visible_message("<span class='danger'>[AM] bounces off of [src]'s rim!</span>")
			return ..()
	else
		return ..()

/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices.")
	return

/obj/machinery/readybutton/attackby(obj/item/W as obj, mob/user as mob, params)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(user.stat || stat & (BROKEN))
		to_chat(user, "This device is not functioning.")
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "The event has already begun!")
		return

	ready = !ready

	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if(button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()
	eventstarted = 1

	for(var/obj/structure/holowindow/W in currentarea)
		qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")
