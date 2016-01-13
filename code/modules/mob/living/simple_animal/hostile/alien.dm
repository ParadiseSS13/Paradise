/mob/living/simple_animal/hostile/alien
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alien_l"
	icon_gib = "syndicate_gib"
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/xenomeat
	meat_amount = 3
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	speak_emote = list("hisses")
	a_intent = I_HARM
	attack_sound = 'sound/weapons/bladeslice.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	var/dead = 0
	unsuitable_atmos_damage = 15
	faction = list("alien")
	status_flags = CANPUSH
	minbodytemp = 0
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	heat_damage_per_tick = 20


/mob/living/simple_animal/hostile/alien/drone
	name = "alien drone"
	icon_state = "aliend_running"
	icon_living = "aliend_running"
	icon_dead = "aliend_l"
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	var/plant_cooldown = 30
	var/plants_off = 0

/mob/living/simple_animal/hostile/alien/drone/Life()
	..()
	if(!stat)
		plant_cooldown--
		if(stance==HOSTILE_STANCE_IDLE)
			if(!plants_off && prob(10) && plant_cooldown<=0)
				plant_cooldown = initial(plant_cooldown)
				SpreadPlants()

/mob/living/simple_animal/hostile/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens_running"
	icon_living = "aliens_running"
	icon_dead = "aliens_l"
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'


/mob/living/simple_animal/hostile/alien/queen
	name = "alien queen"
	icon_state = "alienq_running"
	icon_living = "alienq_running"
	icon_dead = "alienq_l"
	health = 250
	maxHealth = 250
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	move_to_delay = 4
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	status_flags = 0
	var/sterile = 1
	var/plants_off = 0
	var/egg_cooldown = 30
	var/plant_cooldown = 30

/mob/living/simple_animal/hostile/alien/queen/Life()
	..()
	if(!stat)
		egg_cooldown--
		plant_cooldown--
		if(stance==HOSTILE_STANCE_IDLE)
			if(!plants_off && prob(10) && plant_cooldown<=0)
				plant_cooldown = initial(plant_cooldown)
				SpreadPlants()
			if(!sterile && prob(10) && egg_cooldown<=0)
				egg_cooldown = initial(egg_cooldown)
				LayEggs()

/mob/living/simple_animal/hostile/alien/proc/SpreadPlants()
	if(!isturf(loc) || istype(loc, /turf/space))
		return
	if(locate(/obj/structure/alien/weeds/node) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] has planted some alien weeds!</span>")
	new /obj/structure/alien/weeds/node(loc)

/mob/living/simple_animal/hostile/alien/proc/LayEggs()
	if(!isturf(loc) || istype(loc, /turf/space))
		return
	if(locate(/obj/structure/alien/egg) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] has laid an egg!</span>")
	new /obj/structure/alien/egg(loc)

/mob/living/simple_animal/hostile/alien/queen/large
	name = "alien empress"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	icon_living = "queen_s"
	icon_dead = "queen_dead"
	move_to_delay = 4
	maxHealth = 400
	health = 400

/obj/item/projectile/neurotox
	name = "neurotoxin"
	damage = 30
	icon_state = "toxin"

/mob/living/simple_animal/hostile/alien/death()
	..()
	if(dead == 0)
		dead = 1
		visible_message("[src] lets out a waning guttural screech, green blood bubbling from its maw...")
		playsound(src, 'sound/voice/hiss6.ogg', 100, 1)
