
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
	var/move_steps = 5
	locked = 1
	remote_disabled = 1
	allow_pai = 0
	report_delivery = 0
	bot_core_type = /obj/machinery/bot_core/mulebot/ssdbot
	health = 250
	maxHealth = 250
	var/list/ignored_ssds = list()
	radio_channel = "Supply"
	var/trapped = 0
	var/trappedcycles = 0
	var/speaks = 0 // debug setting.
	var/soundeffects = 0
	var/automatic_mode = 1 // if 1, players cannot reconfigure it
	buckle_lying = 1
	force_threshold = 20
	var/list/areas_to_ignore = list(/area/medical/virology, /area/toxins/xenobiology, /area/security/prison, /area/security/permabrig)
	var/pickup_delay = 60 // 60 cycles, 120 seconds
	var/list/previous_targets = list()
	var/mob/targetssd = null

/mob/living/simple_animal/bot/mulebot/ssdbot/New()
	..()
	name = initial(name)
	home_turf = get_turf(src)
	access_card.access = get_all_accesses()
	prev_access = access_card.access

/mob/living/simple_animal/bot/mulebot/ssdbot/MouseDrop_T(atom/movable/AM, mob/user)
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/call_bot()
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/door_opened(obj/machinery/door/D)
	..()
	spawn(30)
		D.close()

/mob/living/simple_animal/bot/mulebot/ssdbot/speak(msg, chan)
	if(speaks)
		..(msg,chan)

/mob/living/simple_animal/bot/mulebot/ssdbot/buzz(type)
	if(soundeffects)
		..(type)
/mob/living/simple_animal/bot/mulebot/ssdbot/emp_act(severity)
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/interact(mob/user)
	if(automatic_mode)
		to_chat(user, "<span class='warning'>[src] is operating in fully automatic mode.</span>")
	else if(bot_core.allowed(user))
		toggle_power(user)
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")

/mob/living/simple_animal/bot/mulebot/ssdbot/attack_ai(mob/user)
	if(automatic_mode)
		to_chat(user, "<span class='warning'>[src] is operating in fully automatic mode.</span>")
	else
		toggle_power(user)

/mob/living/simple_animal/bot/mulebot/ssdbot/proc/toggle_power(mob/user)
	if(on)
		to_chat(user, "<span class='notice'>You turn off [src].</span>")
		turn_off()
	else
		to_chat(user, "<span class='notice'>You turn on [src].</span>")
		turn_on()

/mob/living/simple_animal/bot/mulebot/ssdbot/turn_off()
	ignored_ssds = list()
	..()

/mob/living/simple_animal/bot/mulebot/ssdbot/show_controls(mob/M)
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/bot_reset()
	..()
	target = null
	targetssd = null
	idle_cycles = 0
	trapped = 0
	trappedcycles = 0

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
			if(idle_cycles > pickup_delay)
				idle_cycles = 0
				var/list/current_targets = list_ssd_targets()
				for(var/mob/living/carbon/human/T in current_targets)
					if(T in previous_targets)
						set_ssd_target(T)
						break
				speak("Current targets: [current_targets.len]. Prev targets: [previous_targets.len].")
				previous_targets = current_targets
		else if(mode == BOT_NO_ROUTE)
			if(loc == home_turf)
				if(targetssd)
					speak("No route to [targetssd] at <b>[get_area(target)]</b>.")
				else
					speak("No route.")
				bot_reset()
			else if(target)
				if(trapped)
					trapped++
					var/breakcycles = min(trappedcycles, 1)
					breakcycles = max(trappedcycles * 5, 60)
					if(trapped > breakcycles) // from 5c (10 seconds) to 60c (two minutes)
						trapped = 1
						trappedcycles++
						start_home()
				else if(target == home_turf)
					speak("No route home  to [get_area(target)].")
					trapped = 1
					trappedcycles = 0
				else
					speak("No route to [targetssd] at <b>[get_area(target)]</b>. Aborting and returning home.")
					start_home()
		else
			spawn(0)
				if(targetssd)
					if(bot_can_pick_up(targetssd))
						target = get_turf(targetssd)
					else
						speak("[targetssd] is no longer valid.")
						start_home()
				for(var/i=num_steps,i>0,i--)
					sleep(2)
					process_bot()

/mob/living/simple_animal/bot/mulebot/ssdbot/proc/list_ssd_targets()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(bot_can_pick_up(H))
			if(H in ignored_ssds)
				continue
			if(H.mind)
				if(H.mind.assigned_role in command_positions)
					continue
			var/valid_area = 1
			for(var/area/A in areas_to_ignore)
				if(istype(get_area(H), A))
					valid_area = 0
					break
			if(!valid_area)
				continue
			possible_targets += H
	return possible_targets

/mob/living/simple_animal/bot/mulebot/ssdbot/proc/set_ssd_target(var/mob/living/carbon/human/H)
	ignored_ssds += H
	target = get_turf(H)
	targetssd = H
	speak("Getting directions to [H] at <b>[get_area(H)]</b>.")
	var/area/dest_area = get_area(target)
	destination = format_text(dest_area.name)
	start()

/mob/living/simple_animal/bot/mulebot/ssdbot/proc/bot_can_pick_up(var/mob/living/carbon/human/H)
	if(H.z != z)
		return 0
	if(!isLivingSSD(H))
		return 0
	if(H.anchored)
		return 0
	if(H.stunned)
		return 0
	if(H.handcuffed)
		return 0
	if(H.loc == home_turf)
		return 0
	if(istype(get_turf(H), /turf/space))
		return 0
	if(H.buckled)
		return 0
	if(H.pulledby)
		return 0
	if(H.grabbed_by)
		return 0
	return 1

/mob/living/simple_animal/bot/mulebot/ssdbot/at_target()
	if(!reached_target)
		if(soundeffects)
			audible_message("[src] makes a chiming sound!", "<span class='emote'>You hear a chime.</span>")
			playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(load)
			speak("Unloading [load].")
			var/mob/living/carbon/human/N = passenger
			unload(SOUTH)

			sleep(20)
			var/obj/machinery/cryopod/Y
			for(var/obj/machinery/cryopod/P in oview(7, src))
				if(!P.occupant && P.check_occupant_allowed(N))
					Y = P
					break
			if(Y)
				if(N in ignored_ssds)
					ignored_ssds -= N
				Y.take_occupant(N, 1)
			else
				speak("No free cryopod for [N].")
		else
			if(auto_pickup)
				var/atom/movable/AM
				for(var/mob/living/carbon/human/H in loc)
					if(bot_can_pick_up(H))
						AM = H
						break
				if(AM)
					load_mob(AM)
					//if(report_delivery)
					speak("Picking up [load] at <b>[get_area(src)]</b>.")
		if(loc == home_turf)
			bot_reset()
		else
			start_home()
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/start_home()
	targetssd = null
	mode = BOT_BLOCKED
	target = get_turf(home_turf)
	var/area/dest_area = get_area(target)
	destination = format_text(dest_area.name)
	start()
	update_icon()

/mob/living/simple_animal/bot/mulebot/ssdbot/emag_act(mob/user)
	to_chat(user, "<span class='warning'>[src] has no visible maintenance hatch.</span>")

/mob/living/simple_animal/bot/mulebot/Move(turf/simulated/next)
	..()
	if(buckled_mob)
		buckled_mob.dir = dir

/mob/living/simple_animal/bot/mulebot/ssdbot/RunOver(mob/living/carbon/human/H)
	H.Weaken(5)

/mob/living/simple_animal/bot/mulebot/ssdbot/update_icon()
	return

/mob/living/simple_animal/bot/mulebot/ssdbot/topic_denied()
	return 1 // deny all topic access and control alteration

#undef SIGH
#undef ANNOYED
#undef DELIGHT

/obj/machinery/bot_core/mulebot/ssdbot
	req_access = list(access_cmo)