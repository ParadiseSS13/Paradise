/obj/item/reagent_containers/food/snacks/grown/Initialize(mapload, obj/item/seeds/new_seed = null)
	. = ..()

	icon = (hispania_icon ? 'modular_hispania/icons/obj/hydroponics/harvest.dmi' : icon)
