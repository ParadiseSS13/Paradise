/mob/living/simple_animal/hostile/bear
	attacktext = "терзает"
	death_sound = 'modular_ss220/mobs/sound/creatures/bear_death.ogg'
	talk_sound = list('modular_ss220/mobs/sound/creatures/bear_talk1.ogg', 'modular_ss220/mobs/sound/creatures/bear_talk2.ogg', 'modular_ss220/mobs/sound/creatures/bear_talk3.ogg')
	damaged_sound = list('modular_ss220/mobs/sound/creatures/bear_onerawr1.ogg', 'modular_ss220/mobs/sound/creatures/bear_onerawr2.ogg', 'modular_ss220/mobs/sound/creatures/bear_onerawr3.ogg')
	var/trigger_sound = 'modular_ss220/mobs/sound/creatures/bear_rawr.ogg'

/mob/living/simple_animal/hostile/bear/handle_automated_movement()
	if(..())
		playsound(src, src.trigger_sound, 40, 1)
