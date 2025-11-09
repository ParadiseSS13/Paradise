/obj/item/reagent_containers/food
	name = "dry tapioca pearls"
	desc = "Small, hard balls of dried tapioca starch."
	inhand_icon_state = "tapioca_drypearls"
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	volume = 10


/obj/item/reagent_containers/food/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	apply(user, user)

/obj/item/reagent_containers/food/proc/apply(mob/living/carbon/C, mob/user)
	if(!istype(C))
		return FALSE

	if(!reagents.total_volume)
		qdel(src)
		return TRUE

/obj/item/reagent_containers/food/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isnull(target.reagents))
		return

	return ..()

/obj/item/reagent_containers/food/mob_act(mob/target, mob/living/user)
	apply(target, user)
	return TRUE

/obj/item/reagent_containers/food/normal_act(atom/target, mob/living/user)
	. = TRUE
	if(!target.is_refillable())
		return
	if(target.reagents.holder_full())
		to_chat(user, "<span class='warning'>[target] is full.</span>")
		return

	to_chat(user, "<span class='notice'>You [!target.reagents.total_volume ? "pour" : "dump"] [src] in [target].</span>")
	for(var/mob/O in oviewers(2, user))
		O.show_message("<span class='warning'>[user] puts something in [target].</span>", 1)
	reagents.trans_to(target, reagents.total_volume)
	qdel(src)

/obj/item/reagent_containers/food/drytapioca_pearls
	name = "dry tapioca pearls"
	desc = "Small, hard balls of dried tapioca starch."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "tapioca_drypearls"
	list_reagents = list("drytapioca" = 10)
