// Forces entry and exit points
/obj/effect/mazegen/module_helper/entry_exit
	name = "entrance/exit allocator"

/obj/effect/mazegen/module_helper/entry_exit/helper_run(blockwise = FALSE, obj/effect/mazegen/host)
	if(blockwise)
		var/turf/T = get_turf(src)
		var/obj/effect/mazegen/generator/blockwise/BWG = host
		T.ChangeTurf(BWG.floor_material)
	else
		for(var/obj/structure/window/reinforced/mazeglass/MG in get_turf(src))
			qdel(MG)

