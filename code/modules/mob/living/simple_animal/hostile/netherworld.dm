/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing-pink"
	icon_living = "otherthing-pink"
	icon_dead = "otherthing-pink-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether")
	contains_xeno_organ = TRUE

	xeno_organ_results = list(
		/obj/item/organ/internal/liver/xenobiology/toxic,
		/obj/item/organ/internal/heart/xenobiology/vestigial,
		/obj/item/organ/internal/heart/xenobiology/incompatible,
		/obj/item/organ/internal/appendix/xenobiology/noisemaker,
	)

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	speed = -0.5
	deathmessage = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'

	xeno_organ_results = list(
		/obj/item/organ/internal/liver/xenobiology/toxic,
		/obj/item/organ/internal/heart/xenobiology/vestigial,
		/obj/item/organ/internal/heart/xenobiology/incompatible,
		/obj/item/organ/internal/liver/xenobiology/sharp
	)

/mob/living/simple_animal/hostile/netherworld/migo/Initialize(mapload)
	. = ..()

/mob/living/simple_animal/hostile/netherworld/migo/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat)
		return
	var/chosen_sound = pick(GLOB.migo_sounds)
	playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(GLOB.migo_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "punches"
	deathmessage = "falls apart into a fine dust."

/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/simple_animal/hostile/netherworld/migo, /mob/living/simple_animal/hostile/netherworld, /mob/living/simple_animal/hostile/netherworld/blankbody)
	faction = list("nether")

/obj/structure/spawner/nether/Initialize(mapload)
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	. = ..()
	if(isskeleton(user))
		. += "A direct link to another dimension full of creatures very happy to see you. <span class='nicegreen'>You can see your house from here!</span>"
	else
		. += "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>"

/obj/structure/spawner/nether/attack_hand(mob/user)
	. = ..()
	if(isskeleton(user))
		to_chat(user, "<span class='notice'>You don't feel like going home yet...</span>")
	else
		user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
							"<span class='userdanger'>Touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
		contents.Add(user)

/obj/structure/spawner/nether/process()
	for(var/mob/living/M in contents)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
			M.adjustBruteLoss(60)
			new /obj/effect/gibspawner/generic(get_turf(M), M.dna)
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = "It's [M], but [M.p_their()] flesh has an ashy texture, and [M.p_their()] face is featureless save an eerie smile."
				visible_message("<span class='warning'>[M] reemerges from the link!</span>")
				qdel(M)
