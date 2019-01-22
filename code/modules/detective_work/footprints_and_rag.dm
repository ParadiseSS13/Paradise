
/mob
	var/bloody_hands = 0
	var/list/feet_blood_DNA
	var/feet_blood_color
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0)

/obj/item/clothing/gloves
	var/transfer_blood = 0

/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null
	flags = NOBLUDGEON
	container_type = OPENCONTAINER
	has_lid = FALSE
	var/wipespeed = 30

/obj/item/reagent_containers/glass/rag/attack(atom/target as obj|turf|area, mob/user as mob , flag)
	if(ismob(target) && target.reagents && reagents.total_volume)
		user.visible_message("<span class='danger'>[user] has smothered \the [target] with \the [src]!</span>", "<span class='danger'>You smother \the [target] with \the [src]!</span>", "You hear some struggling and muffled cries of surprise")
		src.reagents.reaction(target, TOUCH)
		src.reagents.clear_reagents()
		return
	else
		..()

/obj/item/reagent_containers/glass/rag/afterattack(atom/A as obj|turf|area, mob/user as mob,proximity)
	if(!proximity) return
	if(istype(A) && src in user)
		user.visible_message("[user] starts to wipe down [A] with [src]!")
		if(do_after(user, wipespeed, target = A))
			user.visible_message("[user] finishes wiping off the [A]!")
			A.clean_blood()
	return
