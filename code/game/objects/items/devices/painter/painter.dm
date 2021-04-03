/// Base painter object (Should not be spawned)
/obj/item/painter
	name = "modular painter"
	icon = 'icons/obj/painting.dmi'
	usesound = 'sound/effects/spray2.ogg'
	flags = CONDUCT | NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)

	var/static/list/painter_types = list(
		"Floor Painter" = /obj/item/painter/floor,
		"Pipe Painter" = /obj/item/painter/pipe,
		"Window Painter" = /obj/item/painter/pipe/window,
		"Airlock Painter" = /obj/item/painter/airlock)

/obj/item/painter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl+click it in your hand to change the type!</span>"

/obj/item/painter/CtrlClick(mob/user)
	. = ..()
	if(!ishuman(user)) // Only want human players doing this
		return
	if(loc != user) // Not being held
		return

	playsound(src, 'sound/effects/pop.ogg', 50, TRUE)
	var/choice = show_radial_menu(user, src, painter_types, require_near = TRUE)
	if(!choice)
		return
	var/choice_path = painter_types[choice]
	if(istype(src, choice_path))
		return

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	do_sparks(1, FALSE, src)
	var/obj/item/painter/P = new choice_path(get_turf(user))
	if(P)
		qdel(src) // Swap it out for the new one
		user.put_in_active_hand(P)

/obj/item/painter/suicide_act(mob/user)
	var/obj/item/organ/internal/lungs/L = user.get_organ_slot("lungs")
	var/turf/T = get_turf(user)
	if(!L)
		return SHAME

	user.visible_message("<span class='suicide'>[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	// Once you've inhaled the toner, you throw up your lungs
	// and then die.

	L.remove(user)

	L.create_reagents(10)
	L.reagents.add_reagent("colorful_reagent", 10)
	L.reagents.reaction(L, REAGENT_TOUCH, 1)
	L.forceMove(T)

	user.emote("scream")
	user.visible_message("<span class='suicide'>[user] vomits out [user.p_their()] [L.name]!</span>")
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)

	// make some vomit under the player, and apply colorful reagent
	var/obj/effect/decal/cleanable/vomit/V = new(T)
	V.create_reagents(10)
	V.reagents.add_reagent("colorful_reagent", 10)
	V.reagents.reaction(V, REAGENT_TOUCH, 1)

	return OXYLOSS
