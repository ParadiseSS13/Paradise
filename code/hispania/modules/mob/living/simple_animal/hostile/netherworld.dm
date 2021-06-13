/mob/living/simple_animal/hostile/netherworld/hispanether //Small Boss RUN OH GOD OH FUCK
	name = "crazy corrupted chef"
	desc = "A poor crazy human corrupted by the power of the netherworld."
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "chaser"
	icon_living = "chaser"
	icon_dead = "chaser_dead"
	health = 550
	maxHealth = 550
	see_in_dark = 8
	armour_penetration = 20
	melee_damage_lower = 50
	melee_damage_upper = 70
	attacktext = "slices"

/mob/living/simple_animal/hostile/netherworld/hispanether/owlmutant  //Small Boss RUN OH GOD OH FUCK
	name = "corrupted owlman"
	desc = "Once a hero, now a villain."
	icon_state = "owlmutant"
	icon_living = "owlmutant"
	icon_dead = "owlmutant-dead"
	health = 400
	maxHealth = 400
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 60
	speak_emote = list("hoots")
	attacktext = "bites"

/mob/living/simple_animal/hostile/hivebot/range/corruptednether
	name = "corrupted hivebot"
	desc = "Not even machines are save from the powerfull netherworld"
	icon = 'icons/hispania/mob/animals.dmi'
	icon_living = "sovbot"
	icon_state = "sovbot"
	melee_damage_lower = 50 //Tienen 15 de vida
	melee_damage_upper = 50
	faction = list("creature")

/mob/living/simple_animal/hostile/netherworld/hispanether/corruptcrew
	name = "corrupted soul"
	desc = "Nothing can be done to save this poor soul"
	icon_state = "sovmeat"
	icon_living = "sovmeat"
	health = 100
	maxHealth = 100
	melee_damage_lower = 25
	melee_damage_upper = 30

