/obj/machinery/cooking
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5

	var/candy = FALSE
	var/on = FALSE	//Is it making food already?
	var/list/food_choices = list()

/obj/machinery/cooking/Initialize(mapload)
	. = ..()
	updatefood()

/obj/machinery/cooking/attackby(obj/item/I, mob/user, params)
	if(on)
		to_chat(user, "The machine is already running.")
		return
	else
		var/obj/item/F = I
		var/obj/item/food/snacks/customizable/C
		C = tgui_input_list(user, "Select food to make.", "Cooking", food_choices)
		if(!C)
			return
		else
			to_chat(user, "You put [F] into [src] for cooking.")
			user.drop_item()
			F.loc = src
			on = TRUE
			if(!candy)
				icon_state = "oven_on"
			else
				icon_state = "mixer_on"
			sleep(100)
			on = FALSE
			if(!candy)
				icon_state = "oven_off"
			else
				icon_state = "mixer_off"
			C.loc = get_turf(src)
			C.attackby(F,user, params)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			updatefood()
			return

/obj/machinery/cooking/proc/updatefood()
	return

/obj/machinery/cooking/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"

/obj/machinery/cooking/oven/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in subtypesof(/obj/item/food/snacks/customizable/cook))
		var/obj/item/food/snacks/customizable/cook/V = new U
		food_choices += V
	return

/obj/machinery/cooking/candy
	name = "candy machine"
	desc = "Get yer box of deep fried deep fried deep fried deep fried cotton candy cereal sandwich cookies here!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "mixer_off"
	candy = TRUE

/obj/machinery/cooking/candy/updatefood()
	for(var/U in food_choices)
		food_choices.Remove(U)
	for(var/U in subtypesof(/obj/item/food/snacks/customizable/candy))
		var/obj/item/food/snacks/customizable/candy/V = new U
		food_choices += V
	return
