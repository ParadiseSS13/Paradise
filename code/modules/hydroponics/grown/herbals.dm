/obj/item/seeds/comfrey
	name = "pack of comfrey seeds"
	desc = "These seeds grow into comfrey."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "comfrey"
	product = /obj/item/reagent_containers/food/snacks/grown/comfrey
	yield = 2
	maturation = 3
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list("styptic_powder" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/comfrey
	seed = /obj/item/seeds/comfrey
	name = "comfrey leaf"
	desc = "Mash to turn into a poultice."
	icon_state = "tea_astra_leaves"
	color = "#378C61"
	bitesize_mod = 2

/obj/item/reagent_containers/food/snacks/grown/comfrey/attack_self(mob/user)
	var/obj/item/stack/medical/bruise_pack/comfrey/C = new(get_turf(user))
	C.heal_brute = seed.potency
	to_chat(user, "<span class='notice'>You mash [src] into a poultice.</span>")
	user.drop_item()
	qdel(src)

/obj/item/seeds/aloe
	name = "pack of aloe seeds"
	desc = "These seeds grow into aloe vera plant."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Aloe Vera Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/aloe
	yield = 2
	icon_dead = "ambrosia-dead"
	reagents_add = list("silver_sulfadiazine" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/aloe
	seed = /obj/item/seeds/aloe
	name = "aloe leaf"
	desc = "Mash to turn into a poultice."
	icon_state = "ambrosiavulgaris"
	color = "#4CC5C7"
	bitesize_mod = 2

/obj/item/reagent_containers/food/snacks/grown/aloe/attack_self(mob/user)
	var/obj/item/stack/medical/ointment/aloe/A = new(get_turf(user))
	A.heal_burn = seed.potency
	to_chat(user, "<span class='notice'>You mash [src] into a poultice.</span>")
	user.drop_item()
	qdel(src)