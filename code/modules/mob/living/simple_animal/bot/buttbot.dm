/mob/living/simple_animal/bot/buttbot
	name = "\improper Buttbot"
	desc = "Well I... uh... huh."
	icon = 'icons/goonstation/obj/aibots.dmi'
	icon_state = "buttbot"
	density = 0
	anchored = 0
	health = 5
	maxHealth = 5
	pass_flags = PASSMOB

	radio_channel = "Service"
	bot_type = BUTT_BOT
	bot_filter = RADIO_BUTTBOT
	model = "Buttbot"
	bot_purpose = "butt, but butt"
	bot_core_type = /obj/machinery/bot_core/buttbot
	window_id = "autobutt"
	window_name = "Automatic Butt Unit v1.2"
	
	var/mob/living/carbon/target
	var/mob/living/carbon/oldtarget
	var/num_butts = 3
	var/butts = 0
	var/superfartable = 1
	var/superfart_timer = null

/obj/machinery/bot_core/buttbot
	req_one_access = list(access_clown, access_robotics)

/mob/living/simple_animal/bot/buttbot/New()
	..()
	spawn(3)
		var/datum/job/clown/J = new/datum/job/clown
		access_card.access += J.get_access()
		prev_access = access_card.access

/mob/living/simple_animal/bot/buttbot/Destroy()
	if(superfart_timer)
		deltimer(superfart_timer)
		superfart_timer = null
	return ..()

/mob/living/simple_animal/bot/buttbot/handle_automated_action()
	if(!..())
		return

	if(frustration > 8)
		target = null
		mode = BOT_IDLE
	
	if(prob(10) || emagged == 2)
		butt(0)

	if(!target)
		target = scan(/mob/living/carbon/human, oldtarget)
		if(target)
			pointed(target)
			oldtarget = target
			butts = num_butts

	if(target && (get_dist(src, target) <= 1))
		mode = BOT_HEALING
		frustration = 0
		pointed(target)
		butt()
		if(!--butts)
			mode = BOT_IDLE
			target = null
		return

	else if(target && path.len && (get_dist(target, path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE

	if(target && !path.len && get_dist(src, target) > 1)
		path = get_path_to(src, get_turf(target), /turf/proc/Distance_cardinal, 0, 30, id = access_card)
		mode = BOT_MOVING
		if(!path.len) //try to get closer if you can't reach the target directly
			path = get_path_to(src, get_turf(target), /turf/proc/Distance_cardinal, 0, 30, 1, id = access_card)
			if(!path.len) //Do not chase a target we cannot reach.
				target = null
				mode = BOT_IDLE

	if(path.len && target)
		if(!bot_move(path[path.len]))
			target = null
			mode = BOT_IDLE
		return

	if(path.len > 8 && target)
		frustration++

	if(auto_patrol && !target)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

/mob/living/simple_animal/bot/buttbot/proc/butt(can_fart = 1)
	if(emagged != 2)
		var/message = pick("butts", "butt")
		speak(message, prob(10) ? "headset" : null)
	else
		var/message = pick("BuTTS", "buTt", "b##t", "bztBUTT", "b^%t", "BUTT", "buott", "bats", "bates", "bouuts", "buttH", "b&/t", "beats", "boats", "booots", "BAAAAATS&/", "//t/%/")
		playsound(loc, 'sound/vox_fem/but.ogg', 50, 0)
		speak(message, prob(25) ? "headset" : null)
		if(can_fart && superfartable && isturf(loc))
			superfartable = 0
			var/turf/T = loc
			playsound(T, 'sound/goonstation/effects/superfart.ogg', 50, 0)
			visible_message("<span class='warning'><b>[src]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!</span>", "<span class='warning'>You hear a [pick("tremendous","gigantic","colossal")] fart.</span>")
			for(var/mob/living/M in view(src, 3))
				shake_camera(M, 10, 5)
				if (M == src)
					continue
				M << "<span class='warning'>You are sent flying!</span>"
				M.Weaken(5)
				step_away(M, T, 15)
				step_away(M, T, 15)
				step_away(M, T, 15)
			superfart_timer = addtimer(src, "refart", 1200)

/mob/living/simple_animal/bot/buttbot/proc/refart()
	superfartable = 1
	superfart_timer = null

/mob/living/simple_animal/bot/buttbot/emag_act(mob/user)
	..()
	if (emagged == 2)
		user << "<span class='danger'>You short out the vocal emitter on [src].</span>"
		visible_message("<span class='danger'>[src] buzzes oddly!</span>")
		playsound(loc, 'sound/vox_fem/but.ogg', 50, 0)

/mob/living/simple_animal/bot/buttbot/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null)
	..()
	repeat(message)

/mob/living/simple_animal/bot/buttbot/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, mob/speaker = null, hard_to_hear = 0, atom/follow_target)
	..()
	repeat(message, "headset")

/mob/living/simple_animal/bot/buttbot/proc/repeat(message, channel)
	if(!message || !on)
		return
	if(prob(25))
		var/list/speech_list = text2list(message, " ")
		if(!speech_list || !speech_list.len)
			return

		var/num_butts = rand(1, 4)
		var/counter = 0
		while(num_butts)
			counter++
			num_butts--
			speech_list[rand(1,speech_list.len)] = "butt"
			if(counter >= (speech_list.len / 2))
				num_butts = 0

		speak(list2text(speech_list, " "), channel)

/mob/living/simple_animal/bot/buttbot/process_scan(mob/living/carbon/M)
	if(!M.stat && M != target)
		return M

/mob/living/simple_animal/bot/buttbot/explode()
	on = 0
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	
	new /obj/item/organ/external/groin(Tsec)
	new /obj/item/device/assembly/voice(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	..()

/mob/living/simple_animal/bot/buttbot/set_custom_texts()
	text_hack = "You corrupt [name]'s vocal emitter."
	text_dehack = "[name]'s vocal emitter has been reset!"
	text_dehack_fail = "[name] does not seem to respond to dat butt!"

/mob/living/simple_animal/bot/buttbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Butt v1.2 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},
text("<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>"))
	if(!locked || issilicon(user) || check_rights(R_ADMIN, 0, user))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"))
	return dat

/mob/living/simple_animal/bot/buttbot/UnarmedAttack(atom/A)
	if(on)
		pointed(A)
		butt()
	..()

/mob/living/simple_animal/bot/buttbot/RangedAttack(atom/A)
	if(on)
		pointed(A)
		butt()
	..()

