/obj/effect/spawner/random_spawners
	name = "random spawners"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"
	var/list/result = list(
	/turf/simulated/floor/plasteel = 1,
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)

// This needs to come before the initialization wave because
// the thing it creates might need to be initialized too
/obj/effect/spawner/random_spawners/New()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		log_runtime(EXCEPTION("Spawner placed in nullspace!"), src)
		return
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /turf))
		T.ChangeTurf(thing_to_place)
	else
		new thing_to_place(T)
	qdel(src)

/obj/effect/spawner/random_spawners/blood_maybe
	name = "blood maybe"
	result = list(
	/turf/simulated/floor/plating = 20,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/blood_often
	name = "blood often"
	result = list(
	/turf/simulated/floor/plating = 5,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/oil_maybe
	name = "oil maybe"
	result = list(
	/turf/simulated/floor/plating = 20,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/oil_maybe
	name = "oil often"
	result = list(
	/turf/simulated/floor/plating = 5,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/wall_rusted_probably
	name = "rusted wall probably"
	result = list(
	/turf/simulated/wall = 2,
	/turf/simulated/wall/rust = 7)

/obj/effect/spawner/random_spawners/wall_rusted_maybe
	name = "rusted wall maybe"
	result = list(
	/turf/simulated/wall = 7,
	/turf/simulated/wall/rust = 1)

/obj/effect/spawner/random_spawners/cobweb_left_frequent
	name = "cobweb left frequent"
	result = list(
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_frequent
	name = "cobweb right frequent"
	result = list(
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/cobweb_left_rare
	name = "cobweb left rare"
	result = list(
	/turf/simulated/floor/plating = 10,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_rare
	name = "cobweb right rare"
	result = list(
	/turf/simulated/floor/plating = 10,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/dirt_frequent
	name = "dirt frequent"
	result = list(
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/dirt_rare
	name = "dirt rare"
	result = list(
	/turf/simulated/floor/plating = 10,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/fungus_maybe
	name = "rusted wall maybe"
	result = list(
	/turf/simulated/wall = 7,
	/obj/effect/decal/cleanable/fungus = 1)

/obj/effect/spawner/random_spawners/fungus_probably
	name = "rusted wall maybe"
	result = list(
	/turf/simulated/wall = 1,
	/obj/effect/decal/cleanable/fungus = 7)


// Used in depot on z6

/obj/effect/spawner/random_spawners/syndicate

// Turrets

/obj/effect/spawner/random_spawners/syndicate/turret_internal
	name = "50pc int turret"
	icon_state = "x"
	result = list(
	/obj/machinery/porta_turret/syndicate/interior  = 1,
	/obj/effect/particle_effect/sparks = 1)

/obj/effect/spawner/random_spawners/syndicate/turret_external
	name = "50pc ext turret"
	icon_state = "x"
	result = list(
	/obj/machinery/porta_turret/syndicate/exterior  = 1,
	/obj/effect/particle_effect/sparks = 1)


// Mobs
/obj/effect/spawner/random_spawners/syndicate/melee
	name = "50pc melee syndimob"
	result = list(
	/mob/living/simple_animal/hostile/syndicate/melee/autogib = 1,
	/obj/effect/particle_effect/sparks = 1)

// Traps

/obj/effect/spawner/random_spawners/syndicate/pizzabomb
	name = "50pc trap pizza"
	result = list(
	/obj/item/pizzabox/meat = 1,
	/obj/item/device/pizza_bomb/autoarm = 1)

/obj/effect/spawner/random_spawners/syndicate/medbot
	name = "50pc trap medibot"
	result = list(
	/mob/living/simple_animal/bot/medbot/syndicate = 1,
	/mob/living/simple_animal/bot/medbot/syndicate/emagged = 1)

/obj/effect/spawner/random_spawners/syndicate/mine
	name = "50pc trap landmine"
	result = list(
	/obj/effect/mine/explosive = 1,
	/obj/effect/particle_effect/sparks = 1)

/obj/effect/spawner/random_spawners/syndicate/toolbox
	name = "50pc trap toolbox"
	result = list(
	/obj/item/weapon/storage/toolbox/syndicate = 1,
	/obj/item/weapon/storage/toolbox/syndicate/trapped = 1)


// Loot

/obj/effect/spawner/random_spawners/syndicate/spacepod
	name = "50pc loot spacepod"
	icon_state = "x3"
	result = list(
	/obj/spacepod/civilian = 1,
	/obj/effect/particle_effect/sparks = 1)

/obj/effect/spawner/random_spawners/syndicate/radiokey
	name = "50pc loot key"
	icon_state = "x3"
	result = list(
	/obj/item/device/radio/headset/syndicate = 1,
	/obj/item/device/encryptionkey/syndicate = 1,
	/obj/effect/particle_effect/sparks = 2)


/obj/effect/spawner/random_spawners/syndicate/jammer_loot
	name = "50pc loot jammer"
	icon_state = "x3"
	result = list(
	/obj/item/device/jammer = 1,
	/obj/effect/particle_effect/sparks = 1)

/obj/effect/spawner/random_spawners/syndicate/spacepod
	name = "50pc loot spacepod"
	icon_state = "x3"
	result = list(
	/obj/spacepod/civilian = 1,
	/obj/effect/particle_effect/sparks = 1)

/obj/effect/spawner/random_spawners/syndicate/x
	name = "50pc x"
	icon_state = "x3"
	result = list(
	/obj/item/weapon/storage/toolbox/syndicate = 1,
	/obj/item/weapon/storage/toolbox/syndicate/trapped = 1)



// Area features

/obj/effect/spawner/random_spawners/syndicate/telebeacon
	name = "50pc feature telebeacon"
	result = list(
	/obj/machinery/bluespace_beacon/syndicate = 1,
	/obj/effect/particle_effect/sparks = 1)

/obj/effect/spawner/random_spawners/syndicate/jammer_structure
	name = "50pc feature strong jammer"
	result = list(
	/obj/structure/syndijammer = 1,
	/obj/effect/particle_effect/sparks = 1)
