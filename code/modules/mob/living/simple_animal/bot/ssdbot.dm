
#define SIGH 0
#define ANNOYED 1
#define DELIGHT 2

/mob/living/simple_animal/bot/mulebot/ssdbot
	name = "\improper SSD retrieval bot"
	desc = "A SSD-Retrieval bot."
	icon = 'icons/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	var/turf/home_turf = null
	var/idle_cycles = 0
	var/move_steps = 10
	locked = 1
	remote_disabled = 1
	allow_pai = 0
	report_delivery = 0
	bot_core_type = /obj/machinery/bot_core/mulebot/ssdbot


/mob/living/simple_animal/bot/mulebot/ssdbot/New()
	..()
	name = initial(name)
	//wires.status & ~WIRE_LOADCHECK
	home_turf = get_turf(src)
	var/datum/job/captain/J = new/datum/job/captain
	access_card.access = J.get_access()
	prev_access = access_card.access
	// set WIRE_REMOTE_TX to off here.

/mob/living/simple_animal/bot/mulebot/ssdbot/MouseDrop_T(atom/movable/AM, mob/user)
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/call_bot()
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/handle_automated_action()
	diag_hud_set_botmode()
	if(!has_power())
		on = 0
		return
	if(on)
		var/num_steps = move_steps
		process_bot()
		num_steps--
		if(mode == BOT_IDLE)
			idle_cycles++
			if(idle_cycles > 4)
				idle_cycles = 0
				acquire_ssd_target()
		else
			spawn(0)
				for(var/i=num_steps,i>0,i--)
					sleep(2)
					process_bot()

/mob/living/simple_animal/bot/mulebot/ssdbot/proc/acquire_ssd_target()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.z == z && isLivingSSD(H) && !H.Adjacent(src))
			target = get_turf(H)
			var/area/dest_area = get_area(target)
			destination = format_text(dest_area.name)
			start()
			break


/mob/living/simple_animal/bot/mulebot/ssdbot/at_target()
	if(!reached_target)
		radio_channel = "Supply" //Supply channel
		audible_message("[src] makes a chiming sound!", "<span class='emote'>You hear a chime.</span>")
		playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(load)
			speak("Destination <b>[destination]</b> reached. Unloading [load].", radio_channel)
			var/mob/living/carbon/human/N = passenger
			unload(2) // south

			sleep(20)
			var/obj/machinery/cryopod/Y
			for(var/obj/machinery/cryopod/P in oview(7, src))
				if(!P.occupant && P.check_occupant_allowed(N))
					Y = P
					break
			if(Y)
				Y.take_occupant(N)
			else
				visible_message("<span class='userdanger'>Unable to place: [N] - no cryopod available.</span>")
		else
			if(auto_pickup)
				var/atom/movable/AM
				for(var/mob/living/carbon/human/H in loc)
					if(!H.anchored && !H.buckled)
						AM = H
						break
				if(AM)
					load_mob(AM)
					//if(report_delivery)
					speak("Now loading [load] at <b>[get_area(src)]</b>.", radio_channel)
		if(auto_return && loc != home_turf)
			start_home()
			mode = BOT_BLOCKED
		else
			bot_reset()

	return

/mob/living/simple_animal/bot/mulebot/ssdbot/start_home()
	target = get_turf(home_turf)
	var/area/dest_area = get_area(target)
	destination = format_text(dest_area.name)
	start()
	update_icon()

/mob/living/simple_animal/bot/mulebot/ssdbot/emag_act(mob/user)
	to_chat(user, "<span class='warning'>[src] has no visible maintenance hatch.</span>")

/mob/living/simple_animal/bot/mulebot/ssdbot/RunOver(mob/living/carbon/human/H)
	H.Weaken(5)
	return // this version doesn't hurt people even if it runs into them

/mob/living/simple_animal/bot/mulebot/ssdbot/update_icon()
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/topic_denied()
	return 1 // deny all topic access and control alteration

#undef SIGH
#undef ANNOYED
#undef DELIGHT

/obj/machinery/bot_core/mulebot/ssdbot
	req_access = list(access_cent_medical)