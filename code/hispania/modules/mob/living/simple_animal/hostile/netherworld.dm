/mob/living/simple_animal/hostile/netherworld/hispanether //Small Boss
	name = "crazy corrupted chef"
	desc = "A poor crazy human corrupted by the power of the netherworld."
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "chaser"
	icon_living = "chaser"
	icon_dead = "chaser_dead"
	health = 450
	maxHealth = 450
	melee_damage_lower = 40
	melee_damage_upper = 50
	attacktext = "slices"

/mob/living/simple_animal/hostile/netherworld/hispanether/owlmutant
	name = "corrupted owlman"
	desc = "Once a hero, now a villain."
	icon_state = "owlmutant"
	icon_living = "owlmutant"
	icon_dead = "owlmutant-dead"
	health = 200
	maxHealth = 200
	melee_damage_lower = 30
	melee_damage_upper = 40
	speak_emote = list("hoots")
	attacktext = "bites"

/mob/living/simple_animal/hostile/hivebot/range/corruptednether
	name = "corrupted hivebot"
	desc = "Not even machines are save from the powerfull netherworld"
	icon = 'icons/hispania/mob/animals.dmi'
	icon_living = "sovbot"
	icon_state = "sovbot"
	melee_damage_lower = 15
	melee_damage_upper = 15
	faction = list("creature")

/mob/living/simple_animal/hostile/netherworld/hispanether/corruptcrew
	name = "corrupted soul"
	desc = "Nothing can be done to save this poor soul"
	icon_state = "sovmeat"
	icon_living = "sovmeat"
	health = 100
	maxHealth = 100
	melee_damage_lower = 15
	melee_damage_upper = 20

