/obj/item/grenade/deconstruction
	name = "R3 material repossession grenade"
	desc = "Designed by NT to remove unwanted constructions from their stations, and reclaim the materials from it. Can be configured to deconstruct walls and windows as well."
	var/full_decon = FALSE
	var/consume_all = FALSE

/obj/item/grenade/deconstruction/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_PLASTIC, MAT_BLUESPACE), 0, TRUE, null, null, null, TRUE)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = 500000 //stack is 100000, so yeah. Should be fine.

/obj/item/grenade/deconstruction/prime()
	deconstruct_obj(3)

/obj/item/grenade/deconstruction/proc/deconstruct_obj(loops = 0)
	for(var/obj/O in range(7, src))
		if(istype(O, /obj/item))
			continue
		if(O.resistance_flags & INDESTRUCTIBLE)
			continue
		O.deconstruct(TRUE)
	if(loops)
		deconstruct_obj(loops -= 1)
	else if(full_decon)
		addtimer(CALLBACK(src, .proc/deconstruct_items), 2) //Slight delay to make sure everything gets deconstructed first

/obj/item/grenade/deconstruction/proc/deconstruct_items()
	for(var/obj/item/I in orange(7, src))
		if(length(I.materials) || consume_all)
			I.forceMove(loc)
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/material_amount = materials.get_item_material_amount(I)
			if(!material_amount)
				qdel(I)
				continue
			materials.insert_item(I, multiplier = 0.95)
			qdel(I)
			materials.retrieve_all()
