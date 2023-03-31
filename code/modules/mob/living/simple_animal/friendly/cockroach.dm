/mob/living/simple_animal/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	mob_size = MOB_SIZE_TINY
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	var/squish_chance = 50
	var/isdancer = FALSE
	var/ispreforming = FALSE
	loot = list(/obj/effect/decal/cleanable/insectguts)
	del_on_death = TRUE

/mob/living/simple_animal/cockroach/can_die()
	return ..() && !SSticker.cinematic //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.

/mob/living/simple_animal/cockroach/Initialize(mapload) //Lizards are a great way to deal with cockroaches
	. = ..()
	ADD_TRAIT(src, TRAIT_EDIBLE_BUG, "edible_bug")

/mob/living/simple_animal/cockroach/Crossed(atom/movable/AM, oldloc)
	if(!ispreforming)
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_SMALL)
				if(prob(squish_chance))
					A.visible_message("<span class='notice'>\The [A] squashed \the [name].</span>", "<span class='notice'>You squashed \the [name].</span>")
					death()
				else
					visible_message("<span class='notice'>\The [name] avoids getting crushed.</span>")
		else if(isstructure(AM))
			visible_message("<span class='notice'>As \the [AM] moved over \the [name], it was crushed.</span>")
			death()

/mob/living/simple_animal/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

/mob/living/simple_animal/cockroach/handle_automated_movement()
	if(!ispreforming)
		..()
	return

/mob/living/simple_animal/cockroach/Initialize()
	..()
	if(prob(1))
		isdancer = TRUE

/mob/living/simple_animal/cockroach/Destroy()
	for(var/i in src.active_timers)
		deltimer(i)
	..()

/mob/living/simple_animal/cockroach/attack_hand(mob/living/carbon/human/M)
	..()
	if(prob(10))
		if(M.a_intent == INTENT_HELP && isdancer)
			startpreformance()
	if(M.a_intent == INTENT_HARM && ispreforming)
		M.gib()
		to_chat(M,"<span class='danger'>No.</span>")

/mob/living/simple_animal/cockroach/attackby(obj/item/W, mob/living/user)
	..()
	if(prob(10))
		if(user.a_intent == INTENT_HELP && isdancer)
			startpreformance()
	else if(user.a_intent == INTENT_HARM && ispreforming)
		to_chat(user,"<span class='danger'>You have been punished for your crime.</span>")
		user.gib()

/mob/living/simple_animal/cockroach/proc/startpreformance()
	if(!ispreforming)
		ispreforming = TRUE
		name = "dancing cockroach"
		icon_state = "cockroach_dance"

		for(var/mob/living/Mi in range(12, src))
			if(Mi in range(6, src))
				to_chat(Mi,"<span class='warning'>You are struck dumb.</span>")
				observepreformance(Mi)
				Mi.Stun(18)
			else
				to_chat(Mi,"<span class='notice'><span class='italics'>What the fuck is that?</span></span>")
		playsound(src, 'sound/hallucinations/dancing_roach_autotune.ogg', 200)
		addtimer(CALLBACK(src, .proc/endpreformance), 340, TIMER_STOPPABLE)

/mob/living/simple_animal/cockroach/proc/observepreformance(mob/living/Mu)
	if(!Mu)
		return
	if(ispreforming && !istype(Mu, /mob/living/simple_animal/cockroach))
		var/outputmessage = pick("<span class='notice'>[Mu] drools.</span>", "<span class='notice'>[Mu] stares dumbly at [src].</span>", "<span class='notice'>[Mu] blinks slowly.</span>")
		Mu.visible_message("[outputmessage]")
		Mu.reagents.add_reagent("krokodil", 1)
		addtimer(CALLBACK(src, .proc/observepreformance, Mu, TIMER_STOPPABLE), rand(50,150))

/mob/living/simple_animal/cockroach/proc/endpreformance()
	src.ispreforming = FALSE
	icon_state = "cockroach"

