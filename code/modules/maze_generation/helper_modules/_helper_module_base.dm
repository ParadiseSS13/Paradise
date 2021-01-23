/obj/effect/mazegen/module_helper
	name = "maze helper"
	desc = "You should not be seeing this!"

/**
  * Helper handler proc
  *
  * This exists as an overridable method so you can do custom helper logic.
  * An example of this is removing all windows on a tile.
  */
/obj/effect/mazegen/module_helper/proc/helper_run()
	CRASH("spawn_loot() not overriden for [type]")
