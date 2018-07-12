//*********//
// Panther //
//*********//

/mob/living/simple_animal/hostile/panther
	name = "panther"
	desc = "A long sleek, black cat with sharp teeth and claws."
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "panther"
	icon_living = "panther"
	icon_dead = "panther_dead"
	icon_resting = "panther_rest"
	icon_gib = "panther_dead"
	speak_chance = 0
	turns_per_move = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	stop_automated_movement_when_pulled = 0
	maxHealth = 50
	health = 50
	pixel_x = -16

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bite.ogg'

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

/mob/living/simple_animal/hostile/panther/FindTarget(var/list/possible_targets)
	. = ..()
	if(.)
		emote("nashes at [.]")

/mob/living/simple_animal/hostile/panther/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

//*******//
// Snake //
//*******//

/mob/living/simple_animal/hostile/snake
	name = "snake"
	desc = "A sinuously coiled, venomous looking reptile."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	icon_gib = "snake_dead"
	speak_chance = 0
	turns_per_move = 1
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	stop_automated_movement_when_pulled = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 2
	melee_damage_lower = 3
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

/mob/living/simple_animal/hostile/snake/FindTarget()
	. = ..()
	if(.)
		emote("hisses wickedly")

/mob/living/simple_animal/hostile/snake/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		L.apply_damage(rand(3,12), TOX)
