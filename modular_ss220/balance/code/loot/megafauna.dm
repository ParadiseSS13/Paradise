/mob/living/simple_animal/hostile/megafauna
	var/static/list/alt_loot = list(/obj/structure/closet/crate/necropolis/tendril)
	var/loot_chance = 75

/mob/living/simple_animal/hostile/megafauna/drop_loot()
	if(enraged || prob(loot_chance))
		return ..()
	if(length(loot))
		loot = alt_loot
	return ..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/drop_loot()
	if(enraged || prob(loot_chance))
		return ..()
	if(length(loot))
		new /obj/structure/closet/crate/necropolis/tendril(loc)

/mob/living/simple_animal/hostile/megafauna/bubblegum/Initialize(mapload)
	. = ..()
	if(!second_life)
		loot -= /obj/item/melee/spellblade/random

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination
	loot_chance = 100

/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon
	loot_chance = 100

/mob/living/simple_animal/hostile/megafauna/fleshling
	loot_chance = 100
