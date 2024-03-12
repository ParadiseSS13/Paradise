/obj/item/storage/surgical_tray/Initialize(mapload)
	. = ..()

	QDEL_LIST_CONTENTS(contents)

	new /obj/item/scalpel(src)
	new /obj/item/cautery(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
