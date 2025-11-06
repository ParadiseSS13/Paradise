/obj/item/painter
	name = "modular painter"
	icon = 'icons/obj/painting.dmi'
	icon_state = "floor_painter"
	usesound = 'sound/effects/spray2.ogg'
	flags = CONDUCT | NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)
	/// Associative list of painter types, with the value being the datum. (For use in the radial menu)
	var/static/list/painter_type_list = list(
		"Floor Painter" = /datum/painter/floor,
		"Pipe Painter" = /datum/painter/pipe,
		"Window Painter" = /datum/painter/pipe/window,
		"Airlock Painter" = /datum/painter/airlock,
		"Decal Painter" = /datum/painter/decal)

	/// Associative list of painter types, with the value being the icon. (For use in the radial menu)
	var/static/list/painter_icon_list = list(
		"Floor Painter" = image(icon = 'icons/obj/painting.dmi', icon_state = "floor_painter"),
		"Pipe Painter" = image(icon = 'icons/obj/painting.dmi', icon_state = "pipe_painter"),
		"Window Painter" = image(icon = 'icons/obj/painting.dmi', icon_state = "window_painter"),
		"Airlock Painter" = image(icon = 'icons/obj/painting.dmi', icon_state = "airlock_painter"),
		"Decal Painter" = image(icon = 'icons/obj/painting.dmi', icon_state = "decal_painter"))

	/// The [/datum/painter] which is currently active.
	var/datum/painter/selected_module = null
	/// List of any instanced [/datum/painter]'s, to avoid spawning more than one of each.
	var/list/module_list = list()

/obj/item/painter/Initialize(mapload, datum/painter/default_module = /datum/painter/floor) // Defaults to a floor painter
	. = ..()
	change_module(default_module)

/obj/item/painter/Destroy()
	selected_module = null
	for(var/I in module_list)
		qdel(I)
	module_list = list()

	return ..()

/obj/item/painter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl+click it in your hand to change the type!</span>"


/**
  * Changes the `selected_module` variable to `new_module`, and updates the painter to reflect the new type.
  *
  * If `new_module` is already present in `module_list`, then that will be used instead.
  * Otherwise a new datum will be spawned and added to `module_list`.
  * The Name, Description, Icon State, and Item State of the painter will be updated using variables from the `new_module` datum.
  *
  * Arguments:
  * * datum/painter/new_module - The new painter datum which will be used.
  * * mob/user - The user interacting with the painter.
  */
/obj/item/painter/proc/change_module(datum/painter/new_module, mob/user)
	if(!new_module)
		return
	selected_module = null

	for(var/I in module_list)
		var/datum/painter/P = I
		if(P.type == new_module)
			selected_module = I
			break
	if(!selected_module)
		var/datum/painter/P = new new_module(src, src)
		module_list += P
		selected_module = P

	name = selected_module.module_name
	desc = selected_module.module_desc
	icon_state = selected_module.module_state
	inhand_icon_state = selected_module.module_state
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()

/**
  * Calls `pick_color()` on the `selected_module`.
  */
/obj/item/painter/attack_self__legacy__attackchain(mob/user)
	selected_module.pick_color(user)

/**
  * If adjacent, calls `paint_atom()` on the `selected_module`, then plays the `usesound`.
  */
/obj/item/painter/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(selected_module.paint_atom(target, user))
		target.add_hiddenprint(user)
		playsound(src, usesound, 30, TRUE)

/**
  * Displays a radial menu for choosing a new painter module.
  */
/obj/item/painter/CtrlClick(mob/user)
	. = ..()
	if(loc != user) // Not being held
		return

	playsound(src, 'sound/effects/pop.ogg', 50, TRUE)
	var/choice = show_radial_menu(user, src, painter_icon_list, require_near = TRUE)
	var/choice_path = painter_type_list[choice]
	if(!choice_path || (selected_module.type == choice_path))
		return

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	do_sparks(1, FALSE, src)
	change_module(choice_path, user)


/obj/item/painter/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, usesound, 50, TRUE)
	var/obj/item/organ/internal/lungs/L = user.get_organ_slot("lungs") // not going to use an organ datum here, would be too easy for slime people to throw up their brains
	var/turf/T = get_turf(user)
	if(!do_mob(user, user, 3 SECONDS) || !L)
		return SHAME
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


/**
  * # Painter Datum
  *
  * Contains variables for updating `holder`, as well as procs for choosing a colour and painting an atom.
  *
  * The `parent_painter` argument is REQUIRED when spawning this in order to link the datum to an [/obj/item/painter].
  */
/datum/painter
	/// Name of the `holder` when using this module.
	var/module_name = null
	/// Desc of the `holder` when using this module.
	var/module_desc = null
	/// Icon and Item state of the `holder` when using this module.
	var/module_state = null

	/// The parent [/obj/item/painter] which this datum is linked to.
	var/obj/item/painter/holder

	/// The current colour or icon state setting.
	var/paint_setting = null

/datum/painter/New(obj/item/painter/parent_painter)
	..()
	ASSERT(parent_painter)
	holder = parent_painter

/datum/painter/ui_host() // For TGUI things.
	return holder

/**
  * Contains code to choose a new colour or icon state for the `paint_setting` variable.
  *
  * Called by `attack_self()` on the `holder` object.
  */
/datum/painter/proc/pick_color(mob/user)
	return

/**
  * Contains code to apply the `paint_setting` variable onto the target atom.
  *
  * Called by `afterattack()` on the `holder` object.
  */
/datum/painter/proc/paint_atom(atom/target, mob/user)
	return
