/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'//
	icon_state = "repairbot"

	emote_type = 2		// pAIs emotes are heard, not seen, so they can be seen through a container (eg. person)
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE
	density = FALSE
	holder_type = /obj/item/holder/pai

	var/ram = 100	// Used as currency to purchase different abilities
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
		"Fairy" = "fairy",
		"Snake" = "snake"
		)

	var/global/list/possible_say_verbs = list(
		"Robotic" = list("states","declares","queries"),
		"Natural" = list("says","yells","asks"),
		"Beep" = list("beeps","beeps loudly","boops"),
		"Chirp" = list("chirps","chirrups","cheeps"),
		"Feline" = list("purrs","yowls","meows"),
		"Canine" = list("yaps","barks","growls"),
		"Hiss" = list("hisses","hisses","hisses")
		)


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

	var/secHUD = FALSE			// Toggles whether the Security HUD is active or not
	var/medHUD = FALSE			// Toggles whether the Medical  HUD is active or not
	var/dHUD = FALSE			// Toggles whether the Diagnostic HUD is active or not

	/// Currently active software
	var/datum/pai_software/active_software

	/// List of all installed software
	var/list/datum/pai_software/installed_software = list()

	/// Integrated remote signaler for signalling
	var/obj/item/assembly/signaler/integ_signaler

	var/translator_on = FALSE // keeps track of the translator module
	var/flashlight_on = FALSE //keeps track of the flashlight module

	var/current_pda_messaging = null
	var/custom_sprite = FALSE
	var/slowdown = 0
	var/speech_state = "Robotic" // Needed for TGUI shit

/mob/living/silicon/pai/Initialize(mapload)
	. = ..()

	if(istype(loc, /obj/item/paicard))
		card = loc
	else
		card = new(get_turf(src))
		forceMove(card)
		card.setPersonality(src)

	if(card)
		faction = card.faction.Copy()

	integ_signaler = new(src)

	if(card)
		if(!card.radio)
			card.radio = new /obj/item/radio(card)
		radio = card.radio

	//Default languages without universal translator software
	add_language("Sol Common")
	add_language("Tradeband")
	add_language("Gutter")
	add_language("Trinary")

	AddSpell(new /obj/effect/proc_holder/spell/access_software_pai)
	AddSpell(new /obj/effect/proc_holder/spell/unfold_chassis_pai)

	//PDA
	pda = new(src)
	pda.ownjob = "Personal Assistant"
	pda.owner = "[src]"
	pda.name = "[pda.owner] ([pda.ownjob])"
	var/datum/data/pda/app/messenger/M = pda.find_program(/datum/data/pda/app/messenger)
	M.toff = TRUE

	// Software modules. No these var names have nothing to do with photoshop
	for(var/PS in subtypesof(/datum/pai_software))
		var/datum/pai_software/PSD = new PS(src)
		if(PSD.default)
			installed_software[PSD.id] = PSD

	active_software = installed_software["mainmenu"] // Default us to the main menu

/mob/living/silicon/pai/can_unbuckle()
	return FALSE

/mob/living/silicon/pai/can_buckle()
	return FALSE

/mob/living/silicon/pai/movement_delay()
	. = ..()
	. += slowdown
	. += 1 //A bit slower than humans, so they're easier to smash
	. += GLOB.configuration.movement.robot_delay

/mob/living/silicon/pai/update_icons()
	if(stat == DEAD)
		icon_state = "[chassis]_dead"
	else
		icon_state = resting ? "[chassis]_rest" : "[chassis]"
	update_icon(UPDATE_OVERLAYS)

/mob/living/silicon/pai/update_fire()
	update_icon(UPDATE_OVERLAYS)

/mob/living/silicon/pai/update_overlays()
	. = ..()
	if(on_fire)
		. += image("icon" = 'icons/mob/OnFire.dmi', "icon_state" = "Generic_mob_burning")

// this function shows the information about being silenced as a pAI in the Status panel
/mob/living/silicon/pai/proc/show_silenced()
	if(silence_time)
		var/timeleft = round((silence_time - world.timeofday)/10 ,1)
		stat(null, "Communications system reboot in -[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


/mob/living/silicon/pai/Stat()
	..()
	if(statpanel("Status"))
		show_silenced()

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

	switch(pick(1, 2, 3))
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
			if(stat != DEAD)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if(stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(stat != DEAD)
				adjustBruteLoss(30)

// See software.dm for ui_act()

/mob/living/silicon/pai/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		add_attack_logs(M, src, "Animal attacked for [damage] damage")
		adjustBruteLoss(damage)

// Procs/code after this point is used to convert the stationary pai item into a
// mobile pai mob. This also includes handling some of the general shit that can occur
// to it. Really this deserves its own file, but for the moment it can sit here. ~ Z

/obj/effect/proc_holder/spell/unfold_chassis_pai
	name = "Unfold/Fold Chassis"
	desc = "Allows you to fold in/out of your mobile form."
	clothes_req = FALSE
	base_cooldown = 20 SECONDS
	action_icon_state = "repairbot"
	action_background_icon_state = "bg_tech_blue"

/obj/effect/proc_holder/spell/unfold_chassis_pai/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/unfold_chassis_pai/cast(list/targets, mob/living/user = usr)
	var/mob/living/silicon/pai/pai_user = user

	if(pai_user.loc != pai_user.card)
		pai_user.close_up()
		return TRUE
	pai_user.force_fold_out()

	pai_user.visible_message("<span class='notice'>[pai_user] folds outwards, expanding into a mobile form.</span>", "<span class='notice'>You fold outwards, expanding into a mobile form.</span>")
	return TRUE

/mob/living/silicon/pai/proc/force_fold_out()
	if(ismob(card.loc))
		var/mob/holder = card.loc
		holder.unEquip(card)
	else if(istype(card.loc, /obj/item/pda))
		var/obj/item/pda/holder = card.loc
		holder.pai = null

	forceMove(get_turf(card))

	card.forceMove(src)
	card.screen_loc = null

/mob/living/silicon/pai/rest()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	if(resting)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT)

	to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>")

	update_icons()

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

/mob/living/silicon/pai/welder_act()
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
	stand_up()
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

/mob/living/silicon/pai/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	return FALSE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()

	var/msg = "<span class='info'>"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += "\nIt appears to be in stand-by mode." //afk
		if(UNCONSCIOUS)
			msg += "\n<span class='warning'>It doesn't seem to be responding.</span>"
		if(DEAD)
			msg += "\n<span class='deadsay'>It looks completely unsalvageable.</span>"

	if(print_flavor_text())
		msg += "\n[print_flavor_text()]"

	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"
	msg += "\n</span>"

	. += msg

/mob/living/silicon/pai/bullet_act(obj/item/projectile/Proj)
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
	if(stat == DEAD)
		H.icon = 'icons/mob/pai.dmi'
		H.icon_state = "[chassis]_dead"
		return
	if(resting)
		icon_state = "[chassis]"
		resting = FALSE
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT)
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

/mob/living/silicon/pai/extinguish_light(force = FALSE)
	flashlight_on = FALSE
	set_light(0)
	card.set_light(0)

/mob/living/silicon/pai/update_runechat_msg_location()
	if(istype(loc, /obj/item/paicard))
		runechat_msg_location = loc.UID()
	else
		return ..()
