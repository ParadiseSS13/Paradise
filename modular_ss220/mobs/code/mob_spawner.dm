/obj/structure/spawner/headcrab
	name = "headcrab nest"
	desc = "A living nest for headcrabs. It is moving ominously."
	icon_state = "headcrab_nest"
	icon = 'modular_ss220/mobs/icons/mob/headcrab.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 600
	mob_types = list(/mob/living/simple_animal/hostile/blackmesa/xen/headcrab, /mob/living/simple_animal/hostile/blackmesa/xen/headcrab/fast, /mob/living/simple_animal/hostile/blackmesa/xen/headcrab/poison)
	spawn_text = "crawls out of"
	faction = list("hostile")

// Headcrab corpse
/obj/effect/mob_spawn/headcrab
	mob_type = /mob/living/simple_animal/hostile/blackmesa/xen/headcrab
	death = TRUE
	name = "Dead headcrab"
	desc = "A small dead parasitic creature that would like to connect with your brain stem."
	icon = 'modular_ss220/mobs/icons/mob/headcrab.dmi'
	icon_state = "headcrab_dead"
