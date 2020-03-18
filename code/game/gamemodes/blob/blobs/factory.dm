/obj/structure/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	max_integrity = 200
	point_return = 18
	var/list/spores = list()
	var/max_spores = 3
	var/spore_delay = 0

/obj/structure/blob/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	spores = null
	return ..()

/obj/structure/blob/factory/run_action()
	if(spores.len >= max_spores)
		return
	if(spore_delay > world.time)
		return
	flick("blob_factory_glow", src)
	spore_delay = world.time + 100 // 10 seconds
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore(src.loc, src)
	if(overmind)
		BS.color = overmind.blob_reagent_datum?.complementary_color
		BS.overmind = overmind
		overmind.blob_mobs.Add(BS)
