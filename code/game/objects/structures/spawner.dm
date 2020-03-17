/obj/structure/spawner
	name = "monster nest"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hole"
	max_integrity = 100

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	var/max_mobs = 5
	var/spawn_time = 300 //30 seconds default
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_text = "emerges from"
	var/faction = list("hostile")
	var/spawner_type = /datum/component/spawner

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/obj/structure/spawner/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return
	..()

/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/simple_animal/hostile/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)

/obj/structure/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, and some still seem to be moving..."
	icon_state = "hole"
	icon = 'icons/mob/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/skeleton)
	spawn_text = "climbs out of"
	faction = list("skeleton")

/obj/structure/spawner/clown
	name = "Laughing Larry"
	desc = "A laughing, jovial figure. Something seems stuck in his throat."
	icon_state = "clownbeacon"
	icon = 'icons/obj/device.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/retaliate/clown)
	spawn_text = "climbs out of"
	faction = list("clown")

/obj/structure/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	icon_state = "hole"
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls out of"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/hivelord, /mob/living/simple_animal/hostile/asteroid/basilisk)
	faction = list("mining")

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath)

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord)

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk)

/obj/structure/spawner/headcrab
	name = "headcrab nest"
	desc = "A living nest for headcrabs. It is moving ominously."
	icon_state = "headcrab_nest"
	icon = 'icons/mob/headcrab.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 600
	mob_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
	spawn_text = "crawls out of"
	faction = list("hostile")
