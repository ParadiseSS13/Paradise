/obj/effect/spawner/random/storage
	name = "storage furniture spawner"
	icon_state = "shelf"
	layer = BELOW_OBJ_LAYER
	loot = list(
		list(
			/obj/structure/shelf = 10,
			/obj/structure/shelf/command,
			/obj/structure/shelf/engineering,
			/obj/structure/shelf/medbay,
			/obj/structure/shelf/science,
			/obj/structure/shelf/security,
			/obj/structure/shelf/service,
			/obj/structure/shelf/supply,
		),
		/obj/structure/rack,
	)
