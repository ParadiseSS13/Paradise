/obj/item/seeds/nymph
	name = "pack of diona nymph seeds"
	desc = "These seeds grow into diona nymphs."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Nymph Pod"
	product = /obj/item/food/grown/nymph_pod
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1
	reagents_add = list("plantmatter" = 0.1)

/obj/item/food/grown/nymph_pod
	seed = /obj/item/seeds/nymph
	name = "nymph pod"
	desc = "A peculiar wriggling pod with a grown nymph inside. Crack it open to let the nymph out."
	icon_state = "mushy"
	bitesize_mod = 2

/obj/item/food/grown/nymph_pod/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	new /mob/living/basic/diona_nymph(get_turf(user))
	to_chat(user, "<span class='notice'>You crack open [src], letting the nymph out.</span>")
	user.drop_item()
	qdel(src)
	return ITEM_INTERACT_COMPLETE
