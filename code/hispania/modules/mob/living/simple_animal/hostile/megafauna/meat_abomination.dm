/mob/living/simple_animal/hostile/megafauna/redspaceoverlord
	name = "Redspace Overlord"
	health = 3000
	maxHealth = 3000
	faction = list("creature")
	armour_penetration = 50
	melee_damage_lower = 40
	melee_damage_upper = 40
	icon = 'icons/hispania/mob/meat_overlord.dmi'
	icon_state = "meatboss_draft"
	icon_living = "meatboss_draft"
	icon_dead = "meatboss_dead"
	friendly = "stares down"
	speak_emote = list("gurgles")
	speed = 6
	move_to_delay = 6
	attacktext = "entangles"
	deathmessage = "explodes, leaving a bunch of meat no longer moving."
	attack_action_types = (/datum/action/innate/megafauna_attack/tentacle_grab)

/datum/action/innate/megafauna_attack/tentacle_grab
	name = "Tentacle Grab"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now firing a tentacle.</span>"
	chosen_attack_num = 1
