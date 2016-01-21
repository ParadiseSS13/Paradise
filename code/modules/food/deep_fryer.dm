/obj/machinery/cooker/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "fryer_off"
	thiscooktype = "deep fried"
	burns = 1
	firechance = 100
	cooktime = 200
	foodcolor = "#FFAD33"
	officon = "fryer_off"
	onicon = "fryer_on"
	has_specials = 1


/obj/machinery/cooker/deepfryer/gettype()
	var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/type = new(get_turf(src))
	return type

/obj/machinery/cooker/deepfryer/checkSpecials(obj/item/I)
	if(!I)
		return 0
	for (var/Type in subtypesof(/datum/deepfryer_special))
		var/datum/deepfryer_special/P = new Type()
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = I
			if(G.seed.kitchen_tag != P.input)
				continue
		else if (!istype(I, P.input))
			continue
		return P
	return 0

/obj/machinery/cooker/deepfryer/cookSpecial(special)
	if(!special)
		return 0
	var/datum/deepfryer_special/recipe = special
	if(!recipe.output)
		return 0
	new recipe.output(get_turf(src))


//////////////////////////////////
//		Deepfryer Special		//
//		Interaction Datums		//
//////////////////////////////////

/datum/deepfryer_special
	var/input		//Thing that goes in
	var/output		//Thing that comes out

/datum/deepfryer_special/shrimp
	input = /obj/item/weapon/reagent_containers/food/snacks/shrimp
	output = /obj/item/weapon/reagent_containers/food/snacks/fried_shrimp

/datum/deepfryer_special/banana
	input = "banana"
	output = /obj/item/weapon/reagent_containers/food/snacks/friedbanana

/datum/deepfryer_special/potato_chips
	input = /obj/item/weapon/reagent_containers/food/snacks/rawsticks
	output = /obj/item/weapon/reagent_containers/food/snacks/chips

/datum/deepfryer_special/corn_chips
	input = "corn"
	output = /obj/item/weapon/reagent_containers/food/snacks/cornchips

/datum/deepfryer_special/fried_tofu
	input = /obj/item/weapon/reagent_containers/food/snacks/tofu
	output = /obj/item/weapon/reagent_containers/food/snacks/fried_tofu
