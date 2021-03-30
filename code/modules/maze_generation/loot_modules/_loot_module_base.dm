/obj/effect/mazegen/module_loot
	name = "maze loot"
	/// Probability for this to spawn in a dead end at all. 0-100%. I dont recommend using values higher than 10
	var/spawn_probability = 0

/**
  * Loot spawner proc
  *
  * This exists as an overridable method so you can do more than just spawn objects.
  * An example of this is spawning a specific mob based on a condition.
  *
  * Arguments:
  * * T - The turf loot will be spawned on
  */
/obj/effect/mazegen/module_loot/proc/spawn_loot(turf/T)
	CRASH("spawn_loot() not overriden for [type]")
