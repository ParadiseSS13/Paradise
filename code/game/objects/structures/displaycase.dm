#define DISPLAYCASE_FRAME_CIRCUIT 0
#define DISPLAYCASE_FRAME_SCREWDRIVER 1

// List and hook used to set up the captain's print on their display case
var/global/list/captain_display_cases = list()

/hook/captain_spawned/proc/displaycase(mob/living/carbon/human/captain)
	if(!captain_display_cases.len)
		return 1
	var/fingerprint = captain.get_full_print()
	for(var/obj/structure/displaycase/D in captain_display_cases)
		if(istype(D))
			D.ue = fingerprint

	return 1

/obj/structure/displaycase_frame
	name = "display case frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_glass"
	var/obj/item/weapon/airlock_electronics/circuit = null
	var/obj/item/device/assembly/prox_sensor/sensor = null
	var/state = DISPLAYCASE_FRAME_CIRCUIT

/obj/structure/displaycase_frame/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	var/pstate = state
	var/turf/T = get_turf(src)
	switch(state)
		if(DISPLAYCASE_FRAME_CIRCUIT)
			if(istype(W, /obj/item/weapon/airlock_electronics) && W.icon_state != "door_electronics_smoked")
				user.drop_item()
				circuit = W
				circuit.forceMove(src)
				state++
				to_chat(user, "<span class='notice'>You add the airlock electronics to the frame.</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			if(istype(W, /obj/item/weapon/crowbar))
				new /obj/machinery/constructable_frame/machine_frame(T)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(T)
				G.amount = 5
				qdel(src)
				to_chat(user, "<span class='notice'>You pry the glass out of the frame.</span>")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				return

		if(DISPLAYCASE_FRAME_SCREWDRIVER)
			if(isscrewdriver(W))
				var/obj/structure/displaycase/C = new(T)
				if(circuit.one_access)
					C.req_access = null
					C.req_one_access = circuit.conf_access
				else
					C.req_access = circuit.conf_access
					C.req_one_access = null
				if(isprox(sensor))
					C.burglar_alarm = 1
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				qdel(src)
				return
			if(istype(W, /obj/item/weapon/crowbar))
				circuit.forceMove(T)
				circuit = null
				if(isprox(sensor))
					sensor.forceMove(T)
					sensor = null
				state--
				to_chat(user, "<span class='notice'>You pry the electronics out of the frame.</span>")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			if(isprox(W) && !isprox(sensor))
				user.drop_item()
				sensor = W
				sensor.forceMove(src)
				to_chat(user, "<span class='notice'>You add the proximity sensor to the frame.</span>")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

	if(pstate != state)
		pstate = state
		update_icon()

/obj/structure/displaycase_frame/update_icon()
	switch(state)
		if(1)
			icon_state = "box_glass_circuit"
		else
			icon_state = "box_glass"

/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox20"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = 1
	anchored = 1
	unacidable = 1 //Dissolving the case would also delete the contents.
	var/health = 30
	var/obj/item/occupant = null
	var/destroyed = 0
	var/locked = 0
	var/burglar_alarm = 0
	var/ue = null
	var/image/occupant_overlay = null
	var/obj/item/weapon/airlock_electronics/circuit

/obj/structure/displaycase/captains_laser
	name = "captain's display case"
	desc = "A display case for the captain's antique laser gun. Hooked up with an anti-theft system."
	burglar_alarm = 1

/obj/structure/displaycase/captains_laser/New()
	captain_display_cases += src
	req_access = list(access_captain)
	locked = 1
	spawn(5)
		occupant = new /obj/item/weapon/gun/energy/laser/captain(src)
		update_icon()

/obj/structure/displaycase/Destroy()
	dump()
	qdel(circuit)
	circuit = null
	return ..()

/obj/structure/displaycase/captains_laser/Destroy()
	captain_display_cases -= src
	return ..()

/obj/structure/displaycase/examine(mob/user)
	..(user)
	to_chat(user, "<span class='notice'>Peering through the glass, you see that it contains:</span>")
	if(occupant)
		to_chat(user, "[bicon(occupant)] <span class='notice'>\A [occupant].</span>")
	else
		to_chat(user, "Nothing.")

/obj/structure/displaycase/proc/dump()
	if(occupant)
		occupant.forceMove(get_turf(src))
		occupant = null
	occupant_overlay = null

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if(1)
			new /obj/item/weapon/shard(loc)
			if(occupant)
				dump()
			qdel(src)
		if(2)
			if(prob(50))
				src.health -= 15
				src.healthcheck()
		if(3)
			if(prob(50))
				src.health -= 5
				src.healthcheck()

/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
	..()
	src.healthcheck()
	return

/obj/structure/displaycase/blob_act()
	if(prob(75))
		new /obj/item/weapon/shard(loc)
		if(occupant) dump()
		qdel(src)

/obj/structure/displaycase/proc/healthcheck()
	if(src.health <= 0)
		health = 0
		if(!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard(loc)
			playsound(get_turf(src), "shatter", 70, 1)
			update_icon()
			spawn(0)
				burglar_alarm()
	else
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/proc/burglar_alarm()
	if(burglar_alarm)
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		visible_message("<span class='danger'>The burglar alarm goes off!</span>")
		// Play the burglar alarm three times
		for(var/i = 0, i < 4, i++)
			playsound(src, 'sound/machines/burglar_alarm.ogg', 50, 0)
			sleep(74) // 7.4 seconds long

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassbox2b"
	else
		src.icon_state = "glassbox2[locked]"
	overlays = 0
	if(occupant)
		var/icon/occupant_icon=getFlatIcon(occupant)
		occupant_icon.Scale(16,16)
		occupant_overlay = image(occupant_icon)
		occupant_overlay.pixel_x = 8
		occupant_overlay.pixel_y = 8
		if(locked)
			occupant_overlay.alpha = 128
		overlays += occupant_overlay
	return

/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/card))
		var/obj/item/weapon/card/id/I = W
		if(!check_access(I))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
		locked = !locked
		if(!locked)
			to_chat(user, "[bicon(src)] <span class='notice'>\The [src] clicks as locks release, and it slowly opens for you.</span>")
		else
			to_chat(user, "[bicon(src)]  <span class='notice'>You close \the [src] and swipe your card, locking it.</span>")
		update_icon()
		return
	if(istype(W,/obj/item/weapon/crowbar) && (!locked || destroyed))
		user.visible_message("[user.name] pries \the [src] apart.", \
			"You pry \the [src] apart.", \
			"You hear something pop.")
		var/turf/T = get_turf(src)
		playsound(T, 'sound/items/Crowbar.ogg', 50, 1)
		dump()
		var/obj/item/weapon/airlock_electronics/C = circuit
		if(!C)
			C = new (src)
		C.one_access = !(req_access && req_access.len>0)
		if(!C.one_access)
			C.conf_access = req_access
		else
			C.conf_access = req_one_access

		if(!destroyed)
			var/obj/structure/displaycase_frame/F = new(T)
			F.state = DISPLAYCASE_FRAME_SCREWDRIVER
			F.circuit = C
			F.circuit.forceMove(F)
			if(burglar_alarm)
				new /obj/item/device/assembly/prox_sensor(T)
			F.update_icon()
		else
			C.forceMove(T)
			circuit = null
			new /obj/machinery/constructable_frame/machine_frame(T)
		qdel(src)
		return
	if(user.a_intent == I_HARM)
		if(locked && !destroyed)
			src.health -= W.force
			src.healthcheck()
			..()
		else if(!locked)
			dump()
			to_chat(user, "<span class='danger'>You smash \the [W] into the delicate electronics at the bottom of the case, and deactivate the hover field.</span>")
			update_icon()
	else
		if(locked)
			to_chat(user, "<span class='warning'>It's locked, you can't put anything into it.</span>")
			return
		if(!occupant)
			to_chat(user, "<span class='notice'>You insert \the [W] into \the [src], and it floats as the hoverfield activates.</span>")
			user.drop_item()
			W.forceMove(src)
			occupant=W
			update_icon()

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if(destroyed || (!locked && user.a_intent == I_HARM))
		if(occupant)
			dump()
			to_chat(user, "<span class='danger'>You smash your fist into the delicate electronics at the bottom of the case, and deactivate the hover field.</span>")
			src.add_fingerprint(user)
			update_icon()
	else
		if(user.a_intent == I_HARM)
			user.changeNext_move(CLICK_CD_MELEE)
			user.do_attack_animation(src)
			user.visible_message("<span class='danger'>[user.name] kicks \the [src]!</span>", \
				"<span class='danger'>You kick \the [src]!</span>", \
				"You hear glass crack.")
			src.health -= 2
			healthcheck()
		else if(!locked)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/print = H.get_full_print()
				if(!ue)
					to_chat(user, "<span class='notice'>Your press your thumb against the fingerprint scanner, registering your identity with the case.</span>")
					ue = print
					return
				if(ue != print)
					to_chat(user, "<span class='warning'>Access denied.</span>")
					return

				if(occupant)
					to_chat(user, "<span class='notice'>Your press your thumb against the fingerprint scanner, and deactivate the hover field built into the case.</span>")
					dump()
					update_icon()
				else
					to_chat(src, "[bicon(src)] <span class='warning'>\The [src] is empty!</span>")
		else
			user.visible_message("[user.name] gently runs his hands over \the [src] in appreciation of its contents.", \
				"You gently run your hands over \the [src] in appreciation of its contents.", \
				"You hear someone streaking glass with their greasy hands.")

#undef DISPLAYCASE_FRAME_CIRCUIT
#undef DISPLAYCASE_FRAME_SCREWDRIVER