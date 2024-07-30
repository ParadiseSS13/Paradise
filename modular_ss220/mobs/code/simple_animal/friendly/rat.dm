/mob/living/simple_animal/mouse/rat
	name = "rat"
	real_name = "rat"
	desc = "Серая крыса. Не яркий представитель своего вида."
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	squeak_sound = 'modular_ss220/mobs/sound/creatures/rat_squeak.ogg'
	icon_state = "rat_gray"
	icon_living = "rat_gray"
	icon_dead = "rat_gray_dead"
	icon_resting = "rat_gray_sleep"
	non_standard = TRUE
	mouse_color = null
	maxHealth = 15
	health = 15
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/food/meat/mouse = 2)

/mob/living/simple_animal/mouse/rat/white
	name = "white rat"
	real_name = "white rat"
	desc = "Типичный представитель лабораторных крыс."
	icon_state = "rat_white"
	icon_living = "rat_white"
	icon_dead = "rat_white_dead"
	icon_resting = "rat_white_sleep"
	mouse_color = "white"

/mob/living/simple_animal/mouse/rat/irish
	name = "irish rat"
	real_name = "irish rat"
	desc = "Ирландская крыса, борец за независимость. На космической станции?! На этот раз им точно некуда бежать!"
	icon_state = "rat_irish"
	icon_living = "rat_irish"
	icon_dead = "rat_irish_dead"
	icon_resting = "rat_irish_sleep"
	mouse_color = "irish"

/mob/living/simple_animal/mouse/rat/color_pick()
	if(!mouse_color)
		mouse_color = pick(list("gray","white","irish"))
	icon_state = "rat_[mouse_color]"
	icon_living = "rat_[mouse_color]"
	icon_dead = "rat_[mouse_color]_dead"
	icon_resting = "rat_[mouse_color]_sleep"

/mob/living/simple_animal/mouse/rat/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE


