/mob/living/simple_animal/hostile/bear
	name = "Космический медведь"
	desc = "Вам не нужно быть быстрее медведя, вам нужно быть быстрее напарников."
	blood_volume = BLOOD_VOLUME_NORMAL
	attacktext = "терзает"
	death_sound = 'modular_ss220/mobs/sound/creatures/bear_death.ogg'
	talk_sound = list('modular_ss220/mobs/sound/creatures/bear_talk1.ogg', 'modular_ss220/mobs/sound/creatures/bear_talk2.ogg', 'modular_ss220/mobs/sound/creatures/bear_talk3.ogg')
	damaged_sound = list('modular_ss220/mobs/sound/creatures/bear_onerawr1.ogg', 'modular_ss220/mobs/sound/creatures/bear_onerawr2.ogg', 'modular_ss220/mobs/sound/creatures/bear_onerawr3.ogg')
	var/trigger_sound = 'modular_ss220/mobs/sound/creatures/bear_rawr.ogg'

/mob/living/simple_animal/hostile/bear/handle_automated_movement()
	if(..())
		playsound(src, src.trigger_sound, 40, 1)

/mob/living/simple_animal/hostile/bear/custom
	name = "Медведь"
	desc = "Не такой уж и плюшевый"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	icon_gib = "brownbear_gib"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/bear/custom/Move()
	. = ..()
	if(stat == DEAD)
		return

	icon_state = icon_living

/mob/living/simple_animal/hostile/bear/custom/brown
	name = "Бурый медведь"
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/bear/custom/snow
	name = "Снежный медведь"
	desc = "Не любит гостей в своей берлоге."
	icon_state = "snowbear"
	icon_living = "snowbear"
	icon_dead = "snowbear_dead"
	icon_gib = "snowbear_gib"
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/bear/custom/combat
	name = "Боевой медведь"
	desc = "Боевая машина для убийств."
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	icon_gib = "combatbear_gib"
	gold_core_spawnable = HOSTILE_SPAWN

	maxHealth = 200
	health = 200
	obj_damage = 80
	melee_damage_lower = 30
	melee_damage_upper = 80 // кто-то вообще думал о балансе, хоть иногда?

	speed = 2
	blood_volume = BLOOD_VOLUME_NORMAL
	attacktext = "терзает"
