/obj/structure/fermenting_barrel/proc/makeTequila(obj/item/reagent_containers/food/snacks/grown/G)
	if(G.reagents)
		G.reagents.trans_to(src, G.reagents.total_volume)
	var/amount = G.seed.potency / 4
	if(G.distill_reagent)
		reagents.add_reagent(G.distill_reagent, amount)
	else
		reagents.add_reagent("tequila", amount)
	qdel(G)
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
