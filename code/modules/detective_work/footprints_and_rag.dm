
/mob
	var/bloody_hands = 0
	var/list/feet_blood_DNA
	var/feet_blood_color
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0, BLOOD_BASE_ALPHA = BLOODY_FOOTPRINT_BASE_ALPHA)

/obj/item/clothing/gloves
	var/transfer_blood = 0

/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 5
	flags = NOBLUDGEON
	container_type = OPENCONTAINER
	has_lid = FALSE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	var/wipespeed = 30

/obj/item/reagent_containers/glass/rag/attack(atom/target as obj|turf|area, mob/user as mob , flag)
	if(ismob(target) && target.reagents && reagents.total_volume)
		user.visible_message("<span class='danger'>[user] has smothered [target] with [src]!</span>", "<span class='danger'>You smother [target] with [src]!</span>", "You hear some struggling and muffled cries of surprise")
		src.reagents.reaction(target, REAGENT_TOUCH)
		src.reagents.clear_reagents()
		return
	else
		..()

/obj/item/reagent_containers/glass/rag/afterattack(atom/target, mob/user, proximity)
	if(!proximity || ishuman(target)) //Human check so we don't clean the person we're trying to ether
		return
	target.cleaning_act(user, src, wipespeed)

/obj/item/reagent_containers/glass/rag/can_clean()
	return TRUE
