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


obj/machinery/cooker/deepfryer/gettype()
	var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/type = new(get_turf(src))
	return type

