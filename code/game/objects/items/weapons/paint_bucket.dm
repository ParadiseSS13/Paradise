//NEVER USE THIS IT SUX	-PETETHEGOAT

/obj/item/reagent_containers/glass/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/paint.dmi'
	icon_state = "paint_neutral"
	inhand_icon_state = "paintcan"
	materials = list(MAT_METAL = 400)
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,20,30,50,70)
	volume = 70
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

/obj/item/reagent_containers/glass/paint/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!is_open_container())
		return ITEM_INTERACT_COMPLETE
	if(istype(target) && reagents.total_volume >= 5)
		user.visible_message("<span class='warning'>[target] has been splashed with something by [user]!</span>")
		spawn(5)
			reagents.reaction(target, REAGENT_TOUCH)
			reagents.remove_any(5)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/item/reagent_containers/glass/paint/red
	name = "red paint bucket"
	icon_state = "paint_red"
	list_reagents = list("paint_red" = 70)

/obj/item/reagent_containers/glass/paint/green
	name = "green paint bucket"
	icon_state = "paint_green"
	list_reagents = list("paint_green" = 70)

/obj/item/reagent_containers/glass/paint/blue
	name = "blue paint bucket"
	icon_state = "paint_blue"
	list_reagents = list("paint_blue" = 70)

/obj/item/reagent_containers/glass/paint/yellow
	name = "yellow paint bucket"
	icon_state = "paint_yellow"
	list_reagents = list("paint_yellow" = 70)

/obj/item/reagent_containers/glass/paint/violet
	name = "violet paint bucket"
	icon_state = "paint_violet"
	list_reagents = list("paint_violet" = 70)

/obj/item/reagent_containers/glass/paint/black
	name = "black paint bucket"
	icon_state = "paint_black"
	list_reagents = list("paint_black" = 70)

/obj/item/reagent_containers/glass/paint/white
	name = "white paint bucket"
	icon_state = "paint_white"
	list_reagents = list("paint_white" = 70)

/obj/item/reagent_containers/glass/paint/remover
	name = "paint remover bucket"
	list_reagents = list("paint_remover" = 70)
