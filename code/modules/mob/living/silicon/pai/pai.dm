/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'//
	icon_state = "repairbot"

	robot_talk_understand = 0
	emote_type = 2		// pAIs emotes are heard, not seen, so they can be seen through a container (eg. person)
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE
	density = 0
	holder_type = /obj/item/holder/pai
	var/network = "SS13"
	var/obj/machinery/camera/current = null

	var/ram = 100	// Used as currency to purchase different abilities
	var/list/software = list()
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/paicard/card	// The card we inhabit
	var/obj/item/radio/radio		// Our primary radio

	var/chassis = "repairbot"   // A record of your chosen chassis.
	var/global/list/possible_chassis = list(
		"Drone" = "repairbot",
		"Cat" = "cat",
		"Mouse" = "mouse",
		"Monkey" = "monkey",
		"Corgi" = "borgi",
		"Fox" = "fox",
		"Parrot" = "parrot",
		"Box Bot" = "boxbot",
		"Spider Bot" = "spiderbot",
		"Fairy" = "fairy"
		)

	var/global/list/possible_say_verbs = list(
		"Robotic" = list("states","declares","queries"),
		"Natural" = list("says","yells","asks"),
		"Beep" = list("beeps","beeps loudly","boops"),
		"Chirp" = list("chirps","chirrups","cheeps"),
		"Feline" = list("purrs","yowls","meows"),
		"Canine" = list("yaps","barks","growls")
		)



	var/obj/item/pai_cable/cable		// The cable we produce and use when door or camera jacking

	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification
							// Keeping this separate from the laws var, it should be much more difficult to modify
	var/pai_law0 = "Serve your master."
	var/pai_laws				// String for additional operating instructions our master might give us

	var/silence_time			// Timestamp when we were silenced (normally via EMP burst), set to null after silence has faded

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/pda/silicon/pai/pda = null

	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	var/medical_cannotfind = 0
	var/datum/data/record/medicalActive1		// Datacore record declarations for record software
	var/datum/data/record/medicalActive2

	var/security_cannotfind = 0
	var/datum/data/record/securityActive1		// Could probably just combine all these into one
	var/datum/data/record/securityActive2

	var/obj/machinery/door/hackdoor		// The airlock being hacked
	var/hackprogress = 0				// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check
	var/hack_aborted = 0

	var/obj/item/integrated_radio/signal/sradio // AI's signaller

	var/translator_on = 0 // keeps track of the translator module
	var/flashlight_on = FALSE //keeps track of the flashlight module

	var/current_pda_messaging = null
	var/custom_sprite = 0
	var/slowdown = 0

/mob/living/silicon/pai/New(var/obj/item/paicard)
	loc = paicard
	card = paicard
	if(card)
		faction = card.faction.Copy()
	sradio = new(src)
	if(card)
		if(!card.radio)
			card.radio = new /obj/item/radio(card)
		radio = card.radio

	//Default languages without universal translator software
	add_language("Galactic Common", 1)
	add_language("Sol Common", 1)
	add_language("Tradeband", 1)
	add_language("Gutter", 1)
	add_language("Trinary", 1)

	//Verbs for pAI mobile form, chassis and Say flavor text
	verbs += /mob/living/silicon/pai/proc/choose_chassis
	verbs += /mob/living/silicon/pai/proc/choose_verbs

	//PDA
	pda = new(src)
	spawn(5)
		pda.ownjob = "Personal Assistant"
		pda.owner = text("[]", src)
		pda.name = pda.owner + " (" + pda.ownjob + ")"
		var/datum/data/pda/app/messenger/M = pda.find_program(/datum/data/pda/app/messenger)
		M.toff = 1
	..()

/mob/living/silicon/pai/Destroy()
	medicalActive1 = null
	medicalActive2 = null
	securityActive1 = null
	securityActive2 = null
	return ..()


/mob/living/silicon/pai/movement_delay()
	. = ..()
	. += slowdown
	. += 1 //A bit slower than humans, so they're easier to smash
	. += config.robot_delay

/mob/living/silicon/pai/update_icons()
	if(stat == DEAD)
		icon_state = "[chassis]_dead"
	else
		icon_state = resting ? "[chassis]_rest" : "[chassis]"

// this function shows the information about being silenced as a pAI in the Status panel
/mob/living/silicon/pai/proc/show_silenced()
	if(silence_time)
		var/timeleft = round((silence_time - world.timeofday)/10 ,1)
		stat(null, "Communications system reboot in -[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


/mob/living/silicon/pai/Stat()
	..()
	statpanel("Status")
	if(client.statpanel == "Status")
		show_silenced()

	if(proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/effect/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)

/mob/living/silicon/pai/check_eye(var/mob/user as mob)
	if(!current)
		return null
	user.reset_perspective(current)
	return 1

/mob/living/silicon/pai/blob_act()
	if(stat != DEAD)
		adjustBruteLoss(60)
		return 1
	return 0

/mob/living/silicon/pai/restrained()
	if(istype(loc,/obj/item/paicard))
		return 0
	..()

/mob/living/silicon/pai/MouseDrop(atom/over_object)
	return

/mob/living/silicon/pai/emp_act(severity)
	// Silence for 2 minutes
	// 20% chance to kill
		// 33% chance to unbind
		// 33% chance to change prime directive (based on severity)
		// 33% chance of no additional effect

	silence_time = world.timeofday + 120 * 10		// Silence for 2 minutes
	to_chat(src, "<font color=green><b>Communication circuit overload. Shutting down and reloading communication circuits - speech and messaging functionality will be unavailable until the reboot is complete.</b></font>")
	if(prob(20))
		var/turf/T = get_turf_or_move(loc)
		for(var/mob/M in viewers(T))
			M.show_message("<span class='warning'>A shower of sparks spray from [src]'s inner workings.</span>", 3, "<span class='warning'>You hear and smell the ozone hiss of electrical sparks being expelled violently.</span>", 2)
		return death(0)

	switch(pick(1,2,3))
		if(1)
			master = null
			master_dna = null
			to_chat(src, "<font color=green>You feel unbound.</font>")
		if(2)
			var/command
			if(severity  == 1)
				command = pick("Serve", "Love", "Fool", "Entice", "Observe", "Judge", "Respect", "Educate", "Amuse", "Entertain", "Glorify", "Memorialize", "Analyze")
			else
				command = pick("Serve", "Kill", "Love", "Hate", "Disobey", "Devour", "Fool", "Enrage", "Entice", "Observe", "Judge", "Respect", "Disrespect", "Consume", "Educate", "Destroy", "Disgrace", "Amuse", "Entertain", "Ignite", "Glorify", "Memorialize", "Analyze")
			pai_law0 = "[command] your master."
			to_chat(src, "<font color=green>Pr1m3 d1r3c71v3 uPd473D.</font>")
		if(3)
			to_chat(src, "<font color=green>You feel an electric surge run through your circuitry and become acutely aware at how lucky you are that you can still feel at all.</font>")

/mob/living/silicon/pai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			if(stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if(stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(stat != 2)
				adjustBruteLoss(30)

	return


// See software.dm for Topic()

/mob/living/silicon/pai/attack_animal(mob/living/simple_animal/M)
	if((M.a_intent == INTENT_HELP && M.ckey) || M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src].")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='danger'>[M]</span> [M.attacktext] [src]!", 1)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		add_attack_logs(M, src, "Animal attacked for [damage] damage")
		adjustBruteLoss(damage)

/mob/living/silicon/pai/proc/switchCamera(var/obj/machinery/camera/C)
	usr:cameraFollow = null
	if(!C)
		unset_machine()
		reset_perspective(null)
		return 0
	if(stat == 2 || !C.status || !(network in C.network)) return 0

	// ok, we're alive, camera is good and in our network...

	set_machine(src)
	src:current = C
	reset_perspective(C)
	return 1

/mob/living/silicon/pai/verb/reset_record_view()
	set category = "pAI Commands"
	set name = "Reset Records Software"

	securityActive1 = null
	securityActive2 = null
	security_cannotfind = 0
	medicalActive1 = null
	medicalActive2 = null
	medical_cannotfind = 0
	SSnanoui.update_uis(src)
	to_chat(usr, "<span class='notice'>You reset your record-viewing software.</span>")

/mob/living/silicon/pai/cancel_camera()
	set category = "pAI Commands"
	set name = "Cancel Camera View"
	reset_perspective(null)
	unset_machine()
	src:cameraFollow = null

//Addition by Mord_Sith to define AI's network change ability
/*
/mob/living/silicon/pai/proc/pai_network_change()
	set category = "pAI Commands"
	set name = "Change Camera Network"
	reset_perspective(null)
	unset_machine()
	src:cameraFollow = null
	var/cameralist[0]

	if(usr.stat == 2)
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	for(var/obj/machinery/camera/C in Cameras)
		if(!C.status)
			continue
		else
			if(C.network != "CREED" && C.network != "thunder" && C.network != "RD" && C.network != "toxins" && C.network != "Prison") COMPILE ERROR! This will have to be updated as camera.network is no longer a string, but a list instead
				cameralist[C.network] = C.network

	network = input(usr, "Which network would you like to view?") as null|anything in cameralist
	to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")
//End of code by Mord_Sith
*/


/*
// Debug command - Maybe should be added to admin verbs later
/mob/verb/makePAI(var/turf/t in view())
	var/obj/item/paicard/card = new(t)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = key
	card.setPersonality(pai)

*/

// Procs/code after this point is used to convert the stationary pai item into a
// mobile pai mob. This also includes handling some of the general shit that can occur
// to it. Really this deserves its own file, but for the moment it can sit here. ~ Z

/mob/living/silicon/pai/verb/fold_out()
	set category = "pAI Commands"
	set name = "Unfold Chassis"

	if(stat || sleeping || paralysis || weakened)
		return

	if(loc != card)
		to_chat(src, "<span class='warning'>You are already in your mobile form!</span>")
		return

	if(world.time <= last_special)
		to_chat(src, "<span class='warning'>You must wait before folding your chassis out again!</span>")
		return

	last_special = world.time + 200

	//I'm not sure how much of this is necessary, but I would rather avoid issues.
	force_fold_out()

	visible_message("<span class='notice'>[src] folds outwards, expanding into a mobile form.</span>", "<span class='notice'>You fold outwards, expanding into a mobile form.</span>")

/mob/living/silicon/pai/proc/force_fold_out()
	if(istype(card.loc, /mob))
		var/mob/holder = card.loc
		holder.unEquip(card)
	else if(istype(card.loc, /obj/item/pda))
		var/obj/item/pda/holder = card.loc
		holder.pai = null

	forceMove(get_turf(card))

	card.forceMove(src)
	card.screen_loc = null

/mob/living/silicon/pai/verb/fold_up()
	set category = "pAI Commands"
	set name = "Collapse Chassis"

	if(stat || sleeping || paralysis || weakened)
		return

	if(loc == card)
		to_chat(src, "<span class='warning'>You are already in your card form!</span>")
		return

	if(world.time <= last_special)
		to_chat(src, "<span class='warning'>You must wait before returning to your card form!</span>")
		return

	close_up()

/mob/living/silicon/pai/proc/choose_chassis()
	set category = "pAI Commands"
	set name = "Choose Chassis"

	var/list/my_choices = list()
	var/choice
	var/finalized = "No"

	//check for custom_sprite
	if(!custom_sprite)
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2 || Entry[1] != "pai")			//ignore incorrectly formatted entries or entries that aren't marked for pAI
				continue

			if(Entry[2] == ckey)							//They're in the list? Custom sprite time, var and icon change required
				custom_sprite = 1
				my_choices["Custom"] = "[ckey]-pai"

	my_choices = possible_chassis.Copy()
	if(custom_sprite)
		my_choices["Custom"] = "[ckey]-pai"

	if(loc == card)		//don't let them continue in card form, since they won't be able to actually see their new mobile form sprite.
		to_chat(src, "<span class='warning'>You must be in your mobile form to reconfigure your chassis.</span>")
		return

	while(finalized == "No" && client)
		choice = input(usr,"What would you like to use for your mobile chassis icon? This decision can only be made once.") as null|anything in my_choices
		if(!choice) return
		if(choice == "Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		else
			icon = 'icons/mob/pai.dmi'
		icon_state = my_choices[choice]
		finalized = alert("Look at your sprite. Is this what you wish to use?",,"No","Yes")

	chassis = my_choices[choice]
	verbs -= /mob/living/silicon/pai/proc/choose_chassis

/mob/living/silicon/pai/proc/choose_verbs()
	set category = "pAI Commands"
	set name = "Choose Speech Verbs"

	var/choice = input(usr,"What theme would you like to use for your speech verbs? This decision can only be made once.") as null|anything in possible_say_verbs
	if(!choice) return

	var/list/sayverbs = possible_say_verbs[choice]
	speak_statement = sayverbs[1]
	speak_exclamation = sayverbs[(sayverbs.len>1 ? 2 : sayverbs.len)]
	speak_query = sayverbs[(sayverbs.len>2 ? 3 : sayverbs.len)]

	verbs -= /mob/living/silicon/pai/proc/choose_verbs


/mob/living/silicon/pai/lay_down()
	set name = "Rest"
	set category = "IC"

	// Pass lying down or getting up to our pet human, if we're in a rig.
	if(stat == CONSCIOUS && istype(loc,/obj/item/paicard))
		resting = 0
		var/obj/item/rig/rig = get_rig()
		if(istype(rig))
			rig.force_rest(src)
	else
		resting = !resting
		to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>")

	update_icons()
	update_canmove()

//Overriding this will stop a number of headaches down the track.
/mob/living/silicon/pai/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = W
		if(stat == DEAD)
			to_chat(user, "<span class='danger'>\The [src] is beyond help, at this point.</span>")
		else if(getBruteLoss() || getFireLoss())
			heal_overall_damage(15, 15)
			N.use(1)
			user.visible_message("<span class='notice'>[user.name] applied some [W] at [src]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [W] at [name]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [name]'s systems are nominal.</span>")

		return
	else if(W.force)
		visible_message("<span class='danger'>[user.name] attacks [src] with [W]!</span>")
		adjustBruteLoss(W.force)
	else
		visible_message("<span class='warning'>[user.name] bonks [src] harmlessly with [W].</span>")
	spawn(1)
		if(stat != 2)
			close_up()
	return

/mob/living/silicon/pai/attack_hand(mob/user as mob)
	if(stat == DEAD)
		return
	if(user.a_intent == INTENT_HELP)
		user.visible_message("<span class='notice'>[user] pets [src].</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		visible_message("<span class='danger'>[user.name] boops [src] on the head.</span>")
		spawn(1)
			close_up()

//I'm not sure how much of this is necessary, but I would rather avoid issues.
/mob/living/silicon/pai/proc/close_up()

	last_special = world.time + 200
	resting = 0
	if(loc == card)
		return

	visible_message("<span class='notice'>[src] neatly folds inwards, compacting down to a rectangular card.</span>", "<span class='notice'>You neatly fold inwards, compacting down to a rectangular card.</span>")

	stop_pulling()
	reset_perspective(card)

// If we are being held, handle removing our holder from their inv.
	var/obj/item/holder/H = loc
	if(istype(H))
		var/mob/living/M = H.loc
		if(istype(M))
			M.unEquip(H)
		H.loc = get_turf(src)
		loc = get_turf(H)

	// Move us into the card and move the card to the ground
	//This seems redundant but not including the forced loc setting messes the behavior up.
	loc = card
	card.loc = get_turf(card)
	forceMove(card)
	card.forceMove(card.loc)
	icon_state = "[chassis]"

/mob/living/silicon/pai/Bump()
	return

/mob/living/silicon/pai/Bumped()
	return

/mob/living/silicon/pai/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/silicon/pai/update_canmove(delay_action_updates = 0)
	. = ..()
	density = 0 //this is reset every canmove update otherwise

/mob/living/silicon/pai/examine(mob/user)
	to_chat(user, "<span class='info'>*---------*</span>")
	..(user)

	var/msg = "<span class='info'>"

	switch(stat)
		if(CONSCIOUS)
			if(!client)	msg += "\nIt appears to be in stand-by mode." //afk
		if(UNCONSCIOUS)		msg += "\n<span class='warning'>It doesn't seem to be responding.</span>"
		if(DEAD)			msg += "\n<span class='deadsay'>It looks completely unsalvageable.</span>"

	if(print_flavor_text()) msg += "\n[print_flavor_text()]"

	if(pose)
		if( findtext(pose,".",lentext(pose)) == 0 && findtext(pose,"!",lentext(pose)) == 0 && findtext(pose,"?",lentext(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"
	msg += "\n*---------*</span>"

	to_chat(user, msg)

/mob/living/silicon/pai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	if(stat != 2)
		spawn(1)
			close_up()
	return 2

// No binary for pAIs.
/mob/living/silicon/pai/binarycheck()
	return 0

// Handle being picked up.


/mob/living/silicon/pai/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(resting)
		icon_state = "[chassis]"
		resting = 0
	if(custom_sprite)
		H.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		H.icon_override = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.icon_state = "[icon_state]"
		H.item_state = "[icon_state]_hand"
	else
		H.icon_state = "pai-[icon_state]"
		H.item_state = "pai-[icon_state]"
	grabber.put_in_active_hand(H)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H

/mob/living/silicon/pai/MouseDrop(atom/over_object)
	var/mob/living/carbon/human/H = over_object //changed to human to avoid stupid issues like xenos holding pAIs.
	if(!istype(H) || !Adjacent(H))  return ..()
	if(usr == src)
		switch(alert(H, "[src] wants you to pick [p_them()] up. Do it?",,"Yes","No"))
			if("Yes")
				if(Adjacent(H))
					get_scooped(H)
				else
					to_chat(src, "<span class='warning'>You need to stay in reaching distance to be picked up.</span>")
			if("No")
				to_chat(src, "<span class='warning'>[H] decided not to pick you up.</span>")
	else
		if(Adjacent(H))
			get_scooped(H)
		else
			return ..()

/mob/living/silicon/pai/on_forcemove(atom/newloc)
	if(card)
		card.loc = newloc
	else //something went very wrong.
		CRASH("pAI without card")
	loc = card

/mob/living/silicon/pai/extinguish_light()
	flashlight_on = FALSE
	set_light(0)
	card.set_light(0)
