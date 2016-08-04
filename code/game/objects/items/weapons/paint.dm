//NEVER USE THIS IT SUX	-PETETHEGOAT

/obj/item/weapon/reagent_containers/glass/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	materials = list(MAT_METAL=200)
	w_class = 3
	burn_state = FLAMMABLE
	burntime = 5
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,20,30,50,70)
	volume = 70
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/paint/afterattack(turf/simulated/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target) && reagents.total_volume >= 5)
		user.visible_message("<span class='warning'>[target] has been splashed with something by [user]!</span>")
		spawn(5)
			reagents.reaction(target, TOUCH)
			reagents.remove_any(5)
	else
		return ..()

/obj/item/weapon/reagent_containers/glass/paint/red
	name = "red paint bucket"
	icon_state = "paint_red"
	list_reagents = list("paint_red" = 70)

/obj/item/weapon/reagent_containers/glass/paint/green
	name = "green paint bucket"
	icon_state = "paint_green"
	list_reagents = list("paint_green" = 70)

/obj/item/weapon/reagent_containers/glass/paint/blue
	name = "blue paint bucket"
	icon_state = "paint_blue"
	list_reagents = list("paint_blue" = 70)

/obj/item/weapon/reagent_containers/glass/paint/yellow
	name = "yellow paint bucket"
	icon_state = "paint_yellow"
	list_reagents = list("paint_yellow" = 70)

/obj/item/weapon/reagent_containers/glass/paint/violet
	name = "violet paint bucket"
	icon_state = "paint_violet"
	list_reagents = list("paint_violet" = 70)

/obj/item/weapon/reagent_containers/glass/paint/black
	name = "black paint bucket"
	icon_state = "paint_black"
	list_reagents = list("paint_black" = 70)

/obj/item/weapon/reagent_containers/glass/paint/white
	name = "white paint bucket"
	icon_state = "paint_white"
	list_reagents = list("paint_white" = 70)

/obj/item/weapon/reagent_containers/glass/paint/remover
	name = "paint remover bucket"
	list_reagents = list("paint_remover" = 70)