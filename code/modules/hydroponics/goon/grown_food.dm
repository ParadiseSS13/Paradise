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