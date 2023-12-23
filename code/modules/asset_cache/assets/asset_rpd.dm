/datum/asset/spritehseet/rpd
	name = "rpd"

/datum/asset/spritehseet/rpd/create_spritesheets()
	InsertAll("", 'icons/obj/pipe-item.dmi', GLOB.alldirs)
	for(var/pipe_type in list("pipe-c", "pipe-j1", "pipe-s", "pipe-t", "pipe-y", "intake", "outlet", "pipe-j1s"))
		for(var/direction in GLOB.cardinal)
			Insert("[pipe_type]-[dir2text(direction)]", 'icons/obj/pipes/disposal.dmi', pipe_type, direction)
