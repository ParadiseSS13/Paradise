/obj/item/mmi/robotic_brain
	name = "robotic brain"
	desc = "A Beta-level artifical intelligence core containing a non-sapient mechanical mind."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris_blank"
	var/blank_icon = "boris_blank"
	var/searching_icon = "boris_recharging"
	var/occupied_icon = "boris"
	origin_tech = "biotech=3;programming=3;plasmatech=2"
	req_access = list(ACCESS_ROBOTICS)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	var/searching = FALSE
	var/silenced = FALSE //if TRUE, they can't talk.
	var/next_ping_at = 0
	var/requires_master = TRUE
	var/mob/living/carbon/human/imprinted_master = null
	var/ejected_flavor_text = "circuit"
	/// If this is a posibrain, which will reject attempting to put a new ghost in it, because this a real brain we care about, not a robobrain
	var/can_be_reinhabited = TRUE
	dead_icon = "boris_blank"

/obj/item/mmi/robotic_brain/Destroy()
	imprinted_master = null
	return ..()

/obj/item/mmi/robotic_brain/attack_self__legacy__attackchain(mob/user)
	if(isgolem(user))
		to_chat(user, "<span class='warning'>Your golem fingers are too large to press the switch on [src].</span>")
		return
	if(requires_master && !imprinted_master)
		to_chat(user, "<span class='notice'>You press your thumb on [src] and imprint your user information.</span>")
		imprinted_master = user
		return
	if(brainmob && !brainmob.key && !searching && can_be_reinhabited)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start [src]'s boot process.</span>")
		request_player()
	else
		silenced = !silenced
		to_chat(user, "<span class='notice'>You toggle the speaker [silenced ? "off" : "on"].</span>")
		if(brainmob && brainmob.key)
			to_chat(brainmob, "<span class='warning'>Your internal speaker has been toggled [silenced ? "off" : "on"].</span>")

/obj/item/mmi/robotic_brain/proc/request_player()
	var/area/our_area = get_area(src)
	icon_state = searching_icon
	searching = TRUE
	notify_ghosts("A robotic brain has been activated in [our_area.name].", source = src, flashwindow = FALSE, action = NOTIFY_ATTACK)
	addtimer(CALLBACK(src, PROC_REF(reset_search)), 60 SECONDS)

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
	to_chat(brainmob, "<b>As a non-sapient synthetic intelligence, you answer to [imprinted_master], unless otherwise placed inside of a lawed synthetic structure or mech.</b>")
	to_chat(brainmob, "<b>Remember, the purpose of your existence is to serve [imprinted_master]'s every word, unless lawed  or placed into a mech in the future.</b>")
	brainmob.mind.assigned_role = "Positronic Brain"

	if(brainmob.has_ahudded())
		log_admin("[key_name(brainmob)] has joined as a robot brain, after having toggled antag hud.")
		message_admins("[key_name(brainmob)] has joined as a robot brain, after having toggled antag hud.")

	visible_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied(occupied_icon)

/obj/item/mmi/robotic_brain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(brainmob && brainmob.key || !searching)
		return

	searching = FALSE
	icon_state = blank_icon

	visible_message("<span class='notice'>[src] buzzes quietly as the light fades out. Perhaps you could try again?</span>")

/obj/item/mmi/robotic_brain/proc/volunteer(mob/dead/observer/user)
	if(!searching)
		return
	if(brainmob && brainmob.key)
		return // No, something is wrong, abort.
	if(!istype(user) && !HAS_TRAIT(user, TRAIT_RESPAWNABLE))
		to_chat(user, "<span class='warning'>Seems you're not a ghost. Could you please file an exploit report on the forums?</span>")
		return
	if(!validity_checks(user))
		to_chat(user, "<span class='warning'>You cannot be \a [src].</span>")
		return
	if(tgui_alert(user, "Are you sure you want to join as a robotic brain?", "Join as robobrain", list("Yes", "No")) != "Yes")
		return
	if(!searching)
		return
	if(!istype(user) && !HAS_TRAIT(user, TRAIT_RESPAWNABLE))
		to_chat(user, "<span class='warning'>Seems you're not a ghost. Could you please file an exploit report on the forums?</span>")
		return
	if(!validity_checks(user))
		to_chat(user, "<span class='warning'>You cannot be \a [src].</span>")
		return
	transfer_personality(user)

/obj/item/mmi/robotic_brain/proc/validity_checks(mob/dead/observer/O)
	if(istype(O))
		if(!O.check_ahud_rejoin_eligibility())
			return FALSE
		if(!(O.ghost_flags & GHOST_CAN_REENTER))
			return FALSE
	if(jobban_isbanned(O, "Cyborg") || jobban_isbanned(O, "nonhumandept"))
		return FALSE
	if(!HAS_TRAIT(O, TRAIT_RESPAWNABLE))
		return FALSE
	if(O.client)
		return TRUE
	return FALSE

/obj/item/mmi/robotic_brain/examine(mob/user)
	. = ..()
	. += "Its speaker is turned [silenced ? "off" : "on"]."

	var/list/msg = list("<span class='notice'>")

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
		if(EMP_HEAVY)
			brainmob.emp_damage += rand(20, 30)
		if(EMP_LIGHT)
			brainmob.emp_damage += rand(10, 20)
	..()

/obj/item/mmi/robotic_brain/New()
	brainmob = new(src)
	brainmob.name = "[pick("PBU", "HIU", "SINA", "ARMA", "OSI")]-[rand(100, 999)]"
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
	if(brainmob && brainmob.key)
		return // No point pinging a posibrain with a player already inside
	if(searching)
		volunteer(O)
		return
	if(validity_checks(O) && (world.time >= next_ping_at))
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
	requires_master = FALSE
	ejected_flavor_text = "metal cube"
	dead_icon = "posibrain"
	can_be_reinhabited = FALSE
