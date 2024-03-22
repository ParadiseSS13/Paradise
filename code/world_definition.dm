// This file is just for the necessary /world definition
// Try looking in game/world.dm

/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15" // If you ever set this to a non-square value you will need to update a lot of the code!
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
	fps = 20 // If this isnt hard-defined, anything relying on this variable before world load will cry a lot
	name = "Paradise Station 13"
	/*
	HUB INFORMATION
	*/
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Space Station 13"
