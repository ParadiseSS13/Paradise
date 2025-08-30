// Carrot
/obj/item/seeds/carrot
	name = "pack of carrot seeds"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/food/grown/carrot
	maturation = 10
	production = 1
	yield = 5
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	mutatelist = list(/obj/item/seeds/carrot/parsnip)
	reagents_add = list("oculine" = 0.25, "vitamin" = 0.04, "plantmatter" = 0.05)

/obj/item/food/grown/carrot
	seed = /obj/item/seeds/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bitesize_mod = 2
	tastes = list("carrot" = 1)
	wine_power = 0.3

/obj/item/food/grown/carrot/wedges
	name = "carrot wedges"
	desc = "Slices of neatly cut carrot."
	icon_state = "carrot_wedges"

/obj/item/food/grown/carrot/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!used.sharp)
		return ..()

	to_chat(user, "<span class='notice'>You sharpen [src] into a shiv with [used].</span>")
	var/obj/item/kitchen/knife/shiv/carrot/shiv = new ()
	if(!remove_item_from_storage(user))
		user.unequip(src)
	user.put_in_hands(shiv)
	qdel(src)
	return ITEM_INTERACT_COMPLETE


// Parsnip
/obj/item/seeds/carrot/parsnip
	name = "pack of parsnip seeds"
	desc = "These seeds grow into parsnips."
	icon_state = "seed-parsnip"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/food/grown/parsnip
	icon_dead = "carrot-dead"
	mutatelist = list()
	reagents_add = list("vitamin" = 0.05, "plantmatter" = 0.05)

/obj/item/food/grown/parsnip
	seed = /obj/item/seeds/carrot/parsnip
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	bitesize_mod = 2
	tastes = list("parsnip" = 1)
	wine_power = 0.35


// White-Beet
/obj/item/seeds/whitebeet
	name = "pack of white beet seeds"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	species = "whitebeet"
	plantname = "White Beet Plants"
	product = /obj/item/food/grown/whitebeet
	lifespan = 60
	endurance = 50
	yield = 6
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	mutatelist = list(/obj/item/seeds/redbeet)
	reagents_add = list("vitamin" = 0.04, "sugar" = 0.2, "plantmatter" = 0.05)

/obj/item/food/grown/whitebeet
	seed = /obj/item/seeds/whitebeet
	name = "white beet"
	desc = "You can't beat white beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	bitesize_mod = 2
	tastes = list("white beet" = 1)
	wine_power = 0.4

// Red Beet
/obj/item/seeds/redbeet
	name = "pack of redbeet seeds"
	desc = "These seeds grow into red beet producing plants."
	icon_state = "seed-redbeet"
	species = "redbeet"
	plantname = "Red Beet Plants"
	product = /obj/item/food/grown/redbeet
	lifespan = 60
	endurance = 50
	yield = 6
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	genes = list(/datum/plant_gene/trait/maxchem)
	reagents_add = list("vitamin" = 0.05, "plantmatter" = 0.05)

/obj/item/food/grown/redbeet
	seed = /obj/item/seeds/redbeet
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	tastes = list("red beet" = 1)
	bitesize_mod = 2
	wine_power = 0.6
