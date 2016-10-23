
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
	var/list/previous_targets = list()
	radio_channel = "Supply"
	var/trapped = 0
	var/speaks = 0
	var/soundeffects = 0


/mob/living/simple_animal/bot/mulebot/ssdbot/New()
	..()
	name = initial(name)
	home_turf = get_turf(src)
	var/datum/job/captain/J = new/datum/job/captain
	access_card.access = J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/mulebot/ssdbot/MouseDrop_T(atom/movable/AM, mob/user)
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/call_bot()
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/speak(msg, chan)
	if(speaks)
		..(msg,chan)

/mob/living/simple_animal/bot/mulebot/ssdbot/buzz(type)
	if(soundeffects)
		..(type)

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
		else if(mode == BOT_NO_ROUTE)
			if(loc == home_turf)
				if(target)
					speak("No route to [target] at <b>[get_area(target)]</b>.")
				else
					speak("No route.")
				bot_reset()
			else if(target)
				if(trapped)
					trapped++
					if(trapped>60)
						trapped = 1
						start_home()
						mode = BOT_BLOCKED
				else if(target == home_turf)
					speak("No route home  to [get_area(target)].")
					trapped = 1
				else
					speak("No route to [target] at <b>[get_area(target)]</b>. Aborting and returning home.")
					start_home()
					mode = BOT_BLOCKED
		else
			spawn(0)
				for(var/i=num_steps,i>0,i--)
					sleep(2)
					process_bot()

/mob/living/simple_animal/bot/mulebot/ssdbot/proc/acquire_ssd_target()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.z == z && isLivingSSD(H) && !H.Adjacent(src) && !(H in previous_targets))
			previous_targets += H
			target = get_turf(H)
			speak("Getting directions to [H] at <b>[get_area(src)]</b>.")
			var/area/dest_area = get_area(target)
			destination = format_text(dest_area.name)
			start()
			break


/mob/living/simple_animal/bot/mulebot/ssdbot/at_target()
	if(!reached_target)
		if(soundeffects)
			audible_message("[src] makes a chiming sound!", "<span class='emote'>You hear a chime.</span>")
			playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(load)
			speak("Unloading [load].")
			var/mob/living/carbon/human/N = passenger
			unload(2) // south

			sleep(20)
			var/obj/machinery/cryopod/Y
			for(var/obj/machinery/cryopod/P in oview(7, src))
				if(!P.occupant && P.check_occupant_allowed(N))
					Y = P
					break
			if(Y)
				if(N in previous_targets)
					previous_targets -= N
				Y.take_occupant(N)
			else
				speak("No free cryopod for [N].")
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
					speak("Picking up [load] at <b>[get_area(src)]</b>.")
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