/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 5
	flags = NOBLUDGEON
	has_lid = FALSE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	var/wipespeed = 30

/obj/item/reagent_containers/glass/rag/mob_act(mob/target, mob/living/user)
	if(target.reagents && reagents.total_volume)
		user.visible_message("<span class='danger'>[user] has smothered [target] with [src]!</span>", "<span class='danger'>You smother [target] with [src]!</span>", "You hear some struggling and muffled cries of surprise")
		src.reagents.reaction(target, REAGENT_TOUCH)
		src.reagents.clear_reagents()
		return TRUE
	else
		return ..()

/obj/item/reagent_containers/glass/rag/normal_act(atom/target, mob/living/user)
	target.cleaning_act(user, src, wipespeed)
	return TRUE

/obj/item/reagent_containers/glass/rag/can_clean()
	return TRUE
