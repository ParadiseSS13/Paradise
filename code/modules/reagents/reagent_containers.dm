/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	var/default = null
	if(amount_per_transfer_from_this in possible_transfer_amounts)
		default = amount_per_transfer_from_this
	var/N = input("Amount per transfer from this:", "[src]", default) as null|anything in possible_transfer_amounts
	if(N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/New()
	..()
	if(!possible_transfer_amounts)
		verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src
	processing_objects.Add(src)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease(0)
		var/list/data = list("viruses" = list(F), "blood_colour" = "#A10808")
		reagents.add_reagent("blood", disease_amount, data)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/weapon/reagent_containers/process()
	if(reagents)
		reagents.reagent_on_tick()
	return

/obj/item/weapon/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/item/weapon/reagent_containers/fire_act()
	reagents.chem_temp += 30
	reagents.handle_reactions()
	..()

/obj/item/weapon/reagent_containers/attack_self(mob/user)
	return

// this prevented pills, food, and other things from being picked up by bags.
// possibly intentional, but removing it allows us to not duplicate functionality.
// -Sayu (storage conslidation)
/*
/obj/item/weapon/reagent_containers/attackby(obj/item/I as obj, mob/user as mob, params)
	return
*/
/obj/item/weapon/reagent_containers/afterattack(obj/target, mob/user , flag)
	return

/obj/item/weapon/reagent_containers/proc/reagentlist(obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack && snack.reagents && snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for(var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] units); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else return "No reagents"

/obj/item/weapon/reagent_containers/wash(mob/user, atom/source)
	if(is_open_container())
		if(reagents.total_volume >= volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		else
			reagents.add_reagent("water", min(volume - reagents.total_volume, amount_per_transfer_from_this))
			to_chat(user, "<span class='notice'>You fill [src] from [source].</span>")
			return
	..()