/mob/living/simple_animal/hostile/megafauna/drop_loot()
	if(length(loot) && prob(50))
		for(var/item in loot)
			new item(get_turf(src))
