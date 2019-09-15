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

/obj/structure/spawner/blob_act(obj/structure/blob/B) //TO-DO-OBJECT-DAMAGE: Kill off when everything is damageable
	take_damage(400, BRUTE, "melee", 0, get_dir(src, B))

/obj/structure/spawner/ex_act(severity) //TO-DO-OBJECT-DAMAGE: Kill off when everything is damageable
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(severity)
		if(1)
			obj_integrity = 0
			qdel(src)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/structure/spawner/mech_melee_attack(obj/mecha/M) //TO-DO-OBJECT-DAMAGE: Kill off when everything is damageable
	M.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = M.damtype
	if(M.selected)
		mech_damtype = M.selected.damtype
		play_soundeffect = 1
	else
		switch(M.damtype)
			if(BRUTE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if(BURN)
				playsound(src, 'sound/items/welder.ogg', 50, 1)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, 1)
				return 0
			else
				return 0
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	return take_damage(M.force*3, mech_damtype, "melee", play_soundeffect, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

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