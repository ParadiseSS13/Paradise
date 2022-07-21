// Nests spawn mobs and objects when crossed by players.
// Nests placed in "spawn_trigger_distance" will always spawn the same type of mob.

/obj/structure/nest
	name = "nest"
	desc = "A twisted, dark passage to the underground."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	move_resist = INFINITY
	anchored = TRUE
	density = FALSE

	var/faction = list("hostile")
	var/spawn_byproduct = list(/obj/item/stack/ore/glass, /obj/item/stack/ore/iron)
	var/spawn_byproduct_max = 3
	var/spawn_max = 2
	var/spawn_mob_type
	var/spawn_mob_type_options = list(/mob/living/simple_animal/crab)
	var/spawn_trigger_distance = 7

/obj/structure/nest/Initialize(mapload)
	..()
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/try_spawn)
	desc = "[initial(desc)] You can hear a cacophony of growling snores from within."

/obj/structure/nest/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return
	..()

/obj/structure/nest/proc/try_spawn(datum/source, atom/movable/AM)
	// We only want players to trigger these
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(!L.mind)
		return

	// We decide what kind of a monster colony we are
	var/chosen_mob_type = pick(spawn_mob_type_options)

	// Activating nests
	to_chat(L, "<span class='danger'>As you stumble across the hole, you can hear ominous rumbling from beneath your feet!</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	for(var/obj/structure/nest/N in range(spawn_trigger_distance, src))
		N.UnregisterSignal(N, COMSIG_MOVABLE_CROSSED)
		N.spawn_mob_type = chosen_mob_type
		addtimer(CALLBACK(N, /obj/structure/nest/.proc/spawn_mob), rand(2, 5) SECONDS)

/obj/structure/nest/proc/spawn_mob()
	var/byproduct = pick(spawn_byproduct)
	new byproduct(get_turf(src), rand(1, spawn_byproduct_max))

	for(var/i in 1 to spawn_max)
		new spawn_mob_type(get_turf(src))
		visible_message("<span class='danger'>\A [spawn_mob_type] crawls out of \the [name]!</span>")
	desc = initial(desc)

/obj/structure/nest/lavaland
	spawn_mob_type_options = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast, /mob/living/simple_animal/hostile/asteroid/goldgrub)

/obj/structure/nest/minigarden
	spawn_mob_type_options = list(/mob/living/simple_animal/hostile/poison/giant_spider/nurse, /mob/living/simple_animal/bunny)
