/obj/item/mmi/robotic_brain
	name = "robotic brain"
	desc = "An advanced circuit, capable of housing an advanced non-sentient synthetic intelligence."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris_blank"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=3;programming=3;plasmatech=2"

	var/searching = 0
	var/askDelay = 10 * 60 * 1
	//var/mob/living/carbon/brain/brainmob = null
	var/list/ghost_volunteers[0]
	req_access = list(access_robotics)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	var/silenced = 0 //if set to 1, they can't talk.
	var/next_ping_at = 0
	var/requires_master = TRUE
	var/mob/living/carbon/human/imprinted_master = null

/obj/item/mmi/robotic_brain/Destroy()
	imprinted_master = null
	return ..()

/obj/item/mmi/robotic_brain/attack_self(mob/user)
	if(requires_master && !imprinted_master)
		to_chat(user, "<span class='notice'>You press your thumb on [src] and imprint your user information.</span>")
		imprinted_master = user
		return
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start [src]'s boot process.</span>")
		icon_state = "boris_recharging"
		ghost_volunteers.Cut()
		searching = 1
		request_player()
		spawn(600)
			if(ghost_volunteers.len)
				var/mob/dead/observer/O
				while(!istype(O) && ghost_volunteers.len)
					O = pick_n_take(ghost_volunteers)
				if(istype(O) && check_observer(O))
					transfer_personality(O)
			reset_search()
	else
		silenced = !silenced
		to_chat(user, "<span class='notice'>You toggle the speaker [silenced ? "off" : "on"].</span>")
		if(brainmob && brainmob.key)
			to_chat(brainmob, "<span class='warning'>Your internal speaker has been toggled [silenced ? "off" : "on"].</span>")

/obj/item/mmi/robotic_brain/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(check_observer(O))
			to_chat(O, "<span class='boldnotice'>\A [src] has been activated. (<a href='?src=[O.UID()];jump=\ref[src]'>Teleport</a> | <a href='?src=[UID()];signup=\ref[O]'>Sign Up</a>)</span>")

/obj/item/mmi/robotic_brain/proc/check_observer(var/mob/dead/observer/O)
	if(cannotPossess(O))
		return 0
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O,"nonhumandept"))
		return 0
	if(!O.can_reenter_corpse)
		return 0
	if(O.client)
		return 1
	return 0

/obj/item/mmi/robotic_brain/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "Someone is requesting a personality for a [src]. Would you like to play as one?", "[src] request", "Yes", "No", "Never for this round")
		if(!C || brainmob.key || 0 == searching)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
		if(response == "Yes")
			transfer_personality(C.mob)
		else if(response == "Never for this round")
			C.prefs.be_special -= ROLE_POSIBRAIN

// This should not ever happen, but let's be safe
/obj/item/mmi/robotic_brain/dropbrain(var/turf/dropspot)
	log_runtime(EXCEPTION("[src] at [loc] attempted to drop brain without a contained brain."), src)
	return

/obj/item/mmi/robotic_brain/transfer_identity(var/mob/living/carbon/H)
	name = "[src] ([H])"
	if(isnull(brainmob.dna))
		brainmob.dna = H.dna.Clone()
	brainmob.name = brainmob.dna.real_name
	brainmob.real_name = brainmob.name
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.stat = CONSCIOUS
	if(brainmob.mind)
		brainmob.mind.assigned_role = "Positronic Brain"
	if(H.mind)
		H.mind.transfer_to(brainmob)
	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a circuit.</span>")
	become_occupied("boris")
	if(radio)
		radio_action.ApplyIcon()
	return

/obj/item/mmi/robotic_brain/attempt_become_organ(obj/item/organ/external/parent, mob/living/carbon/human/H)
	if(..())
		if(imprinted_master)
			to_chat(H, "<span class='biggerdanger'>You are permanently imprinted to [imprinted_master], obey [imprinted_master]'s every order and assist [imprinted_master.p_them()] in completing [imprinted_master.p_their()] goals at any cost.</span>")


/obj/item/mmi/robotic_brain/proc/transfer_personality(mob/candidate)
	searching = 0
	brainmob.key = candidate.key
	name = "[src] ([brainmob.name])"

	to_chat(brainmob, "<b>You are a [src], brought into existence on [station_name()].</b>")
	to_chat(brainmob, "<b>As a non-sentient synthetic intelligence, you answer to [imprinted_master], unless otherwise placed inside of a lawed synthetic structure or mech.</b>")
	to_chat(brainmob, "<b>Remember, the purpose of your existence is to serve [imprinted_master]'s every word, unless lawed  or placed into a mech in the future.</b>")
	brainmob.mind.assigned_role = "Positronic Brain"

	var/turf/T = get_turf_or_move(loc)
	for(var/mob/M in viewers(T))
		M.show_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied("boris")


/obj/item/mmi/robotic_brain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(src.brainmob && src.brainmob.key) return

	src.searching = 0
	icon_state = "boris_blank"

	var/turf/T = get_turf_or_move(src.loc)
	for(var/mob/M in viewers(T))
		M.show_message("<span class='notice'>[src] buzzes quietly as the red light fades out. Perhaps you could try again?</span>")

/obj/item/mmi/robotic_brain/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O) return
		volunteer(O)

/obj/item/mmi/robotic_brain/proc/volunteer(var/mob/dead/observer/O)
	if(!searching)
		to_chat(O, "Not looking for a ghost, yet.")
		return
	if(!istype(O))
		to_chat(O, "<span class='warning'>Error.</span>")
		return
	if(O in ghost_volunteers)
		to_chat(O, "<span class='notice'>Removed from registration list.</span>")
		ghost_volunteers.Remove(O)
		return
	if(!check_observer(O))
		to_chat(O, "<span class='warning'>You cannot be \a [src].</span>")
		return
	if(cannotPossess(O))
		to_chat(O, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O,"nonhumandept"))
		to_chat(O, "<span class='warning'>You are job banned from this role.</span>")
		return
	to_chat(O., "<span class='notice'>You've been added to the list of ghosts that may become this [src].  Click again to unvolunteer.</span>")
	ghost_volunteers.Add(O)


/obj/item/mmi/robotic_brain/examine(mob/user)
	to_chat(user, "Its speaker is turned [silenced ? "off" : "on"].")
	to_chat(user, "<span class='info'>*---------*</span>")
	. = ..()
	if(!.)
		to_chat(user, "<span class='info'>*---------*</span>")
		return

	var/list/msg = list("<span class='info'>")

	if(brainmob && brainmob.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "*---------*</span>"
	to_chat(user, msg.Join(""))

/obj/item/mmi/robotic_brain/emp_act(severity)
	if(!src.brainmob)
		return
	else
		switch(severity)
			if(1)
				src.brainmob.emp_damage += rand(20,30)
			if(2)
				src.brainmob.emp_damage += rand(10,20)
			if(3)
				src.brainmob.emp_damage += rand(0,10)
	..()

/obj/item/mmi/robotic_brain/New()
	src.brainmob = new(src)
	src.brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	src.brainmob.real_name = src.brainmob.name
	src.brainmob.loc = src
	src.brainmob.container = src
	src.brainmob.stat = 0
	src.brainmob.SetSilence(0)
	dead_mob_list -= src.brainmob

	..()

/obj/item/mmi/robotic_brain/attack_ghost(var/mob/dead/observer/O)
	if(searching)
		volunteer(O)
		return
	if(brainmob && brainmob.key)
		return // No point pinging a posibrain with a player already inside
	if(check_observer(O) && (world.time >= next_ping_at))
		next_ping_at = world.time + (20 SECONDS)
		playsound(get_turf(src), 'sound/items/posiping.ogg', 80, 0)
		var/turf/T = get_turf_or_move(src.loc)
		for(var/mob/M in viewers(T))
			M.show_message("<span class='notice'>[src] pings softly.</span>")