// Basically they are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = 1
	flags = CONDUCT
	var/obj/item/target/pinned_target // the current pinned target

/obj/structure/target_stake/Destroy()
	QDEL_NULL(pinned_target)
	return ..()

/obj/structure/target_stake/Move()
	. = ..()
	// Move the pinned target along with the stake
	if(pinned_target in view(3, src))
		pinned_target.loc = loc

	else // Sanity check: if the pinned target can't be found in immediate view
		pinned_target = null
		density = 1

/obj/structure/target_stake/attackby(obj/item/W, mob/user, params)
	// Putting objects on the stake. Most importantly, targets
	if(istype(W, /obj/item/target) && !pinned_target)
		density = 0
		W.density = 1
		user.drop_item(src)
		W.loc = loc
		W.layer = 3.1
		pinned_target = W
		to_chat(user, "You slide the target into the stake.")
		return
	return ..()

/obj/structure/target_stake/attack_hand(mob/user)
	// taking pinned targets off!
	if(pinned_target)
		density = 1
		pinned_target.density = 0
		pinned_target.layer = OBJ_LAYER

		pinned_target.loc = user.loc
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hands(pinned_target)
				to_chat(user, "You take the target out of the stake.")
		else
			pinned_target.loc = get_turf(user)
			to_chat(user, "You take the target out of the stake.")

		pinned_target = null
