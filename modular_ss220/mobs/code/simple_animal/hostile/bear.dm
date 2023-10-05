/mob/living/simple_animal/hostile/bear
	name = "космический медведь"
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

// /mob/living/simple_animal/hostile/bear/Move()
// 			icon_state = "[icon_living]"
// 			icon_state = "[icon_living]floor"

/mob/living/simple_animal/hostile/bear/brown
	name = "бурый медведь"
	desc = "Не такой уж и плюшевый"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	icon_gib = "brownbear_gib"

/mob/living/simple_animal/hostile/bear/snow
	name = "снежный медведь"
	desc = "Не любит гостей в своей берлоге."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "snowbear"
	icon_living = "snowbear"
	icon_dead = "snowbear_dead"
	icon_gib = "snowbear_gib"

/mob/living/simple_animal/hostile/bear/combat
	name = "боевой медведь"
	desc = "Боевая машина для убийств."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	icon_gib = "combatbear_gib"

	maxHealth = 200
	health = 200
	obj_damage = 80
	melee_damage_lower = 30
	melee_damage_upper = 80

	speed = 2
	blood_volume = BLOOD_VOLUME_NORMAL
	attacktext = "терзает"
