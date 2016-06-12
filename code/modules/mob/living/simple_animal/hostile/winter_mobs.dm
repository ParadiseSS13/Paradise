//////////////////////////
//		Winter Mobs		//
//////////////////////////

/mob/living/simple_animal/hostile/winter
	faction = list("hostile", "syndicate", "winter")
	speak_chance = 0
	turns_per_move = 5
	speed = 1
	maxHealth = 50
	health = 50
	icon = 'icons/mob/winter_mob.dmi'
	icon_state = "placeholder"
	icon_living = "placeholder"
	icon_dead = "placeholder"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	melee_damage_lower = 3
	melee_damage_upper = 7

/mob/living/simple_animal/hostile/winter/snowman
	name = "snowman"
	desc = "A very angry snowman. Doesn't look like it wants to play around..."
	icon_state = "snowman"
	icon_living = "snowman"
	icon_dead = "snowman-dead"

	bodytemperature = 73.0		//it's made of snow and hatred, so it's pretty cold.
	maxbodytemp = 280.15		//at roughly 7 C, these will start melting (dying) from the warmth. Mind over matter or something.
	heat_damage_per_tick = 10	//Now With Rapid Thawing Action!
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE


/mob/living/simple_animal/hostile/winter/snowman/death()
	if(prob(50))		//50% chance to drop weapon on death, if it has one to drop
		loot = list(/obj/item/weapon/melee/candy_sword)
	if(prob(20))	//chance to become a stationary snowman structure instead of a corpse
		loot.Add(/obj/structure/snowman)
		visible_message("<span class='notice'>The [src.name] shimmers as its animating magic fades away!</span>")
		..()		//this is just to make sure it gets properly killed before we qdel it
		qdel(src)
	else
		..()

/mob/living/simple_animal/hostile/winter/snowman/ranged
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/snowball

/mob/living/simple_animal/hostile/winter/reindeer
	name = "reindeer"
	desc = "Apparently murder is a reindeer game."
	icon_state = "reindeer"
	icon_living = "reindeer"
	icon_dead = "reindeer-dead"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)

	melee_damage_lower = 5
	melee_damage_upper = 10
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

/mob/living/simple_animal/hostile/winter/santa
	maxHealth = 150		//if this seems low for a "boss", it's because you have to fight him multiple times, with him fully healing between stages
	health = 150
	var/next_stage = null
	var/death_message
	name = "Santa Claus"

	icon_state = "santa"
	icon_living = "santa"
	icon_dead = "santa-dead"

/mob/living/simple_animal/hostile/winter/santa/death()
	..()
	if(death_message)
		visible_message(death_message)
	if(next_stage)
		spawn(10)
			new next_stage(get_turf(src))
			qdel(src)	//hide the body

/mob/living/simple_animal/hostile/winter/santa/stage_1		//stage 1: slow melee
	desc = "GET THE FAT MAN!"
	next_stage = /mob/living/simple_animal/hostile/winter/santa/stage_2
	death_message = "<span class='danger'>HO HO HO! YOU THOUGHT IT WOULD BE THIS EASY?!?</span>"
	speed = 2
	melee_damage_lower = 5
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/winter/santa/stage_2		//stage 2: slow ranged
	desc = "GET THE FAT MAN AGAIN!"
	next_stage = /mob/living/simple_animal/hostile/winter/santa/stage_3
	death_message = "<span class='danger'>YOU'VE BEEN VERY NAUGHTY! PREPARE TO DIE!</span>"
	ranged = 1
	projectiletype = /obj/item/projectile/ornament
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/winter/santa/stage_3		//stage 3: fast rapidfire ranged
	desc = "WHY WON'T HE DIE ALREADY!?"
	next_stage = /mob/living/simple_animal/hostile/winter/santa/stage_4
	death_message = "<span class='danger'>FACE MY FINAL FORM AND KNOW DESPAIR!</span>"
	ranged = 1
	rapid = 1
	speed = 0	//he's lost some weight from the fighting
	projectiletype = /obj/item/projectile/ornament
	retreat_distance = 3
	minimum_distance = 3

/mob/living/simple_animal/hostile/winter/santa/stage_4		//stage 4: fast spinebreaker
	name = "Final Form Santa"
	desc = "WHAT THE HELL IS HE!?! WHY WON'T HE STAY DEAD!?!"
	maxHealth = 200
	health = 200
	speed = 0	//he's lost some weight from the fighting

	environment_smash = 2		//naughty walls must be punished too
	melee_damage_lower = 15
	melee_damage_upper = 25		//that's gonna leave a mark, for sure

/mob/living/simple_animal/hostile/winter/santa/stage_4/death()
	to_chat(world, "<span class='notice'><hr></span>")
	to_chat(world, "<span class='notice'>THE FAT MAN HAS FALLEN!</span>")
	to_chat(world, "<span class='notice'>SANTA CLAUS HAS BEEN DEFEATED!</span>")
	to_chat(world, "<span class='notice'><hr></span>")
	..()
	var/obj/item/weapon/grenade/clusterbuster/xmas/X = new /obj/item/weapon/grenade/clusterbuster/xmas(get_turf(src))
	var/obj/item/weapon/grenade/clusterbuster/xmas/Y = new /obj/item/weapon/grenade/clusterbuster/xmas(get_turf(src))
	X.prime()
	Y.prime()