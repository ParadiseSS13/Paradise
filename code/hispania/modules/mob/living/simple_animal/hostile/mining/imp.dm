//A speedy, annoying and scaredy demon
/mob/living/simple_animal/hostile/asteroid/imp
	name = "lava imp"
	desc = "Lowest on the hierarchy of slaughter demons, this one is still nothing to sneer at."
	icon = 'icons/hispania/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "imp"
	icon_living = "imp"
	icon_aggro = "imp"
	icon_dead = "imp_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/magic/fireball/infernal/impfire
	projectilesound = 'sound/hispania/misc/impranged.wav'
	ranged = TRUE
	ranged_message = "shoots a fireball"
	ranged_cooldown_time = 70
	throw_message = "does nothing against the hardened skin of"
	vision_range = 5
	speed = 3
	maxHealth = 150
	health = 150
	harm_intent_damage = 15
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "claws"
	a_intent = INTENT_HARM
	speak_emote = list("groans")
	attack_sound = 'sound/hispania/misc/impattacks.wav'
	aggro_vision_range = 15
	retreat_distance = 5
	gold_core_spawnable = HOSTILE_SPAWN
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/impskull
	loot = list()
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/stack/sheet/bone = 3, /obj/item/stack/sheet/sinew = 2)
	death_sound = 'sound/hispania/misc/impdies.wav'

/obj/item/projectile/magic/fireball/infernal/impfire
	exp_fire = 2

/mob/living/simple_animal/hostile/asteroid/imp/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	playsound(src, 'sound/hispania/misc/impinjured.wav', rand(25,100), -1)

/mob/living/simple_animal/hostile/asteroid/imp/bullet_act(obj/item/projectile/P)
	. = ..()
	playsound(src, 'sound/hispania/misc/impinjured.wav', rand(25,100), -1)

/mob/living/simple_animal/hostile/asteroid/imp/Aggro()
	. = ..()
	playsound(src, pick('sound/hispania/misc/impsight.wav', 'sound/hispania/misc/impsight2.wav'), rand(50,75), -1)

/mob/living/simple_animal/hostile/asteroid/imp/LoseAggro()
	. = ..()
	playsound(src, pick('sound/hispania/misc/impnearby.wav', 'sound/hispania/misc/impnearby.wav'), rand(25, 60), -1)

/mob/living/simple_animal/hostile/asteroid/imp/tendril
	fromtendril = TRUE

//lava imp crusher trophy
/obj/item/crusher_trophy/blaster_tubes/impskull
	name = "imp skull"
	desc = "Somebody got glory killed. Suitable as a trophy."
	icon = 'icons/hispania/obj/lavaland/artefacts.dmi'
	icon_state = "impskull"
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/impskull/effect_desc()
	return "causes every marker to deal <b>[bonus_value]</b> damage."

/obj/item/crusher_trophy/blaster_tubes/impskull/on_projectile_fire(obj/item/projectile/destabilizer/marker, mob/living/user)
	marker.name = "fiery [marker.name]"
	marker.icon_state = "fireball"
	marker.damage = bonus_value
	marker.nodamage = FALSE
	playsound(user.loc, 'sound/hispania/misc/impranged.wav', 50, 0)
