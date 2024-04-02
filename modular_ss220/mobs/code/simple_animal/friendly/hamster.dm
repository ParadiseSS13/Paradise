/mob/living/simple_animal/mouse/hamster
	name = "хомяк"
	real_name = "хомяк"
	desc = "С надутыми щечками."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	icon_resting = "hamster_rest"
	gender = MALE
	non_standard = TRUE
	speak_chance = 0
	childtype = list(/mob/living/simple_animal/mouse/hamster/baby)
	animal_species = /mob/living/simple_animal/mouse/hamster
	holder_type = /obj/item/holder/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	maxHealth = 10
	health = 10


/mob/living/simple_animal/mouse/hamster/baby
	name = "хомячок"
	real_name = "хомячок"
	desc = "Очень миленький! Какие у него пушистые щечки!"
	turns_per_move = 2
	response_help  = "полапал"
	response_disarm = "аккуратно отодвинул"
	response_harm   = "пихнул"
	attacktext = "толкается"
	transform = matrix(0.7, 0, 0, 0, 0.7, 0)
	health = 3
	maxHealth = 3
	var/amount_grown = 0
	can_hide = 1
	can_collar = 0
	holder_type = /obj/item/holder/hamster

// Hamster procs
#define MAX_HAMSTER 20
GLOBAL_VAR_INIT(hamster_count, 0)

/mob/living/simple_animal/mouse/hamster/color_pick()
	reinitial()
	return

/mob/living/simple_animal/mouse/hamster/New()
	gender = prob(80) ? MALE : FEMALE
	desc += MALE ? " Самец!" : " Самочка! Ох... Нет... "
	GLOB.hamster_count++
	. = ..()

/mob/living/simple_animal/mouse/hamster/Destroy()
	GLOB.hamster_count--
	. = ..()

/mob/living/simple_animal/mouse/hamster/death(gibbed)
	if(!gibbed)
		GLOB.hamster_count--
	. = ..()

/mob/living/simple_animal/mouse/hamster/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE

/mob/living/simple_animal/mouse/hamster/Life(seconds, times_fired)
	..()
	if(GLOB.hamster_count < MAX_HAMSTER)
		make_babies()

/mob/living/simple_animal/mouse/hamster/baby/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(show_message)
		to_chat(src, "<span class='warning'>Вы слишком малы чтобы что-то тащить.</span>")
	return

/mob/living/simple_animal/mouse/hamster/baby/Life(seconds, times_fired)
	. =..()
	if(.)
		amount_grown++
		if(amount_grown >= 100)
			var/mob/living/simple_animal/A = new /mob/living/simple_animal/mouse/hamster(loc)
			if(mind)
				mind.transfer_to(A)
			qdel(src)

/mob/living/simple_animal/mouse/hamster/baby/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] раздавлен!</span>")
			death()
			splat(user = AM)
	..()
