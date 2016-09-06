/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. The speaker switch is set to 'on'."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = 3
	origin_tech = "biotech=3;programming=2"

	var/searching = 0
	var/askDelay = 10 * 60 * 1
	//var/mob/living/carbon/brain/brainmob = null
	var/list/ghost_volunteers[0]
	req_access = list(access_robotics)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	var/silenced = 0 //if set to 1, they can't talk.
	var/next_ping_at = 0


/obj/item/device/mmi/posibrain/attack_self(mob/user as mob)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		to_chat(user, "\blue You carefully locate the manual activation switch and start the positronic brain's boot process.")
		icon_state = "posibrain-searching"
		ghost_volunteers.Cut()
		src.searching = 1
		src.request_player()
		spawn(600)
			if(ghost_volunteers.len)
				var/mob/dead/observer/O = pick(ghost_volunteers)
				if(check_observer(O))
					transfer_personality(O)
			reset_search()
	else
		if(silenced)
			silenced = 0
			to_chat(user, "<span class='notice'>You toggle the speaker to 'on', on the [src].</span>")
			desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. The speaker switch is set to 'on'."
			if(brainmob && brainmob.key)
				to_chat(brainmob, "<span class='warning'>Your internal speaker has been toggled to 'on'.</span>")
		else
			silenced = 1
			to_chat(user, "<span class='notice'>You toggle the speaker to 'off', on the [src].</span>")
			desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. The speaker switch is set to 'off'."
			if(brainmob && brainmob.key)
				to_chat(brainmob, "<span class='warning'>Your internal speaker has been toggled to 'off'.</span>")

/obj/item/device/mmi/posibrain/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(check_observer(O))
			to_chat(O, "<span class='boldnotice'>\A [src] has been activated. (<a href='?src=[O.UID()];jump=\ref[src]'>Teleport</a> | <a href='?src=[UID()];signup=\ref[O]'>Sign Up</a>)</span>")

/obj/item/device/mmi/posibrain/proc/check_observer(var/mob/dead/observer/O)
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O,"nonhumandept"))
		return 0
	if(!O.can_reenter_corpse)
		return 0
	if(O.client)
		return 1
	return 0

/obj/item/device/mmi/posibrain/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "Someone is requesting a personality for a positronic brain. Would you like to play as one?", "Positronic brain request", "Yes", "No", "Never for this round")
		if(!C || brainmob.key || 0 == searching)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
		if(response == "Yes")
			transfer_personality(C.mob)
		else if(response == "Never for this round")
			C.prefs.be_special -= ROLE_POSIBRAIN

// This should not ever happen, but let's be safe
/obj/item/device/mmi/posibrain/dropbrain(var/turf/dropspot)
	log_runtime(EXCEPTION("[src] at [loc] attempted to drop brain without a contained brain."), src)
	return

/obj/item/device/mmi/posibrain/transfer_identity(var/mob/living/carbon/H)
	name = "positronic brain ([H])"
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
	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a metal cube.</span>")
	icon_state = "posibrain-occupied"
	return

/obj/item/device/mmi/posibrain/proc/transfer_personality(var/mob/candidate)
	src.searching = 0
	src.brainmob.key = candidate.key
	src.name = "positronic brain ([src.brainmob.name])"

	to_chat(src.brainmob, "<b>You are a positronic brain, brought into existence on [station_name()].</b>")
	to_chat(src.brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(src.brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	src.brainmob.mind.assigned_role = "Positronic Brain"

	var/turf/T = get_turf_or_move(src.loc)
	for(var/mob/M in viewers(T))
		M.show_message("\blue The positronic brain chimes quietly.")
	icon_state = "posibrain-occupied"

/obj/item/device/mmi/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(src.brainmob && src.brainmob.key) return

	src.searching = 0
	icon_state = "posibrain"

	var/turf/T = get_turf_or_move(src.loc)
	for(var/mob/M in viewers(T))
		M.show_message("\blue The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?")

/obj/item/device/mmi/posibrain/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O) return
		volunteer(O)

/obj/item/device/mmi/posibrain/proc/volunteer(var/mob/dead/observer/O)
	if(!searching)
		to_chat(O, "Not looking for a ghost, yet.")
		return
	if(!istype(O))
		to_chat(O, "\red Error.")
		return
	if(O in ghost_volunteers)
		to_chat(O, "\blue Removed from registration list.")
		ghost_volunteers.Remove(O)
		return
	if(!check_observer(O))
		to_chat(O, "\red You cannot be \a [src].")
		return
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		to_chat(O, "\red Upon using the antagHUD you forfeited the ability to join the round.")
		return
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O,"nonhumandept"))
		to_chat(O, "\red You are job banned from this role.")
		return
	to_chat(O., "\blue You've been added to the list of ghosts that may become this [src].  Click again to unvolunteer.")
	ghost_volunteers.Add(O)


/obj/item/device/mmi/posibrain/examine(mob/user)
	to_chat(user, "<span class='info'>*---------*</span>")
	if(!..(user))
		to_chat(user, "<span class='info'>*---------*</span>")
		return

	var/msg = "<span class='info'>"

	if(src.brainmob && src.brainmob.key)
		switch(src.brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "*---------*</span>"
	to_chat(user, msg)

/obj/item/device/mmi/posibrain/emp_act(severity)
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

/obj/item/device/mmi/posibrain/New()
	src.brainmob = new(src)
	src.brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	src.brainmob.real_name = src.brainmob.name
	src.brainmob.loc = src
	src.brainmob.container = src
	src.brainmob.stat = 0
	src.brainmob.silent = 0
	dead_mob_list -= src.brainmob

	..()

/obj/item/device/mmi/posibrain/attack_ghost(var/mob/dead/observer/O)
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
			M.show_message("\blue The positronic brain pings softly.")

/obj/item/device/mmi/posibrain/ipc
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. The speaker switch is set to 'off'."
	silenced = 1
