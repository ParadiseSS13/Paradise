/obj/structure/spawner/mining/carps
	name = "Carps den"
	desc = "A den housing a nest of carps, oh god why?"
	mob_types = list(/mob/living/simple_animal/hostile/carp)

/obj/structure/spawner/headcrab_old
	name = "headcrab old nest"
	desc = "A living nest for headcrabs."
	icon_state = "headcrab_nest"
	icon = 'icons/mob/headcrab.dmi'
	max_integrity = 300
	max_mobs = 3
	spawn_time = 250
	mob_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
	spawn_text = "crawls out of"
	faction = list("hostile")
