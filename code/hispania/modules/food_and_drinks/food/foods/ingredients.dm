//////////////
////Butter////
/////////////

/obj/item/reagent_containers/food/snacks/butter
	name = "butter"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "butter"
	desc = "Delicious milk fat."
	filling_color = "#fff98f"
	bitesize = 3
	list_reagents = list("butter" = 20)
	tastes = list("butter" = 1)
	junkiness = 20
	var/stick = FALSE

/obj/item/reagent_containers/food/snacks/butter/update_icon()
	if(stick)
		icon_state = "butter_stick"
		name = "butter on a stick"
	else
		icon_state = "butter"

//butter + metal rod = butter on a stick
/obj/item/reagent_containers/food/snacks/butter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods) && !stick)
		to_chat(user, "<span class='notice'>You insert the [I] into the [src].</span>")
		stick = TRUE
		update_icon()
		qdel(I)
	else
		return ..()
