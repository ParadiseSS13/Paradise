/datum/chemical_reaction/

	tofu
		name = "Tofu"
		id = "tofu"
		result = null
		required_reagents = list("soymilk" = 10)
		required_catalysts = list("enzyme" = 5)
		result_amount = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/i = 1, i <= created_volume, i++)
				new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
			return

	chocolate_bar
		name = "Chocolate Bar"
		id = "chocolate_bar"
		result = null
		required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
		result_amount = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/i = 1, i <= created_volume, i++)
				new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
			return

	chocolate_bar2
		name = "Chocolate Bar"
		id = "chocolate_bar"
		result = null
		required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
		result_amount = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			for(var/i = 1, i <= created_volume, i++)
				new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
			return


	soysauce
		name = "Soy Sauce"
		id = "soysauce"
		result = "soysauce"
		required_reagents = list("soymilk" = 2, "flour" = 1, "sodiumchloride" = 1, "water" = 3)
		result_amount = 7

	cheesewheel
		name = "Cheesewheel"
		id = "cheesewheel"
		result = null
		required_reagents = list("milk" = 40)
		required_catalysts = list("enzyme" = 5)
		result_amount = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)
			return

	syntiflesh
		name = "Syntiflesh"
		id = "syntiflesh"
		result = null
		required_reagents = list("blood" = 5, "cryoxadone" = 1)
		result_amount = 1
		on_reaction(var/datum/reagents/holder, var/created_volume)
			var/location = get_turf(holder.my_atom)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
			return

	hot_ramen
		name = "Hot Ramen"
		id = "hot_ramen"
		result = "hot_ramen"
		required_reagents = list("water" = 1, "dry_ramen" = 3)
		result_amount = 3

	hell_ramen
		name = "Hell Ramen"
		id = "hell_ramen"
		result = "hell_ramen"
		required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
		result_amount = 6

	doughball
		name = "Ball of dough"
		id = "dough_ball"
		result = "dough_ball"
		required_reagents = list("flour" = 15, "water" = 5)
		required_catalysts = list("enzyme" = 5)

	sodiumchloride
		name = "Sodium Chloride"
		id = "sodiumchloride"
		result = "sodiumchloride"
		required_reagents = list("sodium" = 1, "chlorine" = 1, "water" = 1)
		result_amount = 3
		mix_message = "The solution crystallizes with a brief flare of light."

	ice
		name = "Ice"
		id = "ice"
		result = "ice"
		required_reagents = list("water" = 1)
		result_amount = 1
		max_temp = 273
		mix_message = "Ice forms as the water freezes."
		mix_sound = null