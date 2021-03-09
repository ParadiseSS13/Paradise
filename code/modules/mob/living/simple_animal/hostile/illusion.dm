/mob/living/simple_animal/hostile/illusion
	name = "illusion"
	desc = "It's a fake!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	melee_damage_lower = 5
	melee_damage_upper = 5
	a_intent = INTENT_HARM
	attacktext = "gores"
	maxHealth = 100
	health = 100
	speed = 0
	faction = list("illusion")
	var/life_span = INFINITY //how long until they despawn
	var/mob/living/parent_mob
	var/multiply_chance = 0 //if we multiply on hit
	deathmessage = "vanishes into thin air! It was a fake!"
	del_on_death = 1


/mob/living/simple_animal/hostile/illusion/Life()
	..()
	if(world.time > life_span)
		death()

/mob/living/simple_animal/hostile/illusion/proc/Copy_Parent(mob/living/original, life = 50, health = 100, damage = 0, replicate = 0 )
	appearance = original.appearance
	parent_mob = original
	dir = original.dir
	life_span = world.time+life
	melee_damage_lower = damage
	melee_damage_upper = damage
	multiply_chance = replicate
	faction -= "neutral"
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)

/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	if(parent_mob)
		. = parent_mob.examine(user)
	else
		. = ..()


/mob/living/simple_animal/hostile/illusion/AttackingTarget()
	. = ..()
	if(. && isliving(target) && prob(multiply_chance))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		var/mob/living/simple_animal/hostile/illusion/M = new(loc)
		M.faction = faction.Copy()
		M.attack_sound = attack_sound
		M.Copy_Parent(parent_mob, 80, health/2, melee_damage_upper, multiply_chance/2)
		M.GiveTarget(L)

///////Actual Types/////////

/mob/living/simple_animal/hostile/illusion/escape
	retreat_distance = 10
	minimum_distance = 10
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -1
	obj_damage = 0
	environment_smash = 0


/mob/living/simple_animal/hostile/illusion/escape/AttackingTarget()
	return

///////Cult Illusions/////////
/mob/living/simple_animal/hostile/illusion/cult
	loot = list(/obj/effect/temp_visual/cult/sparks) // So that they SPARKLE on death

/mob/living/simple_animal/hostile/illusion/escape/cult
	loot = list(/obj/effect/temp_visual/cult/sparks)
