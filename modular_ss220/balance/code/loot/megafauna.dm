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

/mob/living/simple_animal/hostile/megafauna/bubblegum/round_2
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum/enraged)
	crusher_loot = list(/obj/structure/closet/crate/necropolis/bubblegum/enraged/crusher)

/obj/structure/closet/crate/necropolis/bubblegum/populate_contents()
	new /obj/item/clothing/suit/space/hostile_environment(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment(src)

/obj/structure/closet/crate/necropolis/bubblegum/enraged/populate_contents()
	. = ..()
	new /obj/item/melee/spellblade/random(src)

/obj/structure/closet/crate/necropolis/bubblegum/enraged/crusher
	name = "bloody bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/enraged/crusher/populate_contents()
	. = ..()
	new /obj/item/crusher_trophy/demon_claws(src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination
	loot_chance = 100

/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon
	loot_chance = 100

/mob/living/simple_animal/hostile/megafauna/fleshling
	loot_chance = 100
