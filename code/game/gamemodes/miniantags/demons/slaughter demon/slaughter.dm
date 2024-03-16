/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
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
	for(var/mob/living/M in view(user.client.maxview(), get_turf(user)))
		if(M && M.mind && M.stat != DEAD)
			if(M == user)
				continue

			validtargets += M

	if(!validtargets.len)
		to_chat(usr, "<span class='warning'>There are no valid targets!</span>")
		return

	var/mob/living/target = tgui_input_list(user, "Choose the target to talk to", "Targeting", validtargets)
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

// Demon heart base type
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=7"
	organ_datums = list(/datum/organ/heart/always_beating)

/obj/item/organ/internal/heart/demon/update_icon_state()
	return //always beating visually

/obj/item/organ/internal/heart/demon/prepare_eat()
	return // Just so people don't accidentally waste it

/obj/item/organ/internal/heart/demon/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
						"<span class='danger'>An unnatural hunger consumes you. You raise [src] to your mouth and devour it!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, 1)

//////////The Loot

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/// SLAUGHTER DEMON HEART

/obj/item/organ/internal/heart/demon/slaughter/attack_self(mob/living/user)
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
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/internal/heart/demon/slaughter/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL, "bloodcrawl")
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)

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
		var/mob/living/simple_animal/demon/slaughter_demon/R = M.current
		kill_count += R.devoured
	if(kill_count >= targetKill)
		return TRUE
	return FALSE

/datum/objective/demon_fluff
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

