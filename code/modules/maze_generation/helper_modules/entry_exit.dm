// Forces entry and exit points
/obj/effect/mazegen/module_helper/entry_exit
	name = "entrance/exit allocator"

/obj/effect/mazegen/module_helper/entry_exit/helper_run()
	for(var/obj/structure/window/reinforced/mazeglass/MG in get_turf(src))
		qdel(MG)

	qdel(src)
