/datum/zlevel
  var/flags = 0
  var/dirt_count = 0
  var/zpos
  var/list/init_list = list()
  var/list/pipes = list()
  var/list/cables = list()

/datum/zlevel/New(z)
  zpos = z

/datum/zlevel/proc/resume_init()
  if(dirt_count > 0)
    throw EXCEPTION("Init told to resume when z-level still dirty. Z level: '[zpos]'")
  log_debug("Releasing freeze on z-level '[zpos]'!")
  log_debug("Beginning initialization!")
  var/watch = start_watch()
  for(var/schmoo in init_list)
    var/atom/movable/AM = schmoo
    if(AM) // to catch stuff like the nuke disk that no longer exists
      AM.initialize()
      if(istype(AM, /obj/machinery/atmospherics))
        pipes.Add(AM)
      else if(istype(AM, /obj/structure/cable))
        cables.Add(AM)
  log_debug("Primary initialization finished in [stop_watch(watch)]s.")
  init_list.Cut()
  do_pipes()
  do_cables()

/datum/zlevel/proc/do_pipes()
  var/watch = start_watch()
  log_debug("Building pipenets on z-level '[zpos]'!")
  for(var/schmoo in pipes)
    var/obj/machinery/atmospherics/machine = schmoo
    if(machine)
      machine.build_network()
  pipes.Cut()
  log_debug("Took [stop_watch(watch)]s")

/datum/zlevel/proc/do_cables()
  var/watch = start_watch()
  log_debug("Building powernets on z-level '[zpos]'!")
  for(var/schmoo in cables)
    var/obj/structure/cable/C = schmoo
    if(C)
      makepowernet_for(C)
  cables.Cut()
  log_debug("Took [stop_watch(watch)]s")
