
//EXTERMINATE
/mob/living/simple_animal/hostile/dalek
	name = "dalek"
	desc = "An alien menace encased in tank-like battle armor, heavily armed and shielded."
	icon = 'icons/mob/dalek.dmi'
	icon_state = "bronze"
	icon_living = "bronze"
	icon_dead = "bronze_dead"
	ranged = 1
	minimum_distance = 3
	speak_chance = 5
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("DALEKS ARE SUPREME","ALERT!","SECURE THE AREA. REMOVE ALL INFERIOR LIFE FORMS!","SEEK. LOCATE. EXTERMINATE!","EXTERMINATE!","YOU WILL BE EXTERMINATED!")
	emote_see = list("scans around with its eyestalk","waves its appendages")
	a_intent = I_HARM
	stop_automated_movement_when_pulled = 0
	health = 400
	maxHealth = 400
	speed = 4
	harm_intent_damage = 1
	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "suckers"
	attack_sound = 'sound/effects/slime_squish.ogg'
	projectiletype = /obj/item/projectile/beam/dalek
	projectilesound = 'sound/weapons/dalekray.ogg'
	faction = list("dalek")

/mob/living/simple_animal/hostile/dalek/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/dalek/death()
	explosion(get_turf(src), 0, 0, 2, 4)
	src.visible_message("\blue \icon[src] [src] blows apart!")
	..()

/obj/item/projectile/beam/dalek
	damage = 40
	name = "electron beam"
	icon_state = "emitter"
	weaken = 5
