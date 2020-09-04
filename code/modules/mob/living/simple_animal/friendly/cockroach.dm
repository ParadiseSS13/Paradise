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
	mob_size = MOB_SIZE_TINY
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	var/squish_chance = 50
	var/ispreforming = FALSE
	loot = list(/obj/effect/decal/cleanable/insectguts)
	del_on_death = 1

/mob/living/simple_animal/cockroach/can_die()
	return ..() && !SSticker.cinematic //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.

/mob/living/simple_animal/cockroach/Crossed(var/atom/movable/AM, oldloc)
	if(!ispreforming)
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_SMALL)
				if(prob(squish_chance))
					A.visible_message("<span class='notice'>\The [A] squashed \the [name].</span>", "<span class='notice'>You squashed \the [name].</span>")
					death()
				else
					visible_message("<span class='notice'>\The [name] avoids getting crushed.</span>")
		else if(istype(AM, /obj/structure))
			visible_message("<span class='notice'>As \the [AM] moved over \the [name], it was crushed.</span>")
			death()

/mob/living/simple_animal/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

/mob/living/simple_animal/cockroach/handle_automated_movement()
	if(!ispreforming)
		..()
	return

/mob/living/simple_animal/cockroach/attackby(obj/item/I, mob/living/user)
	if(1)
		//src.layer = 1
		ispreforming = TRUE
		icon_state = "cockroach_dance"
		I.Destroy()
		for(var/mob/living/M in range(12, src))
			if(M in range(6, src))
				to_chat(M,"<span class='warning'>You are struck dumb.</span>")
				observepreformance(M)
				M.Stun(30)
			else
				to_chat(M,"<span class='notice'><span class='italics'>What the fuck is that?.</span></span>")
		addtimer(CALLBACK(src, .proc/bestowal), 340)
		playsound(src, 'sound/hallucinations/dancing_roach_autotune.ogg', 200)

/mob/living/simple_animal/cockroach/proc/bestowal()
	icon_state = "cockroach"
	for(var/mob/living/M in range(6, src))
		to_chat(M,"<span class='danger'><span class='reallybig'>You have been shown mercy.</span></span>")
		M.gib()
	addtimer(CALLBACK(src, .proc/endpreformance), 50)

/mob/living/simple_animal/cockroach/proc/endpreformance()
	ispreforming = FALSE

/mob/living/simple_animal/cockroach/proc/observepreformance(mob/living/M)
	if(ispreforming)
		pick(M.visible_message("<span class='notice'>[M] drools.</span>"), M.visible_message("<span class='notice'>[M] stares dumbly at the [src].</span>"), M.visible_message("<span class='notice'>[M] blinks slowly.</span>"))
		addtimer(CALLBACK(src, .proc/observepreformance), rand(5,15))

