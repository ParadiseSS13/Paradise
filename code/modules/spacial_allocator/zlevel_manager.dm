var/global/datum/zlev_manager/zlevels = new

/datum/zlev_manager
  // A list of z-levels
  var/list/z_list = list()


// Populate our z level list
/datum/zlev_manager/proc/initialize()
  for(var/i = 1, i < world.maxz, i++)
    z_list.Add(new /datum/zlevel(i))


// For when you need the z-level to be at a certain point
/datum/zlev_manager/proc/increase_max_zlevel_to(new_maxz)
  if(world.maxz>=new_maxz)
    return
  while(world.maxz<new_maxz)
    add_new_zlevel()

// Increments the max z-level by one
// For convenience's sake returns the z-level added
/datum/zlev_manager/proc/add_new_zlevel()
  world.maxz++
  var/our_z = world.maxz
  z_list.Add(new /datum/zlevel(our_z))
  return our_z

/datum/zlev_manager/proc/cut_levels_downto(new_maxz)
  if(world.maxz <= new_maxz)
    return
  while(world.maxz>new_maxz)
    kill_topmost_zlevel()

// Decrements the max z-level by one
// not normally used, but hey the swapmap loader wanted it
/datum/zlev_manager/proc/kill_topmost_zlevel()
  var/our_z = world.maxz
  qdel(z_list[our_z])
  z_list.Remove(our_z)
  world.maxz--

/*
* "Dirt" management
* "Dirt" is used to keep track of whether a z level should automatically have
* stuff on it initialize or not - the map loaders, when set to defer init, place
* a freeze on the z levels they touch so as to prevent atmos from exploding,
* among other things
*/


// Returns whether the given z level has a freeze on initialization
/datum/zlev_manager/proc/is_zlevel_dirty(z)
  if(z > z_list.len)
    return 0 // It's not dirty if it's not being tracked
  var/datum/zlevel/our_z = z_list[z]
  return (our_z.dirt_count > 0)


// Increases the dirt count on a z level
/datum/zlev_manager/proc/add_dirt(z)
  var/datum/zlevel/our_z = z_list[z]
  our_z.dirt_count++


// Decreases the dirt count on a z level
/datum/zlev_manager/proc/remove_dirt(z)
  var/datum/zlevel/our_z = z_list[z]
  our_z.dirt_count--
