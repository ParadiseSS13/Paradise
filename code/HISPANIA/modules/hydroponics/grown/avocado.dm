/obj/item/seeds/avocado
	name = "pack of avocado seeds"
	desc = "These seeds grow into avocado trees. Watery."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "seed-avocado"
	species = "avocado"
	plantname = "Avocado Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/avocado
	lifespan = 50
	endurance = 35
	production = 5
	potency = 30
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "avocado-grow"
	icon_dead = "avocado-dead"
	mutatelist = list(/obj/item/seeds/avocado/aircado, /obj/item/seeds/avocado/firecado, /obj/item/seeds/avocado/earthcado)
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list( "water" = 0.05, "vitamin" = 0.05, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/avocado
	seed = /obj/item/seeds/avocado
	name = "avocado"
	desc = "An unusually fatty fruit containing a single large seed."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "avocado"
	slice_path = /obj/item/reagent_containers/food/snacks/avocadoslice
	slices_num = 2

/obj/item/reagent_containers/food/snacks/avocadoslice
	name = "avocado slice"
	desc = "A slice of green goodness."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "avocado_cut"

/obj/item/reagent_containers/food/snacks/grown/avocado/attackby(obj/item/W, mob/user, params)
	if(is_sharp(W))
		var/mob/living/carbon/human/H = user
		if(prob(5))
			var/picked_hand = pick("l_hand", "r_hand")
			var/obj/item/organ/external/M = H.get_organ(picked_hand)
			if (prob(99))
				to_chat(user, "<span class='warning'>You fail to cut [src] and cut your hand instead!</span>")
				H.apply_damage(20, BRUTE, picked_hand)
				M.fracture()
				return
			else
				to_chat(viewers(user), "<span class='danger'>[user] fails horribly to cut [src] and cuts [p_their()] hand right off instead!</span>")
				user.emote("scream")
				M.droplimb()
				H.regenerate_icons()
				return
		else
			..()

/obj/item/seeds/avocado/aircado
	name = "pack of avocado seeds"
	desc = "These seeds grow into aircado trees. Airy."
	icon_state = "seed-aircado"
	species = "aircado"
	plantname = "Aircado Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/avocado/aircado
	mutatelist = list(/obj/item/seeds/avocado, /obj/item/seeds/avocado/firecado, /obj/item/seeds/avocado/earthcado)
	reagents_add = list( "oxygen" = 0.05)
	rarity = 20

/obj/item/seeds/avocado/firecado
	name = "pack of firecado seeds"
	desc = "These seeds grow into firecado trees. Fiery."
	icon_state = "seed-firecado"
	species = "firecado"
	plantname = "Firecado Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/avocado/firecado
	mutatelist = list(/obj/item/seeds/avocado, /obj/item/seeds/avocado/aircado, /obj/item/seeds/avocado/earthcado)
	reagents_add = list( "oil" = 0.05, "plantmatter" = 0.1)
	rarity = 20

/obj/item/seeds/avocado/earthcado
	name = "pack of earthcado seeds"
	desc = "These seeds grow into earthcado trees. Earthy."
	icon_state = "seed-earthcado"
	species = "earthcado"
	plantname = "Earthcado Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/avocado/earthcado
	mutatelist = list(/obj/item/seeds/avocado, /obj/item/seeds/avocado/firecado, /obj/item/seeds/avocado/aircado)
	reagents_add = list( "carbon" = 0.05, "plantmatter" = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/avocado/aircado
	seed = /obj/item/seeds/avocado/aircado
	name = "aircado"
	desc = "An unusually airy fruit containing a single large seed."
	icon_state = "aircado"
	slice_path = /obj/item/reagent_containers/food/snacks/avocadoslice/aircado

/obj/item/reagent_containers/food/snacks/grown/avocado/firecado
	seed = /obj/item/seeds/avocado/firecado
	name = "firecado"
	desc = "An unusually fiery fruit containing a single large seed."
	icon_state = "firecado"
	slice_path = /obj/item/reagent_containers/food/snacks/avocadoslice/firecado

/obj/item/reagent_containers/food/snacks/grown/avocado/earthcado
	seed = /obj/item/seeds/avocado/earthcado
	name = "earthcado"
	desc = "An unusually earthy fruit containing a single large seed."
	icon_state = "earthcado"
	slice_path = /obj/item/reagent_containers/food/snacks/avocadoslice/earthcado

/obj/item/reagent_containers/food/snacks/avocadoslice/aircado
	name = "aircado slice"
	desc = "A slice of white goodness."
	icon_state = "aircado_cut"

/obj/item/reagent_containers/food/snacks/avocadoslice/firecado
	name = "firecado slice"
	desc = "A slice of red goodness."
	icon_state = "firecado_cut"

/obj/item/reagent_containers/food/snacks/avocadoslice/earthcado
	name = "earthcado slice"
	desc = "A slice of brown goodness."
	icon_state = "earthcado_cut"
