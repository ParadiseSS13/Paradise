/obj/effect/spawner/lootdrop
	var/list/hispa_spawns = list()

/obj/effect/spawner/lootdrop/proc/make_hispa_loot()
	loot |= hispa_spawns

/obj/effect/spawner/lootdrop/maintenance
	hispa_spawns = list(/obj/item/reagent_containers/food/snacks/canned_food/true = 10)

/obj/effect/spawner/lootdrop/animals4maint
	name = "maint fauna"
	loot = list(
				/mob/living/simple_animal/mouse = 60,
				/mob/living/simple_animal/lizard = 30,
				/mob/living/simple_animal/cockroach = 30,
				/mob/living/simple_animal/hostile/retaliate/poison/snake = 10,
				/mob/living/simple_animal/hostile/poison/giant_spider = 5,
				"" = 20 //Nada
				)
