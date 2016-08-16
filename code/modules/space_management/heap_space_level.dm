// This represents a level we can carve up as we please, and hand out
// chunks of to whatever requests it
/datum/space_level/heap
  var/datum/space_chunk/top
  linkage = UNAFFECTED

/datum/space_level/heap/New()
  ..()
  top = new

/datum/space_level/heap/proc/request(width, height)
  return 1 // All are welcome! At least until I add code for this

/datum/zlevel/heap/proc/allocate(width, height)
  return
