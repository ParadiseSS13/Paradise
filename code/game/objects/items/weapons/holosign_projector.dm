/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "This shouldnt exist, if it does, tell a coder."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	inhand_icon_state = "electronic"
	belt_icon = "holosign_creator"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	origin_tech = "magnets=1;programming=3"
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	flags = NOBLUDGEON
	var/list/signs = list()
	var/max_signs = 6
	/// Time to create a holosign in deciseconds.
	var/creation_time = 0
	var/holosign_type = null
	var/holocreator_busy = FALSE // To prevent placing multiple holo barriers at once.
	new_attack_chain = TRUE

/obj/item/holosign_creator/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!check_allowed_items(target, 1))
		to_chat(user, SPAN_WARNING("You can't create a holosign there!"))
		return ITEM_INTERACT_COMPLETE

	var/turf/target_turf = get_turf(target)
	var/obj/structure/holosign/existing_sign = locate(holosign_type) in target_turf
	if(existing_sign)
		to_chat(user, SPAN_NOTICE("You use [src] to deactivate [existing_sign]."))
		qdel(existing_sign)
		return ITEM_INTERACT_COMPLETE

	if(target_turf.is_blocked_turf(exclude_mobs = TRUE)) // Can't put holograms on a tile that has dense stuff.
		to_chat(user, SPAN_WARNING("You can't create a holosign there because it's blocked!"))
		return ITEM_INTERACT_COMPLETE

	if(holocreator_busy)
		to_chat(user, SPAN_WARNING("[src] is busy creating a hologram!"))
		return ITEM_INTERACT_COMPLETE

	if(length(signs) >= max_signs)
		to_chat(user, SPAN_WARNING("[src] is projecting at max capacity!"))
		return ITEM_INTERACT_COMPLETE

	playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
	if(creation_time)
		holocreator_busy = TRUE
		if(!do_after(user, creation_time, target = target))
			holocreator_busy = FALSE
			return ITEM_INTERACT_COMPLETE
		holocreator_busy = FALSE
		if(length(signs) >= max_signs)
			return ITEM_INTERACT_COMPLETE
		if(target_turf.is_blocked_turf(exclude_mobs = TRUE)) // Don't try to sneak dense stuff on our tile during the wait.
			return ITEM_INTERACT_COMPLETE
	var/obj/structure/holosign/new_sign = new holosign_type(get_turf(target), src)
	to_chat(user, SPAN_NOTICE("You create [new_sign] with [src]."))
	return new_sign

/obj/item/holosign_creator/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(!length(signs))
		return ITEM_INTERACT_COMPLETE

	for(var/H in signs)
		qdel(H)
	to_chat(user, SPAN_NOTICE("You clear all active holograms."))
	return ITEM_INTERACT_COMPLETE

/obj/item/holosign_creator/janitor
	name = "janitorial holosign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	holosign_type = /obj/structure/holosign/wetsign
	max_signs = 18
	var/wet_enabled = TRUE

/obj/item/holosign_creator/janitor/AltClick(mob/user)
	wet_enabled = !wet_enabled
	playsound(loc, 'sound/weapons/empty.ogg', 20)
	if(wet_enabled)
		to_chat(user, SPAN_NOTICE("You enable the W.E.T. (wet evaporation timer)\nAny newly placed holographic signs will clear after the likely time it takes for a mopped tile to dry."))
	else
		to_chat(user, SPAN_NOTICE("You disable the W.E.T. (wet evaporation timer)\nAny newly placed holographic signs will now stay indefinitely."))

/obj/item/holosign_creator/janitor/examine(mob/user)
	. = ..()
	if(ishuman(user))
		. += SPAN_NOTICE("Alt Click to [wet_enabled ? "deactivate" : "activate"] its built-in wet evaporation timer.")

/obj/item/holosign_creator/janitor/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/obj/structure/holosign/wetsign/new_sign = ..()
	if(istype(new_sign) && wet_enabled)
		new_sign.wet_timer_start(src)
		return new_sign

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 30

/obj/item/holosign_creator/detective
	name = "detective holobarrier projector"
	desc = "A holographic projector that creates shocked investigation barriers."
	icon_state = "signmaker_det"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier/cyborg/hacked/detective
	creation_time = 1 SECONDS
	max_signs = 8

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 30

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_engi"
	belt_icon = null
	holosign_type = /obj/structure/holosign/barrier/atmos
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "energy barrier projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/activate_self(mob/user)
	var/mob/living/silicon/robot/robot_user = user

	if(isrobot(user) && shock)
		to_chat(user, SPAN_NOTICE("You clear all active holograms, and reset your projector to normal."))
		holosign_type = /obj/structure/holosign/barrier/cyborg
		creation_time = 5
		if(length(signs))
			for(var/H in signs)
				qdel(H)
		shock = 0
		return ITEM_INTERACT_COMPLETE

	if(isrobot(user) && robot_user.emagged && !shock)
		to_chat(user, SPAN_WARNING("You clear all active holograms, and overload your energy projector!"))
		holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
		creation_time = 30
		if(length(signs))
			for(var/H in signs)
				qdel(H)
		shock = 1
		return ITEM_INTERACT_COMPLETE

	if(!length(signs))
		return ..()
	for(var/H in signs)
		qdel(H)
	to_chat(user, SPAN_NOTICE("You clear all active holograms."))
	return ITEM_INTERACT_COMPLETE
