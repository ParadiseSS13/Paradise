///hispania foods



///Cookies by Ume

/datum/chemical_reaction/cookiedough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list("milk" = 10, "flour" = 10, "sugar" = 5)
	result_amount = 1
	mix_message = "The ingredients form a dough. It smells sweet and yummy."

/datum/chemical_reaction/cookiedough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cookiedough(location)
