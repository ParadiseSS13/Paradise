/datum/zlevel/heap
  var/datum/space_chunk/top

/datum/zlevel/heap/New()
  ..()
  top = new

/datum/zlevel/heap/proc/request(width, height)
  return 1 // All are welcome! At least until I add code for this

/datum/zlevel/heap/allocate(width, height)
  return
