//////////////////The Monster

/mob/living/simple_animal/demon/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales. You should run."
	maxHealth = 240
	health = 240
	speak = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	var/boost = 0
	var/feast_sound = 'sound/misc/demon_consume.ogg'
	var/devoured = 0
	var/list/consumed_mobs = list()

	var/list/nearby_mortals = list()
	var/cooldown = 0
	var/gorecooldown = 0
	var/vialspawned = FALSE
	loot = list(/obj/effect/decal/cleanable/blood/innards, /obj/effect/decal/cleanable/blood, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic, /obj/item/organ/internal/heart/demon/slaughter)
	var/playstyle_string = "<B>You are the Slaughter Demon, a terrible creature from another existence. You have a single desire: to kill.  \
						You may use the blood crawl icon when on blood pools to travel through them, appearing and dissapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. \
						You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"
	deathmessage = "screams in anger as it collapses into a puddle of viscera!"


/mob/living/simple_animal/demon/slaughter/New()
	..()
	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
	var/datum/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = TRUE
	addtimer(CALLBACK(src, PROC_REF(attempt_objectives)), 5 SECONDS)


/mob/living/simple_animal/demon/slaughter/Life(seconds, times_fired)
	..()
	if(boost < world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/demon/slaughter/proc/attempt_objectives()
	if(mind)
		var/list/messages = list()
		messages.Add(playstyle_string)
		messages.Add("<b><span class ='notice'>You are not currently in the same plane of existence as the station. Use the blood crawl action at a blood pool to manifest.</span></b>")
		SEND_SOUND(src, sound('sound/misc/demon_dies.ogg'))
		if(!vialspawned)
			SSticker.mode.traitors |= mind
			mind.add_mind_objective(/datum/objective/slaughter)
			mind.add_mind_objective(/datum/objective/demon_fluff)
			messages.Add(mind.prepare_announce_objectives(FALSE))

		messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Slaughter_Demon)</span>")
		to_chat(src, chat_box_red(messages.Join("<br>")))


/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	base_icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	random_icon_states = list("innards")
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	weightless_icon = 'icons/obj/surgery.dmi'

/mob/living/simple_animal/demon/slaughter/Destroy()
	// Only execute the below if we successfully died
	for(var/mob/living/M in consumed_mobs)
		REMOVE_TRAIT(M, TRAIT_UNREVIVABLE, "demon")
		release_consumed(M)
	. = ..()

/mob/living/simple_animal/demon/slaughter/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))


// Midround slaughter demon, less tanky

/mob/living/simple_animal/demon/slaughter/lesser
	maxHealth = 170
	health = 170

// Cult slaughter demon
/// Summoned as part of the cult objective "Bring the Slaughter"
/mob/living/simple_animal/demon/slaughter/cult
	name = "harbinger of the slaughter"
	real_name = "harbinger of the Slaughter"
	desc = "An awful creature from beyond the realms of madness."
	maxHealth = 540
	health = 540
	melee_damage_upper = 60
	melee_damage_lower = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS //Smashes through EVERYTHING - r-walls included
	faction = list("cult")
	playstyle_string = "<b><span class='userdanger'>You are a Harbinger of the Slaughter.</span> Brought forth by the servants of Nar'Sie, you have a single purpose: slaughter the heretics \
	who do not worship your master. You may use the ability 'Blood Crawl' near a pool of blood to enter it and become incorporeal. Using the ability again near a blood pool will allow you \
	to emerge from it. You are fast, powerful, and almost invincible. By dragging a dead or unconscious body into a blood pool with you, you will consume it after a time and fully regain \
	your health. You may use the ability 'Sense Victims' in your Cultist tab to locate a random, living heretic.</span></b>"

/datum/spell/sense_victims
	name = "Sense Victims"
	desc = "Sense the location of heretics."
	base_cooldown = 0
	clothes_req = FALSE
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_cult"

/datum/spell/sense_victims/create_new_targeting()
	return new /datum/spell_targeting/alive_mob_list

/datum/spell/sense_victims/valid_target(mob/living/target, user)
	return target.stat == CONSCIOUS && target.key && !IS_CULTIST(target) // Only conscious, non cultist players

/datum/spell/sense_victims/cast(list/targets, mob/user)
	var/mob/living/victim = targets[1]
	to_chat(victim, "<span class='userdanger'>You feel an awful sense of being watched...</span>")
	victim.Stun(6 SECONDS) //HUE
	var/area/A = get_area(victim)
	if(!A)
		to_chat(user, "<span class='warning'>You could not locate any sapient heretics for the Slaughter.</span>")
		return 0
	to_chat(user, "<span class='danger'>You sense a terrified soul at [A]. <b>Show [A.p_them()] the error of [A.p_their()] ways.</b></span>")

/mob/living/simple_animal/demon/slaughter/cult/New()
	..()
	spawn(5)
		var/list/demon_candidates = SSghost_spawns.poll_candidates("Do you want to play as a slaughter demon?", ROLE_DEMON, TRUE, 10 SECONDS, source = /mob/living/simple_animal/demon/slaughter/cult)
		if(!length(demon_candidates))
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return
		if(QDELETED(src)) // Just in case
			return
		var/mob/M = pick(demon_candidates)
		var/mob/living/simple_animal/demon/slaughter/cult/S = src
		if(!M || !M.client)
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return
		var/client/C = M.client

		S.key = C.key
		dust_if_respawnable(M)
		S.mind.assigned_role = "Harbinger of the Slaughter"
		S.mind.special_role = "Harbinger of the Slaughter"
		to_chat(S, playstyle_string)
		S.mind.add_antag_datum(/datum/antagonist/cultist)
		var/datum/spell/sense_victims/SV = new
		AddSpell(SV)

		S.mind.add_mind_objective(/datum/objective/cult_slaughter)
		var/list/messages = S.mind.prepare_announce_objectives(FALSE)
		to_chat(S, chat_box_red(messages.Join("<br>")))

////////////////////The Powers

//Paradise Port: I added this because..SPOOPY DEMON IN YOUR BRAIN


/datum/action/innate/demon_whisper
	name = "Demonic Whisper"
	button_icon_state = "demon_comms"
	background_icon_state = "bg_demon"

/datum/action/innate/demon_whisper/proc/choose_targets(mob/user = usr)//yes i am copying from telepathy..hush...
	var/list/validtargets = list()
	for(var/mob/living/M in view(user.client.maxview(), get_turf(user)))
		if(M && M.mind && M.stat != DEAD)
			if(M == user)
				continue

			validtargets += M

	if(!length(validtargets))
		to_chat(usr, "<span class='warning'>There are no valid targets!</span>")
		return

	var/mob/living/target = tgui_input_list(user, "Choose the target to talk to", "Targeting", validtargets)
	return target

/datum/action/innate/demon_whisper/Activate()
	var/mob/living/choice = choose_targets()
	if(!choice)
		return

	var/msg = tgui_input_text(usr, "What do you wish to tell [choice]?", null, "")
	if(!msg)
		return
	log_say("(SLAUGHTER to [key_name(choice)]) [msg]", usr)
	to_chat(usr, "<span class='notice'><b>You whisper to [choice]: </b>[msg]</span>")
	to_chat(choice, "<span class='deadsay'><b>Suddenly a strange, demonic voice resonates in your head... </b></span><i><span class='danger'> [msg]</span></I>")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>Demonic message from <b>[usr]</b> ([ghost_follow_link(usr, ghost=G)]) to <b>[choice]</b> ([ghost_follow_link(choice, ghost=G)]): [msg]</i>")


//////////The Loot

// Demon heart base type
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=7"
	organ_datums = list(/datum/organ/heart/always_beating, /datum/organ/battery)

/obj/item/organ/internal/heart/demon/update_icon_state()
	return //always beating visually

/obj/item/organ/internal/heart/demon/prepare_eat()
	return // Just so people don't accidentally waste it

/obj/item/organ/internal/heart/demon/attack_self__legacy__attackchain(mob/living/user)
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
						"<span class='danger'>An unnatural hunger consumes you. You raise [src] to your mouth and devour it!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, 1)

//////////The Loot

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/// SLAUGHTER DEMON HEART

/obj/item/organ/internal/heart/demon/slaughter/attack_self__legacy__attackchain(mob/living/user)
	..()

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
		to_chat(user, "You feel differ-<span class='danger'> CONSUME THEM!</span>")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		qdel(src) // Replacing their demon heart with another demon heart is pointless, just delete this one and return.
		return TRUE

	// Eating any more than 2 demon hearts does nothing.
	to_chat(user, "<span class='warning'>...and you don't feel any different.</span>")
	qdel(src)

/obj/item/organ/internal/heart/demon/slaughter/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.AddSpell(new /datum/spell/bloodcrawl(null))

/obj/item/organ/internal/heart/demon/slaughter/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL, "bloodcrawl")
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		M.mind.RemoveSpell(/datum/spell/bloodcrawl)

/mob/living/simple_animal/demon/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles", "titters", "chuckles")
	emote_hear = list("gaffaws", "laughs")
	response_help  = "hugs"
	attacktext = "wildly tickles"
	maxHealth = 215
	health = 215
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

/mob/living/simple_animal/demon/slaughter/laughter/release_consumed(mob/living/M)
	if(M.revive())
		M.grab_ghost(force = TRUE)
		playsound(get_turf(src), feast_sound, 50, TRUE, -1)
		to_chat(M, "<span class='clown'>You leave [src]'s warm embrace, and feel ready to take on the world.</span>")
	..(M)


//Objectives and helpers.

//Objective info, Based on Reverent mini Atang
/datum/objective/slaughter
	needs_target = FALSE
	var/targetKill = 10

/datum/objective/slaughter/New()
	targetKill = rand(10,20)
	explanation_text = "Devour [targetKill] mortals."
	..()

/datum/objective/slaughter/check_completion()
	var/kill_count = 0
	for(var/datum/mind/M in get_owners())
		if(!isslaughterdemon(M.current) || QDELETED(M.current))
			continue
		var/mob/living/simple_animal/demon/slaughter/R = M.current
		kill_count += R.devoured
	if(kill_count >= targetKill)
		return TRUE
	return FALSE

/datum/objective/demon_fluff
	name = "Spread blood"
	needs_target = FALSE

/datum/objective/demon_fluff/New()
	find_target()
	var/targetname = "someone"
	if(target && target.current)
		targetname = target.current.real_name
	var/list/explanation_texts = list(
		"Spread blood all over the bridge.",
		"Spread blood all over the brig.",
		"Spread blood all over the chapel.",
		"Kill or Destroy all Janitors or Sanitation bots.",
		"Spare a few after striking them... make them bleed before the harvest.",
		"Hunt those that try to hunt you first.",
		"Hunt those that run away from you in fear",
		"Show [targetname] the power of blood.",
		"Drive [targetname] insane with demonic whispering."
	)
	// As this is a fluff objective, we don't need a target, so we want to null it out.
	// We don't want the demon getting a "Time for Plan B" message if the target cryos.
	target = null
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/demon_fluff/check_completion()
	return TRUE

/datum/objective/cult_slaughter
	explanation_text = "Bring forth the Slaughter to the nonbelievers."
	needs_target = FALSE
