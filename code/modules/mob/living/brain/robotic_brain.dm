/obj/item/mmi/robotic_brain
	name = "robotic brain"
	desc = "A Beta-level artifical intelligence core containing a non-sapient mechanical mind."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris_blank"
	var/blank_icon = "boris_blank"
	var/searching_icon = "boris_recharging"
	var/occupied_icon = "boris"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=3;programming=3;plasmatech=2"

	var/searching = FALSE
	var/askDelay = 10 * 60 * 1
	//var/mob/living/brain/brainmob = null
	var/list/ghost_volunteers[0]
	req_access = list(ACCESS_ROBOTICS)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	var/silenced = FALSE //if TRUE, they can't talk.
	var/next_ping_at = 0
	var/requires_master = TRUE
	var/mob/living/carbon/human/imprinted_master = null
	var/ejected_flavor_text = "circuit"

	dead_icon = "boris_blank"

/obj/item/mmi/robotic_brain/Destroy()
	imprinted_master = null
	return ..()

/obj/item/mmi/robotic_brain/attack_self(mob/user)
	if(isgolem(user))
		to_chat(user, "<span class='warning'>Your golem fingers are too large to press the switch on [src].</span>")
		return
	if(requires_master && !imprinted_master)
		to_chat(user, "<span class='notice'>You press your thumb on [src] and imprint your user information.</span>")
		imprinted_master = user
		return
	if(brainmob && !brainmob.key && !searching)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start [src]'s boot process.</span>")
		icon_state = searching_icon
		ghost_volunteers.Cut()
		searching = TRUE
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
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(check_observer(O))
			to_chat(O, "<span class='boldnotice'>\A [src] has been activated. (<a href='?src=[O.UID()];jump=\ref[src]'>Teleport</a> | <a href='?src=[UID()];signup=\ref[O]'>Sign Up</a>)</span>")

/obj/item/mmi/robotic_brain/proc/check_observer(mob/dead/observer/O)
	if(!O.check_ahud_rejoin_eligibility())
		return FALSE
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O, "nonhumandept"))
		return FALSE
	if(!O.can_reenter_corpse)
		return FALSE
	if(O.client)
		return TRUE
	return FALSE

// This should not ever happen, but let's be safe
/obj/item/mmi/robotic_brain/dropbrain(turf/dropspot)
	CRASH("[src] at [loc] attempted to drop brain without a contained brain.")

/obj/item/mmi/robotic_brain/transfer_identity(mob/living/carbon/H)
	name = "[src] ([H])"

	brainmob.dna = H.dna.Clone()
	// I'm not sure we can remove species override. There might be some loophole
	// that would allow posibrains to be cloned without this.
	brainmob.dna.species = new /datum/species/machine()
	brainmob.real_name = brainmob.dna.real_name
	brainmob.name = brainmob.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.set_stat(CONSCIOUS)
	if(brainmob.mind)
		brainmob.mind.assigned_role = "Positronic Brain"
	if(H.mind)
		H.mind.transfer_to(brainmob)
	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a [ejected_flavor_text].</span>")
	become_occupied(occupied_icon)

/obj/item/mmi/robotic_brain/attempt_become_organ(obj/item/organ/external/parent, mob/living/carbon/human/H)
	if(..())
		if(imprinted_master)
			to_chat(H, "<span class='biggerdanger'>You are permanently imprinted to [imprinted_master], obey [imprinted_master]'s every order and assist [imprinted_master.p_them()] in completing [imprinted_master.p_their()] goals at any cost.</span>")

/obj/item/mmi/robotic_brain/proc/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.key = candidate.key
	name = "[src] ([brainmob.name])"

	to_chat(brainmob, "<b>You are a [src], brought into existence on [station_name()].</b>")
	to_chat(brainmob, "<b>As a non-sentient synthetic intelligence, you answer to [imprinted_master], unless otherwise placed inside of a lawed synthetic structure or mech.</b>")
	to_chat(brainmob, "<b>Remember, the purpose of your existence is to serve [imprinted_master]'s every word, unless lawed  or placed into a mech in the future.</b>")
	brainmob.mind.assigned_role = "Positronic Brain"

	if(brainmob.has_ahudded())
		log_admin("[key_name(brainmob)] has joined as a robot brain, after having toggled antag hud.")
		message_admins("[key_name(brainmob)] has joined as a robot brain, after having toggled antag hud.")

	visible_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied(occupied_icon)


/obj/item/mmi/robotic_brain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(brainmob && brainmob.key)
		return

	searching = FALSE
	icon_state = blank_icon

	visible_message("<span class='notice'>[src] buzzes quietly as the light fades out. Perhaps you could try again?</span>")

/obj/item/mmi/robotic_brain/Topic(href, href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O)
			return
		volunteer(O)

/obj/item/mmi/robotic_brain/proc/volunteer(mob/dead/observer/O)
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
	if(!O.check_ahud_rejoin_eligibility())
		to_chat(O, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O, "nonhumandept"))
		to_chat(O, "<span class='warning'>You are job banned from this role.</span>")
		return
	to_chat(O, "<span class='notice'>You've been added to the list of ghosts that may become this [src].  Click again to unvolunteer.</span>")
	ghost_volunteers.Add(O)


/obj/item/mmi/robotic_brain/examine(mob/user)
	. += "Its speaker is turned [silenced ? "off" : "on"]."
	. = ..()

	var/list/msg = list("<span class='info'>")

	if(brainmob && brainmob.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
					msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)
				msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)
				msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "</span>"
	. += msg.Join("")

/obj/item/mmi/robotic_brain/emp_act(severity)
	if(!brainmob)
		return
	switch(severity)
		if(1)
			brainmob.emp_damage += rand(20, 30)
		if(2)
			brainmob.emp_damage += rand(10, 20)
		if(3)
			brainmob.emp_damage += rand(0, 10)
	..()

/obj/item/mmi/robotic_brain/New()
	brainmob = new(src)
	brainmob.name = "[pick(list("PBU", "HIU", "SINA", "ARMA", "OSI"))]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.container = src
	brainmob.forceMove(src)
	brainmob.set_stat(CONSCIOUS)
	brainmob.SetSilence(0)
	brainmob.dna = new(brainmob)
	brainmob.dna.species = new /datum/species/machine() // Else it will default to human. And we don't want to clone IRC humans now do we?
	brainmob.dna.ResetSE()
	brainmob.dna.ResetUI()
	GLOB.dead_mob_list -= brainmob
	..()

/obj/item/mmi/robotic_brain/attack_ghost(mob/dead/observer/O)
	if(searching)
		volunteer(O)
		return
	if(brainmob && brainmob.key)
		return // No point pinging a posibrain with a player already inside
	if(check_observer(O) && (world.time >= next_ping_at))
		next_ping_at = world.time + (20 SECONDS)
		playsound(get_turf(src), 'sound/items/posiping.ogg', 80, 0)
		visible_message("<span class='notice'>[src] pings softly.</span>")

/obj/item/mmi/robotic_brain/positronic
	name = "positronic brain"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	blank_icon = "posibrain"
	searching_icon = "posibrain-searching"
	occupied_icon = "posibrain-occupied"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	silenced = TRUE
	requires_master = FALSE
	ejected_flavor_text = "metal cube"
	dead_icon = "posibrain"
