GLOBAL_VAR_INIT(spores_active, 0)
#define MAX_GLOBAL_SPORES 25
/obj/structure/blob/factory
	name = "factory blob"
	icon_state = "blob_factory"
	max_integrity = 200
	point_return = 18
	var/list/spores = list()
	var/max_spores = 5
	var/spore_delay = 0

/obj/structure/blob/factory/Destroy()
	for(var/mob/living/basic/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	spores = null
	return ..()

/obj/structure/blob/factory/run_action()
	if(length(spores) >= max_spores || GLOB.spores_active >= MAX_GLOBAL_SPORES)
		return
	if(spore_delay > world.time)
		return
	flick("blob_factory_glow", src)
	spore_delay = world.time + 10 SECONDS
	var/mob/living/basic/blob/blobspore/BS = new/mob/living/basic/blob/blobspore(src.loc, src)
	if(overmind)
		overmind.add_mob_to_overmind(BS)

#undef MAX_GLOBAL_SPORES
