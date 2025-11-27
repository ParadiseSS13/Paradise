/// The Monster

/mob/living/basic/demon/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales. You should run."
	maxHealth = 240
	health = 240
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
	death_message = "screams in anger as it collapses into a puddle of viscera!"

/mob/living/basic/demon/slaughter/New()
	..()
	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
	var/datum/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = TRUE
	addtimer(CALLBACK(src, PROC_REF(attempt_objectives)), 5 SECONDS)

/mob/living/basic/demon/slaughter/Life(seconds, times_fired)
	..()
	if(boost < world.time)
		speed = 1
	else
		speed = 0

/mob/living/basic/demon/slaughter/proc/attempt_objectives()
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

/mob/living/basic/demon/slaughter/Destroy()
	// Only execute the below if we successfully died
	for(var/mob/living/M in consumed_mobs)
		REMOVE_TRAIT(M, TRAIT_UNREVIVABLE, "demon")
		release_consumed(M)
	. = ..()

/mob/living/basic/demon/slaughter/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))

// Midround slaughter demon, less tanky
/mob/living/basic/demon/slaughter/lesser
	maxHealth = 170
	health = 170

// Cult slaughter demon
/// Summoned as part of the cult objective "Bring the Slaughter"
/mob/living/basic/demon/slaughter/cult
	name = "harbinger of the slaughter"
	real_name = "harbinger of the Slaughter"
	desc = "An awful creature from beyond the realms of madness."
	maxHealth = 540
	health = 540
	melee_damage_upper = 60
	melee_damage_lower = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS // Smashes through EVERYTHING - r-walls included
	faction = list("cult")
	playstyle_string = "<b><span class='userdanger'>You are a Harbinger of the Slaughter.</span> Brought forth by the servants of Nar'Sie, you have a single purpose: slaughter the heretics \
	who do not worship your master. You may use the ability 'Blood Crawl' near a pool of blood to enter it and become incorporeal. Using the ability again near a blood pool will allow you \
	to emerge from it. You are fast, powerful, and almost invincible. By dragging a dead or unconscious body into a blood pool with you, you will consume it after a time and fully regain \
	your health. You may use the ability 'Sense Victims' in your Cultist tab to locate a random, living heretic.</span></b>"

/mob/living/basic/demon/slaughter/cult/New()
	..()
	spawn(5)
		var/list/demon_candidates = SSghost_spawns.poll_candidates("Do you want to play as a slaughter demon?", ROLE_DEMON, TRUE, 10 SECONDS, source = /mob/living/basic/demon/slaughter/cult)
		if(!length(demon_candidates))
			visible_message("<span class='warning'>[src] disappears in a flash of red light!</span>")
			qdel(src)
			return
		if(QDELETED(src)) // Just in case
			return
		var/mob/M = pick(demon_candidates)
		var/mob/living/basic/demon/slaughter/cult/S = src
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

/mob/living/basic/demon/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles", "titters", "chuckles", "gaffaws", "laughs")
	response_help_continuous = "hugs"
	response_help_simple = "hug"
	attack_verb_continuous = "wildly tickles"
	attack_verb_simple = "wildly tickles"
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
	death_message = "fades out, as all of its friends are released from its prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

/mob/living/basic/demon/slaughter/laughter/release_consumed(mob/living/M)
	if(M.revive())
		M.grab_ghost(force = TRUE)
		playsound(get_turf(src), feast_sound, 50, TRUE, -1)
		to_chat(M, "<span class='clown'>You leave [src]'s warm embrace, and feel ready to take on the world.</span>")
	..(M)
