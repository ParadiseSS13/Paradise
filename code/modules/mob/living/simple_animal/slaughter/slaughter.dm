//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "Slaughter Demon"
	real_name = "Slaughter Demon"
	desc = "You should run."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	speed = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/misc/demon_attack1.ogg'
	min_oxy = 0
	max_oxy = INFINITY
	min_tox = 0
	max_tox = INFINITY
	min_co2 = 0
	max_co2 = INFINITY
	min_n2  = 0
	max_n2  = INFINITY
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	environment_smash = 1
	//universal_understand = 1
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	var/boost = 0
	bloodcrawl = BLOODCRAWL_EAT


	var/devoured = 0

	var/list/nearby_mortals = list()
	var/cooldown = 0
	var/gorecooldown = 0
	var/vialspawned = FALSE
	var/playstyle_string = "<B>You are the Slaughter Demon, a terrible creature from another existence. You have a single desire: To kill.  \
						You may Ctrl+Click on blood pools to travel through them, appearing and dissaapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. \
						You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"


/mob/living/simple_animal/slaughter/New()
	..()
	spawn()
		if(src.mind)
			src.mind.current.verbs += /mob/living/simple_animal/slaughter/proc/slaughterWhisper
			src << src.playstyle_string
			src << "<B><span class ='notice'>You are not currently in the same plane of existence as the station. Ctrl+Click a blood pool to manifest.</span></B>"
			if(!(vialspawned))
				var/datum/objective/slaughter/objective = new
				var/datum/objective/demonFluff/fluffObjective = new
				ticker.mode.traitors |= src.mind
				objective.owner = src.mind
				fluffObjective.owner = src.mind
				//Paradise Port:I added the objective for one spawned like this
				src.mind.objectives += objective
				src.mind.objectives += fluffObjective
				src << "<B>Objective #[1]</B>: [objective.explanation_text]"
				src << "<B>Objective #[2]</B>: [fluffObjective.explanation_text]"


/mob/living/simple_animal/slaughter/Life()
	..()
	if(boost<world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/slaughter/Die()
	..()
	new /obj/effect/decal/cleanable/blood (src.loc)
	new /obj/effect/gibspawner/generic(get_turf(src))
	new /obj/effect/gibspawner/generic(get_turf(src))
	playsound(get_turf(src),'sound/misc/demon_dies.ogg', 200, 1)
	new /obj/item/weapon/demonheart (src.loc)
	visible_message("<span class='danger'>The [src] screams in anger as its form collapes into a pool of viscera.</span>")
	ghostize()
	qdel(src)



/mob/living/simple_animal/slaughter/phasein()
	..()
	speed = 0
	boost = world.time + 30

/mob/living/simple_animal/slaughter/say(message)
	return 0
////////////////////The Powers

//Paradise Port:I added this cuase..SPOOPY DEMON IN YOUR BRAIN


/mob/living/simple_animal/slaughter/proc/slaughterWhisper()
	set name = "Whisper"
	set desc = "Whisper to a mortal"
	set category = "Daemon"

	var/list/choices = list()
	for(var/mob/living/carbon/C in living_mob_list)
		if(C.stat != 2 && C.client && C.stat != DEAD)
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to talk to?") in null|choices
	spawn(0)
		var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
		if(!(msg))
			return
		usr << "<span class='info'><b>You whisper to [M]:</b> [msg]</span>"
		M << "<span class='deadsay'><b>Suddenly a strange,demonic,voice resonates in your head...</b></span><i><span class='danger'> [msg]</span></I>"

//////////The Loot

/obj/item/weapon/demonheart
	name = "demon's heart"
	desc = "It's still faintly beating with rage"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	origin_tech = "combat=5;biotech=8"


/obj/item/weapon/demonheart/attack_self(mob/living/user)
	visible_message("[user] feasts upon the [src].")
	if(user.bloodcrawl == 0)
		user << "You absorb some of the demon's power!"
		user.bloodcrawl = BLOODCRAWL
	else if(user.bloodcrawl == 1)
		user << "You absorb some of the demon's power!"
		user << "You feel diffr-<span class = 'danger'> CONSUME THEM! </span>"
		user.bloodcrawl = BLOODCRAWL_EAT
	qdel(src)


//Objectives and helpers.

//Objective info, Based on Reverent mini Atang
/datum/objective/slaughter
	var/targetKill = 10

/datum/objective/slaughter/New()
	targetKill = rand(10,20)
	explanation_text = "Devour [targetKill] mortals."
	..()

/datum/objective/slaughter/check_completion()
	if(!istype(owner.current, /mob/living/simple_animal/slaughter) || !owner.current)
		return 0
	var/mob/living/simple_animal/slaughter/R = owner.current
	if(!R || R.stat == DEAD)
		return 0
	var/deathCount = R.devoured
	if(deathCount < targetKill)
		return 0
	return 1

/datum/objective/demonFluff


/datum/objective/demonFluff/New()
	find_target()
	var/targetname = "someone"
	if(target && target.current)
		targetname = target.current.real_name
	var/list/explanationTexts = list("Attempt to make your presence unknown to the crew.", \
									 "Kill or Destroy all Janitors or Sanitation bots.", \
									 "Drive [targetname] insane with demonic whispering."
									 )

	explanation_text = pick(explanationTexts)
	..()

/datum/objective/demonFluff/check_completion()
	return 1