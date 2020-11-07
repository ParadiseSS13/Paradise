/obj/item/reagent_containers/food/condiment/mayonnaise
	name = "mayonnaise"
	desc = "Tasty and beauty mayonnaise!"
	list_reagents = list("mayonnaise" = 35)
	icon_state = "mayonnaise"

/obj/item/reagent_containers/food/condiment/pack/discount_sauce
	name = "Discount Dan's Special Sauce"
	desc = "Discount Dan brings you his very own special blend of delicious ingredients in one discount sauce!"
	list_reagents = list("discount_sauce" = 10)
	icon = 'icons/hispania/obj/food/containers.dmi'
	icon_state = "discount_sauce"

/obj/item/reagent_containers/food/condiment/pack/discount_sauce/on_reagent_change()
	icon = 'icons/hispania/obj/food/containers.dmi'
	icon_state = "discount_sauce"
