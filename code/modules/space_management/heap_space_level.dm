// This represents a level we can carve up as we please, and hand out
// chunks of to whatever requests it
/datum/space_level/heap
  name = "Heap level #ERROR"
  var/datum/space_chunk/top
  linkage = UNAFFECTED

/datum/space_level/heap/New(name, traits)
  ..()
  top = new
  flags = traits

/*
  Returns whether this z level has room for the given amount of space
*/
/datum/space_level/heap/proc/request(width, height)
  return TRUE // All are welcome! At least until I add code for this

// Returns a space chunk datum for some nerd to work with -
//    tells them what's safe to write into, and such
/datum/zlevel/heap/proc/allocate(width, height)
  return
