/mob/living/simple_animal/hostile/guardian/punch
	melee_damage_lower = 20
	melee_damage_upper = 20
	obj_damage = 80
	damage_transfer = 0.4
	playstyle_string = "As a <b>Standard</b> type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls."
	environment_smash = 2
	magic_fluff_string = "..And draw the Assistant, faceless and generic, but never to be underestimated."
	tech_fluff_string = "Boot sequence complete. Standard combat modules loaded. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm stirs to life, ready to tear apart your enemies."
	var/battlecry = "AT"

/mob/living/simple_animal/hostile/guardian/punch/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch"
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 5 characters.", ,"", 6)
	if(input)
		battlecry = input

/mob/living/simple_animal/hostile/guardian/punch/AttackingTarget()
	. = ..()
	if(iscarbon(target) && target != summoner)
		if(length(battlecry) > 11)//no more then 11 letters in a battle cry.
			visible_message("<span class='danger'>[src] punches [target]!</span>")
		else
			say("[battlecry][battlecry][battlecry][battlecry][battlecry]", TRUE)
		playsound(loc, attack_sound, 50, 1, 1)
		playsound(loc, attack_sound, 50, 1, 1)
		playsound(loc, attack_sound, 50, 1, 1)
		playsound(loc, attack_sound, 50, 1, 1)

/mob/living/simple_animal/hostile/guardian/punch/sealpunch
	name = "Seal Sprit"
	real_name = "Seal Sprit"
	icon = 'icons/mob/animal.dmi'
	icon_living = "seal"
	icon_state = "seal"
	attacktext = "slaps"
	speak_emote = list("barks")
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	damage_transfer = 0
	playstyle_string = "As a standard type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls."
	environment_smash = 2
	battlecry = "URK"
	adminseal = TRUE