/obj/effect/spawner/lootdrop
	var/list/hispa_spawns = list()

/obj/effect/spawner/lootdrop/proc/make_hispa_loot()
	loot |= hispa_spawns

/obj/effect/spawner/lootdrop/maintenance
	hispa_spawns = list(/obj/item/reagent_containers/food/snacks/canned_food/true = 10)
