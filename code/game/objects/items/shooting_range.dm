// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = FALSE
	var/hp = 1800

/obj/item/target/Destroy()
	cut_overlays()
	// if a target is deleted and associated with a stake, force stake to forget
	for(var/obj/structure/target_stake/T in view(3, src))
		if(T.pinned_target == src)
			T.pinned_target = null
			T.density = TRUE
			break
	return ..() // delete target

/obj/item/target/Move()
	..()
	// After target moves, check for nearby stakes. If associated, move to target
	for(var/obj/structure/target_stake/M in view(3, src))
		if(!M.density && M.pinned_target == src)
			M.loc = loc

	// This may seem a little counter-intuitive but I assure you that's for a purpose.
	// Stakes are the ones that carry targets, yes, but in the stake code we set
	// a stake's density to 0 meaning it can't be pushed anymore. Instead of pushing
	// the stake now, we have to push the target.


/obj/item/target/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!use_tool(src, user, 0, volume = I.tool_volume))
		return
	overlays.Cut()
	to_chat(user, "<span class='notice'>You slice off [src]'s uneven chunks of aluminium and scorch marks.</span>")

/obj/item/target/attack_hand(mob/user)
	// taking pinned targets off!
	var/obj/structure/target_stake/stake
	for(var/obj/structure/target_stake/T in view(3,src))
		if(T.pinned_target == src)
			stake = T
			break

	if(stake)
		if(stake.pinned_target)
			stake.density = TRUE
			density = FALSE
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

#define DECALTYPE_SCORCH 1
#define DECALTYPE_BULLET 2

/obj/item/target/bullet_act(obj/item/projectile/P)
	var/p_x = P.p_x + pick(0,0,0,0,0,-1,1) // really ugly way of coding "sometimes offset P.p_x!"
	var/p_y = P.p_y + pick(0,0,0,0,0,-1,1)
	var/decaltype = DECALTYPE_SCORCH
	if(istype(P, /obj/item/projectile/bullet))
		decaltype = DECALTYPE_BULLET

	var/icon/C = icon(icon, icon_state)
	if(LAZYLEN(overlays) <= 35 && C.GetPixel(p_x, p_y)) // if the located pixel isn't blank (null)
		hp -= P.damage
		if(hp <= 0)
			visible_message("<span class='danger'>[src] breaks into tiny pieces and collapses!</span>")
			qdel(src)
			return
		var/image/bullet_hole = image('icons/effects/effects.dmi', "scorch", OBJ_LAYER + 0.5)
		bullet_hole.pixel_x = p_x - 1 //offset correction
		bullet_hole.pixel_y = p_y - 1
		if(decaltype == DECALTYPE_SCORCH)
			if(P.damage >= 20 || istype(P, /obj/item/projectile/beam/practice))
				bullet_hole.dir = pick(NORTH,SOUTH,EAST,WEST) // random scorch design. light_scorch does not have different directions
			else
				bullet_hole.icon_state = "light_scorch"
		else
			bullet_hole.icon_state = "dent"
		add_overlay(bullet_hole)
		return

	return -1 // the bullet/projectile goes through the target! Ie, you missed

#undef DECALTYPE_SCORCH
#undef DECALTYPE_BULLET
