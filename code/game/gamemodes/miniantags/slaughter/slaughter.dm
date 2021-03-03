//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales. You should run."
	speak = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	speed = 1
	a_intent = INTENT_HARM
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/misc/demon_attack1.ogg'
	var/feast_sound = 'sound/misc/demon_consume.ogg'
	death_sound = 'sound/misc/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	environment_smash = 1
	//universal_understand = 1
	obj_damage = 50
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/boost = 0


	var/devoured = 0
	var/list/consumed_mobs = list()

	var/list/nearby_mortals = list()
	var/cooldown = 0
	var/gorecooldown = 0
	var/vialspawned = FALSE
	loot = list(/obj/effect/decal/cleanable/blood/innards, /obj/effect/decal/cleanable/blood, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic, /obj/item/organ/internal/heart/demon)
	var/playstyle_string = "<B>You are the Slaughter Demon, a terrible creature from another existence. You have a single desire: to kill.  \
						You may use the blood crawl icon when on blood pools to travel through them, appearing and dissapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. \
						You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"
	del_on_death = 1
	deathmessage = "screams in anger as it collapses into a puddle of viscera!"

	var/datum/action/innate/demon/whisper/whisper_action


/mob/living/simple_animal/slaughter/New()
	..()
	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	whisper_action = new()
	whisper_action.Grant(src)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = 1
	addtimer(CALLBACK(src, .proc/attempt_objectives), 5 SECONDS)


/mob/living/simple_animal/slaughter/Life(seconds, times_fired)
	..()
	if(boost < world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/slaughter/proc/attempt_objectives()
	if(mind)
		to_chat(src, src.playstyle_string)
		to_chat(src, "<B><span class ='notice'>You are not currently in the same plane of existence as the station. Use the blood crawl action at a blood pool to manifest.</span></B>")
		SEND_SOUND(src, sound('sound/misc/demon_dies.ogg'))
		if(!(vialspawned))
			var/datum/objective/slaughter/objective = new
			var/datum/objective/demonFluff/fluffObjective = new
			SSticker.mode.traitors |= mind
			objective.owner = mind
			fluffObjective.owner = mind
			//Paradise Port:I added the objective for one spawned like this
			mind.objectives += objective
			mind.objectives += fluffObjective
			to_chat(src, "<B>Objective #[1]</B>: [objective.explanation_text]")
			to_chat(src, "<B>Objective #[2]</B>: [fluffObjective.explanation_text]")


/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."

/mob/living/simple_animal/slaughter/Destroy()
	// Only execute the below if we successfully died
	for(var/mob/living/M in consumed_mobs)
		release_consumed(M)
	. = ..()

/mob/living/simple_animal/slaughter/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))

/mob/living/simple_animal/slaughter/phasein()
	. = ..()
	speed = 0
	boost = world.time + 60

// Cult slaughter demon
/mob/living/simple_animal/slaughter/cult //Summoned as part of the cult objective "Bring the Slaughter"
	name = "harbinger of the slaughter"
	real_name = "harbinger of the Slaughter"
	desc = "An awful creature from beyond the realms of madness."
	maxHealth = 500
	health = 500
	melee_damage_upper = 60
	melee_damage_lower = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS //Smashes through EVERYTHING - r-walls included
	faction = list("cult")
	playstyle_string = "<b><span class='userdanger'>You are a Harbinger of the Slaughter.</span> Brought forth by the servants of Nar'Sie, you have a single purpose: slaughter the heretics \
	who do not worship your master. You may use the ability 'Blood Crawl' near a pool of blood to enter it and become incorporeal. Using the ability again near a blood pool will allow you \
	to emerge from it. You are fast, powerful, and almost invincible. By dragging a dead or unconscious body into a blood pool with you, you will consume it after a time and fully regain \
	your health. You may use the ability 'Sense Victims' in your Cultist tab to locate a random, living heretic.</span></b>"

/obj/effect/proc_holder/spell/targeted/sense_victims
	name = "Sense Victims"
	desc = "Sense the location of heretics"
	charge_max = 0
	clothes_req = 0
	range = 20
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_cult"
	panel = "Demon"

/obj/effect/proc_holder/spell/targeted/sense_victims/cast(list/targets, mob/user)
	var/list/victims = targets
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(!L.stat && !iscultist(L) && L.key && L != usr)
			victims.Add(L)
	if(!targets.len)
		to_chat(usr, "<span class='warning'>You could not locate any sapient heretics for the Slaughter.</span>")
		return 0
	var/mob/living/victim = pick(victims)
	to_chat(victim, "<span class='userdanger'>You feel an awful sense of being watched...</span>")
	victim.Stun(3) //HUE
	var/area/A = get_area(victim)
	if(!A)
		to_chat(usr, "<span class='warning'>You could not locate any sapient heretics for the Slaughter.</span>")
		return 0
	to_chat(usr, "<span class='danger'>You sense a terrified soul at [A]. <b>Show [A.p_them()] the error of [A.p_their()] ways.</b></span>")

/mob/living/simple_animal/slaughter/cult/New()
	..()
	spawn(5)
		var/list/demon_candidates = SSghost_spawns.poll_candidates("Do you want to play as a slaughter demon?", ROLE_DEMON, TRUE, 10 SECONDS, source = /mob/living/simple_animal/slaughter/cult)
		if(!demon_candidates.len)
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return
		var/mob/M = pick(demon_candidates)
		var/mob/living/simple_animal/slaughter/cult/S = src
		if(!M || !M.client)
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return
		var/client/C = M.client

		S.key = C.key
		S.mind.assigned_role = "Harbinger of the Slaughter"
		S.mind.special_role = "Harbinger of the Slaughter"
		to_chat(S, playstyle_string)
		SSticker.mode.add_cultist(S.mind)
		var/obj/effect/proc_holder/spell/targeted/sense_victims/SV = new
		AddSpell(SV)
		var/datum/objective/new_objective = new /datum/objective
		new_objective.owner = S.mind
		new_objective.explanation_text = "Bring forth the Slaughter to the nonbelievers."
		S.mind.objectives += new_objective
		to_chat(S, "<B>Objective #[1]</B>: [new_objective.explanation_text]")

////////////////////The Powers

//Paradise Port: I added this because..SPOOPY DEMON IN YOUR BRAIN


/datum/action/innate/demon/whisper
	name = "Demonic Whisper"
	button_icon_state = "cult_comms"
	background_icon_state = "bg_demon"

/datum/action/innate/demon/whisper/IsAvailable()
	return ..()

/datum/action/innate/demon/whisper/proc/choose_targets(mob/user = usr)//yes i am copying from telepathy..hush...
	var/list/validtargets = list()
	for(var/mob/living/M in view(user.client.view, get_turf(user)))
		if(M && M.mind && M.stat != DEAD)
			if(M == user)
				continue

			validtargets += M

	if(!validtargets.len)
		to_chat(usr, "<span class='warning'>There are no valid targets!</span>")
		return

	var/mob/living/target = input("Choose the target to talk to.", "Targeting") as null|mob in validtargets
	return target

/datum/action/innate/demon/whisper/Activate()
	var/mob/living/choice = choose_targets()
	if(!choice)
		return

	var/msg = stripped_input(usr, "What do you wish to tell [choice]?", null, "")
	if(!(msg))
		return
	log_say("(SLAUGHTER to [key_name(choice)]) [msg]", usr)
	to_chat(usr, "<span class='info'><b>You whisper to [choice]: </b>[msg]</span>")
	to_chat(choice, "<span class='deadsay'><b>Suddenly a strange, demonic voice resonates in your head... </b></span><i><span class='danger'> [msg]</span></I>")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>Demonic message from <b>[usr]</b> ([ghost_follow_link(usr, ghost=G)]) to <b>[choice]</b> ([ghost_follow_link(choice, ghost=G)]): [msg]</i>")


//////////The Loot

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=7"

/obj/item/organ/internal/heart/demon/update_icon()
	return //always beating visually

/obj/item/organ/internal/heart/demon/prepare_eat()
	return // Just so people don't accidentally waste it

/obj/item/organ/internal/heart/demon/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
						 "<span class='danger'>An unnatural hunger consumes you. You raise [src] to your mouth and devour it!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, 1)

	// Eating the heart for the first time. Gives basic bloodcrawling. This is the only time we need to insert the heart.
	if(!HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		user.visible_message("<span class='warning'>[user]'s eyes flare a deep crimson!</span>", \
						 "<span class='userdanger'>You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!</span>")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL, "bloodcrawl")
		user.drop_item()
		insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E.
		return TRUE

	// Eating a 2nd heart. Gives the ability to drag people into blood and eat them.
	if(HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		to_chat(user, "You feel differ-<span class = 'danger'> CONSUME THEM! </span>")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		qdel(src) // Replacing their demon heart with another demon heart is pointless, just delete this one and return.
		return TRUE

	// Eating any more than 2 demon hearts does nothing.
	to_chat(user, "<span class='warning'>...and you don't feel any different.</span>")
	qdel(src)

/obj/item/organ/internal/heart/demon/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/internal/heart/demon/remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL, "bloodcrawl")
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)

/obj/item/organ/internal/heart/demon/Stop()
	return 0 // Always beating.


/mob/living/simple_animal/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles", "titters", "chuckles")
	emote_hear = list("gaffaws", "laughs")
	response_help  = "hugs"
	attacktext = "wildly tickles"
	maxHealth = 175
	health = 175
	melee_damage_lower = 25
	melee_damage_upper = 25
	playstyle_string = "<B>You are the Laughter Demon, an adorable creature from another existence. You have a single desire: to hug and tickle.  \
						You may use the blood crawl icon when on blood pools to travel through them, appearing and dissapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to hug them. \
						You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. \
						(You should be attacking people on harm intent, and not nuzzling them.)</B>"

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	death_sound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	deathmessage = "fades out, as all of its friends are released from its prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

/mob/living/simple_animal/slaughter/laughter/release_consumed(mob/living/M)
	if(M.revive())
		M.grab_ghost(force = TRUE)
		playsound(get_turf(src), feast_sound, 50, 1, -1)
		to_chat(M, "<span class='clown'>You leave [src]'s warm embrace, and feel ready to take on the world.</span>")
	..(M)


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
	var/list/explanationTexts = list("Spread blood all over the bridge.", \
									 "Spread blood all over the brig.", \
									 "Spread blood all over the chapel.", \
									 "Kill or Destroy all Janitors or Sanitation bots.", \
									 "Spare a few after striking them... make them bleed before the harvest.", \
									 "Hunt those that try to hunt you first.", \
									 "Hunt those that run away from you in fear", \
									 "Show [targetname] the power of blood.", \
									 "Drive [targetname] insane with demonic whispering."
									 )

	explanation_text = pick(explanationTexts)
	..()

/datum/objective/demonFluff/check_completion()
	return 1
