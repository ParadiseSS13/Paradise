//Random ruins, thanks to KorPhaeron from /tg/ station
#define RANDOM_UPPER_X 220
#define RANDOM_UPPER_Y 220
#define RANDOM_LOWER_X 30
#define RANDOM_LOWER_Y 30

var/global/list/potentialRandomZlevels = generateMapList(filename = "config/away_mission_config.txt")
//var/global/list/potentialLavaRuins = generateMapList(filename = "config/lavaRuinConfig.txt") //Maybe some other time ;)
//If we ever get lavaland, remember to create config/lavaRuinConfig.txt and add maps to _maps/map_files/RandomRuins/LavaRuins
var/global/list/potentialSpaceRuins = generateMapList(filename = "config/spaceRuinConfig.txt")

/proc/late_setup_level(turfs, smoothTurfs)
	if(!smoothTurfs)
		smoothTurfs = turfs

	if(air_master)
		air_master.setup_allturfs(turfs)
	for(var/turf/T in turfs)
		if(T.dynamic_lighting)
			T.lighting_build_overlays()
		for(var/obj/structure/cable/PC in T)
			makepowernet_for(PC)
	for(var/turf/T in smoothTurfs)
		if(T.smooth)
			smooth_icon(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smooth)
				smooth_icon(A)

/proc/createRandomZlevel()
  if(awaydestinations.len)	//crude, but it saves another var!
    return

  if(potentialRandomZlevels && potentialRandomZlevels.len)
    var/watch = start_watch()
    log_startup_progress("<span class='boldannounce'>Loading away mission...</span>")

    var/map = pick(potentialRandomZlevels)
    var/file = file(map)
    if(isfile(file))
      maploader.load_map(file)
      late_setup_level(block(locate(1, 1, world.maxz), locate(world.maxx, world.maxy, world.maxz)))
      log_to_dd("  Away mission loaded: [map]")

    //map_transition_config.Add(AWAY_MISSION_LIST) //Maybe I'm just dumb and we have some special proc for this, so leaving this here, just in case

    for(var/obj/effect/landmark/L in landmarks_list)
      if (L.name != "awaystart")
        continue
      awaydestinations.Add(L)

    log_startup_progress("  Away mission loaded in [stop_watch(watch)]s.")

  else
    log_startup_progress("  No away missions found.")
    return


/proc/generateMapList(filename)
  var/list/potentialMaps = list()
  var/list/Lines = file2list(filename)
  if(!Lines.len)	return
  for (var/t in Lines)
    if (!t)
      continue

    t = trim(t)
    if (length(t) == 0)
      continue
    else if (copytext(t, 1, 2) == "#")
      continue

    var/pos = findtext(t, " ")
    var/name = null

    if (pos)
      name = lowertext(copytext(t, 1, pos))
    else
      name = lowertext(t)

    if (!name)
      continue

    potentialMaps.Add(t)

    return potentialMaps

/proc/seedRuins(z_level = 1, ruin_number = 0, whitelist = /area/space, list/potentialRuins = potentialSpaceRuins)
  ruin_number = min(ruin_number, potentialRuins.len)

  while(ruin_number)
    var/sanity = 0
    var/valid = FALSE
    while(!valid)
      valid = TRUE
      sanity++
      if(sanity > 100)
        ruin_number--
        break
      var/turf/T = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), z_level)

      for(var/turf/check in range(T, 15))
        var/area/new_area = get_area(check)
        if(!(istype(new_area, whitelist)))
          valid = FALSE
          break

      if(valid)
        log_to_dd("  Ruins marker placed at [T.x][T.y][T.z]")
    		var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
    		R.Load(potentialRuins, -15, -15)
    		ruin_number --

  return

/obj/effect/ruin_loader
  name = "random ruin"
  icon = 'icons/obj/weapons.dmi'
  icon_state = "syndballoon"
  invisibility = 0

/obj/effect/ruin_loader/proc/Load(list/potentialRuins = potentialSpaceRuins, x_offset = 0, y_offset = 0)
  if(potentialRuins.len)
    var/watch = start_watch()
    log_startup_progress("  Loading ruins...")

    var/map = pick(potentialRuins)
    var/file = file(map)
    if(isfile(file))
      maploader.load_map(file, src.x + x_offset, src.y + y_offset, src.z)
      log_to_dd("  [map] loaded at [src.x + x_offset],[src.y + y_offset],[src.z]")
    potentialRuins -= map //Don't want to load the same one twice
    log_startup_progress("  Ruins loaded in [stop_watch(watch)]s.")
  else
    log_startup_progress("  No ruins found.")
    return

  qdel(src)

#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y
#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
