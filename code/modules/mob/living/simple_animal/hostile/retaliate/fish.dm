
/mob/living/simple_animal/hostile/retaliate/carp
	name = "sea carp"
	desc = "A large fish bearing similarities to a certain space-faring menace."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/carpmeat
	meat_amount = 1
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 25
	health = 25

	retreat_distance = 6
	vision_range = 5

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")

	faction = list("carp")
	flying = 1