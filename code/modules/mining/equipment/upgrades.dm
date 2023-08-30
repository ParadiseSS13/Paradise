//plasma magmite is exclusively used to upgrade mining equipment, by using it on a heated world anvil to make upgradeparts.
/obj/item/magmite
	name = "plasma magmite"
	desc = "A chunk of plasma magmite, crystallized deep under the planet's surface. It seems to lose strength as it gets further from the planet!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "Magmite ore"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/magmite_parts
	name = "plasma magmite upgrade parts"
	desc = "Forged on the legendary World Anvil, these parts can be used to upgrade many kinds of mining equipment."
	icon = 'icons/obj/mining.dmi'
	icon_state = "upgrade_parts"
	w_class = WEIGHT_CLASS_NORMAL
	var/inert = FALSE

/obj/item/magmite_parts/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(go_inert)), 10 MINUTES)

/obj/item/magmite_parts/proc/go_inert()
	if(inert)
		return
	visible_message(span_warning("The [src] loses it's glow!"))
	inert = TRUE
	name = "inert plasma magmite upgrade parts"
	icon_state = "upgrade_parts_inert"
	desc += "It appears to have lost its magma-like glow."

/obj/item/magmite_parts/proc/restore()
	if(!inert)
		return
	inert = FALSE
	name = initial(name)
	icon_state = initial(icon_state)
	desc = initial(desc)
	addtimer(CALLBACK(src, PROC_REF(go_inert)), 10 MINUTES)

/obj/item/magmite_parts/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(inert)
		to_chat(user, span_warning("[src] appears inert! Perhaps the World Anvil can restore it!"))
		return

	switch(target.type)
		if(/obj/item/gun/energy/kinetic_accelerator/experimental)
			var/obj/item/gun/energy/kinetic_accelerator/gun = target
			if(gun.bayonet)
				gun.bayonet.forceMove(drop_location())
				gun.clear_bayonet()
			if(gun.gun_light)
				for(var/obj/item/flashlight/seclite/S in gun)
					S.loc = get_turf(user)
					S.update_brightness(user)
			for(var/obj/item/borg/upgrade/modkit/kit in gun.modkits)
				kit.uninstall(gun)
			qdel(gun)
			var/obj/item/gun/energy/kinetic_accelerator/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user, span_notice("Harsh tendrils wraps around the kinetic accelerator, merging the parts and kinetic accelerator to form a mega kinetic accelerator."))
			qdel(src)
		if(/obj/item/gun/energy/plasmacutter/adv)
			var/obj/item/gun/energy/plasmacutter/adv/gun = target
			qdel(gun)
			var/obj/item/gun/energy/plasmacutter/adv/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user,span_notice("Harsh tendrils wraps around the plasma cutter, merging the parts and cutter to form a mega plasma cutter."))
			qdel(src)
		if(/obj/item/gun/energy/plasmacutter/shotgun)
			var/obj/item/gun/energy/plasmacutter/shotgun/gun = target
			qdel(gun)
			var/obj/item/gun/energy/plasmacutter/shotgun/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user,span_notice("Harsh tendrils wraps around the plasma cutter shotgun, merging the parts and cutter to form a mega plasma cutter shotgun."))
			qdel(src)
		if(/obj/item/twohanded/kinetic_crusher) //sure hope there is a better way to do it..
			var/obj/item/twohanded/kinetic_crusher/gun = target
			for(var/t in gun.trophies)
				var/obj/item/crusher_trophy/T = t
				T.remove_from(gun, user)
			qdel(gun)
			var/obj/item/twohanded/kinetic_crusher/mega/newgun = new(get_turf(user))
			user.put_in_hands(newgun)
			to_chat(user,span_notice("Harsh tendrils wraps around the kinetic crusher, merging the parts and crusher to form a mega kinetic crusher."))
			qdel(src)

