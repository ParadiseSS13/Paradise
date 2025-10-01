// Nests spawn mobs and objects when crossed by players.

// Once a nest is triggered, it picks a mob from 'spawn_mob_options', then
// looks around in 'spawn_trigger_distance' distance and activates all nests
// in that area. After a few seconds, the selected mob spawns from every
// triggered nest, alongside with some items dictated by 'spawn_byproduct'.
// Once spawned, the nests become inactive by the 'spawn_is_triggered' variable
// becoming TRUE.

/obj/structure/nest
	name = "tunnel"
	desc = "A twisted, dark passage to the underground."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	move_resist = INFINITY
	anchored = TRUE

	var/faction = list("hostile")	// If you spawn auto-attacking mobs, make sure that their faction and the nest's is the same
	var/spawn_byproduct = list(/obj/item/stack/ore/glass, /obj/item/stack/ore/iron)	// When mobs spawn, these items also spawn on top of the tunnel
	var/spawn_byproduct_max = 3		// Maximum number of item spawns
	var/spawn_is_triggered = FALSE	// This is set to TRUE once the nest is triggered, preventing multiple triggers; set it to FALSE to re-activate it
	var/spawn_max = 2				// Maximum number of mob spawns
	var/spawn_mob_options = list(/mob/living/basic/crab)	// The nest picks one mob type of this list and spawns them
	var/spawn_trigger_distance = 7	// The triggered nest will look this many tiles around itself to find other triggerable nests

/obj/structure/nest/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/nest/examine(mob/user)
	. = ..()
	if(!spawn_is_triggered)
		. += "<span class='warning'>You can hear a cacophony of growling snores from within.</span>"

/obj/structure/nest/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return
	..()

/obj/structure/nest/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED
	if(spawn_is_triggered)
		return
	if(!isliving(entered))
		return
	var/mob/living/L = entered
	if(!L.mind)
		return

	try_spawn(L)

/obj/structure/nest/proc/try_spawn(mob/living/L)
	var/chosen_mob = pick(spawn_mob_options)

	to_chat(L, "<span class='danger'>As you stumble across \the [name], you can hear ominous rumbling from beneath your feet!</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	for(var/obj/structure/nest/N in range(spawn_trigger_distance, src))
		N.spawn_is_triggered = TRUE
		addtimer(CALLBACK(N, TYPE_PROC_REF(/obj/structure/nest, spawn_mob), chosen_mob), rand(2, 5) SECONDS)

/obj/structure/nest/proc/spawn_mob(mob/M)
	var/byproduct = pick(spawn_byproduct)
	new byproduct(get_turf(src), rand(1, spawn_byproduct_max))

	for(var/i in 1 to spawn_max)
		var/mob/spawned_mob = new M(get_turf(src))
		visible_message("<span class='danger'>\A [spawned_mob.name] crawls out of \the [name]!</span>")

/obj/structure/nest/lavaland
	spawn_mob_options = list(
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/goldgrub,
	)

/obj/structure/nest/carppuppy
	spawn_mob_options = list(/mob/living/basic/carp, /mob/living/simple_animal/pet/dog/corgi/puppy/void)
	spawn_trigger_distance = 3
