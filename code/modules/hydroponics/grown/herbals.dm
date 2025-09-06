/obj/item/seeds/comfrey
	name = "pack of comfrey seeds"
	desc = "These seeds grow into comfrey."
	icon_state = "seed-lettuce"
	species = "cabbage"
	plantname = "Comfrey"
	product = /obj/item/food/grown/comfrey
	yield = 2
	maturation = 3
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list("styptic_powder" = 0.1)

/obj/item/food/grown/comfrey
	seed = /obj/item/seeds/comfrey
	name = "comfrey leaf"
	desc = "Mash to turn into a poultice."
	icon_state = "tea_astra_leaves"
	color = "#378C61"
	tastes = list("comfrey" = 1)
	bitesize_mod = 2

/obj/item/food/grown/comfrey/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	var/obj/item/stack/medical/bruise_pack/comfrey/C = new(get_turf(user))
	C.heal_brute = seed.potency / 4
	to_chat(user, "<span class='notice'>You mash [src] into a poultice.</span>")
	user.drop_item()
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/seeds/aloe
	name = "pack of aloe seeds"
	desc = "These seeds grow into aloe vera plant."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Aloe Vera Plant"
	product = /obj/item/food/grown/aloe
	yield = 2
	icon_dead = "ambrosia-dead"
	reagents_add = list("silver_sulfadiazine" = 0.1)

/obj/item/food/grown/aloe
	seed = /obj/item/seeds/aloe
	name = "aloe leaf"
	desc = "Mash to turn into a poultice."
	icon_state = "ambrosiavulgaris"
	color = "#4CC5C7"
	tastes = list("aloe" = 1)
	bitesize_mod = 2

/obj/item/food/grown/aloe/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	var/obj/item/stack/medical/ointment/aloe/A = new(get_turf(user))
	A.heal_burn = seed.potency / 4
	to_chat(user, "<span class='notice'>You mash [src] into a poultice.</span>")
	user.drop_item()
	qdel(src)
	return ITEM_INTERACT_COMPLETE

// mint
/obj/item/seeds/mint
	name = "pack of mint seeds"
	desc = "These seeds grow into mint plants."
	icon_state = "seed-mint"
	species = "mint"
	plantname = "Mint Plant"
	product = /obj/item/food/grown/mint
	lifespan = 20
	maturation = 4
	production = 5
	yield = 5
	growthstages = 3
	icon_dead = "mint-dead"
	reagents_add = list("mint" = 0.03, "plantmatter" = 0.03)

/obj/item/food/grown/mint
	seed = /obj/item/seeds/mint
	name = "mint leaves"
	desc = "Process for mint. Distill for menthol. No need to experi-mint." //haha
	icon_state = "mint"
	tastes = list("mint" = 1)
	filling_color = "#A7EE9F"
	distill_reagent = "menthol"
