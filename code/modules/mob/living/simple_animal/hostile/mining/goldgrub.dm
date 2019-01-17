/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 2
	aggro_vision_range = 9
	idle_vision_range = 2
	move_to_delay = 5
	friendly = "harmlessly rolls into"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HELP
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/uranium)

	var/chase_time = 100
	var/will_burrow = TRUE

/mob/living/simple_animal/hostile/asteroid/goldgrub/New()
	..()
	var/i = rand(1,3)
	while(i)
		loot += pick(/obj/item/stack/ore/silver, /obj/item/stack/ore/gold, /obj/item/stack/ore/uranium, /obj/item/stack/ore/diamond)
		i--

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	target = new_target
	if(target != null)
		if(istype(target, /obj/item/stack/ore) && loot.len < 10)
			visible_message("<span class='notice'>The [name] looks at [target.name] with hungry eyes.</span>")
		else if(isliving(target))
			Aggro()
			visible_message("<span class='danger'>The [name] tries to flee from [target.name]!</span>")
			retreat_distance = 10
			minimum_distance = 10
			if(will_burrow)
				spawn(chase_time)
					Burrow()

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/stack/ore))
		EatOre(target)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(var/atom/targeted_ore)
	for(var/obj/item/stack/ore/O in get_turf(targeted_ore))
		if(loot.len < 10)
			var/using = min(10 - loot.len, O.amount)
			for(var/i in 1 to using)
				loot += O.type
			O.use(using)
	visible_message("<span class='notice'>The ore was swallowed whole!</span>")


/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!stat)
		visible_message("<span class='danger'>The [src.name] buries into the ground, vanishing from sight!</span>")
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>The [P.name] was repelled by [src.name]'s girth!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(damage)
	idle_vision_range = 9
	. = ..()
