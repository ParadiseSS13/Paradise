// Airlock painter

/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on a completed airlock to change its paintjob."
	icon = 'icons/obj/device.dmi'
	icon_state = "airlock_painter"
	item_state = "airlock_painter"

	usesound = 'sound/effects/spray2.ogg'

	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT

	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)


//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/paint(mob/user)
	playsound(loc, usesound, 50, TRUE)
	return TRUE

/obj/item/airlock_painter/suicide_act(mob/user)

	var/obj/item/organ/internal/lungs/L = user.get_organ_slot("lungs")
	var/lungs_name = "\improper[L.name]"

	if(L)
		user.visible_message("<span class='suicide'>[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// they managed to lose their lungs between then and now. Good job.
		if(!L)
			return FALSE

		L.remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent("colorful_reagent", 10)
		L.reagents.reaction(L, TOUCH, 1)

		user.emote("scream")
		user.visible_message("<span class='suicide'>[user] vomits out [user.p_their()] [lungs_name]!</span>")
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		// make some vomit under the player, and apply colorful reagent
		var/obj/effect/decal/cleanable/vomit/V = new(get_turf(user))
		V.create_reagents(10)
		V.reagents.add_reagent("colorful_reagent", 10)
		V.reagents.reaction(V, TOUCH, 1)

		L.forceMove(get_turf(user))

		return OXYLOSS
	else
		return SHAME
