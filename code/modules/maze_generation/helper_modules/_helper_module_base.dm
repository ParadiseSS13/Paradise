/obj/effect/mazegen/module_helper
	name = "maze helper"

/**
  * Helper handler proc
  *
  * This exists as an overridable method so you can do custom helper logic.
  * An example of this is removing all windows on a tile.
  *
  * Arguments:
  * * blockwise - This will be TRUE if the maze this is running on is a blockwise maze
  */
/obj/effect/mazegen/module_helper/proc/helper_run(blockwise = FALSE, obj/effect/mazegen/host)
	CRASH("spawn_loot() not overriden for [type]")
