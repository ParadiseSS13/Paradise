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
	see_in_dark = 8

	emote_taunt = list("nashes")
	taunt_chance = 20

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bite.ogg'

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

/mob/living/simple_animal/hostile/panther/AttackingTarget()
	. = ..()
	if(.)
		if(prob(15) && iscarbon(target))
			var/mob/living/carbon/C = target
			C.Weaken(3)
			C.visible_message("<span class='danger'>\the [src] knocks down \the [C]!</span>")

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

	emote_taunt = list("hisses wickedly")
	taunt_chance = 20

	harm_intent_damage = 2
	melee_damage_lower = 3
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	layer = 3.1		//so they can stay hidde under the /obj/structure/bush
	var/stalk_tick_delay = 3
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

/mob/living/simple_animal/hostile/snake/AttackingTarget()
	. =..()
	if(.)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.apply_damage(rand(3, 12), TOX)
