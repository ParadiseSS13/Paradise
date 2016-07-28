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
	openicon = "fryer_open"
	has_specials = 1
	upgradeable = 1

/obj/machinery/cooker/deepfryer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/deepfryer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/cooker/deepfryer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/deepfryer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/cooker/deepfryer/RefreshParts()
	var/E = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		E += L.rating
	E -= 2		//Standard parts is 0 (1+1-2), Tier 4 parts is 6 (4+4-2)
	cooktime = (200 - (E * 20))		//Effectively each laser improves cooktime by 20 per rating beyond the first (200 base, 80 max upgrade)

/obj/machinery/cooker/deepfryer/gettype()
	var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/type = new(get_turf(src))
	return type

/obj/machinery/cooker/deepfryer/checkSpecials(obj/item/I)
	if(!I)
		return 0
	for(var/Type in subtypesof(/datum/deepfryer_special))
		var/datum/deepfryer_special/P = new Type()
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = I
			if(G.seed.kitchen_tag != P.input)
				continue
		else if(!istype(I, P.input))
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

/datum/deepfryer_special/chimichanga
	input = /obj/item/weapon/reagent_containers/food/snacks/burrito
	output = /obj/item/weapon/reagent_containers/food/snacks/chimichanga