/obj/item/weapon/reagent_containers/food/snacks/grown/tomatoexplosive
	name = "seething tomato"
	desc = "I say to-mah-to, you say KABOOM."
	icon_state = "explosivetomato"
	filling_color = "#FF0000"
	potency = 10
	plantname = "explosivetomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomatoexplosive/throw_impact(atom/hit_atom)
	..()
	src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
	var/location = get_turf(hit_atom)
	explosion(location, 0, 0, 2)
	new/obj/effect/decal/cleanable/tomato_smudge(src.loc)
	return

/obj/item/weapon/reagent_containers/food/snacks/grown/steelwheat
	name = "steel wheat"
	desc = "This wheat has a steely look to it."
	gender = PLURAL
	icon_state = "steelwheat"
	filling_color = "#808080"
	plantname = "steelwheat"

/obj/item/weapon/reagent_containers/food/snacks/grown/soylentsoybeans
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "soylentsoybeans"

/obj/item/weapon/reagent_containers/food/snacks/grown/purplegoop
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "dripper"

/obj/item/weapon/reagent_containers/food/snacks/grown/glowfruit
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "light_lotus"

/obj/item/weapon/reagent_containers/food/snacks/grown/contusine
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "contusine"

/obj/item/weapon/reagent_containers/food/snacks/grown/shiveringcontusine
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "shiveringcontusine"

/obj/item/weapon/reagent_containers/food/snacks/grown/quiveringcontusine
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "quiveringcontusine"

/obj/item/weapon/reagent_containers/food/snacks/grown/nureous
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "nureous"

/obj/item/weapon/reagent_containers/food/snacks/grown/fuzzynureous
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "fuzzynureous"

/obj/item/weapon/reagent_containers/food/snacks/grown/asomna
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "asomna"

/obj/item/weapon/reagent_containers/food/snacks/grown/robustasomna
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "robustasomna"

/obj/item/weapon/reagent_containers/food/snacks/grown/commol
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "commol"

/obj/item/weapon/reagent_containers/food/snacks/grown/burningcommol
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "burningcommol"

/obj/item/weapon/reagent_containers/food/snacks/grown/venne
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "venne"

/obj/item/weapon/reagent_containers/food/snacks/grown/toxicvenne
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "toxicvenne"

/obj/item/weapon/reagent_containers/food/snacks/grown/curativevenne
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "curativevenne"

/obj/item/weapon/reagent_containers/food/snacks/grown/cannabis
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "cannabis"

/obj/item/weapon/reagent_containers/food/snacks/grown/lifeweed
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "lifeweed"

/obj/item/weapon/reagent_containers/food/snacks/grown/deathweed
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "deathweed"

/obj/item/weapon/reagent_containers/food/snacks/grown/rainbowweed
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "rainbowweed"

/obj/item/weapon/reagent_containers/food/snacks/grown/omegaweed
	name = "strange soybean"
	desc = "Something isn't right about this."
	gender = PLURAL
	icon_state = "soylentsoybeans"
	filling_color = "#808080"
	plantname = "omegaweed"

