// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = 0
	var/hp = 1800

/obj/item/target/Destroy()
	// if a target is deleted and associated with a stake, force stake to forget
	for(var/obj/structure/target_stake/T in view(3,src))
		if(T.pinned_target == src)
			T.pinned_target = null
			T.density = 1
			break
	return ..() // delete target

/obj/item/target/Move()
	..()
	// After target moves, check for nearby stakes. If associated, move to target
	for(var/obj/structure/target_stake/M in view(3,src))
		if(M.density == 0 && M.pinned_target == src)
			M.loc = loc

	// This may seem a little counter-intuitive but I assure you that's for a purpose.
	// Stakes are the ones that carry targets, yes, but in the stake code we set
	// a stake's density to 0 meaning it can't be pushed anymore. Instead of pushing
	// the stake now, we have to push the target.



/obj/item/target/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			overlays.Cut()
			to_chat(usr, "You slice off [src]'s uneven chunks of aluminum and scorch marks.")
			return


/obj/item/target/attack_hand(mob/user as mob)
	// taking pinned targets off!
	var/obj/structure/target_stake/stake
	for(var/obj/structure/target_stake/T in view(3,src))
		if(T.pinned_target == src)
			stake = T
			break

	if(stake)
		if(stake.pinned_target)
			stake.density = 1
			density = 0
			layer = OBJ_LAYER

			loc = user.loc
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(src)
					to_chat(user, "You take the target out of the stake.")
			else
				src.loc = get_turf(user)
				to_chat(user, "You take the target out of the stake.")

			stake.pinned_target = null
			return

	else
		..()

/obj/item/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like a syndicate scum."
	hp = 2600 // i guess syndie targets are sturdier?

/obj/item/target/alien
	icon_state = "target_q"
	desc = "A shooting target that looks like a xenomorphic alien."
	hp = 2350 // alium onest too kinda
