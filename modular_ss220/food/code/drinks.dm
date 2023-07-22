/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	. = ..()
	if(!reagents.reagent_list.len)
		icon = initial(icon)
		return
	var/datum/reagent/reagent = reagents.get_master_reagent()
	if(!istype(reagent, /datum/reagent/consumable/ethanol))
		return
	var/datum/reagent/consumable/ethanol/booze = reagent
	icon = booze.drinking_glass_icon

/datum/reagent/consumable/ethanol
	var/drinking_glass_icon = 'icons/obj/drinks.dmi'

/obj/machinery/chem_dispenser/beer/Initialize(mapload)
	. = ..()
	dispensable_reagents |= "sambuka"

/obj/item/handheld_chem_dispenser/booze/Initialize(mapload)
	. = ..()
	dispensable_reagents |= "sambuka"

/datum/reagent/consumable/ethanol/sambuka
	name = "Sambuka"
	id = "sambuka"
	description = "Flying into space, many thought that they had grasped fate."
	color = "#e0e0e0"
	alcohol_perc = 0.45
	dizzy_adj = 1
	drink_icon = "sambukaglass"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Glass of Sambuka"
	drink_desc = "Flying into space, many thought that they had grasped fate."
	taste_description = "twirly fire"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	description = "Remember that big brother sees everything."
	color = "#746463"
	alcohol_perc = 0.5
	drink_icon = "innocent_erp"
	drinking_glass_icon = 'modular_ss220/food/icons/drinks.dmi'
	drink_name = "Innocent ERP"
	drink_desc = "Remember that big brother sees everything."
	taste_description = "loss of flirtatiousness"

/datum/chemical_reaction/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	result = "innocent_erp"
	required_reagents = list("sambuka" = 3, "triple_citrus" = 1, "irishcream" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
